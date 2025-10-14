from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app import crud
from app.schemas import EspecialidadResponse
from typing import List

router = APIRouter(prefix="/especialidades", tags=["Especialidades"])

@router.get("/", response_model=List[EspecialidadResponse])
def listar_especialidades(db: Session = Depends(get_db)):
    return crud.get_especialidades(db)
