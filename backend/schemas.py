from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class RiskScore(BaseModel):
    storm: float
    flood: float
    landslide: float
    tree_fall: float
    heatwave: float


class GridCellResponse(BaseModel):
    cell_id: str
    center_lat: float
    center_lng: float
    district: str
    commune: str
    risks: RiskScore
    alert_level: str  # green / yellow / red
    temperature: float
    rain_24h: float
    wind_speed: float
    last_updated: Optional[datetime] = None

    class Config:
        from_attributes = True


class AreaRiskResponse(BaseModel):
    cells: list[GridCellResponse]
    total: int


class RiskDetailResponse(BaseModel):
    cell_id: str
    center_lat: float
    center_lng: float
    district: str
    commune: str
    risks: RiskScore
    alert_level: str
    temperature: float
    rain_24h: float
    rain_72h: float
    rain_7d: float
    wind_speed: float
    humidity: float
    elevation: float
    slope: float


class ReportCreate(BaseModel):
    disaster_type: str  # landslide / tree_fall / flood / other
    lat: float
    lng: float
    description: Optional[str] = ""


class ReportResponse(BaseModel):
    report_id: int
    disaster_type: str
    lat: float
    lng: float
    description: Optional[str]
    status: str
    confirm_count: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class AlertResponse(BaseModel):
    alert_id: int
    disaster_type: str
    level: str
    district: str
    commune: str
    risk_score: float
    message_vi: str
    triggered_at: Optional[datetime] = None
    is_active: bool

    class Config:
        from_attributes = True


class ForecastPoint(BaseModel):
    hour: int
    risks: RiskScore


class ForecastResponse(BaseModel):
    cell_id: str
    district: str
    commune: str
    forecast: list[ForecastPoint]


class TokenRegister(BaseModel):
    token: str
    platform: str = "android"
