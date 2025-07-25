USE melodb;

-- insert new playlists for random users
INSERT INTO Playlist (user_id, name)
SELECT user_id, CONCAT('Mix ', user_id)
FROM User
WHERE RAND() < 0.4;

-- assign 40 random songs to each playlist
SELECT p.playlist_id, s.song_id
FROM Playlist p
JOIN (
    SELECT song_id, ROW_NUMBER() OVER (ORDER BY RAND()) AS rn
    FROM Song
) s ON TRUE
WHERE s.rn <= 40;