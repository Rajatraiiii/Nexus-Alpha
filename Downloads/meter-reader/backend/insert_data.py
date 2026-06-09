from database import get_connection

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
(
    ?,
    ?,
    ?,
    ?,
    ?,
    ?,
    ?
)
""",
(
    "METER-101",
    28.6139,
    77.2090,
    "/images/meter101.jpg",
    "1045.2",
    None,
    "COMPLETED"
))

conn.commit()

conn.close()

print("Data Inserted")