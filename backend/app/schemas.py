"""Schemes (Pydantic) utilizados por la API.

Base: campos comunes.
Create: lo que necesita el cliente para crear un recurso.
Response: lo que devolvés en la API.

Valida los campos de entrada y salida.
"""

from datetime import date, time
from pydantic import BaseModel, EmailStr
from typing import Optional, List, Literal




# OBRAS SOCIALES
class ObraSocialBase(BaseModel):
    nombre: str

class ObraSocialCreate(ObraSocialBase):
    pass

class ObraSocialResponse(ObraSocialBase):
    id: int

    class Config:
        from_attributes = True



# USUARIOS
class UsuarioBase(BaseModel):
    email: EmailStr
    nombre: str
    apellido: str
    documento: str
    fecha_nacimiento: date
    id_obra_social: Optional[int] = None
    plan_obra_social: Optional[str] = None
    nro_afiliado: Optional[str] = None
    activo: Optional[bool] = True

class UsuarioCreate(UsuarioBase):
    pass # Tiene los campos que necesita gracias a usuario base. Los hereda.

class UsuarioResponse(UsuarioBase):
    id: int
    obra_social: Optional[ObraSocialResponse] = None   # relación

    class Config:
        from_attributes = True
        
class UsuarioCheck(BaseModel):
    documento: str


# ESPECIALIDADES
class EspecialidadBase(BaseModel):
    nombre: str

class EspecialidadCreate(EspecialidadBase):
    pass

class EspecialidadResponse(BaseModel):
    id: int
    nombre: str

    class Config:
        from_attributes = True


# PROFESIONALES
class ProfesionalBase(BaseModel):
    nombre: str
    id_especialidad: int

class ProfesionalCreate(ProfesionalBase):
    pass

class ProfesionalResponse(BaseModel):
    id: int
    nombre: str
    id_especialidad: int
    especialidad: Optional[EspecialidadResponse] = None  # Incluir datos de la especialidad

    class Config:
        from_attributes = True


# TURNOS
class TurnoBase(BaseModel):
    fecha: date
    horario: time


class TurnoCreate(TurnoBase):
    id_profesional: int  # Siempre requerido (frontend asigna uno aleatorio si usuario elige "Cualquiera")


class TurnoResponse(TurnoBase):
    id: int
    estado: Literal["activo", "pasado", "cancelado"]
    usuario: Optional[UsuarioResponse] = None
    profesional: Optional[ProfesionalResponse] = None

    class Config:
        from_attributes = True 


