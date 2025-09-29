# Definimos los endpoints relacionados a usuarios

# app/routers/usuarios.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import get_db
from app.deps import get_current_firebase_user

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

# El frontend (Flutter) primero llama a Firebase para crear la cuenta con email y contraseña (o Google, etc.). Firebase devuelve un idToken (token de sesión válido para ese usuario). y ahi se guarda en nuestra DB
@router.post("/", response_model=schemas.UsuarioResponse)
def create_usuario(
    usuario: schemas.UsuarioCreate,
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    uid = firebase_user.get("uid")
    email_from_token = firebase_user.get("email")

    # 1) Si ya existe perfil vinculado a ese firebase_uid -> devolvemos (idempotente)
    existing = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if existing:
        return existing

    # 2) Evitamos duplicar por email
    if db.query(models.Usuario).filter(models.Usuario.email == usuario.email).first():
        raise HTTPException(status_code=400, detail="Email ya registrado en la base de datos")

    # 3) Creamos el usuario (guardamos firebase_uid)
    new_user = models.Usuario(
        firebase_uid = uid,
        email = usuario.email if usuario.email else email_from_token, # El email puede venir del token o del body
        nombre = usuario.nombre,
        apellido = usuario.apellido,
        documento = usuario.documento,
        fecha_nacimiento = usuario.fecha_nacimiento,
        id_obra_social = usuario.id_obra_social,
        plan_obra_social = usuario.plan_obra_social,
        nro_afiliado = usuario.nro_afiliado,
        activo = usuario.activo if usuario.activo is not None else True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
