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
[Default]
-> Sort: avg_happy_rating DESC (actual time=5.53..5.54 rows=40 loops=1) -> Filter: (votes >= 2) (actual time=5.46..5.47 rows=40 loops=1) -> Table scan on <temporary> (actual time=5.46..5.46 rows=40 loops=1) -> Aggregate using temporary table (actual time=5.45..5.45 rows=40 loops=1) -> Nested loop inner join (cost=554 rows=333) (actual time=0.555..4.9 rows=340 loops=1) -> Filter: ((m.mood_label = 'Happy') and (m.ts >= <cache>((now() - interval 30 day))) and (m.song_id is not null)) (cost=437 rows=333) (actual time=0.317..3.72 rows=340 loops=1) -> Table scan on m (cost=437 rows=5000) (actual time=0.292..2.63 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.0031..0.00313 rows=1 loops=340)

[Single-Column Index on MoodLog(mood_label)]
-> Sort: avg_happy_rating DESC (actual time=3.09..3.09 rows=40 loops=1) -> Filter: (votes >= 2) (actual time=3.03..3.04 rows=40 loops=1) -> Table scan on <temporary> (actual time=3.03..3.03 rows=40 loops=1) -> Aggregate using temporary table (actual time=3.03..3.03 rows=40 loops=1) -> Nested loop inner join (cost=163 rows=335) (actual time=0.417..2.62 rows=340 loops=1) -> Filter: ((m.ts >= <cache>((now() - interval 30 day))) and (m.song_id is not null)) (cost=45.5 rows=335) (actual time=0.402..1.99 rows=340 loops=1) -> Index lookup on m using idx_ml_moodlabel (mood_label='Happy'), with index condition: (m.mood_label = 'Happy') (cost=45.5 rows=1006) (actual time=0.391..1.87 rows=1006 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.00163..0.00166 rows=1 loops=340)

[Composite Index on (mood_label, ts)]
-> Sort: avg_happy_rating DESC (actual time=2.04..2.04 rows=40 loops=1) -> Filter: (votes >= 2) (actual time=1.98..1.99 rows=40 loops=1) -> Table scan on <temporary> (actual time=1.98..1.98 rows=40 loops=1) -> Aggregate using temporary table (actual time=1.98..1.98 rows=40 loops=1) -> Nested loop inner join (cost=272 rows=340) (actual time=0.467..1.57 rows=340 loops=1) -> Filter: (m.song_id is not null) (cost=153 rows=340) (actual time=0.452..0.918 rows=340 loops=1) -> Index range scan on m using idx_ml_mood_ts over (mood_label = 'Happy' AND '2025-06-26 00:42:09' <= ts), with index condition: ((m.mood_label = 'Happy') and (m.ts >= <cache>((now() - interval 30 day)))) (cost=153 rows=340) (actual time=0.44..0.88 rows=340 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.00167..0.0017 rows=1 loops=340)

[Composite Index on (mood_label, ts, song_id)
]
-> Sort: avg_happy_rating DESC (actual time=1.83..1.83 rows=40 loops=1) -> Filter: (votes >= 2) (actual time=1.77..1.78 rows=40 loops=1) -> Table scan on <temporary> (actual time=1.76..1.77 rows=40 loops=1) -> Aggregate using temporary table (actual time=1.76..1.76 rows=40 loops=1) -> Nested loop inner join (cost=272 rows=340) (actual time=0.437..1.42 rows=340 loops=1) -> Index range scan on m using idx_ml_mood_ts_songid over (mood_label = 'Happy' AND '2025-06-26 00:42:35' <= ts), with index condition: (((m.mood_label = 'Happy') and (m.ts >= <cache>((now() - interval 30 day)))) and (m.song_id is not null)) (cost=153 rows=340) (actual time=0.423..0.89 rows=340 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=m.song_id) (cost=0.25 rows=1) (actual time=0.00133..0.00135 rows=1 loops=340)
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
[Default]
-> Sort: total_logs DESC (actual time=19.3..19.3 rows=246 loops=1) -> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=0.623..19.1 rows=246 loops=1) -> Stream results (cost=1369 rows=1000) (actual time=0.602..18.7 rows=617 loops=1) -> Group aggregate: avg(m.rating), count(0), count(distinct m.mood_label) (cost=1369 rows=1000) (actual time=0.57..17.9 rows=617 loops=1) -> Nested loop inner join (cost=1087 rows=2817) (actual time=0.362..15 rows=5000 loops=1) -> Index scan on u using PRIMARY (cost=101 rows=1000) (actual time=0.0867..0.416 rows=1000 loops=1) -> Index lookup on m using idx_moodlog_user_ts (user_id=u.user_id) (cost=0.705 rows=2.82) (actual time=0.00694..0.0141 rows=5 loops=1000)

