# Definimos los endpoints relacionados a usuarios
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import schemas, crud, database

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/")
def crear_usuario(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)): #schemas.UsuarioCreate valida que se cumpla el modelo en schemas.py
    return crud.create_usuario(db, usuario)
