import mysql.connector
from flask import Flask, jsonify, render_template, request
from flask_cors import CORS
from config import load_db_credentials

app = Flask(__name__)
CORS(app)


def get_db():
    cfg = load_db_credentials("db_config.txt")
    print(cfg)
    return mysql.connector.connect(
        host=cfg["DB_HOST"],
        user=cfg["DB_USER"],
        password=cfg["DB_PASS"],
        database=cfg["DB_NAME"],
    )


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


if __name__ == "__main__":
    print("Starting MeloMood...")
    app.run(debug=True, host="0.0.0.0", port=8000)
