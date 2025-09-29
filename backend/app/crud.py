"""
Aca van las funciones que hacen las operaciones en la DB usando models.py ; Se llaman desde los endpoints
se escriben funciones como create_usuario, get_usuario, listar_usuarios.

Cada una recibe la sesión (db) y un schema (UsuarioCreate, por ejemplo).
"""

import models, schemas
from sqlalchemy.orm import Session

def get_usuario(db: Session, usuario_id: int):
    return db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()

def create_usuario(db: Session, usuario: schemas.UsuarioCreate): #Ejemplo de crear usuario. Sin todos los datos...
    nuevo_usuario = models.Usuario(
        nombre=usuario.nombre,
        email=usuario.email
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario
