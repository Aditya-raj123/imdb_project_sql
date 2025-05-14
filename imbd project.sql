CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;

SELECT COUNT(*) FROM names_table;
SELECT COUNT(*) FROM ratings_table;
SELECT COUNT(*) FROM movies_table;
SELECT COUNT(*) FROM genres_table;
SELECT COUNT(*) FROM role_mapping_table;

-- Q1. Count of rows in each table
-- Expected Output:
-- +------------------+------------+
-- | table_name       | row_count  |
-- +------------------+------------+
-- | movies_table     | 10000      |
-- | genres_table     | 9500       |
-- | ratings_table    | 10000      |
-- | names_table      | 8500       |
-- | role_mapping     | 16000      |
-- +------------------+------------+

SELECT table_name,table_rows AS row_count
FROM information_schema.tables
WHERE table_schema ='imdb';

-- Q2. Identify columns with NULLs in movies_table
-- Expected Output:
-- +-----------------------+
-- | column_with_nulls     |
-- +-----------------------+
-- | production_company     |
-- | gross_income_usd       |
-- +-----------------------+

SELECT * 
FROM movies_table;

SELECT COLUMN_NAME AS column_with_null
FROM information_schema.columns
WHERE table_name ='movies_table'
AND table_schema ='imdb'
AND is_nullable = 'YES';


-- Q3. Movies released per year
-- Expected Output:
-- +------+------------------+
-- | year | number_of_movies |
-- +------+------------------+
-- | 2017 | 1300             |
-- | 2018 | 1700             |
-- +------+------------------+

SELECT year,COUNT(*) AS number_of_movies
FROM movies_table
GROUP BY year
ORDER BY year;

-- Q4. Movies per month
-- Expected Output:
-- +------------+------------------+
-- | month_num  | number_of_movies |
-- +------------+------------------+
-- | 1          | 125              |
-- | 2          | 118              |
-- +------------+------------------+

SELECT 
	MONTH(STR_TO_DATE(date_published,'%Y-%m-%d')) AS month_num,
    COUNT(*) AS number_of_movies
    FROM movies_table
WHERE MONTH(STR_TO_DATE(date_published,'%Y-%m-%d')) IS NOT NULL
GROUP BY month_num
ORDER BY month_num;

-- Q5. Movies from USA or India in 2019
-- Expected Output:
-- +---------+
-- | count   |
-- +---------+
-- | 1245    |
-- +---------+

SELECT COUNT(*) AS count
FROM movies_table
WHERE country IN ('United States','India') AND Year = 2019;


-- Q6. Unique genres
-- Expected Output:
-- +---------+
-- | genre   |
-- +---------+
-- | Drama   |
-- | Comedy  |
-- +---------+

WITH RECURSIVE genre_split AS(
		SELECT 
			movie_id,
            TRIM(SUBSTRING_INDEX(genres,',',1)) AS genre,
            SUBSTRING(genres,LENGTH(SUBSTRING_INDEX(genres,',',1))+ 2) AS remaining
		FROM genres_table
        UNION ALL
		SELECT 
			movie_id,   
            TRIM(SUBSTRING_INDEX(remaining,',',1)) AS genre,
            SUBSTRING(remaining,LENGTH(SUBSTRING_INDEX(remaining,',',1))+2)
            FROM genre_split
            WHERE remaining !=''
)
SELECT DISTINCT genre
FROM  genre_split
WHERE genre IS NOT NULL
ORDER BY genre;

-- Q7. Genre with most movies
-- Expected Output:
-- +---------+---------------+
-- | genre   | movie_count   |
-- +---------+---------------+
-- | Drama   | 3050          |
-- +---------+---------------+

WITH RECURSIVE genre_split AS(
		SELECT 
			movie_id,
            TRIM(SUBSTRING_INDEX(genres,',',1)) AS genre,
            SUBSTRING(genres,LENGTH(SUBSTRING_INDEX(genres,',',1))+ 2) AS remaining
		FROM genres_table
        UNION ALL
		SELECT 
			movie_id,   
            TRIM(SUBSTRING_INDEX(remaining,',',1)) AS genre,
            SUBSTRING(remaining,LENGTH(SUBSTRING_INDEX(remaining,',',1))+2)
            FROM genre_split
            WHERE remaining !=''
)
SELECT genre,COUNT(DISTINCT movie_id) AS movie_count
FROM genre_split
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

-- Q8. Movies with only one genre
-- Expected Output:
-- +----------+
-- | count    |
-- +----------+
-- | 3125     |
-- +----------+

