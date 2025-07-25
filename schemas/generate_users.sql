INSERT INTO MoodLog (user_id, song_id, mood_label, rating, ts)
SELECT  u.user_id,
        s.song_id,
        ELT(FLOOR(1+RAND()*5),'Happy','Sad','Calm','Energetic','Angry'),
        FLOOR(60+RAND()*40),
        NOW() - INTERVAL FLOOR(RAND()*90) DAY
FROM
  (SELECT user_id FROM User ORDER BY RAND() LIMIT 1000) u
CROSS JOIN
  (SELECT song_id FROM Song ORDER BY RAND() LIMIT 1000) s
ORDER BY RAND()
LIMIT 5000;