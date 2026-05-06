import asyncio
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import GridCell
from schemas import ForecastResponse, ForecastPoint, RiskScore
from services.weather import fetch_forecast
from services.ml_service import predict_all_risks

router = APIRouter(prefix="/api/v1/forecast", tags=["forecast"])


@router.get("/{cell_id}/{hours}", response_model=ForecastResponse)
async def get_forecast(cell_id: str, hours: int, db: Session = Depends(get_db)):
    cell = db.query(GridCell).filter(GridCell.cell_id == cell_id).first()
    if not cell:
        raise HTTPException(status_code=404, detail="Cell not found")

    forecast_data = await fetch_forecast(cell.center_lat, cell.center_lng)

    cell_dict = {
        "slope": cell.slope,
        "elevation": cell.elevation,
        "soil_type": cell.soil_type,
        "vegetation_index": cell.vegetation_index,
        "historical_count": cell.historical_count,
        "near_river": False,
        "is_urban": False,
    }

    points = []
    for item in forecast_data:
        if item["hour"] > hours:
            break
        weather = {
            "temperature": item["temperature"],
            "humidity": item["humidity"],
            "wind_speed": item["wind_speed"],
            "rain_24h": item["rain_3h"] * 8,  # approximate 24h from 3h
            "rain_72h": item["rain_3h"] * 24,
            "rain_7d": item["rain_3h"] * 56,
        }
        risks = predict_all_risks(cell_dict, weather)
        points.append(ForecastPoint(
            hour=item["hour"],
            risks=RiskScore(**risks),
        ))

    return ForecastResponse(
        cell_id=cell.cell_id,
        district=cell.district or "",
        commune=cell.commune or "",
        forecast=points,
    )


@router.get("/location/{lat}/{lng}/{hours}", response_model=ForecastResponse)
async def get_forecast_by_location(lat: float, lng: float, hours: int, db: Session = Depends(get_db)):
    cell_lat = round(round(lat / 0.01) * 0.01, 2)
    cell_lng = round(round(lng / 0.01) * 0.01, 2)
    cell_id = f"PT_{cell_lat:.2f}_{cell_lng:.2f}"
    return await get_forecast(cell_id, hours, db)
