-- Spotify Query SQL Project, Kaggle Dataset --

-- create table --
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- EDA - Exploratory Data Analysis --

SELECT * FROM spotify

-- Total number of songs / all rows--
SELECT COUNT(*) FROM spotify;
-- 20594, minus 2 when we delete songs that are 0 seconds long below --

-- Total number of artists --
SELECT COUNT(DISTINCT artist) FROM spotify;
-- 2074 --

-- Total number of albums --
SELECT COUNT(DISTINCT album) FROM spotify;
-- 11854 --

-- Total number of songs with a music video --
SELECT COUNT(*) 
FROM spotify
WHERE official_video = 'true';

-- Different places where the songs are most played on --
Select DISTINCT most_played_on FROM spotify;
-- Youtube and Spotify --

-- Different types of albums --
SELECT DISTINCT album_type FROM spotify;

-- Different channels that songs can be played on --
SELECT DISTINCT channel FROM spotify;

-- Longest song by minutes --
SELECT MAX(duration_min) FROM spotify;

-- Shortest song by minutes --
SELECT MIN(duration_min) FROM spotify;

-- Songs that are for 0 seconds --
SELECT * FROM spotify
WHERE duration_min = 0;
-- 2 songs, These Words by Natasha Bedingfield and Raining in the Early Morning by White Noise for Babies

-- Songs above that are not neeeded and can be deleted --
DELETE FROM spotify
WHERE duration_min = 0;
-- cleaning up the data --

-- Seeing how many songs each artist has in the db --
SELECT COUNT(track) AS tracks, artist
FROM spotify
GROUP BY artist
ORDER BY tracks ASC;

-- Querying how many streams/listens each artists songs have largest to smallest
SELECT SUM(stream) AS total_streams, artist
FROM spotify
GROUP BY artist
ORDER BY total_streams DESC;
-- Post Malone, Ed Sheeran and Dua Lipa have the most streams/listens, most is 15,251,263,853 --
 
-- Querying how many views each artists music videos has for their songs largest to smallest
 SELECT SUM(views) AS total_views, artist
 FROM spotify
 GROUP BY artist
 ORDER BY total_views DESC;
 -- Ed Sheeran, CoComelon, and Katy Perry have the most amount of views --

----------------------------------
-- Easy Data Analysis Questions --
----------------------------------

-- Query for all the names of tracks that have over a billion streams --
 SELECT stream, track, artist
 FROM spotify
 WHERE stream > 1000000000
 ORDER BY stream DESC;
 
-- Count them aswell --
SELECT COUNT(track)
FROM spotify
WHERE stream > 1000000000;
-- 385 tracks have over a billion streams

----------------------------------

-- List all albums along with there artist --
SELECT DISTINCT(album), artist
FROM spotify
ORDER BY artist;

-- Count the amount of albums each artist has aswell, lowest amount of albums to highest --
SELECT COUNT(DISTINCT(album)), artist
FROM spotify
GROUP BY artist
ORDER BY count ASC;

----------------------------------
-- Get the total number of comments where licensed = true
----------------------------------
-- SELECT DISTINCT licensed FROM spotify;

SELECT SUM(comments) AS licensed_comments
FROM spotify
WHERE licensed = 'true';

----------------------------------
-- Find all the tracks where the album type is single
----------------------------------

SELECT * 
FROM spotify
WHERE album_type = 'single'; --or ILIKE to check also

----------------------------------
-- Find the average number of likes for songs with a music video, round to two dec
----------------------------------

SELECT ROUND(AVG(likes), 2)
FROM spotify
WHERE official_video = 'true';

-------------------------------------
-- Medium Data Analytics Questions --
-------------------------------------
--Find the average danceability of tracks in each album

SELECT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;

------------------------------------
--Find the top 5 tracks with the highest energy values
------------------------------------

SELECT  track, MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

------------------------------------
--List all the tracks with there views and likes where offical_video = 'true'
------------------------------------

SELECT track, 
	SUM(views) AS total_views, 
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;

-----------------------------------
-- For each album find the total views of all associated tracks
-----------------------------------
---

SELECT album, SUM(views) AS total_album_views
FROM spotify
GROUP BY 1
ORDER BY 2 DESC


----------------------------------
-- Retrieve the track names of songs that are played more on Spotify than Youtube
----------------------------------
-- some songs stream on both, some dont
SELECT * FROM
(SELECT track, --most_played_on, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
FROM spotify
GROUP BY 1) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0
ORDER BY streamed_on_spotify DESC;

---------------------------------------
-- Advanced Data Analytics Questions --
---------------------------------------

-- Find the top 3 most-viewed tracks for each artist with window functions

-- artists and the total views for each track
-- track with highest views, ranked top 3 for each artist

WITH track_rank
AS
(SELECT artist, 
	track, 
	SUM(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
) 
SELECT * FROM track_rank
WHERE rank <= 3;

------------------------------------
-- Find the tracks where the liveness is above the average
------------------------------------

SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- SELECT AVG(liveness) FROM spotify, the average liveness of all the songs

------------------------------------
--Use the WITH clause to find the diffrence between the highest and the lowest energy valuse for tracks in each album
------------------------------------
WITH cte
AS
(SELECT album, MAX(energy) AS high_energy,
MIN(energy) AS low_energy
FROM spotify
GROUP BY 1   -- Finding the highest and lowest energy
)
SELECT album, high_energy - low_energy AS energy_diff
FROM cte; -- getting the difference

------------------------------------
-- Find the cumulative sum of likes for tracks ordered by the number of views
------------------------------------

------------------------------------
--Find tracks where the ratio for the energy-to-liveness is greater than 1.2
------------------------------------

------------------------------------
--Query optimization
------------------------------------

EXPLAIN ANALYZE -- Execution Time: 4.184ms, Planning Time: 0.058ms
SELECT artist,
track,
views
FROM spotify
WHERE  artist = 'Gorillaz'
 AND most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25

-- Analyze, first it is doing a Seq Scan to get the tracks with artist
-- Gorillaz and that are most played on Youtube, then it is sorting by 
-- the amount of streams each has in discending order, and finally getting the limit

CREATE INDEX artist_index ON spotify (artist);
-- After Indexing the above queries Execution Time : 0.037ms, Planning Time: 0.065ms
-- Making the query significantly faster.

-- adding two more indexes for optimization and speed
CREATE INDEX track_index ON spotify (track);
CREATE INDEX album_index ON spotify (album);