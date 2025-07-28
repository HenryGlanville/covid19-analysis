-- 02 DATA CLEANING
-- Cleaning imported data in staging tables for insert into production tables for further analysis and exploration

-- Checking for negative values for what should be unsigned integer types
SELECT
	date,
    location,
    new_cases,
    new_deaths,
    total_cases,
    total_deaths,
    weekly_cases,
    weekly_deaths,
	biweekly_cases,
    biweekly_deaths
FROM CovidProject.CovidDeaths_Staging
WHERE CAST(new_cases AS SIGNED) < 0
	OR CAST(new_deaths AS SIGNED) < 0
    OR CAST(total_cases AS SIGNED) < 0
    OR CAST(total_deaths AS SIGNED) < 0
    OR CAST(weekly_cases AS SIGNED) < 0
    OR CAST(weekly_deaths AS SIGNED) < 0
    OR CAST(biweekly_cases AS SIGNED) < 0
    OR CAST(biweekly_deaths AS SIGNED) < 0;
-- No unusual negative values from deaths table

SELECT
	location,
	iso_code,
	date,
	total_vaccinations,
	people_vaccinated,
	people_fully_vaccinated,
	total_boosters,
	daily_vaccinations_raw,
	daily_vaccinations,
	total_vaccinations_per_hundred,
	people_vaccinated_per_hundred,
	people_fully_vaccinated_per_hundred,
	total_boosters_per_hundred,
	daily_vaccinations_per_million,
	daily_people_vaccinated,
	daily_people_vaccinated_per_hundred
FROM CovidProject.CovidVaccinations_Staging2
WHERE CAST(total_vaccinations AS SIGNED) < 0
	OR CAST(people_vaccinated AS SIGNED) < 0
    OR CAST(people_fully_vaccinated AS SIGNED) < 0
    OR CAST(total_boosters AS SIGNED) < 0
    OR CAST(daily_vaccinations_raw AS SIGNED) < 0
    OR CAST(daily_vaccinations AS SIGNED) < 0
    OR CAST(total_vaccinations_per_hundred AS SIGNED) < 0
    OR CAST(people_vaccinated_per_hundred AS SIGNED) < 0
	OR CAST(people_fully_vaccinated_per_hundred AS SIGNED) < 0
    OR CAST(total_boosters_per_hundred AS SIGNED) < 0
    OR CAST(daily_vaccinations_per_million AS SIGNED) < 0
    OR CAST(daily_people_vaccinated AS SIGNED) < 0
    OR CAST(daily_people_vaccinated_per_hundred AS SIGNED) < 0;
-- No unusual negative values from vaccinations table

SELECT
	entity
    population
FROM CovidProject.Populations_Staging
WHERE CAST(population AS SIGNED) < 0;
-- No unusual negative values from populations table



-- Checking for explicit duplicate entries
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY location, date) row_num
		FROM CovidProject.CovidDeaths_Staging
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY location;
-- No duplicates in deaths table

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY location, date) row_num
		FROM CovidProject.CovidVaccinations_Staging
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY location;
-- No duplicates in vaccinations table

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY entity, year) row_num
		FROM CovidProject.Populations_Staging
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY entity;
-- No duplicates in populations table

-- Check for less explicit duplicates across tables
SELECT loc
FROM (
    SELECT DISTINCT location AS loc FROM CovidProject.CovidDeaths_Staging
    UNION
    SELECT DISTINCT location FROM CovidProject.CovidVaccinations_Staging
    UNION
    SELECT DISTINCT entity FROM CovidProject.Populations_Staging
) AS all_locations
LEFT JOIN (
    SELECT DISTINCT location FROM CovidProject.CovidDeaths_Staging
) AS d ON all_locations.loc = d.location
LEFT JOIN (
    SELECT DISTINCT location FROM CovidProject.CovidVaccinations_Staging
) AS v ON all_locations.loc = v.location
LEFT JOIN (
    SELECT DISTINCT entity FROM CovidProject.Populations_Staging
) AS p ON all_locations.loc = p.entity
WHERE d.location IS NULL
   OR v.location IS NULL
   OR p.entity IS NULL
ORDER BY loc;



-- Resolve naming conflicts

-- Change East Timor to Timor in deaths table to resolve duplicates
UPDATE CovidProject.CovidDeaths_Staging
SET location = 'Timor'
WHERE location = 'East Timor';

-- Change Faeroe Islands to Faroe Islands in vaccinations and populations tables to resolve duplicates
UPDATE CovidProject.CovidVaccinations_Staging
SET location = 'Faroe Islands'
WHERE location = 'Faeroe Islands';

UPDATE CovidProject.Populations_Staging
SET entity = 'Faroe Islands'
WHERE entity = 'Faeroe Islands';



-- Preparing tables for production

-- Finding appropriate length for VARCHAR datatypes
SELECT MAX(LENGTH(location)) AS max_length_loc
FROM CovidProject.CovidDeaths_Raw;

