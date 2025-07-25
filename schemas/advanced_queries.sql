/* Top Happy tracks last 30 days */
SELECT s.track_name, s.artist,
       ROUND(AVG(m.rating),1) AS avg_happy_rating,
       COUNT(*)               AS votes
FROM   Song s
JOIN   MoodLog m ON m.song_id = s.song_id
WHERE  m.mood_label = 'Happy'
  AND  m.ts >= NOW() - INTERVAL 30 DAY
GROUP  BY s.song_id
HAVING votes >= 10
ORDER  BY avg_happy_rating DESC
LIMIT 15;

SELECT u.username,
       COUNT(*) AS total_logs,
       COUNT(DISTINCT m.mood_label) AS distinct_moods,
       ROUND(AVG(m.rating),1) AS avg_rating
FROM   User u
JOIN   MoodLog m USING (user_id)
GROUP  BY u.user_id
HAVING distinct_moods >= 3
   AND avg_rating     >= 80
ORDER BY total_logs DESC
LIMIT 15;

WITH crowd AS (
  SELECT song_id,
         AVG(CASE WHEN mood_label='Happy' THEN rating END)/100 AS crowd_valence
  FROM   MoodLog
  GROUP  BY song_id)
SELECT s.track_name, s.artist, s.valence, ROUND(c.crowd_valence,3) AS crowd_valence,
       ROUND(ABS(s.valence-c.crowd_valence),3) AS diff
FROM   Song s
JOIN   crowd c USING (song_id)
WHERE  c.crowd_valence IS NOT NULL
HAVING diff > 0.30
ORDER  BY diff DESC
LIMIT 15;

SELECT p.playlist_id, p.name, u.username,
       COUNT(DISTINCT m.mood_label) AS mood_diversity,
       COUNT(*) AS total_tracks
FROM   Playlist p
JOIN   User u USING (user_id)
JOIN   PlaylistSong ps USING (playlist_id)
JOIN   MoodLog m ON m.song_id = ps.song_id
GROUP  BY p.playlist_id
ORDER  BY mood_diversity DESC, total_tracks DESC
LIMIT 15;