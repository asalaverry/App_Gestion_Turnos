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
def enviar_recordatorios_24h(
    db: Session = Depends(get_db),
    x_cron_key: str = Header(None),
):
    """
    - Protegido con X-CRON-KEY.
    - Busca turnos activos ~24h antes.
    - Envía push y marca recordatorio_24h = True.
    """

    # 1. Seguridad: validar secret
    cron_secret_env = os.getenv("CRON_SECRET")
    if cron_secret_env is None:
        # Si te olvidaste de cargarlo en Render, prefiero que grite feo
        raise HTTPException(status_code=500, detail="CRON_SECRET no configurado en el servidor")

    if x_cron_key != cron_secret_env:
        raise HTTPException(status_code=403, detail="Acceso no autorizado")

    # 2. Lógica de recordatorios
    ahora = datetime.utcnow()
    objetivo = ahora + timedelta(hours=24)

    # Ventana de tolerancia +-5 min alrededor de 'ahora+24h'
    ventana_inicio = objetivo - timedelta(minutes=5)
    ventana_fin    = objetivo + timedelta(minutes=5)

    # Buscamos turnos candidatos
    turnos = (
        db.query(models.Turno)
        .join(models.Usuario, models.Turno.id_usuario == models.Usuario.id)
        .join(models.Profesional, models.Turno.id_profesional == models.Profesional.id)
        .filter(
            models.Turno.estado == "activo",
            models.Turno.recordatorio_24h == False,            # no avisado todavía
            models.Usuario.device_token.isnot(None),           # tiene token FCM
        )
        .all()
    )

    enviados = []

    for turno in turnos:
        dt_turno = _combinar_fecha_hora(turno.fecha, turno.horario)

        # ¿cae dentro de la ventana (24h ±5min)?
        if ventana_inicio <= dt_turno <= ventana_fin:
            usuario = turno.usuario
            profesional = turno.profesional

            token = usuario.device_token
            if not token:
                continue  # por las dudas

            titulo = "Recordatorio de turno"
            cuerpo = (
                f"Tenés turno el {turno.fecha.strftime('%d/%m/%Y')} "
                f"a las {turno.horario.strftime('%H:%M')} "
                f"con {profesional.nombre}."
            )

            resp = _send_push(token, titulo, cuerpo)

            # marcamos que ya se notificó este turno
            turno.recordatorio_24h = True

            enviados.append({
                "turno_id": turno.id,
                "paciente": f"{usuario.nombre} {usuario.apellido}",
                "email": usuario.email,
                "profesional": profesional.nombre,
                "fecha": turno.fecha.isoformat(),
                "hora": turno.horario.strftime("%H:%M"),
                "fcm_response": resp,
            })

    # persistimos el flag recordatorio_24h=True
    db.commit()

    return {
        "ok": True,
        "total_enviados": len(enviados),
        "detalles": enviados,
        "ventana_inicio": ventana_inicio.isoformat(),
        "ventana_fin": ventana_fin.isoformat(),
        "now_utc": ahora.isoformat(),
    }
