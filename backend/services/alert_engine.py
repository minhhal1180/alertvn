import logging
from datetime import datetime
from sqlalchemy.orm import Session
from models import AlertHistory, GridCell
from services.ml_service import classify_level

logger = logging.getLogger(__name__)

DISASTER_MESSAGES = {
    "landslide": {
        "yellow": "Nguy cơ sạt lở đất ở mức chú ý. Hãy tránh xa taluy, mái dốc và khu vực ven đồi.",
        "red": "CẢNH BÁO ĐỎ: Nguy cơ sạt lở đất rất cao! Di chuyển ngay khỏi vùng đồi núi, taluy và ven sông suối!",
    },
    "flood": {
        "yellow": "Nguy cơ lũ lụt ở mức chú ý. Theo dõi mực nước sông và chuẩn bị di dời khi cần.",
        "red": "CẢNH BÁO ĐỎ: Nguy cơ lũ lụt rất cao! Di chuyển đồ vật lên cao và sẵn sàng sơ tán ngay!",
    },
    "storm": {
        "yellow": "Cảnh báo gió mạnh. Gia cố nhà cửa và tránh ra ngoài khi không cần thiết.",
        "red": "CẢNH BÁO ĐỎ: Bão mạnh đang đến! Ở trong nhà, tránh xa cây to và công trình không vững chắc!",
    },
    "tree_fall": {
        "yellow": "Nguy cơ cây đổ. Tránh đỗ xe dưới tán cây và không đứng gần cây to.",
        "red": "CẢNH BÁO ĐỎ: Nguy cơ cây đổ rất cao! Không ra đường, tránh xa cây xanh và cột điện!",
    },
    "heatwave": {
        "yellow": "Nắng nóng gay gắt. Uống đủ nước, tránh ra ngoài từ 11h-15h.",
        "red": "CẢNH BÁO ĐỎ: Nắng nóng cực đoan! Không ra ngoài ban ngày, uống nhiều nước và nghỉ ngơi trong mát!",
    },
}


def process_cell_alerts(db: Session, cell: GridCell, risks: dict):
    """Create or update alerts for a grid cell based on new risk scores."""
    level = classify_level(risks)
    if level == "green":
        # Resolve active alerts for this cell
        db.query(AlertHistory).filter(
            AlertHistory.cell_id == cell.cell_id,
            AlertHistory.is_active == True
        ).update({"is_active": False, "resolved_at": datetime.utcnow()})
        return

    max_type = max(risks, key=risks.get)
    max_score = risks[max_type]

    # Check if alert already exists for this cell+type+level
    existing = db.query(AlertHistory).filter(
        AlertHistory.cell_id == cell.cell_id,
        AlertHistory.disaster_type == max_type,
        AlertHistory.is_active == True,
    ).first()

    message = DISASTER_MESSAGES.get(max_type, {}).get(level, "Cảnh báo thiên tai.")

    if existing:
        existing.level = level
        existing.risk_score = max_score
        existing.message_vi = message
    else:
        alert = AlertHistory(
            disaster_type=max_type,
            level=level,
            cell_id=cell.cell_id,
            district=cell.district or "",
            commune=cell.commune or "",
            risk_score=max_score,
            message_vi=message,
            is_active=True,
        )
        db.add(alert)
