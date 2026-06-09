import sqlite3
import os

def get_connection():

    db_path = os.path.join(
        os.path.dirname(__file__),
        "..",
        "database",
        "meters.db"
    )

    conn = sqlite3.connect(
        db_path,
        timeout=30
    )

    return conn