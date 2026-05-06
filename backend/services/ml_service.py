import pickle
import numpy as np
import os
import logging

logger = logging.getLogger(__name__)

MODEL_PATH = os.path.join(os.path.dirname(__file__), "..", "ml", "landslide_model.pkl")

_model = None


def load_model():
    global _model
    if _model is not None:
        return _model
    if os.path.exists(MODEL_PATH):
        with open(MODEL_PATH, "rb") as f:
            _model = pickle.load(f)
        logger.info("Landslide Random Forest model loaded.")
    else:
        logger.warning("Model file not found, using rule-based fallback.")
    return _model


def predict_landslide(
    slope: float,
    elevation: float,
    rain_24h: float,
    rain_72h: float,
    rain_7d: float,
    soil_type: int,
    vegetation_index: float,
    historical_count: int,
) -> float:
    """Return landslide probability 0.0–1.0."""
    model = load_model()
    features = np.array([[slope, elevation, rain_24h, rain_72h, rain_7d,
                          soil_type, vegetation_index, historical_count]])
    if model is not None:
        try:
            proba = model.predict_proba(features)[0][1]
            return float(proba)
        except Exception as e:
            logger.error(f"Model predict error: {e}")

    # Rule-based fallback
    score = 0.0
    if slope > 35:
        score += 0.4
    elif slope > 25:
        score += 0.25
    elif slope > 15:
        score += 0.1

    if rain_24h > 100:
        score += 0.35
    elif rain_24h > 50:
        score += 0.2
    elif rain_24h > 25:
        score += 0.1

    if rain_72h > 200:
        score += 0.15
    elif rain_72h > 100:
        score += 0.08

    if historical_count > 5:
        score += 0.1
    elif historical_count > 0:
        score += 0.05

    if soil_type in (3, 4):  # clay-heavy soil
        score += 0.05

    return min(1.0, score)


def predict_all_risks(cell: dict, weather: dict) -> dict:
    """Compute risk scores for all 5 disaster types."""
    rain_24h = weather.get("rain_24h", 0.0)
    rain_72h = weather.get("rain_72h", rain_24h * 2.5)
    rain_7d = weather.get("rain_7d", rain_24h * 6)
    wind_speed = weather.get("wind_speed", 0.0)
    temperature = weather.get("temperature", 25.0)
    humidity = weather.get("humidity", 70.0)
    slope = cell.get("slope", 0.0)
    elevation = cell.get("elevation", 50.0)
    soil_type = cell.get("soil_type", 1)
    vegetation_index = cell.get("vegetation_index", 0.5)
    historical_count = cell.get("historical_count", 0)
    near_river = cell.get("near_river", False)
    is_urban = cell.get("is_urban", False)

    landslide = predict_landslide(
        slope, elevation, rain_24h, rain_72h, rain_7d,
        soil_type, vegetation_index, historical_count
    )

    # Flood (rule-based)
    flood = 0.0
    if rain_24h > 80 and slope < 5:
        flood += 0.5
    if near_river and rain_24h > 40:
        flood += 0.3
    if rain_72h > 150:
        flood += 0.2
    flood = min(1.0, flood)

    # Storm (rule-based from wind speed km/h)
    storm = 0.0
    if wind_speed > 100:
        storm = 0.9
    elif wind_speed > 75:
        storm = 0.7
    elif wind_speed > 60:
        storm = 0.5
    elif wind_speed > 40:
        storm = 0.3
    elif wind_speed > 20:
        storm = 0.1

    # Tree fall
    tree_fall = 0.0
    if wind_speed > 60 and is_urban:
        tree_fall = min(1.0, (wind_speed - 60) / 60 + 0.4)
    elif wind_speed > 40:
        tree_fall = min(0.4, (wind_speed - 40) / 60)

    # Heatwave
    heatwave = 0.0
    if temperature > 38 and humidity < 40:
        heatwave = min(1.0, (temperature - 38) / 10 + 0.5)
    elif temperature > 35:
        heatwave = min(0.4, (temperature - 35) / 10)

    return {
        "storm": round(storm, 3),
        "flood": round(flood, 3),
        "landslide": round(landslide, 3),
        "tree_fall": round(tree_fall, 3),
        "heatwave": round(heatwave, 3),
    }


def classify_level(risks: dict) -> str:
    max_risk = max(risks.values())
    if max_risk >= 0.70:
        return "red"
    elif max_risk >= 0.40:
        return "yellow"
    return "green"
