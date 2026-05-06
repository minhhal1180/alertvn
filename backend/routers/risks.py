from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from database import get_db
from models import GridCell
from schemas import RiskDetailResponse, AreaRiskResponse, GridCellResponse, RiskScore
from services.ml_service import predict_all_risks, classify_level
import math

router = APIRouter(prefix="/api/v1/risks", tags=["risks"])


def _cell_to_response(cell: GridCell) -> GridCellResponse:
    risks = RiskScore(
        storm=cell.risk_storm,
        flood=cell.risk_flood,
        landslide=cell.risk_landslide,
        tree_fall=cell.risk_tree_fall,
        heatwave=cell.risk_heatwave,
    )
    return GridCellResponse(
        cell_id=cell.cell_id,
        center_lat=cell.center_lat,
        center_lng=cell.center_lng,
        district=cell.district or "",
        commune=cell.commune or "",
        risks=risks,
        alert_level=cell.alert_level,
        temperature=cell.temperature,
        rain_24h=cell.rain_24h,
        wind_speed=cell.wind_speed,
        last_updated=cell.last_updated,
    )


@router.get("/{lat}/{lng}", response_model=RiskDetailResponse)
def get_risk_at_location(lat: float, lng: float, db: Session = Depends(get_db)):
    """Get risk scores for the grid cell nearest to (lat, lng)."""
    # Round to nearest 0.01° grid
    cell_lat = round(round(lat / 0.01) * 0.01, 2)
    cell_lng = round(round(lng / 0.01) * 0.01, 2)
    cell_id = f"PT_{cell_lat:.2f}_{cell_lng:.2f}"

    cell = db.query(GridCell).filter(GridCell.cell_id == cell_id).first()
    if cell is None:
        # Find nearest cell
        cells = db.query(GridCell).all()
        if not cells:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="No grid data available. Run generate_grid.py first.")
        cell = min(cells, key=lambda c: (c.center_lat - lat) ** 2 + (c.center_lng - lng) ** 2)

    risks = RiskScore(
        storm=cell.risk_storm,
        flood=cell.risk_flood,
        landslide=cell.risk_landslide,
        tree_fall=cell.risk_tree_fall,
        heatwave=cell.risk_heatwave,
    )
    return RiskDetailResponse(
        cell_id=cell.cell_id,
        center_lat=cell.center_lat,
        center_lng=cell.center_lng,
        district=cell.district or "",
        commune=cell.commune or "",
        risks=risks,
        alert_level=cell.alert_level,
        temperature=cell.temperature,
        rain_24h=cell.rain_24h,
        rain_72h=cell.rain_72h,
        rain_7d=cell.rain_7d,
        wind_speed=cell.wind_speed,
        humidity=cell.humidity,
        elevation=cell.elevation,
        slope=cell.slope,
    )


@router.get("/area", response_model=AreaRiskResponse)
def get_risks_in_area(
    min_lat: float = Query(...),
    max_lat: float = Query(...),
    min_lng: float = Query(...),
    max_lng: float = Query(...),
    db: Session = Depends(get_db),
):
    """Get all grid cells within a bounding box (for map rendering)."""
    cells = db.query(GridCell).filter(
        GridCell.center_lat >= min_lat,
        GridCell.center_lat <= max_lat,
        GridCell.center_lng >= min_lng,
        GridCell.center_lng <= max_lng,
    ).all()

    return AreaRiskResponse(
        cells=[_cell_to_response(c) for c in cells],
        total=len(cells),
    )