-- Create deaths table
CREATE TABLE CovidProject.CovidDeaths(
	date DATE,
    location VARCHAR(40),
    new_cases INT UNSIGNED,
    new_deaths INT UNSIGNED,
    total_cases BIGINT UNSIGNED,
    total_deaths BIGINT UNSIGNED,
    weekly_cases FLOAT,
    weekly_deaths FLOAT,
	biweekly_cases FLOAT,
    biweekly_deaths FLOAT
    );
-- As dealing with scientific data on populations, precision is not critical and so floats are adequate for use for rates

-- Populating deaths table
INSERT INTO CovidProject.CovidDeaths(
	date,
    location,
    new_cases,
    new_deaths,
    total_cases,
    total_deaths,
    weekly_cases,
    weekly_deaths,
	biweekly_cases,
    biweekly_deaths
)
SELECT
	CAST(date AS DATE),
    location,
    CAST(new_cases AS UNSIGNED),
    CAST(new_deaths AS UNSIGNED),
    CAST(total_cases AS UNSIGNED),
    CAST(total_deaths AS UNSIGNED),
    CAST(weekly_cases AS FLOAT),
    CAST(weekly_deaths AS FLOAT),
	CAST(biweekly_cases AS FLOAT),
    CAST(biweekly_deaths AS FLOAT)
FROM CovidProject.CovidDeaths_Staging;
    

    
-- Create vaccinations table
SELECT MAX(LENGTH(iso_code)) AS max_length_iso, MAX(LENGTH(location)) AS max_length_loc
FROM CovidProject.CovidVaccinations_Raw;

CREATE TABLE CovidProject.CovidVaccinations(
	location VARCHAR(40),
	iso_code VARCHAR(10),
	date DATE,
	total_vaccinations BIGINT UNSIGNED,
	people_vaccinated BIGINT UNSIGNED,
	people_fully_vaccinated BIGINT UNSIGNED,
	total_boosters INT UNSIGNED,
	daily_vaccinations_raw INT UNSIGNED,
	daily_vaccinations INT UNSIGNED,
	total_vaccinations_per_hundred FLOAT,
	people_vaccinated_per_hundred FLOAT,
	people_fully_vaccinated_per_hundred FLOAT,
	total_boosters_per_hundred FLOAT,
	daily_vaccinations_per_million FLOAT,
	daily_people_vaccinated INT UNSIGNED,
	daily_people_vaccinated_per_hundred FLOAT
    );

-- Populating vaccinations table
INSERT INTO CovidProject.CovidVaccinations(
	location,
	iso_code,
	date,
	total_vaccinations,
	people_vaccinated,
	people_fully_vaccinated,
	total_boosters,
	daily_vaccinations_raw,
	daily_vaccinations,
	total_vaccinations_per_hundred,
	people_vaccinated_per_hundred,
	people_fully_vaccinated_per_hundred,
	total_boosters_per_hundred,
	daily_vaccinations_per_million,
	daily_people_vaccinated,
	daily_people_vaccinated_per_hundred
)
SELECT
	location,
	iso_code,
	CAST(date AS DATE),
	CAST(total_vaccinations AS UNSIGNED),
	CAST(people_vaccinated AS UNSIGNED),
	CAST(people_fully_vaccinated AS UNSIGNED),
	CAST(total_boosters AS UNSIGNED),
	CAST(daily_vaccinations_raw AS UNSIGNED),
	CAST(daily_vaccinations AS UNSIGNED),
	CAST(total_vaccinations_per_hundred AS FLOAT),
	CAST(people_vaccinated_per_hundred AS FLOAT),
	CAST(people_fully_vaccinated_per_hundred AS FLOAT),
	CAST(total_boosters_per_hundred AS FLOAT),
	CAST(daily_vaccinations_per_million AS FLOAT),
	CAST(daily_people_vaccinated AS UNSIGNED),
	CAST(daily_people_vaccinated_per_hundred AS FLOAT)
FROM CovidProject.CovidVaccinations_Staging;



-- Create populations table
SELECT 
	MAX(LENGTH(entity)) AS max_length_ent, 
    MAX(LENGTH(iso_code)) AS max_length_iso,
    MAX(LENGTH(source)) AS max_length_src
FROM CovidProject.Populations_Raw;

CREATE TABLE CovidProject.Populations(
	entity VARCHAR(40),
	iso_code VARCHAR(10),
    year INT UNSIGNED,
    population BIGINT UNSIGNED,
    source VARCHAR(100)
    );

-- Populating vaccinations table
INSERT INTO CovidProject.Populations(
	entity,
	iso_code,
    year,
    population,
    source
)
SELECT
	entity,
	iso_code,
    CAST(year AS UNSIGNED),
    CAST(population AS UNSIGNED),
    source
FROM CovidProject.Populations_Staging;



