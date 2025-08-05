DROP PROCEDURE IF EXISTS create_mood_playlist;

CREATE PROCEDURE create_mood_playlist (
    IN p_user_id INT,
    IN p_playlist_name VARCHAR(100),
    IN p_total_tracks INT,
    IN p_happy_pct DECIMAL(5,2),
    IN p_sad_pct DECIMAL(5,2),
    IN p_calm_pct DECIMAL(5,2),
    IN p_energetic_pct DECIMAL(5,2),
    IN p_angry_pct DECIMAL(5,2)
)
BEGIN
    SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    START TRANSACTION;

    DECLARE v_playlist_id     INT;
    DECLARE v_happy_cnt       INT;
    DECLARE v_sad_cnt         INT;
    DECLARE v_calm_cnt        INT;
    DECLARE v_energetic_cnt   INT;
    DECLARE v_angry_cnt       INT;

    SET v_happy_cnt      = ROUND(p_total_tracks * p_happy_pct);
    SET v_sad_cnt        = ROUND(p_total_tracks * p_sad_pct);
    SET v_calm_cnt       = ROUND(p_total_tracks * p_calm_pct);
    SET v_energetic_cnt  = ROUND(p_total_tracks * p_energetic_pct);
    SET v_angry_cnt      = p_total_tracks
                           - v_happy_cnt - v_sad_cnt - v_calm_cnt - v_energetic_cnt;

    INSERT INTO Playlist (user_id, name)
    VALUES (p_user_id, p_playlist_name);
    SET v_playlist_id = LAST_INSERT_ID();

    INSERT INTO PlaylistSong (playlist_id, song_id)
      SELECT v_playlist_id, song_id
      FROM (SELECT song_id
            FROM MoodLog
            WHERE mood_label = 'Happy'
            ORDER BY RAND()
            LIMIT v_happy_cnt) AS t;

    INSERT INTO PlaylistSong (playlist_id, song_id)
      SELECT v_playlist_id, song_id
      FROM (SELECT song_id
            FROM MoodLog
            WHERE mood_label = 'Sad'
            ORDER BY RAND()
            LIMIT v_sad_cnt) AS t;

    INSERT INTO PlaylistSong (playlist_id, song_id)
      SELECT v_playlist_id, song_id
      FROM (SELECT song_id
            FROM MoodLog
            WHERE mood_label = 'Calm'
            ORDER BY RAND()
            LIMIT v_calm_cnt) AS t;

    INSERT INTO PlaylistSong (playlist_id, song_id)
      SELECT v_playlist_id, song_id
      FROM (SELECT song_id
            FROM MoodLog
            WHERE mood_label = 'Energetic'
            ORDER BY RAND()
            LIMIT v_energetic_cnt) AS t;

    INSERT INTO PlaylistSong (playlist_id, song_id)
      SELECT v_playlist_id, song_id
      FROM (SELECT song_id
            FROM MoodLog
            WHERE mood_label = 'Angry'
            ORDER BY RAND()
            LIMIT v_angry_cnt) AS t;

    SELECT v_playlist_id AS new_playlist_id;

    COMMIT;
END;
