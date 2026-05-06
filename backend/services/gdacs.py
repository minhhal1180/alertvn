import httpx
import logging
from xml.etree import ElementTree as ET

logger = logging.getLogger(__name__)

GDACS_URL = "https://www.gdacs.org/xml/rss.xml"

# Bounding box for Vietnam
VN_LAT_MIN, VN_LAT_MAX = 8.0, 24.0
VN_LNG_MIN, VN_LNG_MAX = 102.0, 110.0


async def fetch_active_storms() -> list[dict]:
    """Fetch active storm alerts from GDACS that affect Vietnam."""
    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(GDACS_URL)
            resp.raise_for_status()
            return _parse_gdacs(resp.text)
    except Exception as e:
        logger.warning(f"GDACS fetch failed: {e}")
        return []


def _parse_gdacs(xml_text: str) -> list[dict]:
    storms = []
    try:
        root = ET.fromstring(xml_text)
        ns = {"gdacs": "http://www.gdacs.org"}
        for item in root.iter("item"):
            event_type = item.find("gdacs:eventtype", ns)
            if event_type is None or event_type.text not in ("TC", "FL"):
                continue
            lat_el = item.find("gdacs:latitude", ns)
            lng_el = item.find("gdacs:longitude", ns)
            if lat_el is None or lng_el is None:
                continue
            try:
                lat = float(lat_el.text)
                lng = float(lng_el.text)
            except (ValueError, TypeError):
                continue
            if not (VN_LAT_MIN <= lat <= VN_LAT_MAX and VN_LNG_MIN <= lng <= VN_LNG_MAX):
                continue
            title = item.find("title")
            alert_level_el = item.find("gdacs:alertlevel", ns)
            storms.append({
                "title": title.text if title is not None else "Unknown",
                "lat": lat,
                "lng": lng,
                "alert_level": alert_level_el.text if alert_level_el is not None else "Green",
                "event_type": event_type.text,
            })
    except ET.ParseError as e:
        logger.error(f"GDACS XML parse error: {e}")
    return storms
