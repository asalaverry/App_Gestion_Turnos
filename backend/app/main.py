# Acá se levanta la app (app = FastAPI()), se configuran middlewares, y se incluyen los routers.
# Para correr el backend, ubicarse en la carpeta "backend" y usar el comando: uvicorn app.main:app --reload

from fastapi import FastAPI
from app.routers import usuarios, obras_sociales
from app import firebase


app = FastAPI(title="API Turnos Medicos")

# incluir routers
app.include_router(usuarios.router)
app.include_router(obras_sociales.router)

