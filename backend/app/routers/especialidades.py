from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
import crud
from schemas import EspecialidadResponse
from typing import List

router = APIRouter(prefix="/especialidades", tags=["Especialidades"])

@router.get("/", response_model=List[EspecialidadResponse])
def listar_especialidades(db: Session = Depends(get_db)):
    return crud.get_especialidades(db)
