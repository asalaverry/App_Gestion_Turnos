# app/routers/recordatorios.py

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app import models
from app.routers.notificaciones import _send_push  # usamos tu mismo helper privado


router = APIRouter(prefix="/recordatorios", tags=["Recordatorios"])

def _combinar_fecha_hora(fecha_date, hora_time) -> datetime:
    """
    Convierte (fecha: date, horario: time) en un datetime UTC naive.
    IMPORTANTE:
    - Si tus horas están en horario local Argentina y tu server está en UTC,
      tal vez quieras ajustar con zona horaria después.
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
def enviar_recordatorios_24h(db: Session = Depends(get_db)):
    """
    Busca turnos activos que ocurren ~24 horas a partir de ahora,
    manda notificación push al paciente y marca recordatorio_24h = True.
    """

    ahora = datetime.utcnow()
    objetivo = ahora + timedelta(hours=24)

    # Definimos ventana de tolerancia +/- 5 minutos
    ventana_inicio = objetivo - timedelta(minutes=5)
    ventana_fin    = objetivo + timedelta(minutes=5)

    # Traemos TODOS los turnos candidatos de la base.
    # Nota: no podemos filtrar aún por rango de datetimes directo
    # porque fecha y horario están separados en columnas.
    # Vamos a filtrar en Python.
    turnos = (
        db.query(models.Turno)
        .join(models.Usuario, models.Turno.id_usuario == models.Usuario.id)
        .join(models.Profesional, models.Turno.id_profesional == models.Profesional.id)
        .filter(
            models.Turno.estado == "activo",
            models.Turno.recordatorio_24h == False,  # aún no avisado
            models.Usuario.device_token.isnot(None), # el paciente tiene token FCM
        )
        .all()
    )

    enviados = []

    for turno in turnos:
        dt_turno = _combinar_fecha_hora(turno.fecha, turno.horario)

        # ¿está dentro de la ventana objetivo?
        if ventana_inicio <= dt_turno <= ventana_fin:
            usuario = turno.usuario
            profesional = turno.profesional

            token = usuario.device_token
            if not token:
                # por seguridad, aunque ya filtramos isnot(None)
                continue

            # armamos el mensaje
            titulo = "Recordatorio de turno"
            # ejemplo: "Tenés turno mañana 09:30 con Dra. Pérez (Cardiología)"
            cuerpo = (
                f"Tenés turno el {turno.fecha.strftime('%d/%m/%Y')} "
                f"a las {turno.horario.strftime('%H:%M')} "
                f"con {profesional.nombre}."
            )

            # mandamos push via FCM
            resp = _send_push(token, titulo, cuerpo)

            # marcamos que este turno ya recibió recordatorio
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

    # guardamos los cambios (recordatorio_24h = True)
    db.commit()

    return {
        "ok": True,
        "total_enviados": len(enviados),
        "detalles": enviados,
        "ventana_inicio": ventana_inicio.isoformat(),
        "ventana_fin": ventana_fin.isoformat(),
        "now_utc": ahora.isoformat(),
    }
