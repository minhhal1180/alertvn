"""
Generate 1km x 1km grid cells for Phu Tho province and seed SQLite DB.
Run from backend/: python scripts/generate_grid.py
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import math
import random
from dotenv import load_dotenv
load_dotenv()

from database import engine, Base, SessionLocal
from models import GridCell, AlertHistory

# Phu Tho bounding box
LAT_MIN, LAT_MAX = 20.92, 21.80
LNG_MIN, LNG_MAX = 104.48, 105.52

# ~0.009° ≈ 1km latitude, ~0.011° ≈ 1km longitude at 21°N
LAT_STEP = 0.009
LNG_STEP = 0.011

# District/commune lookup (simplified grid-based)
DISTRICTS = {
    (21.40, 105.18): "Việt Trì",
    (21.60, 105.03): "Phù Ninh",
    (21.37, 104.95): "Tam Nông",
    (21.50, 104.80): "Thanh Sơn",
    (21.70, 104.97): "Yên Lập",
    (21.28, 105.10): "Lâm Thao",
    (21.53, 105.27): "Đoan Hùng",
    (21.40, 105.02): "Cẩm Khê",
    (21.33, 105.10): "Phù Ninh",
    (21.18, 105.13): "Thanh Thủy",
    (21.52, 104.97): "Hạ Hòa",
    (21.45, 105.35): "Phú Ninh",
}


def get_district(lat: float, lng: float) -> tuple[str, str]:
    min_d = float("inf")
    district = "Phú Thọ"
    for (dlat, dlng), dname in DISTRICTS.items():
        d = math.sqrt((lat - dlat) ** 2 + (lng - dlng) ** 2)
        if d < min_d:
            min_d = d
            district = dname
    commune = f"Xã {district[:4]}-{int((lat*100)%100):02d}"
    return district, commune


def estimate_slope(lat: float, lng: float) -> float:
    """Synthetic slope: mountainous north-west, flat south-east."""
    base = max(0, (21.8 - lat) * 15 + (105.5 - lng) * 20)
    noise = random.gauss(0, 5)
    return max(0, min(60, base + noise))


def estimate_elevation(lat: float, lng: float) -> float:
    """Synthetic elevation."""
    base = max(10, (21.8 - lat) * 300 + (105.5 - lng) * 400)
    noise = random.gauss(0, 30)
    return max(5, min(1800, base + noise))


def is_near_river(lat: float, lng: float) -> bool:
    """Rivers: Red River (Hồng), Lo River, Da River."""
    rivers = [
        (21.25, 105.20, 0.05),  # Song Hong / Viet Tri
        (21.45, 105.30, 0.04),  # Song Lo upper
        (21.37, 104.83, 0.04),  # Song Da
        (21.55, 105.23, 0.03),  # Song Lo Doan Hung
    ]
    for rlat, rlng, radius in rivers:
        if math.sqrt((lat - rlat) ** 2 + (lng - rlng) ** 2) < radius:
            return True
    return False


def main():
    random.seed(42)
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    # Clear existing grid
    db.query(GridCell).delete()
    db.commit()

    count = 0
    lat = LAT_MIN
    while lat <= LAT_MAX:
        lng = LNG_MIN
        while lng <= LNG_MAX:
            cell_lat = round(lat, 3)
            cell_lng = round(lng, 3)
            cell_id = f"PT_{cell_lat:.3f}_{cell_lng:.3f}"
            district, commune = get_district(cell_lat, cell_lng)
            slope = estimate_slope(cell_lat, cell_lng)
            elevation = estimate_elevation(cell_lat, cell_lng)
            soil_type = random.choices([1, 2, 3, 4, 5], weights=[20, 30, 25, 15, 10])[0]
            vegetation_index = random.uniform(0.2, 0.85)
            historical_count = random.choices(range(0, 12), weights=[40,20,15,8,5,4,3,2,1,1,1,1])[0]
            near_river = is_near_river(cell_lat, cell_lng)
            # Slightly higher baseline risk for demo visibility
            base_landslide = min(0.6, slope / 120 + random.uniform(0, 0.05))
            base_flood = 0.2 if near_river else 0.0

            cell = GridCell(
                cell_id=cell_id,
                center_lat=cell_lat,
                center_lng=cell_lng,
                district=district,
                commune=commune,
                elevation=round(elevation, 1),
                slope=round(slope, 1),
                soil_type=soil_type,
                vegetation_index=round(vegetation_index, 3),
                historical_count=historical_count,
                risk_storm=round(random.uniform(0, 0.1), 3),
                risk_flood=round(base_flood + random.uniform(0, 0.1), 3),
                risk_landslide=round(base_landslide, 3),
                risk_tree_fall=round(random.uniform(0, 0.05), 3),
                risk_heatwave=round(random.uniform(0, 0.08), 3),
                alert_level="green",
                rain_24h=0.0,
                rain_72h=0.0,
                rain_7d=0.0,
                temperature=27.0,
                humidity=75.0,
                wind_speed=10.0,
            )
            db.add(cell)
            count += 1
            if count % 500 == 0:
                db.commit()
                print(f"  Inserted {count} cells...")
            lng += LNG_STEP
        lat += LAT_STEP

    db.commit()

    # Seed a few demo alerts for UI testing
    demo_alerts = [
        AlertHistory(
            disaster_type="landslide",
            level="red",
            cell_id="PT_21.500_104.800",
            district="Thanh Sơn",
            commune="Xã Thượng Cửu",
            risk_score=0.82,
            message_vi="CẢNH BÁO ĐỎ: Nguy cơ sạt lở đất rất cao tại Thanh Sơn! Di chuyển ngay khỏi vùng đồi núi!",
            is_active=True,
        ),
        AlertHistory(
            disaster_type="flood",
            level="yellow",
            cell_id="PT_21.250_105.200",
            district="Lâm Thao",
            commune="Xã Bản Nguyên",
            risk_score=0.55,
            message_vi="Nguy cơ lũ lụt ở mức chú ý tại Lâm Thao. Theo dõi mực nước sông Hồng.",
            is_active=True,
        ),
        AlertHistory(
            disaster_type="heatwave",
            level="yellow",
            cell_id="PT_21.400_105.180",
            district="Việt Trì",
            commune="Phường Tân Dân",
            risk_score=0.48,
            message_vi="Nắng nóng gay gắt tại Việt Trì. Hạn chế ra ngoài từ 11h-15h, uống đủ nước.",
            is_active=True,
        ),
    ]
    for a in demo_alerts:
        db.add(a)
    db.commit()

    print(f"\nDone! Generated {count} grid cells for Phu Tho province.")
    print(f"Added {len(demo_alerts)} demo alerts.")
    db.close()


if __name__ == "__main__":
    main()
