-- 05 VACCINATIONS ANALYSIS 
-- Analysis of total and new vaccinations

-- Weekly measures for vaccinations and people vaccinated are required for consistent time measures across analyses 

-- Countries' weekly and daily vaccinations and people vaccinated 
WITH row_nums AS (
	SELECT
		location,
		date,
		daily_vaccinations,
		daily_people_vaccinated,
		ROUND(((ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) + 3) / 7), 0) AS week_num
	FROM CovidProject.CovidData
)
SELECT
	location,
    date,
    daily_vaccinations,
    daily_people_vaccinated,
	ROUND(IFNULL(SUM(daily_vaccinations) OVER (
		PARTITION BY location, week_num
	), 0), 0) AS weekly_vaccinations,
    ROUND(IFNULL(SUM(daily_people_vaccinated) OVER (
		PARTITION BY location, week_num
	), 0), 0) AS weekly_people_vaccinated
FROM row_nums
ORDER BY location, date;
-- This solution is better than partitioning over the week and year, as this is not affected by the change of the year

-- Create new columns in data table
ALTER TABLE CovidProject.CovidData
ADD COLUMN weekly_vaccinations FLOAT,
ADD COLUMN weekly_people_vaccinated FLOAT;

-- Insert weekly people vaccinated data into new columns
WITH weekly_data AS (
    WITH row_nums AS (
		SELECT
			location,
			date,
			daily_vaccinations,
			daily_people_vaccinated,
			ROUND(((ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) + 3) / 7), 0) AS week_num
		FROM CovidProject.CovidData
	)
	SELECT
		location,
		date,
		daily_vaccinations,
		daily_people_vaccinated,
		ROUND(IFNULL(SUM(daily_vaccinations) OVER (
			PARTITION BY location, week_num
		), 0), 0) AS weekly_vaccinations,
		ROUND(IFNULL(SUM(daily_people_vaccinated) OVER (
			PARTITION BY location, week_num
		), 0), 0) AS weekly_people_vaccinated
	FROM row_nums
	ORDER BY location, date
)
UPDATE CovidProject.CovidData cd
JOIN weekly_data w
	ON cd.location = w.location
		AND cd.date = w.date
SET cd.weekly_vaccinations = w.weekly_vaccinations,
	cd.weekly_people_vaccinated = w.weekly_people_vaccinated;



-- 1a. Global total vaccinations, people vaccinated, population and perecent of the population that has been vaccinated
SELECT 
	SUM(daily_vaccinations) AS total_vaccinations,
    SUM(daily_people_vaccinated) AS people_vaccinated,
    SUM(DISTINCT population) AS population,
    ROUND(SUM(daily_people_vaccinated)/ SUM(DISTINCT population) * 100, 4) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania');

-- Verify numbers
SELECT 
	SUM(daily_vaccinations) AS total_vaccinations,
    SUM(daily_people_vaccinated) AS people_vaccinated,
	MAX(population) AS population,
    ROUND(SUM(daily_people_vaccinated)/MAX(population) * 100, 4) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location = 'World';

SELECT 
	MAX(total_vaccinations) AS total_vaccinations,
    MAX(people_vaccinated) AS people_vaccinated,
	MAX(population) AS population,
	ROUND(MAX(people_vaccinated)/MAX(population) * 100, 4) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location = 'World'
GROUP BY population;
-- Again, not entirely consistent, possibly due to last recorded date differing for some countries

-- 1b. Global weekly vaccinations and people vaccinated
SELECT 
	date,
	SUM(weekly_vaccinations) AS weekly_vaccinations,
    SUM(weekly_people_vaccinated) AS weekly_people_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY date
ORDER BY date;



-- 2. Contients' total vaccinations, people vaccinated and percent population vaccinated
SELECT 
    location,
    population,
    MAX(total_vaccinations) AS total_vaccinations,
    MAX(people_vaccinated) AS people_vaccinated,
    ROUND(MAX(people_vaccinated)/population * 100, 4) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location IN (
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location, population
ORDER BY percent_people_vaccinated DESC;



-- 3. Countries' weekly vaccinations, people vaccinated and percent population vaccinated
WITH row_nums AS (
	SELECT
		location,
		date,
        population,
        weekly_vaccinations,
		weekly_people_vaccinated,
		ROUND(weekly_people_vaccinated/population * 100, 4) AS percent_people_vaccinated,
		ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS day_num
	FROM CovidProject.CovidData
    WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
    ORDER BY location, date
)
SELECT
	location,
    date,
    population,
    weekly_vaccinations,
    weekly_people_vaccinated,
    percent_people_vaccinated
FROM row_nums
WHERE day_num % 7 = 0;



-- 4. Top 10 countries with highest total vaccinations
SELECT 
    location,
    MAX(total_vaccinations) AS total_vaccinations
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location
ORDER BY total_vaccinations DESC
LIMIT 10;



-- 5a. Top 10 countries total people vaccinated
SELECT 
    location,
    MAX(people_vaccinated) AS people_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location
ORDER BY people_vaccinated DESC
LIMIT 10;

-- 5b. Top 10 countries total percent population vaccinated
SELECT 
    location,
    ROUND(MAX(people_vaccinated)/MAX(population) * 100, 4) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location
ORDER BY percent_people_vaccinated DESC
LIMIT 10;



-- 6a. Top 10 countries total people fully vaccinated
SELECT 
    location,
    MAX(people_fully_vaccinated) AS people_fully_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location
ORDER BY people_fully_vaccinated DESC
LIMIT 10;

-- 6b. Top 10 countries total percent population fully vaccinated
SELECT 
    location,
    ROUND(MAX(people_fully_vaccinated)/MAX(population) * 100, 4) AS percent_people_fully_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location
ORDER BY percent_people_fully_vaccinated DESC
LIMIT 10;
