import httpx
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)

OWM_KEY = os.getenv("OPENWEATHER_API_KEY", "")
OWM_BASE = "https://api.openweathermap.org/data/2.5"

# Representative weather stations across Phu Tho
PHU_THO_STATIONS = [
    (21.417, 105.183, "Việt Trì"),
    (21.600, 105.033, "Phù Ninh"),
    (21.367, 104.950, "Tam Nông"),
    (21.500, 104.800, "Thanh Sơn"),
    (21.700, 104.967, "Yên Lập"),
    (21.283, 105.100, "Lâm Thao"),
    (21.533, 105.267, "Đoan Hùng"),
    (21.400, 105.017, "Cẩm Khê"),
]


async def fetch_current_weather(lat: float, lng: float) -> Optional[dict]:
    if not OWM_KEY:
        return _mock_weather(lat, lng)
    url = f"{OWM_BASE}/weather"
    params = {"lat": lat, "lon": lng, "appid": OWM_KEY, "units": "metric"}
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url, params=params)
            resp.raise_for_status()
            data = resp.json()
            return {
                "temperature": data["main"]["temp"],
                "humidity": data["main"]["humidity"],
                "pressure": data["main"]["pressure"],
                "wind_speed": data["wind"]["speed"] * 3.6,  # m/s → km/h
                "rain_1h": data.get("rain", {}).get("1h", 0.0),
                "description": data["weather"][0]["description"],
            }
    except Exception as e:
        logger.warning(f"OWM fetch failed for ({lat},{lng}): {e}")
        return _mock_weather(lat, lng)


async def fetch_forecast(lat: float, lng: float) -> list[dict]:
    """Fetch 5-day / 3-hour forecast, return list of hourly-ish data."""
    if not OWM_KEY:
        return _mock_forecast()
    url = f"{OWM_BASE}/forecast"
    params = {"lat": lat, "lon": lng, "appid": OWM_KEY, "units": "metric", "cnt": 24}
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url, params=params)
            resp.raise_for_status()
            items = resp.json().get("list", [])
            result = []
            for i, item in enumerate(items):
                result.append({
                    "hour": i * 3,
                    "temperature": item["main"]["temp"],
                    "humidity": item["main"]["humidity"],
                    "wind_speed": item["wind"]["speed"] * 3.6,
                    "rain_3h": item.get("rain", {}).get("3h", 0.0),
                })
            return result
    except Exception as e:
        logger.warning(f"OWM forecast failed: {e}")
        return _mock_forecast()


def idw_interpolate(stations: list[dict], target_lat: float, target_lng: float, key: str) -> float:
    """Inverse Distance Weighting interpolation."""
    import math
    total_weight = 0.0
    weighted_sum = 0.0
    for st in stations:
        d = math.sqrt((st["lat"] - target_lat) ** 2 + (st["lng"] - target_lng) ** 2)
        if d < 1e-6:
            return st.get(key, 0.0)
        w = 1.0 / (d ** 2)
        weighted_sum += w * st.get(key, 0.0)
        total_weight += w
    return weighted_sum / total_weight if total_weight > 0 else 0.0


def _mock_weather(lat: float, lng: float) -> dict:
    import math, time
    hour = (time.time() // 3600) % 24
    base_temp = 28.0 + 5 * math.sin(math.pi * hour / 12)
    return {
        "temperature": round(base_temp + (lat - 21.3) * 2, 1),
        "humidity": 75.0,
        "pressure": 1012.0,
        "wind_speed": 15.0,
        "rain_1h": 0.0,
        "description": "partly cloudy",
    }


def _mock_forecast() -> list[dict]:
    import math
    result = []
    for i in range(24):
        hour = i * 3
        temp = 28.0 + 5 * math.sin(math.pi * hour / 24)
        rain = max(0, 5 * math.sin(math.pi * hour / 12) + 2)
        result.append({
            "hour": hour,
            "temperature": round(temp, 1),
            "humidity": 75.0,
            "wind_speed": 15.0,
            "rain_3h": round(rain, 1),
        })
    return result
