# AlertVN – Hệ thống cảnh báo thiên tai tổng hợp

## Chạy demo local

### Bước 1: Khởi động Backend
```batch
# Chạy file (double-click hoặc terminal):
start_backend.bat
```
Hoặc thủ công:
```bash
cd backend
python ml/train.py               # Train model (1 lần)
python scripts/generate_grid.py  # Tạo grid (1 lần)
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**API Docs:** http://localhost:8000/docs

### Bước 2: Chạy Flutter App
```bash
cd frontend
flutter run                      # Android emulator
# hoặc
flutter build apk               # Build APK
```

> **Thiết bị thật:** Sửa `kBackendUrl` trong `lib/config/constants.dart`  
> Đổi `10.0.2.2` → IP máy tính (ví dụ `192.168.1.5`)

---

## Cấu trúc dự án
```
alertvn/
├── backend/          Python FastAPI + SQLite + ML
│   ├── main.py       Entry point
│   ├── ml/           Random Forest model
│   ├── scripts/      Grid generation
│   └── data/         SQLite database
├── frontend/         Flutter Android app
│   └── lib/
│       ├── screens/  6 màn hình
│       ├── services/ API, Location, TTS
│       └── providers/ State management
└── start_backend.bat Startup script
```

## API Endpoints
| Method | URL | Mô tả |
|--------|-----|--------|
| GET | `/api/v1/risks/{lat}/{lng}` | Nguy cơ tại vị trí |
| GET | `/api/v1/risks/area?bounds=...` | Nguy cơ vùng bản đồ |
| GET | `/api/v1/alerts/active` | Cảnh báo hiệu lực |
| POST | `/api/v1/reports` | Báo cáo cộng đồng |
| GET | `/api/v1/forecast/{cell_id}/{hours}` | Dự báo N giờ tới |

## Stack
- **Backend:** Python 3.11, FastAPI, SQLite, scikit-learn (Random Forest 84.3% acc)
- **Frontend:** Flutter 3.24, flutter_map (OpenStreetMap), Provider
- **Data:** OpenWeatherMap API, NASA SRTM (synthetic for demo), GDACS
- **AI:** Random Forest Classifier, rule-based engine (5 loại thiên tai)
