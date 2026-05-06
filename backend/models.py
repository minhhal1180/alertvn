from sqlalchemy import Column, String, Float, Integer, Boolean, DateTime, Text, JSON
from sqlalchemy.sql import func
from database import Base


class GridCell(Base):
    __tablename__ = "grid_cells"

    cell_id = Column(String, primary_key=True)  # "PT_21.30_105.00"
    center_lat = Column(Float, nullable=False)
    center_lng = Column(Float, nullable=False)
    district = Column(String)
    commune = Column(String)
    elevation = Column(Float, default=0.0)
    slope = Column(Float, default=0.0)
    soil_type = Column(Integer, default=1)
    vegetation_index = Column(Float, default=0.5)
    historical_count = Column(Integer, default=0)

    # Current risk scores (0.0 – 1.0)
    risk_storm = Column(Float, default=0.0)
    risk_flood = Column(Float, default=0.0)
    risk_landslide = Column(Float, default=0.0)
    risk_tree_fall = Column(Float, default=0.0)
    risk_heatwave = Column(Float, default=0.0)
    alert_level = Column(String, default="green")  # green / yellow / red

    rain_24h = Column(Float, default=0.0)
    rain_72h = Column(Float, default=0.0)
    rain_7d = Column(Float, default=0.0)
    temperature = Column(Float, default=25.0)
    humidity = Column(Float, default=70.0)
    wind_speed = Column(Float, default=0.0)

    last_updated = Column(DateTime, server_default=func.now(), onupdate=func.now())


class CommunityReport(Base):
    __tablename__ = "community_reports"

    report_id = Column(Integer, primary_key=True, autoincrement=True)
    disaster_type = Column(String, nullable=False)  # landslide/tree_fall/flood/other
    lat = Column(Float, nullable=False)
    lng = Column(Float, nullable=False)
    description = Column(Text)
    status = Column(String, default="pending")  # pending/verified/rejected
    confirm_count = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())


class AlertHistory(Base):
    __tablename__ = "alerts_history"

    alert_id = Column(Integer, primary_key=True, autoincrement=True)
    disaster_type = Column(String, nullable=False)
    level = Column(String, nullable=False)  # yellow / red
    cell_id = Column(String)
    district = Column(String)
    commune = Column(String)
    risk_score = Column(Float)
    message_vi = Column(Text)
    triggered_at = Column(DateTime, server_default=func.now())
    resolved_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