[Single-Column Index on MoodLog(user_id)]
-> Sort: total_logs DESC (actual time=15.4..15.4 rows=246 loops=1) -> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=12.5..15.3 rows=246 loops=1) -> Stream results (actual time=12.4..15.2 rows=617 loops=1) -> Group aggregate: avg(MoodLog.rating), count(0), count(distinct MoodLog.mood_label) (actual time=12.4..14.8 rows=617 loops=1) -> Sort: u.user_id (actual time=12.4..12.8 rows=5000 loops=1) -> Stream results (cost=2254 rows=5000) (actual time=0.162..10.2 rows=5000 loops=1) -> Nested loop inner join (cost=2254 rows=5000) (actual time=0.156..7.53 rows=5000 loops=1) -> Filter: (m.user_id is not null) (cost=504 rows=5000) (actual time=0.139..1.95 rows=5000 loops=1) -> Table scan on m (cost=504 rows=5000) (actual time=0.137..1.58 rows=5000 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=m.user_id) (cost=0.25 rows=1) (actual time=913e-6..945e-6 rows=1 loops=5000)

[Composite Index on MoodLog(user_id, mood_label)]
-> Sort: total_logs DESC (actual time=15.7..15.8 rows=246 loops=1) -> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=12.9..15.7 rows=246 loops=1) -> Stream results (actual time=12.9..15.5 rows=617 loops=1) -> Group aggregate: avg(MoodLog.rating), count(0), count(distinct MoodLog.mood_label) (actual time=12.9..15.2 rows=617 loops=1) -> Sort: u.user_id (actual time=12.9..13.3 rows=5000 loops=1) -> Stream results (cost=2254 rows=5000) (actual time=0.269..11.1 rows=5000 loops=1) -> Nested loop inner join (cost=2254 rows=5000) (actual time=0.263..8.21 rows=5000 loops=1) -> Filter: (m.user_id is not null) (cost=504 rows=5000) (actual time=0.244..2.23 rows=5000 loops=1) -> Table scan on m (cost=504 rows=5000) (actual time=0.243..1.85 rows=5000 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=m.user_id) (cost=0.25 rows=1) (actual time=988e-6..0.00102 rows=1 loops=5000)

[Composite Index on MoodLog(user_id, mood_label, rating)]
-> Sort: total_logs DESC (actual time=7.23..7.24 rows=246 loops=1) -> Filter: ((distinct_moods >= 3) and (avg_rating >= 80)) (actual time=0.123..7.12 rows=246 loops=1) -> Stream results (cost=2627 rows=1000) (actual time=0.119..6.96 rows=617 loops=1) -> Group aggregate: avg(m.rating), count(0), count(distinct m.mood_label) (cost=2627 rows=1000) (actual time=0.114..6.57 rows=617 loops=1) -> Nested loop inner join (cost=1817 rows=8104) (actual time=0.0915..4.38 rows=5000 loops=1) -> Index scan on u using PRIMARY (cost=101 rows=1000) (actual time=0.0581..0.314 rows=1000 loops=1) -> Covering index lookup on m using idx_ml_userid_moodlabel_rating (user_id=u.user_id) (cost=0.906 rows=8.1) (actual time=0.00268..0.00364 rows=5 loops=1000)
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
[Default]
-> Sort: diff DESC (actual time=10.8..10.8 rows=21 loops=1) -> Filter: (diff > 0.30) (actual time=10.5..10.7 rows=21 loops=1) -> Stream results (cost=2315 rows=5000) (actual time=10.5..10.7 rows=40 loops=1) -> Nested loop inner join (cost=2315 rows=5000) (actual time=10.5..10.7 rows=40 loops=1) -> Filter: (c.song_id is not null) (cost=1423..565 rows=5000) (actual time=10.4..10.4 rows=40 loops=1) -> Table scan on c (cost=1423..1478 rows=4194) (actual time=10.4..10.4 rows=40 loops=1) -> Materialize CTE crowd (cost=1423..1423 rows=4194) (actual time=10.4..10.4 rows=40 loops=1) -> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=4194) (actual time=1.87..10.3 rows=40 loops=1) -> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=4194) (actual time=1.86..10.3 rows=40 loops=1) -> Index scan on MoodLog using idx_moodlog_song_mood (cost=504 rows=5000) (actual time=1.68..8.82 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00653..0.00656 rows=1 loops=40)

