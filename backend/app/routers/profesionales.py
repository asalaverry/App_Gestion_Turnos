from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app import crud
from app.schemas import ProfesionalResponse
from typing import List

router = APIRouter(prefix="/profesionales", tags=["Profesionales"])

@router.get("/", response_model=List[ProfesionalResponse])
def listar_profesionales(id_especialidad: int = None, db: Session = Depends(get_db)):
    return crud.get_profesionales(db, id_especialidad)
