"""
Aca van las funciones que hacen las operaciones en la DB usando models.py ; Se llaman desde los endpoints
se escriben funciones como create_usuario, get_usuario, listar_usuarios.

Cada una recibe la sesión (db) y un schema (UsuarioCreate, por ejemplo).
"""
from sqlalchemy.orm import Session
from app import models, schemas

# Usuarios:
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

# Buscar usuario por email. Sirve para evitar duplicados y para login.
def get_usuario_by_email(db: Session, email: str): 
    return db.query(models.Usuario).filter(models.Usuario.email == email).first()

def get_usuario_by_id(db: Session, usuario_id: int):
    return db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()

# Buscar usuario por uid de Firebase (para login con Firebase)
def get_usuario_by_uid(db: Session, uid: str):
    return db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()

# Obras sociales:
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
        estado="activo",
        recordatorio_activado=turno.recordatorio_activado if turno.recordatorio_activado is not None else False,
        recordatorio_enviado=False  # Siempre inicia en False
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

# Obtener horarios ocupados para una fecha, especialidad y profesional (opcional)
def obtener_horarios_ocupados(db: Session, fecha: str, id_especialidad: int, id_profesional: int = None):
    """
    Retorna una lista de horarios (formato HH:MM) ocupados para:
    - Una fecha específica
    - Una especialidad
    - Un profesional específico (opcional)
    
    Si id_profesional es None, retorna SOLO los horarios donde TODOS los profesionales
    de la especialidad están ocupados (para mostrar horarios con al menos un profesional disponible).
    """
    # Si se especificó un profesional, buscar solo sus horarios ocupados
    if id_profesional is not None:
        query = db.query(models.Turno).filter(
            models.Turno.fecha == fecha,
            models.Turno.estado == "activo",
            models.Turno.id_profesional == id_profesional
        )
        turnos = query.all()
        horarios = [str(turno.horario)[:5] for turno in turnos]
        return horarios
    
    # Si NO se especificó profesional (usuario eligió "Cualquiera"):
    profesionales_especialidad = db.query(models.Profesional).filter(
        models.Profesional.id_especialidad == id_especialidad
    ).all()
    
    if not profesionales_especialidad:
        return []
    
    total_profesionales = len(profesionales_especialidad)
    ids_profesionales = [p.id for p in profesionales_especialidad]
    
    # Obtener todos los turnos de estos profesionales en esta fecha
    turnos = db.query(models.Turno).filter(
        models.Turno.fecha == fecha,
        models.Turno.estado == "activo",
        models.Turno.id_profesional.in_(ids_profesionales)
    ).all()
    
    from collections import Counter
    horarios_counter = Counter([str(turno.horario)[:5] for turno in turnos])
    
    # Solo marcar como ocupado si TODOS los profesionales tienen turno en ese horario
    horarios_completamente_ocupados = [
        horario for horario, count in horarios_counter.items()
        if count >= total_profesionales
    ]
    
    return horarios_completamente_ocupados