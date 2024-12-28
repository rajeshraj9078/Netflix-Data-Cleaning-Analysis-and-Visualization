-- Create table with corrected column names
CREATE TABLE projects.netflix (
    Id VARCHAR(50) PRIMARY KEY,
    Content_type VARCHAR(255),  
    Title VARCHAR(255),
    Director VARCHAR(255),
    Country VARCHAR(255),
    Date_added VARCHAR(255),
    Release_year INT,
    Rating VARCHAR(100),        
    Duration VARCHAR(50),        
    Listed_in VARCHAR(255)      
);

-- Retrieve all data from the table
SELECT * FROM projects.netflix;

-- Group by 'Id' and count occurrences (although Id should be unique, this can still show counts)
SELECT Id, COUNT(*) 
FROM projects.netflix 
GROUP BY Id 
ORDER BY Id DESC;

-- Count null values for each column in the 'projects.netflix' table (PostgreSQL version)
SELECT 
    COUNT(*) FILTER (WHERE Id IS NULL) AS id_nulls,
    COUNT(*) FILTER (WHERE Content_type IS NULL) AS content_type_nulls,
    COUNT(*) FILTER (WHERE Title IS NULL) AS title_nulls,
    COUNT(*) FILTER (WHERE Director IS NULL) AS director_nulls,
    COUNT(*) FILTER (WHERE Country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE Date_added IS NULL) AS date_added_nulls,
    COUNT(*) FILTER (WHERE Release_year IS NULL) AS release_year_nulls,
    COUNT(*) FILTER (WHERE Rating IS NULL) AS rating_nulls,
    COUNT(*) FILTER (WHERE Duration IS NULL) AS duration_nulls,
    COUNT(*) FILTER (WHERE Listed_in IS NULL) AS listed_in_nulls
FROM projects.netflix;

-- CTE to concatenate 'Director' and 'Movie Cast' (make sure 'movie_cast' column exists in your table)
WITH cte AS (
    SELECT Title, CONCAT(Director, '---', movie_cast) AS director_cast 
    FROM projects.netflix
)
SELECT director_cast, COUNT(*) AS count
FROM cte
GROUP BY director_cast
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- Update director where 'movie_cast' is 'David Attenborough' and 'director' is NULL
UPDATE projects.netflix 
SET Director = 'Alastair Fothergill'
WHERE movie_cast = 'David Attenborough' AND Director IS NULL;

-- Update 'Country' where it is NULL
UPDATE projects.netflix 
SET Country = 'Not Given'
WHERE Country IS NULL;

-- Select rows where 'Date_added' is NULL
SELECT show_id, Date_added
FROM projects.netflix
WHERE Date_added IS NULL;

-- Delete specific rows from 'projects.netflix' by 'show_id'
DELETE FROM projects.netflix
WHERE Id IN ('6797', 's6067', 's6175', 's6807', 's6902', 's7255', 's7197', 's7407', 's7848', 's8183');

-- Select rows with NULL 'Date_added' after cleaning
SELECT show_id, Rating
FROM projects.netflix
WHERE Date_added IS NULL;

-- Delete rows where 'Rating' is NULL
DELETE FROM projects.netflix 
WHERE Id IN (SELECT Id FROM projects.netflix WHERE Rating IS NULL)
RETURNING *;

-- Delete rows where 'Duration' is NULL
DELETE FROM projects.netflix 
WHERE Id IN (SELECT Id FROM projects.netflix WHERE Duration IS NULL);

-- Count non-null values across all columns
SELECT 
    COUNT(*) FILTER (WHERE Id IS NOT NULL) AS showid_non_nulls,
    COUNT(*) FILTER (WHERE Content_type IS NOT NULL) AS type_non_nulls,
    COUNT(*) FILTER (WHERE Title IS NOT NULL) AS title_non_nulls,
    COUNT(*) FILTER (WHERE Director IS NOT NULL) AS director_non_nulls,
    COUNT(*) FILTER (WHERE Country IS NOT NULL) AS country_non_nulls,
    COUNT(*) FILTER (WHERE Date_added IS NOT NULL) AS date_added_non_nulls,
    COUNT(*) FILTER (WHERE Release_year IS NOT NULL) AS release_year_non_nulls,
    COUNT(*) FILTER (WHERE Rating IS NOT NULL) AS rating_non_nulls,
    COUNT(*) FILTER (WHERE Duration IS NOT NULL) AS duration_non_nulls,
    COUNT(*) FILTER (WHERE Listed_in IS NOT NULL) AS listed_in_non_nulls
FROM projects.netflix;

-- Drop unnecessary columns from the table (ensure these columns exist)
ALTER TABLE projects.netflix
DROP COLUMN movie_cast, 
DROP COLUMN description;

-- Split 'Country' column into multiple parts (PostgreSQL syntax)
SELECT *,
       SPLIT_PART(Country, ',', 1) AS country1, 
       SPLIT_PART(Country, ',', 2) AS country2,
       SPLIT_PART(Country, ',', 3) AS country3,
       SPLIT_PART(Country, ',', 4) AS country4,
       SPLIT_PART(Country, ',', 5) AS country5,
       SPLIT_PART(Country, ',', 6) AS country6,
       SPLIT_PART(Country, ',', 7) AS country7,
       SPLIT_PART(Country, ',', 8) AS country8,
       SPLIT_PART(Country, ',', 9) AS country9,
       SPLIT_PART(Country, ',', 10) AS country10
FROM projects.netflix;

-- Update the 'Country' column by splitting it
ALTER TABLE projects.netflix 
ADD country1 VARCHAR(500);

UPDATE projects.netflix 
SET country1 = SPLIT_PART(Country, ',', 1);

-- Drop the old 'Country' column and rename the new one
ALTER TABLE projects.netflix 
DROP COLUMN Country;

ALTER TABLE projects.netflix 
RENAME COLUMN country1 TO Country;

-- Update 'Director' to 'Not Given' where it is NULL
UPDATE projects.netflix 
SET Director = 'Not Given'
WHERE Director IS NULL;

-- Use COALESCE to update 'Country' for rows where it is NULL, based on matching 'Director'
SELECT COALESCE(nt.Country, nt2.Country) 
FROM projects.netflix AS nt
JOIN projects.netflix AS nt2 
ON nt.Director = nt2.Director 
AND nt.Id <> nt2.Id
WHERE nt.Country IS NULL;

UPDATE projects.netflix
SET Country = nt2.Country
FROM projects.netflix AS nt2
WHERE projects.netflix.Director = nt2.Director 
AND projects.netflix.Id <> nt2.Id
AND projects.netflix.Country IS NULL;

-- Select rows with NULL 'Country'
SELECT Director, Country, Date_added
FROM projects.netflix
WHERE Country IS NULL;

-- Final update to set 'Country' as 'Not Given' where NULL
UPDATE projects.netflix 
SET Country = 'Not Given'
WHERE Country IS NULL;
