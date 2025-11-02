# app/routers/recordatorios.py

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
import os

from app.database import get_db
from app import models
from app.routers.notificaciones import _send_push  # usamos tu helper privado

router = APIRouter(prefix="/recordatorios", tags=["Recordatorios"])

def _combinar_fecha_hora(fecha_date, hora_time) -> datetime:
    """
    Convierte (fecha: date, horario: time) en un datetime naive.
    Si guardás fechas/horas en horario local, esto los combina tal cual.
    """
    return datetime(
        year=fecha_date.year,
        month=fecha_date.month,
        day=fecha_date.day,
        hour=hora_time.hour,
        minute=hora_time.minute,
        second=hora_time.second,
    )

@router.post("/run")
def enviar_recordatorios_12h(
    db: Session = Depends(get_db),
    x_cron_key: str = Header(None),
):
    """
    - Protegido con X-CRON-KEY.
    - Busca turnos activos ~12h antes.
    - Envía push y marca recordatorio_12h = True.
    """

    # 1. Seguridad: validar secret
    cron_secret_env = os.getenv("CRON_SECRET")
    if cron_secret_env is None:
        raise HTTPException(status_code=500, detail="CRON_SECRET no configurado en el servidor")

    if x_cron_key != cron_secret_env:
        raise HTTPException(status_code=403, detail="Acceso no autorizado")

    # 2. Lógica de recordatorios
    ahora = datetime.utcnow()
    objetivo = ahora + timedelta(hours=12)   # 🔹 CAMBIO: antes decía 24

    # Ventana de tolerancia ±5 min
    ventana_inicio = objetivo - timedelta(minutes=5)
    ventana_fin = objetivo + timedelta(minutes=5)

    # Buscamos turnos candidatos
    turnos = (
        db.query(models.Turno)
        .join(models.Usuario, models.Turno.id_usuario == models.Usuario.id)
        .join(models.Profesional, models.Turno.id_profesional == models.Profesional.id)
        .filter(
            models.Turno.estado == "activo",
            models.Turno.recordatorio_24h == False,  # podés cambiarlo a recordatorio_12h si agregás ese campo
            models.Usuario.device_token.isnot(None),
        )
        .all()
    )

    enviados = []

    for turno in turnos:
        dt_turno = _combinar_fecha_hora(turno.fecha, turno.horario)

        if ventana_inicio <= dt_turno <= ventana_fin:
            usuario = turno.usuario
            profesional = turno.profesional

            token = usuario.device_token
            if not token:
                continue

            titulo = "Recordatorio de turno"
            cuerpo = (
                f"Tenés turno el {turno.fecha.strftime('%d/%m/%Y')} "
                f"a las {turno.horario.strftime('%H:%M')} "
                f"con {profesional.nombre}."
            )

            resp = _send_push(token, titulo, cuerpo)

            turno.recordatorio_24h = True  # o recordatorio_12h si lo renombrás

            enviados.append({
                "turno_id": turno.id,
                "paciente": f"{usuario.nombre} {usuario.apellido}",
                "email": usuario.email,
                "profesional": profesional.nombre,
                "fecha": turno.fecha.isoformat(),
                "hora": turno.horario.strftime("%H:%M"),
                "fcm_response": resp,
            })

    db.commit()

    return {
        "ok": True,
        "total_enviados": len(enviados),
        "detalles": enviados,
        "ventana_inicio": ventana_inicio.isoformat(),
        "ventana_fin": ventana_fin.isoformat(),
        "now_utc": ahora.isoformat(),
    }
