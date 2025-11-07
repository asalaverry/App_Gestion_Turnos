# flutter_application_1

# Aplicación de Gestión de Turnos Médicos  

Aplicación que permite a los pacientes **reservar turnos médicos**, visualizar sus turnos próximos/pasados y recibir **recordatorios automáticos**.  
Incluye autenticación, manejo de horarios disponibles, filtrado por especialidad/profesional y notificaciones push.

---

## Tecnologías principales
- **Frontend:** Flutter
- **Backend:** FastAPI (Python)
- **BD:** PostgreSQL
- **Autenticación:** Firebase Auth
- **Notificaciones:** Firebase Cloud Messaging
- **Infraestructura:** Render + GitHub + GitHub Actions

---

## Arquitectura
App_Gestion_Turnos/
│
├── .github/
│   └── workflows/
│       └── recordatorios.yml
│
├── backend/
│   └── app/
│       ├── main.py
│       ├── database.py
│       ├── crud.py
│       ├── firebase.py
│       ├── deps.py
│       ├── models.py
│       ├── schemas.py
│       ├── notificaciones.py
│       ├── turnos.py
│       └── profesionales.py
│   ├── recordatorios.py
│   ├── requirements.txt
│   └── .env
│
└── frontend/
    ├── lib/
    ├── android/
    ├── ios/
    └── pubspec.yaml


## Autenticación
- Login / Registro mediante **Firebase Authentication**
- El frontend obtiene un **idToken**
- Este token se envía al backend en cada request:
Authorization: Bearer <idToken>
- El backend lo valida con `firebase_admin`

## Notificaciones push
- Se registra un token FCM por usuario
- Backend puede enviar notificaciones
- Recordatorios 24 h antes del turno

## Base de datos
Tablas principales:
- usuarios
- profesionales
- especialidades
- turnos

## Flujo de uso
1. Usuario inicia sesión con Firebase
2. Se registra token del dispositivo
3. Selecciona especialidades y profesionales
4. Consulta horarios disponibles
5. Reserva turno
6. Recibe recordatorios/avisos