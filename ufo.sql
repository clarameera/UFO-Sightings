
/*The following script is broken into 4 sections:
 * 	- SET-UP AND CLEAN 
 * 	- EXPLORATORY DATA ANALYSIS with us_ufo
 *  - SET-UP AND CLEAN MOVIES DATASET 
 *  - EXPLORATORY DATA ANALYSIS with us_ufo AND hit_alien_movies
 * 	- */ 

--SET-UP AND CLEAN----------------------------------------------------------------------------------------

--first, create copy of ufo_raw, call if ufo
CREATE TABLE ufo AS
SELECT * FROM ufo_raw;

--look at data 
SELECT *
FROM ufo;

--HANDLE NULL VALUES
----------------------

--look at number of null values 
SELECT 
COUNT(CASE WHEN state IS NULL THEN 1 END) AS null_state,
COUNT(CASE WHEN country IS NULL THEN 1 END) AS null_country,
COUNT(CASE WHEN shape IS NULL THEN 1 END) AS shape
FROM ufo;

--drop sightings where country AND state are NULL (not enough info for our purposes)
DELETE FROM ufo
WHERE country IS NULL and state IS NULL;

--ADJUST DATA TYPES
----------------------

--change 'date posted' to date type, add separate date and time columns
ALTER TABLE ufo 
ALTER COLUMN "date posted" TYPE date,
ADD date DATE,
ADD time TEXT;

--set new date and time columns by splitting datetime 
UPDATE ufo
SET date = TO_DATE(substring(datetime FROM 1 FOR 10), 'mm/dd/YYYY'),
 	time = substring(datetime FROM 11 FOR 6);

--CLEAN WHITESPACE
----------------------

--check each column for whitespace
SELECT COUNT(*) AS rows_with_whitespace
FROM ufo
WHERE datetime != TRIM(datetime)
   OR city != TRIM(city)
   OR state != TRIM(state)
   OR country != TRIM(country)
   OR shape != TRIM(shape)
   OR ("duration (hours/min)") != TRIM("duration (hours/min)")
   OR comments != TRIM(comments)
   OR time != TRIM(time);

--new 'time' column has a lot of white space. clean up: 
UPDATE ufo
SET time = TRIM(time)
WHERE time != TRIM(time);

-- CLEAN COMMENTS
----------------------
-- look for html codes
SELECT "comments"
FROM ufo
WHERE "comments" LIKE '%&#%';
-- update each html entity to corresponding character
UPDATE ufo
SET "comments" = REPLACE("comments", '&#44', ',')
WHERE "comments" LIKE '%&#44%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#39', '''')
WHERE "comments" LIKE '%&#39%';

UPDATE ufo 
SET "comments" = REPLACE("comments", '&#8217;', '''')
WHERE "comments" LIKE '%&#8217%'

UPDATE ufo
SET "comments" = REPLACE("comments", '&#33', '!')
WHERE "comments" LIKE '%&#33%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#8212;', '--')
WHERE "comments" LIKE '%&#8212%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#8226;&#9;', '')
WHERE "comments" LIKE '%&#8226;&#9;%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#8230;', '...')
WHERE "comments" LIKE '%&#8230%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#160;', ' ')
WHERE "comments" LIKE '%&#160%';

UPDATE ufo
SET "comments" = REPLACE("comments", '&#9;', '')
WHERE "comments" LIKE '&#9%';
UPDATE ufo
SET "comments" = REPLACE("comments", '&#9;', ' ')
WHERE "comments" LIKE '%&#9%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#8220;', '"')
WHERE "comments" LIKE '%&#8220;%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#8221;', '"')
WHERE "comments" LIKE '%&#8221;%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#186;', '')
WHERE "comments" LIKE '%&#186%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#8211;', '-')
WHERE "comments" LIKE '%&#8211%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#8216;', '''')
WHERE "comments" LIKE '%&#8216%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#176;', ' degrees')
WHERE "comments" LIKE '%&#176%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#180;', '''')
WHERE "comments" LIKE '%&#180%';