[Single-Column Index on MoodLog(song_id)]
-> Sort: diff DESC (actual time=9.48..9.48 rows=21 loops=1) -> Filter: (diff > 0.30) (actual time=9.26..9.45 rows=21 loops=1) -> Stream results (cost=2315 rows=5000) (actual time=9.25..9.44 rows=40 loops=1) -> Nested loop inner join (cost=2315 rows=5000) (actual time=9.24..9.4 rows=40 loops=1) -> Filter: (c.song_id is not null) (cost=1008..565 rows=5000) (actual time=9.15..9.15 rows=40 loops=1) -> Table scan on c (cost=1008..1011 rows=40) (actual time=9.14..9.15 rows=40 loops=1) -> Materialize CTE crowd (cost=1008..1008 rows=40) (actual time=9.14..9.14 rows=40 loops=1) -> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=40) (actual time=1.17..9.06 rows=40 loops=1) -> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=40) (actual time=1.17..9.02 rows=40 loops=1) -> Index scan on MoodLog using idx_ml_songid (cost=504 rows=5000) (actual time=1.1..8.06 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00581..0.00584 rows=1 loops=40)

[Composite Index on MoodLog(song_id, mood_label)]
-> Sort: diff DESC (actual time=7.77..7.77 rows=21 loops=1) -> Filter: (diff > 0.30) (actual time=7.59..7.74 rows=21 loops=1) -> Stream results (cost=2315 rows=5000) (actual time=7.58..7.74 rows=40 loops=1) -> Nested loop inner join (cost=2315 rows=5000) (actual time=7.57..7.69 rows=40 loops=1) -> Filter: (c.song_id is not null) (cost=1008..565 rows=5000) (actual time=7.55..7.55 rows=40 loops=1) -> Table scan on c (cost=1008..1011 rows=40) (actual time=7.54..7.55 rows=40 loops=1) -> Materialize CTE crowd (cost=1008..1008 rows=40) (actual time=7.53..7.53 rows=40 loops=1) -> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=40) (actual time=0.848..7.47 rows=40 loops=1) -> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=40) (actual time=0.842..7.44 rows=40 loops=1) -> Index scan on MoodLog using idx_moodlog_song_mood (cost=504 rows=5000) (actual time=0.801..6.61 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00319..0.00322 rows=1 loops=40)

[Covering Index: MoodLog(song_id, mood_label, rating)]
-> Sort: diff DESC (actual time=2.54..2.55 rows=21 loops=1) -> Filter: (diff > 0.30) (actual time=2.31..2.51 rows=21 loops=1) -> Stream results (cost=2315 rows=5000) (actual time=2.3..2.5 rows=40 loops=1) -> Nested loop inner join (cost=2315 rows=5000) (actual time=2.29..2.46 rows=40 loops=1) -> Filter: (c.song_id is not null) (cost=1008..565 rows=5000) (actual time=2.27..2.28 rows=40 loops=1) -> Table scan on c (cost=1008..1011 rows=40) (actual time=2.27..2.27 rows=40 loops=1) -> Materialize CTE crowd (cost=1008..1008 rows=40) (actual time=2.27..2.27 rows=40 loops=1) -> Filter: ((avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) / 100) is not null) (cost=1004 rows=40) (actual time=0.179..2.22 rows=40 loops=1) -> Group aggregate: avg((case when (MoodLog.mood_label = 'Happy') then MoodLog.rating end)) (cost=1004 rows=40) (actual time=0.159..2.18 rows=40 loops=1) -> Covering index scan on MoodLog using idx_ml_songid_moodlabel_rating (cost=504 rows=5000) (actual time=0.118..1.4 rows=5000 loops=1) -> Single-row index lookup on s using PRIMARY (song_id=c.song_id) (cost=0.25 rows=1) (actual time=0.00422..0.00426 rows=1 loops=40)
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
[Default]
-> Sort: mood_diversity DESC, total_tracks DESC (actual time=3979..3979 rows=764 loops=1) -> Stream results (cost=18458 rows=764) (actual time=4.35..3976 rows=764 loops=1) -> Group aggregate: count(distinct m.mood_label), count(0) (cost=18458 rows=764) (actual time=4.35..3973 rows=764 loops=1) -> Nested loop inner join (cost=14830 rows=36274) (actual time=0.123..2366 rows=3.82e+6 loops=1) -> Nested loop inner join (cost=3593 rows=30429) (actual time=0.104..33.4 rows=30560 loops=1) -> Nested loop inner join (cost=345 rows=764) (actual time=0.0766..9.87 rows=764 loops=1) -> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0605..2.34 rows=764 loops=1) -> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0595..1.67 rows=764 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00858..0.00874 rows=1 loops=764) -> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0157..0.0264 rows=40 loops=764) -> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.25 rows=1.19) (actual time=0.00339..0.067 rows=125 loops=30560)

