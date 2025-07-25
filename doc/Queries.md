# Queries

## Part 1

### 1) Implement at least five tables
![Tables in the GCP database](figures/gcp-db-connection.png)

### 2) Provide DDL
Please reference the [database design](Database%20Design.md#Entities%20and%20Assumptions) from previous submission.

### 3) Insert data into these tables
In the screenshot above, it also highlights row count in each table.
It should satisfy the 1000-row requirement.

### 4) Advanced SQL queries

#### Top happy tracks last 30 days

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

#### Finding playlists with diversed mood

## Part 2
### 1) `EXPLAIN ANALYZE`

### 2) Explore tradeoffs of adding different indices

### 3) Final index design

### 4)