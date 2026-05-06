from fastapi import APIRouter
from schemas import TokenRegister

router = APIRouter(prefix="/api/v1/users", tags=["users"])

_tokens: list[dict] = []


@router.post("/register-token", status_code=200)
def register_token(payload: TokenRegister):
    _tokens.append({"token": payload.token, "platform": payload.platform})
    return {"status": "registered", "message": "Token saved (local demo mode)"}
