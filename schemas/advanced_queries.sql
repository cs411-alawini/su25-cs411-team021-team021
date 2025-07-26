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
-> Sort: avg_happy_rating DESC (actual time=5.53..5.54 rows=40 loops=1) -> Filter: (votes >= 2) (actual time=5.46..5.47 rows=40 loops=1) -> Table scan on <temporary> (actual time=5.46..5.46 rows=40 loops=1) -> Aggregate using temporary table (actual time=5.45..5.45 rows=40 loops=1) -> Nested loop inner join (cost=554 rows=333) (actual time=0.555..4.9 rows=340 loops=1) -> Filter: ((m.mood_label = 'Happy') and (m.ts >= <cache>((now() - interval 30 day))) and (m.song_id is not null)) (cost=437 rows=333) (actual time=0.317..3.72 rows=340 loops=1) -> Table scan on m (cost=437 rows=5000) (actual time=0.292..2.63 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.0031..0.00313 rows=1 loops=340)
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
-> Sort: total_logs DESC (actual time=19.3..19.3 rows=246 loops=1) -> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=0.623..19.1 rows=246 loops=1) -> Stream results (cost=1369 rows=1000) (actual time=0.602..18.7 rows=617 loops=1) -> Group aggregate: avg(m.rating), count(0), count(distinct m.mood_label) (cost=1369 rows=1000) (actual time=0.57..17.9 rows=617 loops=1) -> Nested loop inner join (cost=1087 rows=2817) (actual time=0.362..15 rows=5000 loops=1) -> Index scan on u using PRIMARY (cost=101 rows=1000) (actual time=0.0867..0.416 rows=1000 loops=1) -> Index lookup on m using idx_moodlog_user_ts (user_id=u.user_id) (cost=0.705 rows=2.82) (actual time=0.00694..0.0141 rows=5 loops=1000)
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
-> Sort: diff DESC (actual time=10.8..10.8 rows=21 loops=1) -> Filter: (diff > 0.30) (actual time=10.5..10.7 rows=21 loops=1) -> Stream results (cost=2315 rows=5000) (actual time=10.5..10.7 rows=40 loops=1) -> Nested loop inner join (cost=2315 rows=5000) (actual time=10.5..10.7 rows=40 loops=1) -> Filter: (c.song_id is not null) (cost=1423..565 rows=5000) (actual time=10.4..10.4 rows=40 loops=1) -> Table scan on c (cost=1423..1478 rows=4194) (actual time=10.4..10.4 rows=40 loops=1) -> Materialize CTE crowd (cost=1423..1423 rows=4194) (actual time=10.4..10.4 rows=40 loops=1) -> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=4194) (actual time=1.87..10.3 rows=40 loops=1) -> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=4194) (actual time=1.86..10.3 rows=40 loops=1) -> Index scan on MoodLog using idx_moodlog_song_mood (cost=504 rows=5000) (actual time=1.68..8.82 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00653..0.00656 rows=1 loops=40)
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
-> Sort: mood_diversity DESC, total_tracks DESC (actual time=3979..3979 rows=764 loops=1) -> Stream results (cost=18458 rows=764) (actual time=4.35..3976 rows=764 loops=1) -> Group aggregate: count(distinct m.mood_label), count(0) (cost=18458 rows=764) (actual time=4.35..3973 rows=764 loops=1) -> Nested loop inner join (cost=14830 rows=36274) (actual time=0.123..2366 rows=3.82e+6 loops=1) -> Nested loop inner join (cost=3593 rows=30429) (actual time=0.104..33.4 rows=30560 loops=1) -> Nested loop inner join (cost=345 rows=764) (actual time=0.0766..9.87 rows=764 loops=1) -> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0605..2.34 rows=764 loops=1) -> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0595..1.67 rows=764 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00858..0.00874 rows=1 loops=764) -> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0157..0.0264 rows=40 loops=764) -> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.25 rows=1.19) (actual time=0.00339..0.067 rows=125 loops=30560)
*/