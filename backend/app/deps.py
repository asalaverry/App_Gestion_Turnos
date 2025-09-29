# Con esto, cualquier endpoint que use Depends(get_current_firebase_user) exigirá un token válido.

from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth as firebase_auth

bearer_scheme = HTTPBearer()

def get_current_firebase_user(credentials: HTTPAuthorizationCredentials = Security(bearer_scheme)):
    token = credentials.credentials
    try:
        decoded = firebase_auth.verify_id_token(token)
        # decoded contiene 'uid', 'email', 'name', etc según proveedor
        return decoded
    except Exception as e:
        raise HTTPException(status_code=401, detail="Token Firebase inválido")