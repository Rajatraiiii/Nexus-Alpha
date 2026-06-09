from fastapi import FastAPI
from pydantic import BaseModel
from database import get_connection
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from typing import Optional

class MeterReading(BaseModel):

    meter_id: str

    latitude: float

    longitude: float

    image_path: str

    ocr_reading: Optional[str] = None

    flag_reason: Optional[str] = None

    processing_status: str

@app.get("/")
def home():
    return {"message": "Backend Running Successfully"}


@app.post("/save-reading")
def save_reading(data: MeterReading):

    conn = None

    try:

        conn = get_connection()

        cursor = conn.cursor()

        cursor.execute("""
        INSERT INTO meter_readings
        (
            meter_id,
            latitude,
            longitude,
            image_path,
            ocr_reading,
            flag_reason,
            processing_status
        )
        VALUES
        (?, ?, ?, ?, ?, ?, ?)
        """,
        (
            data.meter_id,
            data.latitude,
            data.longitude,
            data.image_path,
            data.ocr_reading,
            data.flag_reason,
            data.processing_status
        ))

        conn.commit()

        return {
            "message": "Saved Successfully"
        }

    finally:

        if conn:
            conn.close()