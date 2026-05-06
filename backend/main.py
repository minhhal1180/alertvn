import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routers import risks, reports, alerts, forecast, users

import logging
logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    from services.ml_service import load_model
    load_model()
    yield


app = FastAPI(
    title="AlertVN API",
    description="Hệ thống cảnh báo thiên tai tổng hợp cho Việt Nam",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(risks.router)
app.include_router(reports.router)
app.include_router(alerts.router)
app.include_router(forecast.router)
app.include_router(users.router)


@app.get("/")
def root():
    return {
        "app": "AlertVN",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running",
    }


@app.get("/health")
def health():
    return {"status": "ok"}
