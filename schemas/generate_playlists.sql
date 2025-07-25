USE melodb;

-- insert new playlists for random users
INSERT INTO Playlist (user_id, name)
SELECT user_id, CONCAT('Mix ', user_id)
FROM User
WHERE RAND() < 0.4;

-- assign 40 random songs to each playlist
INSERT INTO PlaylistSong (playlist_id, song_id)
SELECT playlist_id, song_id
FROM (
    SELECT
        p.playlist_id,
        s.song_id,
        ROW_NUMBER() OVER (
            PARTITION BY p.playlist_id
            ORDER BY RAND()
        ) AS rn
    FROM Playlist p
    JOIN Song s
) AS pairs
WHERE rn <= 40;