SELECT COUNT(*) AS count
FROM genres_table
WHERE genres NOT LIKE '%,%';

-- Q9. Average movie duration per genre
-- Expected Output:
-- +---------+------------------+
-- | genre   | avg_duration     |
-- +---------+------------------+
-- | Drama   | 107.2            |
-- | Action  | 112.8            |
-- +---------+------------------+

WITH number AS(
	SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
),

genre_duration AS (
	SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(g.genres,',',n.n),',',-1)) AS genre,
    m.duration_in_mins
    FROM genres_table g
    JOIN movies_table m ON g.movie_id = m.movie_id
    JOIN number n ON n.n <=1 + LENGTH(g.genres) - LENGTH(REPLACE(g.genres,',',''))
)

SELECT genre,ROUND(AVG(duration_in_mins),1) AS avg_duration
FROM genre_duration
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY avg_duration DESC;

-- Q10. Rank of 'thriller' genre by movie count
-- Expected Output:
-- +----------+-------------+-------------+
-- | genre    | movie_count | genre_rank  |
-- +----------+-------------+-------------+
-- | Thriller | 2050        | 3           |
-- +----------+-------------+-------------+

WITH genre_movie_counts AS(
	SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(g.genres,',',n.n),',',-1)) AS genre,
    COUNT(m.movie_id) AS movie_count
    FROM movies_table m
    JOIN genres_table g ON m.movie_id = g.movie_id
    JOIN(SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7)
    WHERE n.n <=LENGTH(g.genres) - LENGTH(REPLACE(g.genres,',','')) + 1
    GROUP BY genre    
)

SELECT 
	genre,
    movie_count,
    RANK() OVER(ORDER  BY movie_count DESC) AS genre_rank
    FROM genre_movie_counts
    WHERE genre = 'Thriller';

-- Q11. Min/Max from ratings_table
-- Expected Output:
-- +----------------+----------------+----------------+----------------+
-- | min_avg_rating | max_avg_rating | min_votes      | max_votes      |
-- +----------------+----------------+----------------+----------------+
-- | 0.0            | 9.8            | 100            | 98000          |
-- +----------------+----------------+----------------+----------------+

SELECT 
MIN(avg_rating) AS min_avg_rating,
MAX(avg_rating) AS max_avg_rating,
MIN(num_of_votes) AS min_votes,
MAX(num_of_votes) AS max_votes
FROM ratings_table;

-- Q12. Top 10 movies by avg rating
-- Expected Output:
-- +---------------------+-------------+-------------+
-- | movie_name          | avg_rating  | movie_rank  |
-- +---------------------+-------------+-------------+
-- | The Dark Knight     | 9.8         | 1           |
-- | Parasite            | 9.6         | 2           |
-- +---------------------+-------------+-------------+

SELECT 
m.movie_name,
r.avg_rating,
	RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM movies_table m
JOIN ratings_table r ON m.movie_id = r.movie_id
ORDER BY movie_rank
LIMIT 10;

-- Q13. Movie counts by median rating
-- Expected Output:
-- +---------------+--------------+
-- | median_rating | movie_count |
-- +---------------+--------------+
-- | 7             | 3000         |
-- | 6             | 2500         |
-- +---------------+--------------+

SELECT 
r.avg_rating,
COUNT(*) AS movie_count
FROM ratings_table r
GROUP BY r.avg_rating
ORDER BY movie_count DESC;

-- Q14. Production house with max hit movies (>8 avg rating)
-- Expected Output:
-- +------------------------+--------------+------------------+
-- | production_company     | movie_count  | prod_company_rank|
-- +------------------------+--------------+------------------+
-- | Dream Warrior Pictures| 9            | 1                |
-- +------------------------+--------------+------------------+

SELECT 
m.production_company,
COUNT(m.movie_id) AS movie_count,
RANK() OVER(ORDER BY COUNT(m.movie_id) DESC) AS prod_comapny_rank
FROM movies_table m
JOIN ratings_table r ON m.movie_id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY movie_count DESC
LIMIT 2;

-- Q15. March 2017 USA genre-wise movies with >1000 votes
-- Expected Output:
-- +----------+--------------+
-- | genre    | movie_count  |
-- +----------+--------------+
-- | Action   | 15           |
-- +----------+--------------+

SELECT
    g.genres AS genre,
    COUNT(DISTINCT m.movie_id) AS movie_count
