# Script para inicializar la base de datos (crear tablas)

from app.database import Base, engine
from app import models # Al importar models hace que las tablas de models esten "registradas" en Base.metadata. --> Las obtiene de ahi para crearlas 

print("Creando tablas...")
Base.metadata.create_all(bind=engine)  
print("¡Tablas creadas en MySQL!")
