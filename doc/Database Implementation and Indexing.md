# Database Implementation and Indexing

## Part 1

### 1) Implement at least five tables
![Tables in the GCP database](figures/gcp-db-connection.png)

### 2) Provide DDL
Please reference the [database design](Database%20Design.md#Entities%20and%20Assumptions) from previous submission.

### 3) Insert data into these tables
In the screenshot above, it also highlights row count in each table.
It should satisfy the 1000-row requirement.

### 4) Advanced SQL queries
All following advanced SQL queries are provided with a screenshot of the top 15 rows of each query result, unless specified explicitly.

#### Top happy tracks last 30 days
```sql
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
```

#### Select active users
Selects the users who have logged >= 3 moods with average ratings >= 80.

```sql
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
```

#### Valence difference
```sql
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
    diff DESC;
```

#### Finding playlists with diversed mood
Finds the top 15 playlists by mood diversity and size, and shows moods represented and total number of logs considered for analysis.

```sql
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
```

## Part 2
### 1) `EXPLAIN ANALYZE`

### 2) Explore tradeoffs of adding different indices

### 3) Final index design

### 4)