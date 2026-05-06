@echo off
echo ========================================
echo   AlertVN Backend - Khoi dong
echo ========================================
cd /d "%~dp0backend"
echo [1] Kiem tra thu vien Python...
pip install fastapi uvicorn sqlalchemy scikit-learn pandas numpy httpx python-dotenv scipy aiohttp python-multipart -q

echo [2] Kiem tra model ML...
IF NOT EXIST ml\landslide_model.pkl (
    echo Train model Random Forest...
    python ml\train.py
) ELSE (
    echo Model da ton tai
)

echo [3] Kiem tra database...
IF NOT EXIST data\alertvn.db (
    echo Tao grid o luoi Phu Tho...
    python scripts\generate_grid.py
) ELSE (
    echo Database da ton tai
)

echo [4] Khoi dong FastAPI server...
echo.
echo API Docs: http://localhost:8000/docs
echo Health:   http://localhost:8000/health
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
