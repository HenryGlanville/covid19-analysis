-- 04 CASES AND DEATHS ANALYSIS 
-- Analysis of total and new cases, deaths and mortality trends

-- 1a. Global total cases, deaths and case fatality rate
SELECT 
    SUM(new_cases) AS total_confirmed_cases,
    SUM(new_deaths) AS total_reported_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS case_fatality_rate
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
	MAX(total_cases) AS total_confirmed_cases, 
	MAX(total_deaths) AS total_reported_deaths, 
    (MAX(total_deaths)/ MAX(total_cases)) * 100 AS case_fatality_rate
FROM CovidProject.CovidData
WHERE location = 'World';
-- Not entirely correct, but close enough for use

-- 1b. Global weekly cases, deaths and case fatality rate
SELECT 
	date,
	SUM(weekly_cases) AS weekly_new_cases,
	SUM(weekly_deaths) AS weekly_new_deaths,
	ROUND((SUM(weekly_deaths) / SUM(weekly_cases)) * 100, 4) AS weekly_case_fatality_rate
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



-- 2. Contients' total cases, deaths, case fatality rate and total cases and deaths per million
SELECT 
    location,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS case_fatality_rate,
    MAX(total_cases)/ population * 1e6 AS total_cases_per_million,
	MAX(total_deaths)/ population * 1e6 AS total_deaths_per_million
FROM CovidProject.CovidData
WHERE location IN ( 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location, population
ORDER BY case_fatality_rate DESC;



-- 3. Countries' weekly cases vs weekly deaths
WITH row_nums AS (
	SELECT 
		location,
		date,
		weekly_cases,
		weekly_deaths,
		ROUND((weekly_deaths / weekly_cases) * 100, 4) AS case_fatality_rate,
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
    weekly_cases,
	weekly_deaths,
    case_fatality_rate
FROM row_nums
WHERE day_num % 7 = 0;



-- 4a. Top 10 countries with highest total cases
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
ORDER BY total_cases DESC
LIMIT 10;

-- 4b. Top 10 countries with highest total cases per million
SELECT 
	location,
	MAX(total_cases)/ population * 1e6 AS total_cases_per_million
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location, population
ORDER BY total_cases_per_million DESC
LIMIT 10;



-- 5a. Top 10 countries with highest total deaths
SELECT 
	location,
	MAX(total_deaths) AS total_deaths
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
ORDER BY total_deaths DESC
LIMIT 10;

-- 5b. Top 10 countries with highest total deaths per million
SELECT 
	location,
	MAX(total_deaths)/ population * 1e6 AS total_deaths_per_million
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
GROUP BY location, population
ORDER BY total_deaths_per_million DESC
LIMIT 10;



-- 6a. Top 10 countries with highest total case fatality rate (with minimum 10,000 total cases)
SELECT 
	location,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS total_deaths,
	(MAX(total_deaths) / MAX(total_cases)) * 100 AS case_fatality_rate
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania')
	AND total_cases >= 10000
GROUP BY location
ORDER BY case_fatality_rate DESC
LIMIT 10;

-- 6b. Top 10 countries with lowest case fatality rate (with minimum 1,000,000 total cases)
SELECT 
    location,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS case_fatality_rate
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
HAVING total_cases >= 1e6
ORDER BY case_fatality_rate ASC
LIMIT 10;
