from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import TurnoCreate, TurnoResponse
from app import crud
from app.deps import get_current_firebase_user
from typing import List

router = APIRouter(prefix="/turnos", tags=["Turnos"])

# Crear turno
@router.post("/", response_model=TurnoResponse)
def crear_turno(
    turno: TurnoCreate, 
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    """
    Crea un turno nuevo para el usuario autenticado (uid)
    """
    uid = firebase_user.get("uid")
    
    # Buscar el usuario en la DB a partir del uid de Firebase
    usuario = crud.get_usuario_by_uid(db, uid)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return crud.crear_turno(db, turno, usuario.id)

# Obtener turnos del usuario autenticado
@router.get("/usuario", response_model=List[TurnoResponse])
def listar_turnos_usuario(
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    """
    Retorna todos los turnos del usuario autenticado (uid)
    """
    uid = firebase_user.get("uid")
    usuario = crud.get_usuario_by_uid(db, uid)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return crud.obtener_turnos_usuario(db, usuario.id)

# Cancelar un turno
@router.put("/{id_turno}/cancelar", response_model=TurnoResponse)
def cancelar_turno(
    id_turno: int, 
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    """
    Cancela un turno del usuario autenticado
    """
    uid = firebase_user.get("uid")
    usuario = crud.get_usuario_by_uid(db, uid)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Verificar que el turno pertenezca al usuario
    turno = crud.cancelar_turno(db, id_turno)
    if not turno:
        raise HTTPException(status_code=404, detail="Turno no encontrado")
    
    if turno.id_usuario != usuario.id:
        raise HTTPException(status_code=403, detail="No tienes permiso para cancelar este turno")
    
    return turno

# Obtener horarios ocupados para una fecha, especialidad y profesional (opcional)
@router.get("/horarios-ocupados")
def obtener_horarios_ocupados(
    fecha: str,
    id_especialidad: int,
    id_profesional: int = None,
    db: Session = Depends(get_db)
):
    horarios = crud.obtener_horarios_ocupados(db, fecha, id_especialidad, id_profesional)
    return {"horarios_ocupados": horarios}