FROM movies_table m
JOIN ratings_table r ON m.movie_id = r.movie_id
JOIN genres_table g ON m.movie_id = g.movie_id
WHERE m.country = 'United States'
    AND STR_TO_DATE(m.date_published, '%Y-%m-%d') 
        BETWEEN '2017-03-01' AND '2017-03-31'
    AND r.num_of_votes > 100
GROUP BY g.genres
ORDER BY movie_count DESC;

-- Q16. Genre-wise movies starting with 'The' and avg_rating > 8
-- Expected Output:
-- +------------------+-------------+--------+
-- | movie_name       | avg_rating  | genre  |
-- +------------------+-------------+--------+
-- | The Pianist      | 8.7         | Drama  |
-- +------------------+-------------+--------+

SELECT
    m.movie_name,
    r.avg_rating,
    g.genres
FROM movies_table m
JOIN ratings_table r ON m.movie_id = r.movie_id
JOIN genres_table g ON m.movie_id = g.movie_id
WHERE m.movie_name LIKE 'The%' 
    AND r.avg_rating > 8
ORDER BY g.genres;

-- Q17. Movies released between 1-Apr-2018 and 1-Apr-2019 with average rating = 8
-- Expected Output:
-- +----------+
-- | count    |
-- +----------+
-- | 42       |
-- +----------+

WITH movie_ratings AS (
    SELECT
        r.avg_rating,
        m.movie_id
    FROM movies_table m
    JOIN ratings_table r ON m.movie_id = r.movie_id
    WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
)
SELECT COUNT(*) AS count
FROM movie_ratings
WHERE avg_rating = 8;


-- 18 Expected Output:
-- +----------+----------+------------------+
-- | country1 | country2 | more_votes       |
-- +----------+----------+------------------+
-- | German   | Italian  | Gn  erma         |
-- +----------+----------+------------------+

SELECT
    'German' AS country1,
    'Italian' AS country2,
    CASE 
        WHEN SUM(CASE WHEN m.country = 'Germany' THEN r.num_of_votes ELSE 0 END) > 
             SUM(CASE WHEN m.country = 'Italy' THEN r.num_of_votes ELSE 0 END)
        THEN 'German'
        ELSE 'Italian'
    END AS more_votes
FROM movies_table m
JOIN ratings_table r ON m.movie_id = r.movie_id
WHERE m.country IN ('Germany', 'Italy');

-- Q19. Columns with nulls in names_table
-- Expected Output:
-- +--------------+---------------+----------------+------------------------+
-- | name_nulls   | birth_years   | death_years    | known_for_movies_nulls|
-- +--------------+---------------+----------------+------------------------+
-- | 0            | 213           | 1350           | 3212                   |
-- +--------------+---------------+----------------+------------------------+

SELECT
    COUNT(CASE WHEN name IS NULL THEN 1 END) AS name_nulls,
    COUNT(CASE WHEN birth_year IS NULL THEN 1 END) AS birth_years,
    COUNT(CASE WHEN death_year IS NULL THEN 1 END) AS death_years,
    COUNT(CASE WHEN known_for_movies IS NULL THEN 1 END) AS known_for_movies_nulls
FROM names_table;

-- Q20. Top 3 directors in top 3 genres with avg_rating > 8
-- Expected Output:
-- +------------------+--------------+
-- | director_name    | movie_count  |
-- +------------------+--------------+
-- | James Cameron    | 5            |
-- +------------------+--------------+

WITH genre_counts AS (
    SELECT
        g.genres,
        COUNT(*) AS genre_count
    FROM genres_table g
    JOIN ratings_table r ON g.movie_id = r.movie_id
    WHERE r.avg_rating > 8
    GROUP BY g.genres
    ORDER BY genre_count DESC
    LIMIT 3
),
top_directors AS (
    SELECT
        nm.name AS director_name,
        g.genres,
        COUNT(*) AS movie_count
    FROM movies_table m
    JOIN ratings_table r ON m.movie_id = r.movie_id
    JOIN genres_table g ON m.movie_id = g.movie_id
    JOIN role_mapping_table rm ON m.movie_id = rm.movie_id
    JOIN names_table nm ON rm.name_id = nm.name_id
    WHERE rm.category = 'director'
      AND r.avg_rating > 8
      AND g.genres IN (SELECT genres FROM genre_counts)
    GROUP BY nm.name, g.genres
)
SELECT
    director_name,
    SUM(movie_count) AS movie_count
FROM top_directors
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;


































