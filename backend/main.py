from fastapi import FastAPI, File, UploadFile, Form
from pydantic import BaseModel
from database import get_connection
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from pathlib import Path
from typing import Optional

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ════════════════════════════════════════════════════
#  FILE UPLOAD CONFIGURATION
# ════════════════════════════════════════════════════
UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "..", "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Serve uploaded files as static files
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

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


# ════════════════════════════════════════════════════
#  IMAGE UPLOAD ENDPOINT
#  Feature 4 & 5: Upload image and return path
# ════════════════════════════════════════════════════

@app.post("/upload-image")
async def upload_image(
    file: UploadFile = File(...),
    meter_id: str = Form(...)
):
    """
    Upload meter image and save with naming convention: {meter_id}.jpg
    
    Args:
        file: Image file (jpg, jpeg, png)
        meter_id: Meter identifier for file naming
        
    Returns:
        {
            "image_path": "uploads/METER-101.jpg",
            "file_name": "METER-101.jpg",
            "file_size": 245623
        }
    """
    try:
        # Validate file extension
        allowed_extensions = {'.jpg', '.jpeg', '.png'}
        file_ext = Path(file.filename or '').suffix.lower()
        
        if file_ext not in allowed_extensions:
            return {
                "detail": "Only JPG and PNG images are allowed"
            }, 400
        
        # Generate filename: {meter_id}.jpg
        filename = f"{meter_id}.jpg"
        filepath = os.path.join(UPLOAD_DIR, filename)
        
        # Read and save file
        contents = await file.read()
        
        with open(filepath, "wb") as f:
            f.write(contents)
        
        # Return relative path for database storage
        relative_path = f"uploads/{filename}"
        
        return {
            "image_path": relative_path,
            "file_name": filename,
            "file_size": len(contents)
        }
        
    except Exception as e:
        return {
            "detail": f"File upload failed: {str(e)}"
        }, 500
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