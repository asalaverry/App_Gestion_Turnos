# Acá se levanta la app (app = FastAPI()), se configuran middlewares, y se incluyen los routers.

from fastapi import FastAPI
from routers import usuarios


app = FastAPI(title="API Turnos Medicos")

# incluir routers
app.include_router(usuarios.router)

