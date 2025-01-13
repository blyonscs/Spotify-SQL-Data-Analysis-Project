# Spotify Advanced SQL Project and Query Optimization, Data Analysis
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/blyonscs/Spotify-SQL-Data-Analysis-Project/blob/main/Spotify_Pictures_Readme/Spotify-Logo-Data.png)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, validating that the dataset is cleaned properly and putting the columns that are needed for visualization into a seperate cleaned dataset. I will also be performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset and visualizing them.

## Metadata
- Columns: 24
- Rows: 20594, removed two records in the cleaning
- Integer Columns: 3
- Float Columns: 12
- String Columns: 9
- Size: 5.58 MB
- File Type: CSV
- Unique Artists: 2074
- Unique Tracks: 17717
- Unique Albums: 11854

## Importing
For this project I am using PostgreSQL to edit and analize the dataset. The first step is to start a new database in PostgreSQL and set a new table with the following query. The strings in the dataset are set to VARCHAR(255), the numbers with decimal places as FLOAT's and the numbers that are not suppose to have decimal places as BIGINTS's because some of the numbers in these columns can get quite large
```sql
-- create table
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
```
## Project Steps

### 1. Cleaning The Dataset to import to PostgreSQL
When you first try to import this dataset into PostgreSQL with the raw data it will return errors. The first error is that some of the BIGINT's in the data do have decimal places in them that need to be removed, which can be done in Excel. Open the data file in Excel and select all the integer columns and go to home and select number, this will set all the numbers to two decimal places and then click decrease deecimal twice to make them all regular whole numbers.

![SET to numbers excel](https://github.com/blyonscs/Spotify-SQL-Data-Analysis-Project/blob/main/Spotify_Pictures_Readme/Numbers_Excel.png)
![DECREASE decimal places twice](https://github.com/blyonscs/Spotify-SQL-Data-Analysis-Project/blob/main/Spotify_Pictures_Readme/Decrease_Decimal_Excel.png)

When importing the dataset we are still getting errors from it, this is because the escape character is set to ', which is used in the Artist, Track, Album and Channel columns. To get rid of this error set the escape character to " and there should be no more errors when importing the data. To do this go to the options when importing the data.

![SET escape character](https://github.com/blyonscs/Spotify-SQL-Data-Analysis-Project/blob/main/Spotify_Pictures_Readme/Escape_Char_SQL.png)

### 2. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

###  3. Data Cleaning in SQL
Removing Duplicate Data and making sure that the data is complete and consistant with what we are suppose to be looking at is very important. We want the data to point us in the right direction and not to get bias or wrong data from it so doing this is needed before querying the data for insights. Only two records were removed because the duration of the song was 0, but the data was also checked to make sure there were not any NULL values where there should not have been.

### 3. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping and aggregation functions.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT stream, track, artist
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC;
```
2. List all albums along with their respective artists.
```sql
SELECT DISTINCT(album), artist
FROM spotify
ORDER BY artist;
```
3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT SUM(comments) AS licensed_comments
FROM spotify
WHERE licensed = 'true';
```
4. Find all tracks that belong to the album type `single`.
```sql
SELECT * 
FROM spotify
WHERE album_type = 'single'; --or ILIKE to check also
```
5. Count the total number of tracks by each artist.
```sql
SELECT COUNT(track) AS tracks, artist
FROM spotify
GROUP BY artist
ORDER BY tracks ASC;
```
### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
SELECT album, AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;
```
2. Find the top 5 tracks with the highest energy values.
```sql
SELECT  track, MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT track, 
	SUM(views) AS total_views, 
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;
```
4. For each album, calculate the total views of all associated tracks.
```sql
SELECT album, SUM(views) AS total_album_views
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT * FROM
(SELECT track, --most_played_on, 
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
FROM spotify
GROUP BY 1) AS t1
WHERE streamed_on_spotify > streamed_on_youtube
AND streamed_on_youtube <> 0
ORDER BY streamed_on_spotify DESC;
```
### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```
3. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT track, artist, liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```
4. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
WITH cte
AS
(SELECT artist,
	track,
	energy,
	liveness,
	ROUND((energy/liveness)::numeric, 2) AS track_ratio -- rounding to two dec for the ratio
FROM spotify
)
SELECT artist,
	track,
	track_ratio
FROM cte
WHERE track_ratio > 1.2
ORDER BY track_ratio DESC;
--18782 total tracks over the 1.2 ratio
```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT track, likes, views, 
SUM(likes) OVER (ORDER BY views DESC) AS total_sum
FROM spotify
ORDER BY 3 DESC;
```


---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Subqueries, Window Functions
- **Tools**: pgAdmin 4, PostgreSQL and visualization with Tableau

## How to Run the Project
1. Install PostgreSQL and pgAdmin (if not already installed).
2. Set up the database table with the sample data (from Kaggle).
3. Use data exploration to better understand the given data and all the fields
4. Execute SQL queries to solve the listed problems.
5. Explore query optimization techniques for large datasets.

---
## Visualizations With Cleaned Dataset
  ![Visualization](https://github.com/blyonscs/Spotify-SQL-Data-Analysis-Project/blob/main/Spotify_Tableau.png)
- Link to it: https://public.tableau.com/app/profile/brandon.lyons/viz/SpotifyDashboard_17357892755210/Dashboard1


## License
This project is licensed under the MIT License.
