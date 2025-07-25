-- Top happy tracks last 30 days
SELECT
    s.track_name, s.artist,
    ROUND(AVG(m.rating),1) AS avg_happy_rating,
    COUNT(*) AS votes
FROM
    Song s
    JOIN MoodLog m ON m.song_id = s.song_id
WHERE
    m.mood_label = 'Happy'
    AND m.ts >= NOW() - INTERVAL 30 DAY
GROUP BY
    s.song_id
HAVING
    votes >= 2
ORDER BY
    avg_happy_rating DESC;

/*
-> Sort: avg_happy_rating DESC (actual time=4.23..4.24 rows=15 loops=1)
-> Filter: (votes >= 2) (actual time=4.13..4.2 rows=15 loops=1)
-> Table scan on <temporary> (actual time=4.12..4.18 rows=353 loops=1)
-> Aggregate using temporary table (actual time=4.12..4.12 rows=353 loops=1)
-> Nested loop inner join (cost=554 rows=333) (actual time=0.179..3.62 rows=369 loops=1)
-> Filter: ((m.mood_label = 'Happy') and (m.ts >= <cache>((now() - interval 30 day))) and (m.song_id is not null)) (cost=437 rows=333) (actual time=0.157..2.38 rows=369 loops=1)
-> Table scan on m (cost=437 rows=5000) (actual time=0.145..1.74 rows=5000 loops=1)
-> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.00314..0.00317 rows=1 loops=369)
*/

-- selects the users who have logged >= 3 moods with average ratings >= 80
SELECT
    u.username,
    COUNT(*) AS total_logs,
    COUNT(DISTINCT m.mood_label) AS distinct_moods,
    ROUND(AVG(m.rating),1) AS avg_rating
FROM
    User u
    JOIN MoodLog m USING (user_id)
GROUP BY
    u.user_id
HAVING
    distinct_moods >= 3
    AND avg_rating >= 80
ORDER BY
    total_logs DESC;

/*
-> Sort: total_logs DESC (actual time=12.8..12.9 rows=342 loops=1)
-> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=0.252..12.7 rows=342 loops=1)
-> Stream results (cost=1369 rows=1000) (actual time=0.246..12.4 rows=989 loops=1)
-> Group aggregate: avg(m.rating), count(0), count(distinct m.mood_label) (cost=1369 rows=1000) (actual time=0.238..11.8 rows=989 loops=1)
-> Nested loop inner join (cost=1087 rows=2817) (actual time=0.203..9.38 rows=5000 loops=1)
-> Index scan on u using PRIMARY (cost=101 rows=1000) (actual time=0.132..0.403 rows=1000 loops=1)
-> Index lookup on m using idx_moodlog_user_ts (user_id=u.user_id) (cost=0.705 rows=2.82) (actual time=0.00548..0.00854 rows=5 loops=1000)
*/

-- compares valence to the average happy rating given by users the MoodLog
-- returns the top 15 songs where the difference is greater than 0.30
WITH crowd AS (
    SELECT
        song_id,
        AVG(CASE WHEN mood_label='Happy' THEN rating END)/100 AS crowd_valence
    FROM
        MoodLog
    GROUP BY
        song_id
    )
SELECT
    s.track_name,
    s.artist,
    s.valence,
    ROUND(c.crowd_valence,3) AS crowd_valence,
    ROUND(ABS(s.valence-c.crowd_valence),3) AS diff
FROM
    Song s
    JOIN crowd c USING (song_id)
WHERE
    c.crowd_valence IS NOT NULL
HAVING
    diff > 0.30
ORDER BY
    diff DESC
LIMIT
    15;

/*
-> Limit: 15 row(s) (actual time=15.3..15.3 rows=15 loops=1)
-> Sort: diff DESC, limit input to 15 row(s) per chunk (actual time=15.3..15.3 rows=15 loops=1)
-> Filter: (diff > 0.30) (actual time=11.2..15.1 rows=519 loops=1)
-> Stream results (cost=2315 rows=5000) (actual time=11.2..15 rows=885 loops=1)
-> Nested loop inner join (cost=2315 rows=5000) (actual time=11.2..14.3 rows=885 loops=1)
-> Filter: (c.song_id is not null) (cost=1423..565 rows=5000) (actual time=11.1..11.4 rows=885 loops=1)
-> Table scan on c (cost=1423..1478 rows=4194) (actual time=11.1..11.3 rows=885 loops=1)
-> Materialize CTE crowd (cost=1423..1423 rows=4194) (actual time=11.1..11.1 rows=885 loops=1)
-> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=4194) (actual time=1.71..10.7 rows=885 loops=1)
-> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=4194) (actual time=1.69..10.1 rows=3126 loops=1)
-> Index scan on MoodLog using idx_moodlog_song_mood (cost=504 rows=5000) (actual time=1.65..8.71 rows=5000 loops=1)
-> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00307..0.0031 rows=1 loops=885)
*/

-- finds the top 15 playlists by mood diversity and size
-- shows moods represented and total number of logs considered for analysis
SELECT
    p.playlist_id,
    p.name,
    u.username,
    COUNT(DISTINCT m.mood_label) AS mood_diversity,
    COUNT(*) AS total_tracks
FROM
    Playlist p
    JOIN User u USING (user_id)
    JOIN PlaylistSong ps USING (playlist_id)
    JOIN MoodLog m ON m.song_id = ps.song_id
GROUP BY
    p.playlist_id
ORDER BY
    mood_diversity DESC,
    total_tracks DESC
LIMIT
    15;

/*
-> Limit: 15 row(s) (actual time=69.7..69.7 rows=0 loops=1)
-> Sort: mood_diversity DESC, total_tracks DESC, limit input to 15 row(s) per chunk (actual time=69.7..69.7 rows=0 loops=1)
-> Stream results (cost=18458 rows=764) (actual time=69.6..69.6 rows=0 loops=1)
-> Group aggregate: count(distinct m.mood_label), count(0) (cost=18458 rows=764) (actual time=69.6..69.6 rows=0 loops=1)
-> Nested loop inner join (cost=14830 rows=36274) (actual time=69.6..69.6 rows=0 loops=1)
-> Nested loop inner join (cost=3593 rows=30429) (actual time=0.0923..16.7 rows=30560 loops=1)
-> Nested loop inner join (cost=345 rows=764) (actual time=0.0659..2.45 rows=764 loops=1)
-> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0508..0.551 rows=764 loops=1)
-> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0495..0.461 rows=764 loops=1)
-> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00226..0.00229 rows=1 loops=764)
-> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0114..0.016 rows=40 loops=764)
-> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.25 rows=1.19) (actual time=0.00162..0.00162 rows=0 loops=30560)
*/