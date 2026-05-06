from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import AlertHistory
from schemas import AlertResponse

router = APIRouter(prefix="/api/v1/alerts", tags=["alerts"])


@router.get("/active", response_model=list[AlertResponse])
def get_active_alerts(db: Session = Depends(get_db)):
    alerts = db.query(AlertHistory).filter(
        AlertHistory.is_active == True
    ).order_by(AlertHistory.triggered_at.desc()).limit(20).all()
    return alerts


@router.get("/history", response_model=list[AlertResponse])
def get_alert_history(limit: int = 50, db: Session = Depends(get_db)):
    alerts = db.query(AlertHistory).order_by(
        AlertHistory.triggered_at.desc()
    ).limit(limit).all()
    return alerts
