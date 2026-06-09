from database import get_connection

conn = get_connection()

cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS meter_readings (

    id INTEGER PRIMARY KEY AUTOINCREMENT,

    meter_id TEXT NOT NULL UNIQUE,

    latitude REAL NOT NULL,

    longitude REAL NOT NULL,

    image_path TEXT NOT NULL,

    ocr_reading TEXT DEFAULT NULL,

    flag_reason TEXT DEFAULT NULL,

    processing_status TEXT NOT NULL DEFAULT 'PENDING',

    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP

)
""")

cursor.execute("""
CREATE INDEX IF NOT EXISTS idx_processing_status
ON meter_readings(processing_status)
""")

conn.commit()

conn.close()

print("Table Created Successfully")