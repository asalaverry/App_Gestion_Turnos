#!/usr/bin/env bash
# Script de inicio para FastAPI en Render

# Espera a que la base de datos esté lista
sleep 3

# Ejecuta la app con uvicorn
uvicorn app.main:app --host 0.0.0.0 --port 10000