[Single-Column Index on MoodLog(song_id)]
-> Sort: mood_diversity DESC, total_tracks DESC (actual time=2825..2825 rows=764 loops=1) -> Stream results (cost=773526 rows=764) (actual time=3.73..2823 rows=764 loops=1) -> Group aggregate: count(distinct m.mood_label), count(0) (cost=773526 rows=764) (actual time=3.73..2821 rows=764 loops=1) -> Nested loop inner join (cost=393168 rows=3.8e+6) (actual time=0.122..1562 rows=3.82e+6 loops=1) -> Nested loop inner join (cost=3593 rows=30429) (actual time=0.0827..25.5 rows=30560 loops=1) -> Nested loop inner join (cost=345 rows=764) (actual time=0.0611..7.87 rows=764 loops=1) -> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0468..1.89 rows=764 loops=1) -> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0459..1.32 rows=764 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00695..0.00706 rows=1 loops=764) -> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0128..0.02 rows=40 loops=764) -> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.303 rows=125) (actual time=0.0262..0.0402 rows=125 loops=30560)

[Composite Index on MoodLog(song_id, mood_label)]
-> Sort: mood_diversity DESC, total_tracks DESC (actual time=2719..2719 rows=764 loops=1) -> Stream results (cost=773526 rows=764) (actual time=3.49..2718 rows=764 loops=1) -> Group aggregate: count(distinct m.mood_label), count(0) (cost=773526 rows=764) (actual time=3.49..2716 rows=764 loops=1) -> Nested loop inner join (cost=393168 rows=3.8e+6) (actual time=0.137..1506 rows=3.82e+6 loops=1) -> Nested loop inner join (cost=3593 rows=30429) (actual time=0.0988..24.4 rows=30560 loops=1) -> Nested loop inner join (cost=345 rows=764) (actual time=0.0787..7.02 rows=764 loops=1) -> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0662..1.74 rows=764 loops=1) -> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0653..1.24 rows=764 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00604..0.00614 rows=1 loops=764) -> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0122..0.0199 rows=40 loops=764) -> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.303 rows=125) (actual time=0.0259..0.0397 rows=125 loops=30560)

[Covering Index: MoodLog(song_id, mood_label, user_id)]
-> Sort: mood_diversity DESC, total_tracks DESC (actual time=2802..2802 rows=764 loops=1) -> Stream results (cost=773526 rows=764) (actual time=7.8..2801 rows=764 loops=1) -> Group aggregate: count(distinct m.mood_label), count(0) (cost=773526 rows=764) (actual time=7.79..2799 rows=764 loops=1) -> Nested loop inner join (cost=393168 rows=3.8e+6) (actual time=0.184..1539 rows=3.82e+6 loops=1) -> Nested loop inner join (cost=3593 rows=30429) (actual time=0.114..25.2 rows=30560 loops=1) -> Nested loop inner join (cost=345 rows=764) (actual time=0.0826..7.24 rows=764 loops=1) -> Filter: (p.user_id is not null) (cost=77.4 rows=764) (actual time=0.0674..1.78 rows=764 loops=1) -> Index scan on p using PRIMARY (cost=77.4 rows=764) (actual time=0.0666..1.24 rows=764 loops=1) -> Single-row index lookup on u using PRIMARY (user_id=p.user_id) (cost=0.25 rows=1) (actual time=0.00622..0.00632 rows=1 loops=764) -> Covering index lookup on ps using PRIMARY (playlist_id=p.playlist_id) (cost=0.274 rows=39.8) (actual time=0.0128..0.0205 rows=40 loops=764) -> Covering index lookup on m using idx_moodlog_song_mood (song_id=ps.song_id) (cost=0.303 rows=125) (actual time=0.0267..0.041 rows=125 loops=30560)
*/