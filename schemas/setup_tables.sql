USE melodb;

CREATE TABLE IF NOT EXISTS Song (
  song_id     INT AUTO_INCREMENT PRIMARY KEY,
  spotify_id  VARCHAR(32) NOT NULL UNIQUE,
  track_name  VARCHAR(255) NOT NULL,
  artist      VARCHAR(255),
  genre       VARCHAR(80),
  valence     DECIMAL(4,3),
  tempo       DECIMAL(6,2),
  popularity  TINYINT UNSIGNED,
  INDEX idx_song_genre (genre)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS User (
  user_id   INT AUTO_INCREMENT PRIMARY KEY,
  username  VARCHAR(50) UNIQUE,
  password_hash VARCHAR(128) NOT NULL DEFAULT '';
  join_date DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS MoodLog (
  log_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT,
  song_id    INT,
  mood_label ENUM('Happy','Sad','Calm','Energetic','Angry') NOT NULL,
  rating     TINYINT CHECK (rating BETWEEN 1 AND 100),
  ts         DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id)  ON DELETE CASCADE,
  FOREIGN KEY (song_id) REFERENCES Song(song_id)  ON DELETE CASCADE,
  INDEX idx_ml_user_ts   (user_id, ts),
  INDEX idx_ml_song_mood (song_id, mood_label)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Playlist (
  playlist_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT,
  name        VARCHAR(100),
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
  INDEX idx_playlist_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS PlaylistSong (
  playlist_id INT,
  song_id     INT,
  added_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (playlist_id, song_id),
  FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id) ON DELETE CASCADE,
  FOREIGN KEY (song_id)     REFERENCES Song(song_id)     ON DELETE CASCADE,
  INDEX idx_ps_song (song_id)
) ENGINE=InnoDB;