-- Create combined table
CREATE TABLE CovidProject.CovidData(
	iso_code VARCHAR(10),
    location VARCHAR(40),
	date DATE,
    new_cases INT UNSIGNED,
    new_deaths INT UNSIGNED,
    total_cases BIGINT UNSIGNED,
    total_deaths BIGINT UNSIGNED,
    weekly_cases FLOAT,
    weekly_deaths FLOAT,
	biweekly_cases FLOAT,
    biweekly_deaths FLOAT,
	total_vaccinations BIGINT UNSIGNED,
	people_vaccinated BIGINT UNSIGNED,
	people_fully_vaccinated BIGINT UNSIGNED,
	total_boosters INT UNSIGNED,
	daily_vaccinations_raw INT UNSIGNED,
	daily_vaccinations INT UNSIGNED,
	total_vaccinations_per_hundred FLOAT,
	people_vaccinated_per_hundred FLOAT,
	people_fully_vaccinated_per_hundred FLOAT,
	total_boosters_per_hundred FLOAT,
	daily_vaccinations_per_million FLOAT,
	daily_people_vaccinated INT UNSIGNED,
	daily_people_vaccinated_per_hundred FLOAT,
	population BIGINT UNSIGNED
    );
    
    
    
-- Populating data table
INSERT INTO CovidProject.CovidData(
	iso_code,
    location,
    date,
    new_cases,
    new_deaths,
    total_cases,
    total_deaths,
    weekly_cases,
    weekly_deaths,
	biweekly_cases,
    biweekly_deaths,
    total_vaccinations,
	people_vaccinated,
	people_fully_vaccinated,
	total_boosters,
	daily_vaccinations_raw,
	daily_vaccinations,
	total_vaccinations_per_hundred,
	people_vaccinated_per_hundred,
	people_fully_vaccinated_per_hundred,
	total_boosters_per_hundred,
	daily_vaccinations_per_million,
	daily_people_vaccinated,
	daily_people_vaccinated_per_hundred,
    population
)
SELECT
	v.iso_code,
    d.location,
    d.date,
    d.new_cases,
    d.new_deaths,
    d.total_cases,
    d.total_deaths,
    d.weekly_cases,
    d.weekly_deaths,
	d.biweekly_cases,
    d.biweekly_deaths,
    v.total_vaccinations,
	v.people_vaccinated,
	v.people_fully_vaccinated,
	v.total_boosters,
	v.daily_vaccinations_raw,
	v.daily_vaccinations,
	v.total_vaccinations_per_hundred,
	v.people_vaccinated_per_hundred,
	v.people_fully_vaccinated_per_hundred,
	v.total_boosters_per_hundred,
	v.daily_vaccinations_per_million,
	v.daily_people_vaccinated,
	v.daily_people_vaccinated_per_hundred,
    p.population
FROM CovidProject.CovidDeaths d
LEFT JOIN CovidProject.CovidVaccinations v
    ON d.location = v.location 
		AND d.date = v.date
LEFT JOIN CovidProject.Populations p
    ON d.location = p.entity
UNION
SELECT
	v.iso_code,
    v.location,
    v.date,
    d.new_cases,
    d.new_deaths,
    d.total_cases,
    d.total_deaths,
    d.weekly_cases,
    d.weekly_deaths,
	d.biweekly_cases,
    d.biweekly_deaths,
    v.total_vaccinations,
	v.people_vaccinated,
	v.people_fully_vaccinated,
	v.total_boosters,
	v.daily_vaccinations_raw,
	v.daily_vaccinations,
	v.total_vaccinations_per_hundred,
	v.people_vaccinated_per_hundred,
	v.people_fully_vaccinated_per_hundred,
	v.total_boosters_per_hundred,
	v.daily_vaccinations_per_million,
	v.daily_people_vaccinated,
	v.daily_people_vaccinated_per_hundred,
    p.population
FROM CovidProject.CovidVaccinations v
LEFT JOIN CovidProject.CovidDeaths d
    ON v.location = d.location 
		AND v.date = d.date
LEFT JOIN CovidProject.Populations p
    ON v.location = p.entity
WHERE d.location IS NULL;



-- Remove unnecessary records
DELETE FROM CovidProject.CovidData
WHERE location IN (
-- Wealth groupings
	'High-income countries',
    'High income',
	'Upper-middle-income countries',
    'Upper middle income',
	'Lower-middle-income countries',
    'Lower middle income',
	'Low-income countries',
    'Low income',
    
-- EU data
    'European Union',
	'European Union (27)',

-- Individual UK countries
	'England',
    'Scotland',
    'Wales',
    'Northern Ireland');
    
-- Remove unnecessary rows
ALTER TABLE CovidProject.CovidData
DROP COLUMN biweekly_cases,
DROP COLUMN biweekly_deaths,
DROP COLUMN total_boosters,
DROP COLUMN total_vaccinations_per_hundred,
DROP COLUMN people_vaccinated_per_hundred,
DROP COLUMN people_fully_vaccinated_per_hundred,
DROP COLUMN total_boosters_per_hundred,
DROP COLUMN daily_vaccinations_per_million,
DROP COLUMN daily_people_vaccinated_per_hundred;