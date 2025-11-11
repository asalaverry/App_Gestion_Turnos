from fastapi import APIRouter, Depends, HTTPException
from app.deps import get_current_firebase_user
from app.database import get_db
from app import models
from sqlalchemy.orm import Session
import requests
import os
import json  
from google.oauth2 import service_account
from google.auth.transport.requests import Request as GoogleAuthRequest

router = APIRouter(prefix="/fcm", tags=["Notificaciones"])

FIREBASE_SCOPES = ["https://www.googleapis.com/auth/firebase.messaging"]
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
SERVICE_JSON_PATH = os.getenv("FIREBASE_CREDENTIALS")

# -----------------------------
# Helpers internos
# -----------------------------
def _get_access_token():
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_JSON_PATH,
        scopes=FIREBASE_SCOPES
    )
    credentials.refresh(GoogleAuthRequest())
    return credentials.token


def _send_push(token_fcm: str, title: str, body: str):
    if not FIREBASE_PROJECT_ID:
        # Defensa mínima por si en prod falta la env var
        raise HTTPException(status_code=500, detail="Falta FIREBASE_PROJECT_ID en el entorno")

    url = f"https://fcm.googleapis.com/v1/projects/{FIREBASE_PROJECT_ID}/messages:send"
    headers = {
        "Authorization": f"Bearer {_get_access_token()}",
        "Content-Type": "application/json; UTF-8",
    }
    payload = {
        "message": {
            "token": token_fcm,
            "notification": {
                "title": title,
                "body": body,
            },
        }
    }

    r = requests.post(url, headers=headers, json=payload)

    # logging útil para debug
    print("FCM status:", r.status_code, r.text)

    if r.status_code not in (200, 204):
        # devolvemos 500 en vez de sólo print, así el cliente ve que falló
        raise HTTPException(
            status_code=500,
            detail=f"Error enviando push a FCM: {r.status_code} {r.text}"
        )

    return r.json() if r.text else {}


# -----------------------------
# Rutas
# -----------------------------
@router.post("/register-device")
def register_device(
    data: dict,
    user = Depends(get_current_firebase_user),
    db: Session = Depends(get_db)
):
    """
    Guarda el token FCM del dispositivo del usuario autenticado.
    Requiere Authorization: Bearer <idTokenFirebase> en el request.
    """
    token_fcm = data.get("token_fcm")
    if not token_fcm:
        raise HTTPException(status_code=400, detail="Falta token_fcm")

    uid = user["uid"]  # viene de verify_id_token en get_current_firebase_user

    usuario = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    usuario.device_token = token_fcm
    db.commit()

    return {
        "status": "ok",
        "message": "Token guardado correctamente"
    }


@router.post("/send-test")
def send_test(
    data: dict,
    db: Session = Depends(get_db)
):
    """
    Envía una notificación push a un usuario según su email.
    Esto es para pruebas manuales (Postman / curl).
    NO requiere auth porque es debugging interno,
    pero en producción conviene protegerlo.
    """
    email = data.get("email")
    title = data.get("title", "Notificación de prueba")
    body = data.get("body", "Hola desde tu backend!")

    user = db.query(models.Usuario).filter(models.Usuario.email == email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    if not user.device_token:
        raise HTTPException(status_code=404, detail="Usuario sin token FCM registrado")

    response = _send_push(user.device_token, title, body)
    return {
        "status": "sent",
        "response": response
    }
