from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import models
from app.database import get_db

router = APIRouter(prefix="/obras-sociales", tags=["obras-sociales"])

@router.get("/")
def get_obras_sociales(db: Session = Depends(get_db)):
    """Obtener todas las obras sociales disponibles"""
    obras = db.query(models.ObraSocial).all()
    return obras