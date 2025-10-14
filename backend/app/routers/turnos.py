from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import TurnoCreate, TurnoResponse
from app import crud
from typing import List

router = APIRouter(prefix="/turnos", tags=["Turnos"])

# Crear turno
@router.post("/", response_model=TurnoResponse)
def crear_turno(turno: TurnoCreate, db: Session = Depends(get_db), uid: str = None):
    """
    Crea un turno nuevo para el usuario autenticado (uid)
    """
    # Buscar el usuario en la DB a partir del uid de Firebase
    usuario = crud.get_usuario_by_uid(db, uid)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return crud.crear_turno(db, turno, usuario.id)

# Obtener turnos del usuario
@router.get("/", response_model=List[TurnoResponse])
def listar_turnos(db: Session = Depends(get_db), uid: str = None):
    usuario = crud.get_usuario_by_uid(db, uid)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return crud.obtener_turnos_usuario(db, usuario.id)

# Cancelar un turno
@router.put("/{id_turno}/cancelar", response_model=TurnoResponse)
def cancelar_turno(id_turno: int, db: Session = Depends(get_db)):
    turno = crud.cancelar_turno(db, id_turno)
    if not turno:
        raise HTTPException(status_code=404, detail="Turno no encontrado")
    return turno
