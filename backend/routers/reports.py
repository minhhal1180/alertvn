from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import CommunityReport
from schemas import ReportCreate, ReportResponse

router = APIRouter(prefix="/api/v1/reports", tags=["reports"])

VALID_TYPES = {"landslide", "tree_fall", "flood", "other"}


@router.post("", response_model=ReportResponse, status_code=201)
def create_report(payload: ReportCreate, db: Session = Depends(get_db)):
    if payload.disaster_type not in VALID_TYPES:
        raise HTTPException(status_code=400, detail=f"Invalid type. Must be one of {VALID_TYPES}")

    report = CommunityReport(
        disaster_type=payload.disaster_type,
        lat=payload.lat,
        lng=payload.lng,
        description=payload.description or "",
        status="pending",
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report


@router.get("", response_model=list[ReportResponse])
def list_reports(
    status: str = "verified",
    limit: int = 50,
    db: Session = Depends(get_db),
):
    query = db.query(CommunityReport)
    if status != "all":
        query = query.filter(CommunityReport.status == status)
    reports = query.order_by(CommunityReport.created_at.desc()).limit(limit).all()
    return reports


@router.post("/{report_id}/confirm", response_model=ReportResponse)
def confirm_report(report_id: int, db: Session = Depends(get_db)):
    report = db.query(CommunityReport).filter(CommunityReport.report_id == report_id).first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    report.confirm_count += 1
    if report.confirm_count >= 3:
        report.status = "verified"
    db.commit()
    db.refresh(report)
    return report
