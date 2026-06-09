from database import get_connection

conn = get_connection()

cursor = conn.cursor()

cursor.execute("SELECT COUNT(*) FROM meter_readings")

count = cursor.fetchone()[0]

print(f"Total Rows = {count}")

cursor.execute("SELECT * FROM meter_readings")

rows = cursor.fetchall()

for row in rows:
    print(row)

conn.close()