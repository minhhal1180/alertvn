from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker
import os
from pathlib import Path

# Always use absolute path so it works regardless of working directory
_BASE_DIR = Path(__file__).parent.resolve()
_DATA_DIR = _BASE_DIR / "data"
_DATA_DIR.mkdir(exist_ok=True)

# Allow override via env var (must be absolute if set)
DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{_DATA_DIR}/alertvn.db")

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
