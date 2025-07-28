-- 03 DATA EXPLORATION
-- Initial exploration and overview of data from both CovidDeaths and CoviVaccinations tables

-- Basic Structure

-- Total row counts
SELECT COUNT(*) AS total_deaths_rows FROM CovidProject.CovidDeaths; -- 411804
SELECT COUNT(*) AS total_vacc_rows FROM CovidProject.CovidVaccinations; -- 196246
SELECT COUNT(*) AS total_pop_rows FROM CovidProject.Populations; -- 251
SELECT COUNT(*) AS total_data_rows FROM CovidProject.CovidData; -- 407184

-- Sample records
SELECT * FROM CovidProject.CovidDeaths LIMIT 10;
SELECT * FROM CovidProject.CovidVaccinations LIMIT 10;
SELECT * FROM CovidProject.Populationa LIMIT 10;
SELECT * FROM CovidProject.CovidData LIMIT 10;

-- Total number of NULLs for important metrics
SELECT
	SUM(CASE WHEN new_cases IS NULL THEN 1 ELSE 0 END) AS null_new_cases, -- 1645
	SUM(CASE WHEN new_deaths IS NULL THEN 1 ELSE 0 END) AS null_new_deaths, -- 1196
	SUM(CASE WHEN total_cases IS NULL THEN 1 ELSE 0 END) AS null_total_cases, -- 0
	SUM(CASE WHEN total_deaths IS NULL THEN 1 ELSE 0 END) AS null_total_deaths, -- 0
	SUM(CASE WHEN weekly_cases IS NULL THEN 1 ELSE 0 END) AS null_weekly_cases, -- 2875
	SUM(CASE WHEN weekly_deaths IS NULL THEN 1 ELSE 0 END) AS null_weekly_deaths -- 2426
FROM CovidProject.CovidDeaths;

SELECT
	SUM(CASE WHEN total_vaccinations IS NULL THEN 1 ELSE 0 END) AS null_total_vac, -- 110829
	SUM(CASE WHEN people_vaccinated IS NULL THEN 1 ELSE 0 END) AS null_people_vac, -- 115114
	SUM(CASE WHEN people_fully_vaccinated IS NULL THEN 1 ELSE 0 END) AS null_fully_vac, -- 118185
	SUM(CASE WHEN daily_vaccinations IS NULL THEN 1 ELSE 0 END) AS null_daily_vac, -- 1217
	SUM(CASE WHEN daily_people_vaccinated IS NULL THEN 1 ELSE 0 END) AS null_daily_people_vac -- 4069
FROM CovidProject.CovidVaccinations;

SELECT
	SUM(CASE WHEN population IS NULL THEN 1 ELSE 0 END) AS null_pop -- 0
FROM CovidProject.Populations;

-- No NULLs in Populations table, however check for locations in combined table with NULL populations
SELECT
	DISTINCT location
FROM CovidProject.CovidData
WHERE population IS NULL; -- Only returns Northern Cyprus

-- Checking population for Cyprus versus information available online
SELECT
	DISTINCT population
FROM CovidProject.CovidData
WHERE location = "Cyprus"; -- returns 896007
-- This is similar to the value given by the government website (cystat.gov) for the Greek controlled part of Cyprus

-- Insert a value for Northern Cyprus 2022 population (382836) pulled from the government website (gov.ct.tr) for the Turkish controlled part of Cyprus
UPDATE CovidProject.CovidData
SET population = 382836
WHERE location = "Northern Cyprus";



-- Date Range

-- Earliest and latest date per table
SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM CovidProject.CovidDeaths;
SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM CovidProject.CovidVaccinations;
SELECT MIN(date) AS start_date, MAX(date) AS end_date FROM CovidProject.CovidData; -- 2020-01-05 to 2024-08-14

-- Earliest and latest date per country per table
SELECT location, MIN(date) AS start_date, MAX(date) AS end_date 
FROM CovidProject.CovidDeaths
GROUP BY location
ORDER BY MAX(date);
-- Here all dates are the same

SELECT location, MIN(date) AS start_date, MAX(date) AS end_date 
FROM CovidProject.CovidVaccinations
GROUP BY location
ORDER BY MAX(date);
-- Here most dates vary



-- Location Overview

-- Location count per table
SELECT COUNT(DISTINCT location) AS num_locations FROM CovidProject.CovidDeaths; -- 246
SELECT COUNT(DISTINCT location) AS num_locations FROM CovidProject.CovidVaccinations; -- 235 
SELECT COUNT(DISTINCT entity) AS num_locations FROM CovidProject.Populations; -- 251
SELECT COUNT(DISTINCT location) AS num_locations FROM CovidProject.CovidData; -- 245

SELECT COUNT(DISTINCT location) AS num_locations
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania'); -- 238

-- All locations in combined table
SELECT DISTINCT location FROM CovidProject.CovidData;
SELECT DISTINCT iso_code, location FROM CovidProject.CovidData ORDER BY iso_code;

-- All locations that exist in every table of deaths, vaccinations and populations tables
SELECT d.location
FROM (
    SELECT DISTINCT location FROM CovidProject.CovidDeaths
) AS d
JOIN (
    SELECT DISTINCT location FROM CovidProject.CovidVaccinations
) AS v
    ON d.location = v.location
JOIN (
    SELECT DISTINCT entity FROM CovidProject.Populations
) AS p
    ON d.location = p.entity
ORDER BY d.location;
-- Normal join times out due to size of dataset

-- All locations in combined table not in every other table
SELECT
	DISTINCT location 
FROM CovidProject.CovidData
WHERE location NOT IN (
	SELECT location
    FROM (
		SELECT d.location
		FROM (
			SELECT DISTINCT location FROM CovidProject.CovidDeaths
		) AS d
		JOIN (
			SELECT DISTINCT location FROM CovidProject.CovidVaccinations
		) AS v
			ON d.location = v.location
		JOIN (
			SELECT DISTINCT entity FROM CovidProject.Populations
		) AS p
			ON d.location = p.entity
		ORDER BY d.location
	) AS locations
);



-- Spot Check Metrics

-- Largest countries by population
SELECT 
	DISTINCT location, 
    population
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
ORDER BY population DESC
LIMIT 10;
-- Continents and "World" need to be filtered out of values for location when evaluating countries 

-- Countries with highest number of total cases
SELECT 
	location, 
	MAX(total_cases) AS total_cases
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
ORDER BY peak_total_cases DESC
LIMIT 10;

-- Countries with highest total case fatality ratio (as %)
SELECT 
	location,
	MAX(total_deaths) / MAX(total_cases) * 100 AS case_fatality_rate
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
ORDER BY case_fatality_rate DESC
LIMIT 10;