UPDATE ufo
SET "comments" = REPLACE(comments, '&#182;', '''')
WHERE "comments" LIKE '%&#182%';

SELECT comments, REPLACE(comments, '&#182;', '') AS cleaned_comments
FROM ufo
WHERE comments LIKE '%&#182%';



--CREATE 'us_ufo' TABLE
--For this analysis, I just want to look at US data. 
--Before simply selecting all 'us' sightings, get entries with missing country value. Could US sightings be hiding there?
SELECT *
FROM ufo
WHERE country IS NULL
ORDER BY state;

--First state in result is 'ab', which appears to refer to Alberta, Canada 
--To find just US sightings for entries where country is NULL, but state value is present, check each state against list of US states. 
--If state matches a state in list of US states, set country to 'us':
UPDATE ufo 
SET country = 'us'
WHERE country IS NULL 
--list include 50 states, DC, PR (Puerto Rico)
AND UPPER(state) IN (
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY');

--drop all null country entries without fear of losing US sightings, since they've all been relabeled 
DELETE FROM ufo
WHERE country IS NULL;

--create us_ufo table
CREATE TABLE us_ufo AS 
SELECT *
FROM ufo
WHERE country = 'us';


--LOOK AT DUPLICATES
--check for datetime/city duplicates: sightings that are the same time, place. Is this an error, or multiple people reporting the same incident?
SELECT city, datetime, COUNT(*), state, "date posted"
FROM us_ufo
GROUP BY datetime, city, state, "date posted"
HAVING COUNT(datetime) > 1 
ORDER BY COUNT(*) DESC;
--tinely park, halloween 2004, 8pm: 14 reports posted 2 days later on 11/02
--look at all 14 reports from that night:
SELECT *
FROM us_ufo
WHERE
	city = 'tinley park'
	AND 
	datetime = '10/31/2004 20:00'
	AND 
	"date posted" = '2004-11-02';
--they're not exact copies. Comments are different, but similar. Most describe 3 red lights
--datetime/city duplicates are not erroneous, but multiple distinct reports of one event 


--instead, check for complete duplicates
SELECT
	datetime,
	city,
	state,
	country,
	shape,
	"duration (seconds)",
	"duration (hours/min)",
	COMMENTS,
	"date posted",
	latitude,
	COUNT(*)
FROM
	us_ufo
GROUP BY
	datetime,
	city,
	state,
	country,
	shape,
	"duration (seconds)",
	"duration (hours/min)",
	COMMENTS,
	"date posted",
	latitude
HAVING
	COUNT(*) > 1;
--returns nothing

--EXPLORATORY DATA ANALYSIS with 'us_ufo'----------------------------------------------------------------------------------------


-- 1. How does the number of sightings change over the decades?
---------------------- 

--view sightings per decade: 
SELECT EXTRACT(YEAR FROM sighting_date)::INT/10 * 10 AS decade,
       COUNT(*) AS sightings
FROM us_ufo
GROUP BY decade
ORDER BY decade;

-- 2. What are the TOP 10 STATES with most sightings in the 1990s? 
----------------------

SELECT state AS top_states, COUNT(*) AS ninties_sightings
FROM us_ufo
WHERE sighting_date BETWEEN '1990-1-1' AND '1999-12-31'
GROUP BY state
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 3. What UFO shape has the most sightings overall? 
----------------------

SELECT COUNT(*), shape
FROM us_ufo
GROUP BY shape
ORDER BY COUNT(*) DESC;
--ANSWER: light is the most recorded shape with 14,644 sightings

-- 4. What was the most common shape EACH YEAR? 
----------------------

--CTE 1: extract year AS sighting_year, group by shape and year
WITH shape_per_year AS (
	SELECT EXTRACT(YEAR FROM sighting_date) AS sighting_year,
         shape,
         COUNT(*) AS shape_sightings
	FROM us_ufo
	WHERE shape IS NOT NULL AND shape NOT LIKE 'unknown' AND shape NOT LIKE 'other'
	GROUP BY sighting_year, shape
	ORDER BY sighting_year
	),
--CTE 2: partitions by sighting_year, ranks by #sightings
ranked AS(
		SELECT *, 
		RANK() OVER(PARTITION BY sighting_year ORDER BY shape_sightings DESC) AS rank
		FROM shape_per_year)
--select top ranking shape for each year and it's number fo sightings
SELECT sighting_year, shape AS top_shape, shape_sightings, rank
FROM ranked 
WHERE RANK = 1
ORDER BY sighting_year DESC;

-- 5. What month has had the most UFO sightings? 
----------------------

SELECT 
	EXTRACT(MONTH FROM sighting_date) AS sighting_month, count(*)
FROM us_ufo
GROUP BY sighting_month
ORDER BY count(*) DESC;
--ANSWER: July has had the most recorded sightings with 8,417 since 1910


-- 6. Do encounters tend to be longer or shorter than 3 minutes?
----------------------

SELECT COUNT(*) AS number_of_sightings,
	CASE WHEN "duration (seconds)" > 300 THEN 'Over Three Minutes'
		 WHEN "duration (seconds)" < 300 THEN 'Under Three Minutes'
		 ELSE 'Exactly Three Minutes'
		 END AS length_of_encounter
FROM us_ufo
GROUP BY length_of_encounter 
ORDER BY number_of_sightings DESC;
--ANSWER: Most (39,254 out of 70,927) encounters are under 3 minutes


--SET-UP AND CLEAN MOVIES DATASET----------------------------------------------------------------------------------------

--create movies table, import csv
CREATE TABLE movies (
    Release_Date VARCHAR,
    Title VARCHAR,
    Overview VARCHAR,
    Popularity FLOAT,
    Vote_Count VARCHAR,
    Vote_Average VARCHAR,
    Original_Language VARCHAR,
    Genre VARCHAR,
    Poster_Url VARCHAR);

--create alien_movies table from movies table
CREATE TABLE alien_movies AS
SELECT *
FROM movies
WHERE overview LIKE '%alien%'
OR overview LIKE '%extraterrestrial%';

--drop language column
ALTER TABLE alien_movies 
DROP COLUMN original_language;

--alter data types: vote_count, vote_average, release_date
ALTER TABLE alien_movies 
ALTER COLUMN vote_count TYPE float USING vote_count::REAL,
ALTER COLUMN vote_average TYPE float USING ROUND(vote_average:: numeric, 1),
ALTER COLUMN release_date TYPE date USING release_date::date;


--EXPLORATORY DATA ANALYSIS with 'us_ufo' AND 'alien_movies'----------------------------------------------------------------------------------------

--How many sightings occurred within 30 days of a given movie's release?
----------------------

--change column name to 'sighting_date' for clarity
ALTER TABLE us_ufo 
RENAME COLUMN date TO sighting_date;
--limit alien_movies list by vote_count and popularity before joining to us_ufo
CREATE VIEW hit_alien_movies AS
SELECT *
FROM alien_movies
WHERE vote_count > 700;

--INNER JOIN hit_alien_movies to us_ufo, count sightings within 30 days after movie release date
SELECT
	m.title,
	m.release_date,
	COUNT(*) AS sightings_within_30_days
FROM us_ufo AS u
INNER JOIN hit_alien_movies AS m
ON
	u.sighting_date BETWEEN m.release_date AND m.release_date + 30
GROUP BY
	m.title,
	m.release_date
ORDER BY
	sightings_within_30_days DESC;

--For any given movie, what was the top shape sighted during the year of it's release?
----------------------

--create table with top shape for each year
CREATE TABLE top_shape_by_year AS
WITH shape_per_year AS (
	SELECT EXTRACT(YEAR FROM sighting_date) AS sighting_year,
         shape,
         COUNT(*) AS shape_sightings
	FROM us_ufo
	WHERE shape IS NOT NULL AND shape NOT LIKE 'unknown' AND shape NOT LIKE 'other'
	GROUP BY sighting_year, shape
	ORDER BY sighting_year
	),
ranked AS (
		SELECT *, 
		RANK() OVER(PARTITION BY sighting_year ORDER BY shape_sightings DESC) AS rank
		FROM shape_per_year) 
SELECT sighting_year, shape AS top_shape
FROM ranked 
WHERE RANK = 1
ORDER BY sighting_year DESC;

--inner join top_shape_per_year with hit_alien_movies to see top shape for each movie/release year
SELECT m.title, s.sighting_year, s.top_shape
FROM top_shape_by_year AS s
INNER JOIN hit_alien_movies AS m
ON s.sighting_year = EXTRACT(YEAR FROM m.release_date)
ORDER BY s.sighting_year;


--More exploration to be done in Tableau...




  
 