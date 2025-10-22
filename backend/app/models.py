# Clases python que representan las tablas de la base de datos
from sqlalchemy import Column, Integer, String, Enum, ForeignKey, Date, Time
from sqlalchemy.orm import relationship
from app.database import Base
from sqlalchemy import Boolean

class ObraSocial(Base):
    __tablename__ = "obras_sociales"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), unique=True)

    usuarios = relationship("Usuario", back_populates="obra_social")

class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(100), unique=True, index=True)
    nombre = Column(String(100))
    apellido = Column(String(100))
    documento = Column(String(50), unique=True)
    fecha_nacimiento = Column(Date)
    id_obra_social = Column(Integer, ForeignKey("obras_sociales.id"), nullable=True)
    plan_obra_social = Column(String(50), nullable=True)
    nro_afiliado = Column(String(50), nullable=True)
    activo = Column(Boolean, default=True)
    firebase_uid = Column(String(128), unique=True)  # Para vincular con Firebase Auth
    device_token = Column(String(255), nullable=True)  # el token del dispositivo para notificaciones push


    obra_social = relationship("ObraSocial", back_populates="usuarios")
    turnos = relationship("Turno", back_populates="usuario")

class Especialidad(Base):
    __tablename__ = "especialidades"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100), unique=True)

    profesionales = relationship("Profesional", back_populates="especialidad")

class Profesional(Base):
    __tablename__ = "profesionales"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(100))
    id_especialidad = Column(Integer, ForeignKey("especialidades.id"))

    especialidad = relationship("Especialidad", back_populates="profesionales")
    turnos = relationship("Turno", back_populates="profesional")

class Turno(Base):
    __tablename__ = "turnos"
    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(Date)
    horario = Column(Time)
    estado = Column(Enum("activo", "pasado", "cancelado", name="estado_turno", create_type=False))
    id_usuario = Column(Integer, ForeignKey("usuarios.id"))
    id_profesional = Column(Integer, ForeignKey("profesionales.id"))

    usuario = relationship("Usuario", back_populates="turnos")
    profesional = relationship("Profesional", back_populates="turnos")
