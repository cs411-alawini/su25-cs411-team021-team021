import hashlib
import logging
from contextlib import closing

import mysql.connector
from flask import Flask, jsonify, render_template, request
from flask_cors import CORS

from config import load_db_credentials

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)

logger = logging.getLogger(__name__)
app = Flask(__name__)
CORS(app)


def get_db():
    cfg = load_db_credentials()
    logger.debug('Accessing DB through user "{User}"', cfg["MELODB_USER"])
    c = mysql.connector.connect(
        unix_socket="/cloudsql/cs411-team021:us-central1:team021-sql-test",
        user=cfg["MELODB_USER"],
        password=cfg["MELODB_PASS"],
        database="melodb",
    )
    logger.debug("MySQL connector {Connector}", c)
    return c


@app.route("/status", methods=["GET"])
def status():
    try:
        with closing(get_db()) as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()  # if this fails, an exception is raised
        return jsonify(status="ok"), 200
    except Exception as exc:
        logger.exception("DB health check failed")
        return jsonify(status="error", detail=str(exc)), 500


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/playlist/<mood>", methods=["GET"])
def generate_playlist(mood):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT s.song_id, s.track_name, s.artist, AVG(m.rating) as avg_rating
        FROM Song s
        JOIN MoodLog m ON s.song_id = m.song_id
        WHERE m.mood_label = %s
        GROUP BY s.song_id
        ORDER BY avg_rating DESC
        LIMIT 10
    """,
        (mood,),
    )
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify(result)


@app.route("/playlist/mix", methods=["POST"])
def make_mixed_playlist():
    data = request.get_json()
    pct = data["percents"]
    args = [
        data["user_id"],
        data["name"],
        data["total"],
        pct.get("Happy", 0),
        pct.get("Sad", 0),
        pct.get("Calm", 0),
        pct.get("Energetic", 0),
        pct.get("Angry", 0),
    ]
    with closing(get_db()) as conn, conn.cursor() as cur:
        cur.callproc("create_mood_playlist", args)
        new_id = None
        for rs in cur.stored_results():
            new_id = rs.fetchone()[0]
        conn.commit()
    return jsonify({"playlist_id": new_id}), 201


@app.route("/moods", methods=["POST"])
def add_mood():
    data = request.get_json()
    db = get_db()
    cursor = db.cursor()
    cursor.execute(
        """
        INSERT INTO MoodLog (user_id, song_id, mood_label, rating)
        VALUES (%s, %s, %s, %s)
    """,
        (data["user_id"], data["song_id"], data["mood_label"], data["rating"]),
    )
    db.commit()
    cursor.close()
    db.close()
    return jsonify({"message": "Added"})


@app.route("/moods", methods=["GET"])
def get_moods():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT m.log_id, u.username, s.track_name, s.artist,
               m.mood_label, m.rating, m.ts
        FROM MoodLog m
        JOIN User u ON m.user_id = u.user_id
        JOIN Song s ON m.song_id = s.song_id
        ORDER BY m.ts DESC LIMIT 10
    """
    )
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify(result)


@app.route("/moods/<int:log_id>", methods=["DELETE"])
def delete_mood(log_id):
    db = get_db()
    cursor = db.cursor()
    cursor.execute("DELETE FROM MoodLog WHERE log_id = %s", (log_id,))
    db.commit()
    cursor.close()
    db.close()
    return jsonify({"message": "Deleted"})


@app.route("/mood-labels", methods=["GET"])
def get_mood_labels():
    db = get_db()
    cursor = db.cursor()
    cursor.execute("SELECT mood_label FROM Mood ORDER BY mood_label")
    labels = [r[0] for r in cursor.fetchall()]
    cursor.close()
    db.close()
    return jsonify(labels)


@app.route("/mood-labels", methods=["POST"])
def add_mood_label():
    label = request.get_json()["mood_label"].strip()
    with closing(get_db()) as db, db.cursor() as cursor:
        cursor.execute("INSERT IGNORE INTO Mood (mood_label) VALUES (%s)", (label,))
        db.commit()
    return jsonify({"ok": True})


@app.route("/users", methods=["GET"])
def get_users():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT user_id, username FROM User LIMIT 10")
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify(result)


@app.route("/songs", methods=["GET"])
def get_songs():
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT song_id, track_name, artist FROM Song LIMIT 10")
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify(result)


@app.route("/search", methods=["GET"])
def search():
    query = request.args.get("q", "")
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT song_id, track_name, artist
        FROM Song
        WHERE track_name LIKE %s OR artist LIKE %s
        LIMIT 5
    """,
        (f"%{query}%", f"%{query}%"),
    )
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify(result)


@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()
    username = data["username"].strip()
    password = data["password"].encode("utf-8")
    pw_hash = hashlib.sha256(password).hexdigest()

    try:
        with closing(get_db()) as db, db.cursor() as cursor:
            cursor.execute(
                "INSERT INTO User (username, password_hash) VALUES (%s, %s)",
                (username, pw_hash),
            )
            db.commit()
        return jsonify({"ok": True, "message": "Registered!"}), 201
    except mysql.connector.errors.IntegrityError:
        return jsonify({"ok": False, "message": "Username already exists"}), 409


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data["username"].strip()
    password = data["password"].encode("utf-8")
    pw_hash = hashlib.sha256(password).hexdigest()

    with closing(get_db()) as db, db.cursor(dictionary=True) as cursor:
        cursor.execute(
            "SELECT user_id FROM User WHERE username = %s AND password_hash = %s",
            (username, pw_hash),
        )
        row = cursor.fetchone()
    if row:
        return (
            jsonify(
                {"ok": True, "user_id": row["user_id"], "message": "Login success"}
            ),
            200,
        )
    else:
        return jsonify({"ok": False, "message": "Invalid credentials"}), 401


if __name__ == "__main__":
    logger.warning("Starting MeloMood...")
    app.run(debug=True, host="0.0.0.0", port=8000)
