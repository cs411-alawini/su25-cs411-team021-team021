INSERT INTO MoodLog (user_id, song_id, mood_label, rating, ts)
SELECT  (SELECT user_id FROM User ORDER BY RAND() LIMIT 1),
        (SELECT song_id FROM Song ORDER BY RAND() LIMIT 1),
        ELT(FLOOR(1+RAND()*5),'Happy','Sad','Calm','Energetic','Angry'),
        FLOOR(60+RAND()*40),
        NOW() - INTERVAL FLOOR(RAND()*90) DAY
FROM    information_schema.columns
LIMIT   100;