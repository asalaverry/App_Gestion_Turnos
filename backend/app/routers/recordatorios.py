# app/routers/recordatorios.py

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
import os

from app.database import get_db
from app import models
from app.routers.notificaciones import _send_push  # usamos helper privado

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
    - Busca turnos activos dentro de las próximas 24h.
    - Envía push y marca recordatorio_24h = True.
    """

    # 1. Seguridad: validar secret
    cron_secret_env = os.getenv("CRON_SECRET")
    if cron_secret_env is None:
        raise HTTPException(status_code=500, detail="CRON_SECRET no configurado en el servidor")

    if x_cron_key != cron_secret_env:
        raise HTTPException(status_code=403, detail="Acceso no autorizado")

    # 2. Lógica de recordatorios - Buscar turnos en las próximas 24h
    ahora = datetime.utcnow()
    
    # Ventana amplia: desde AHORA hasta AHORA+24h
    # Esto garantiza que cualquier turno dentro de las próximas 24h reciba recordatorio
    ventana_inicio = ahora
    ventana_fin = ahora + timedelta(hours=24)

    # Buscamos turnos candidatos que cumplan TODAS estas condiciones:
    # - Estado activo
    # - Usuario QUIERE recordatorio (recordatorio_activado == True)
    # - Recordatorio NO enviado aún (recordatorio_enviado == False)
    # - Usuario tiene device_token registrado
    # - Usuario está activo
    turnos = (
        db.query(models.Turno)
        .join(models.Usuario, models.Turno.id_usuario == models.Usuario.id)
        .join(models.Profesional, models.Turno.id_profesional == models.Profesional.id)
        .filter(
            models.Turno.estado == "activo",
            models.Turno.recordatorio_activado == True,   # Usuario activó el recordatorio
            models.Turno.recordatorio_enviado == False,   # No se ha enviado aún
            models.Usuario.device_token.isnot(None),
            models.Usuario.activo == True,  # Solo usuarios activos
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
                f"Tenés turno mañana {turno.fecha.strftime('%d/%m/%Y')} "
                f"a las {turno.horario.strftime('%H:%M')} "
                f"con {profesional.nombre}."
            )

            resp = _send_push(token, titulo, cuerpo)

            # Marcar como enviado para no enviar duplicados
            turno.recordatorio_enviado = True

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
