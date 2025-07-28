-- 06 DASHBOARD QUERIES
-- Final queries for use in Tableau Dashboard

-- Parameters: country, measure (cases/deaths/people vaccinated)

-- 1. Text Table: Global total cases, deaths, people vaccinated, population, case fatality rate and vaccination rate

-- 2. Choropleth Map: Compare countries' total numbers

-- 3. Line graphs: Individual countries' weekly numbers for the specified measure 

-- 4. Bar chart: Compare countries' proportional numbers (i.e. cases/deaths per million and percent of population vaccinated)



-- 1. Global numbers
SELECT 
    SUM(new_cases) AS total_reported_cases,
    SUM(new_deaths) AS total_reported_deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases)) * 100, 2) AS case_fatality_rate,
    SUM(daily_people_vaccinated) AS total_people_vaccinated,
	SUM(DISTINCT population) AS global_population,
	ROUND((SUM(daily_people_vaccinated) / SUM(DISTINCT population)) * 100, 2) AS percent_people_vaccinated
FROM CovidProject.CovidData
WHERE location NOT IN (
	'World', 
	'Asia',
	'Africa',
	'North America',
	'South America',
	'Europe',
	'Oceania');



-- 2. Comparison data: total cases, deaths and people vaccinated
SELECT 
    location,
    MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
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
ORDER BY location;



-- 3. Individual country data: weekly total cases, deaths and people vaccinated
WITH first_vaccine_dates AS (
	SELECT
		location,
		MIN(date) AS first_vaccination_date
	FROM CovidProject.CovidData
	WHERE location NOT IN (
		'World',
		'Asia',
		'Africa',
		'North America',
		'South America',
		'Europe',
		'Oceania')
		AND daily_vaccinations > 0
	GROUP BY location
),
vaccination_data AS(
	SELECT
		cd.location,
		cd.date,
		cd.weekly_cases,
		cd.weekly_deaths,
		cd.weekly_people_vaccinated,
		ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS day_num,
		CASE
			WHEN cd.date < fv.first_vaccination_date THEN 'Before Vaccinations'
			ELSE 'After Vaccinations'
		END AS vaccination_state
	FROM CovidProject.CovidData cd
	JOIN first_vaccine_dates fv
		ON cd.location = fv.location
	WHERE cd.location NOT IN (
		'World', 
		'Asia',
		'Africa',
		'North America',
		'South America',
		'Europe',
		'Oceania')
	ORDER BY cd.location, cd.date
)
SELECT
    location,
    date,
    weekly_cases,
    weekly_deaths,
    weekly_people_vaccinated,
    vaccination_state
FROM vaccination_data
WHERE day_num % 7 = 0;


-- 4. Comparison data: total cases and deaths per million, and percent population vaccinated
SELECT 
	location,
	population,
	ROUND(MAX(total_cases)/population * 1e6, 0) AS total_cases_per_million,
	ROUND(MAX(total_deaths)/population * 1e6, 0) AS total_deaths_per_million,
	ROUND(MAX(people_vaccinated)/population * 100, 2) AS percent_people_vaccinated
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
ORDER BY percent_people_vaccinated DESC;
