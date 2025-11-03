# Definimos los endpoints relacionados a usuarios

# app/routers/usuarios.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import get_db
from app.deps import get_current_firebase_user

router = APIRouter(prefix="/usuarios", tags=["usuarios"])

# El frontend (Flutter) primero llama a Firebase para crear la cuenta con email y contraseña (o Google, etc.). Firebase devuelve un idToken (token de sesión válido para ese usuario). y ahi se guarda en nuestra DB
@router.post("/", response_model=schemas.UsuarioResponse)
def create_usuario(
    usuario: schemas.UsuarioCreate,
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    uid = firebase_user.get("uid")
    email_from_token = firebase_user.get("email")

    # 1) Si ya existe perfil vinculado a ese firebase_uid -> devolvemos (idempotente). Buena practica.
    existing = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if existing:
        return existing

    # 2) Evitamos duplicar por email (solo entre usuarios activos)
    email_existente = db.query(models.Usuario).filter(
        models.Usuario.email == usuario.email,
        models.Usuario.activo == True
    ).first()
    if email_existente:
        raise HTTPException(status_code=400, detail="Email ya registrado en la base de datos")
    
    # 3) Creamos el usuario (guardamos firebase_uid)
    new_user = models.Usuario(
        firebase_uid = uid,
        email = usuario.email if usuario.email else email_from_token, # El email puede venir del token o del body
        nombre = usuario.nombre,
        apellido = usuario.apellido,
        documento = usuario.documento,
        fecha_nacimiento = usuario.fecha_nacimiento,
        id_obra_social = usuario.id_obra_social,
        plan_obra_social = usuario.plan_obra_social,
        nro_afiliado = usuario.nro_afiliado,
        activo = usuario.activo if usuario.activo is not None else True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.post("/check")
def check_usuario(usuario: schemas.UsuarioCheck, db: Session = Depends(get_db)):
    # Buscar por documento (solo entre usuarios activos)
    existe = db.query(models.Usuario).filter(
        models.Usuario.documento == usuario.documento,
        models.Usuario.activo == True
    ).first()
    if existe:
        return {"exists": True}
    return {"exists": False}

@router.put("/{uid}/token")
def actualizar_token(uid: str, token: str, db: Session = Depends(get_db)):
    usuario = db.query(models.Usuario).filter(models.Usuario.uid_firebase == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    usuario.device_token = token
    db.commit()
    return {"message": "Token actualizado correctamente"}


# Obtener datos del usuario autenticado actual
@router.get("/me", response_model=schemas.UsuarioResponse)
def get_usuario_actual(
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    uid = firebase_user.get("uid")
    
    usuario = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    return usuario


# Actualizar datos personales del usuario actual
@router.put("/me", response_model=schemas.UsuarioResponse)
def actualizar_usuario_actual(
    datos: schemas.UsuarioUpdate,
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    uid = firebase_user.get("uid")
    
    usuario = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Verificar si el DNI ya está en uso por otro usuario activo
    if datos.documento is not None and datos.documento != usuario.documento:
        dni_existente = db.query(models.Usuario).filter(
            models.Usuario.documento == datos.documento,
            models.Usuario.id != usuario.id,
            models.Usuario.activo == True
        ).first()
        if dni_existente:
            raise HTTPException(status_code=400, detail="Ya existe un usuario con ese DNI")
    
    # Actualizar solo los campos proporcionados
    if datos.nombre is not None:
        usuario.nombre = datos.nombre
    if datos.apellido is not None:
        usuario.apellido = datos.apellido
    if datos.documento is not None:
        usuario.documento = datos.documento
    if datos.fecha_nacimiento is not None:
        usuario.fecha_nacimiento = datos.fecha_nacimiento
    
    db.commit()
    db.refresh(usuario)
    return usuario


# Actualizar cobertura médica del usuario actual
@router.put("/me/cobertura", response_model=schemas.UsuarioResponse)
def actualizar_cobertura_actual(
    datos: schemas.UsuarioCoberturaUpdate,
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    uid = firebase_user.get("uid")
    
    usuario = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Actualizar cobertura (permitiendo valores None/NULL)
    # Si id_obra_social es None, también se limpian plan y nro_afiliado
    usuario.id_obra_social = datos.id_obra_social
    usuario.plan_obra_social = datos.plan_obra_social
    usuario.nro_afiliado = datos.nro_afiliado
    
    db.commit()
    db.refresh(usuario)
    return usuario


# Eliminar cuenta del usuario actual
@router.delete("/me")
def eliminar_usuario_actual(
    db: Session = Depends(get_db),
    firebase_user: dict = Depends(get_current_firebase_user)
):
    from firebase_admin import auth
    
    uid = firebase_user.get("uid")
    
    usuario = db.query(models.Usuario).filter(models.Usuario.firebase_uid == uid).first()
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # 1. Cancelar todos los turnos activos del usuario
    turnos_activos = db.query(models.Turno).filter(
        models.Turno.id_usuario == usuario.id,
        models.Turno.estado == "activo"
    ).all()
    
    for turno in turnos_activos:
        turno.estado = "cancelado"
    
    # 2. Marcar como inactivo en la base de datos (soft delete)
    usuario.activo = False
    db.commit()
    
    # 3. Eliminar la cuenta de Firebase Authentication
    try:
        auth.delete_user(uid)
    except Exception as e:
        # Si falla la eliminación en Firebase, registrar el error pero continuar
        print(f"⚠️ Error al eliminar usuario de Firebase: {e}")
        # No lanzamos excepción porque el usuario ya está inactivo en la DB
    
    return {"message": "Cuenta eliminada correctamente"}


