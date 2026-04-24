from datetime import datetime, timedelta, timezone
from typing import Optional

import bcrypt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from core.config import get_settings
from db.database import get_db
from models.user import User

_settings = get_settings()
_bearer = HTTPBearer(auto_error=False)

_BCRYPT_MAX = 72  # bcrypt silently truncates beyond 72 bytes; we clamp explicitly.


def _clamp(password: str) -> bytes:
    return password.encode("utf-8")[:_BCRYPT_MAX]


def hash_password(password: str) -> str:
    return bcrypt.hashpw(_clamp(password), bcrypt.gensalt(rounds=12)).decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(_clamp(plain), hashed.encode("utf-8"))
    except Exception:
        return False


def create_access_token(subject: str, extra: Optional[dict] = None) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=_settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": subject, "exp": expire, "iat": datetime.now(timezone.utc)}
    if extra:
        payload.update(extra)
    return jwt.encode(payload, _settings.SECRET_KEY, algorithm=_settings.ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, _settings.SECRET_KEY, algorithms=[_settings.ALGORITHM])
    except JWTError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    payload = decode_token(credentials.credentials)
    subject = payload.get("sub")
    if not subject:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject")
    user = db.query(User).filter(User.email == subject).one_or_none()
    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or inactive")
    return user


def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer),
    db: Session = Depends(get_db),
) -> Optional[User]:
    if credentials is None:
        return None
    try:
        return get_current_user(credentials=credentials, db=db)
    except HTTPException:
        return None
