"""
Aca van las funciones que hacen las operaciones en la DB usando models.py ; Se llaman desde los endpoints
se escriben funciones como create_usuario, get_usuario, listar_usuarios.

Cada una recibe la sesión (db) y un schema (UsuarioCreate, por ejemplo).
"""
from sqlalchemy.orm import Session
from app import models, schemas


def create_usuario(db: Session, usuario: schemas.UsuarioCreate):
    db_usuario = models.Usuario(
        email=usuario.email,
        nombre=usuario.nombre,
        apellido=usuario.apellido,
        documento=usuario.documento,
        fecha_nacimiento=usuario.fecha_nacimiento,
        id_obra_social=usuario.id_obra_social,
        plan_obra_social=usuario.plan_obra_social,
        nro_afiliado=usuario.nro_afiliado,
        activo=True
    )
    db.add(db_usuario)
    db.commit()
    db.refresh(db_usuario)
    return db_usuario

def get_usuario_by_email(db: Session, email: str): # Buscar usuario por email. Sirve para evitar duplicados y para login.
    return db.query(models.Usuario).filter(models.Usuario.email == email).first()

def get_usuario_by_id(db: Session, usuario_id: int):
    return db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()

def get_usuario_by_uid(db: Session, uid: str):
    return db.query(models.Usuario).filter(models.Usuario.uid == uid).first()

# CRUD para usuarios que faltan: Cambiar el estado, actualizar datos (QUE datos?)

def get_obra_social_by_id(db: Session, obra_social_id: int):
    return db.query(models.ObraSocial).filter(models.ObraSocial.id == obra_social_id).first()

def get_obras_sociales(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.ObraSocial).offset(skip).limit(limit).all()

# Turnos: 
def crear_turno(db: Session, turno: schemas.TurnoCreate, id_usuario: int):
    nuevo_turno = models.Turno(
        fecha=turno.fecha,
        horario=turno.horario,
        id_usuario=id_usuario,
        id_profesional=turno.id_profesional,
        estado="activo"
    )
    db.add(nuevo_turno)
    db.commit()
    db.refresh(nuevo_turno)
    return nuevo_turno

# Obtener turnos de un usuario
def obtener_turnos_usuario(db: Session, id_usuario: int):
    return db.query(models.Turno).filter(models.Turno.id_usuario == id_usuario).all()

# Cancelar un turno
def cancelar_turno(db: Session, id_turno: int):
    turno = db.query(models.Turno).filter(models.Turno.id == id_turno).first()
    if turno:
        turno.estado = "cancelado"
        db.commit()
        db.refresh(turno)
    return turno


# Obtener todas las especialidades
def get_especialidades(db: Session):
    return db.query(models.Especialidad).all()

# Obtener todos los profesionales (opcionalmente filtrados)
def get_profesionales(db: Session, id_especialidad: int = None):
    query = db.query(models.Profesional)
    if id_especialidad:
        query = query.filter(models.Profesional.id_especialidad == id_especialidad)
    return query.all()