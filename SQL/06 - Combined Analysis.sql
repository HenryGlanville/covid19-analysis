-- 06 COMBINED ANALYSIS 
-- Combined case, death and vaccination analysis

-- 1a. Global total cases, deaths, case fatality rate, vaccinations, people vaccinated, population and perecent population vaccinated
SELECT 
    SUM(new_cases) AS total_confirmed_cases,
    SUM(new_deaths) AS total_reported_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS case_fatality_rate,
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

-- 1b. Global weekly cases, deaths, vaccinations and people vaccinated
SELECT 
	date,
	SUM(weekly_cases) AS weekly_new_cases,
	SUM(weekly_deaths) AS weekly_new_deaths,
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



-- 2. Continents' total cases, deaths, case fatality rate, vaccinations, people vaccinated and percent population vaccinated
SELECT 
    location,
    population,
	MAX(total_cases) AS total_cases,
    MAX(total_deaths) AS total_deaths,
    (MAX(total_deaths) / MAX(total_cases)) * 100 AS case_fatality_rate,
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
ORDER BY location;



-- 3. Countries' cases per million, deaths per million and percent population vaccinated
SELECT 
    location,
	MAX(total_cases)/population * 1e6 AS total_cases_per_million,
	MAX(total_deaths)/population * 1e6 AS total_deaths_per_million,
    ROUND(MAX(people_vaccinated)/population * 100, 4) AS percent_people_vaccinated
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
ORDER BY location;



-- 4a. Countries' dates for first vaccinations
SELECT
	location,
    daily_vaccinations,
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
GROUP BY location, daily_vaccinations
ORDER BY location;

-- 4b. Countries' weekly cases, deaths and people vaccinated before and after starting vaccinations
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
vaccination_data AS (
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

-- 4c. Countries' total cases, total deaths, total cases per million and total deaths per millin 90 days before and after starting vaccinations
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
        cd.population,
		cd.new_cases,
		cd.new_deaths,
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
	AND cd.date BETWEEN DATE_SUB(fv.first_vaccination_date, INTERVAL 90 DAY)
		AND DATE_ADD(fv.first_vaccination_date, INTERVAL 89 DAY)
	ORDER BY cd.location, cd.date
)
SELECT
    location,
    vaccination_state,
	SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_cases)/ population * 1e6 AS total_cases_per_million,
    SUM(new_deaths)/ population * 1e6 AS total_deaths_per_million
FROM vaccination_data
GROUP BY location, vaccination_state, population
ORDER BY location, vaccination_state DESC;

-- 4d. Countries' percent changes in case fatality, total cases per million and total deaths per million 120 days before and after starting vaccinations
-- (Strong impact of vaccine rollout: Counties with a decrease of more than 20% in both cases and deaths)
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
        cd.population,
		cd.new_cases,
		cd.new_deaths,
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
	AND cd.date BETWEEN DATE_SUB(fv.first_vaccination_date, INTERVAL 120 DAY)
		AND DATE_ADD(fv.first_vaccination_date, INTERVAL 119 DAY)
	ORDER BY cd.location, cd.date
),
aggregated AS (
	SELECT
		location,
        population,
		vaccination_state,
		SUM(new_cases) AS total_cases,
		SUM(new_deaths) AS total_deaths,
		ROUND(SUM(new_cases)/ population * 1e6, 4) AS total_cases_per_million,
		ROUND(SUM(new_deaths)/ population * 1e6, 4) AS total_deaths_per_million
	FROM vaccination_data
	GROUP BY location, vaccination_state, population
),
pivoted AS (
	SELECT
		location,
        population,
		MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_cases END) AS cases_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_cases END) AS cases_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_deaths END) AS deaths_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_deaths END) AS deaths_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_cases_per_million END) AS cases_per_million_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_cases_per_million END) AS cases_per_million_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_deaths_per_million END) AS deaths_per_million_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_deaths_per_million END) AS deaths_per_million_after
	FROM aggregated 
	GROUP BY location, population
)
SELECT 
	location,
    ROUND(deaths_before/cases_before * 100, 2) AS case_fatality_before,
    ROUND(deaths_after/cases_after * 100, 2) AS case_fatality_after,
    ROUND((deaths_after/cases_after - deaths_before/cases_before) * 100, 2) As case_fatality_change,
    ROUND((cases_per_million_after - cases_per_million_before) / cases_per_million_before * 100, 2) AS cases_per_million_percent_change,
    ROUND((deaths_per_million_after - deaths_per_million_before) / deaths_per_million_before * 100, 2) AS deaths_per_million_percent_change
FROM pivoted
WHERE population > 1e6 
	AND cases_per_million_before > 5000
	AND ROUND((cases_per_million_after - cases_per_million_before) / cases_per_million_before * 100, 2) < -20
    AND ROUND((deaths_per_million_after - deaths_per_million_before) / deaths_per_million_before * 100, 2) < -20
ORDER BY cases_per_million_percent_change;

-- 4e. Countries' percent changes in case fatality, total cases per million and total deaths per million 120 days before and after starting vaccinations
-- (Weak impact of vaccine rollout: Counties with an increase in both cases and deaths)
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
        cd.population,
		cd.new_cases,
		cd.new_deaths,
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
	AND cd.date BETWEEN DATE_SUB(fv.first_vaccination_date, INTERVAL 120 DAY)
		AND DATE_ADD(fv.first_vaccination_date, INTERVAL 119 DAY)
	ORDER BY cd.location, cd.date
),
aggregated AS (
	SELECT
		location,
        population,
		vaccination_state,
		SUM(new_cases) AS total_cases,
		SUM(new_deaths) AS total_deaths,
		ROUND(SUM(new_cases)/ population * 1e6, 4) AS total_cases_per_million,
		ROUND(SUM(new_deaths)/ population * 1e6, 4) AS total_deaths_per_million
	FROM vaccination_data
	GROUP BY location, vaccination_state, population
),
pivoted AS (
	SELECT
		location,
        population,
		MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_cases END) AS cases_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_cases END) AS cases_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_deaths END) AS deaths_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_deaths END) AS deaths_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_cases_per_million END) AS cases_per_million_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_cases_per_million END) AS cases_per_million_after,
        MAX(CASE WHEN vaccination_state = 'Before Vaccinations' THEN total_deaths_per_million END) AS deaths_per_million_before,
        MAX(CASE WHEN vaccination_state = 'After Vaccinations' THEN total_deaths_per_million END) AS deaths_per_million_after
	FROM aggregated 
	GROUP BY location, population
)
SELECT 
	location,
    ROUND(deaths_before/cases_before * 100, 2) AS case_fatality_before,
    ROUND(deaths_after/cases_after * 100, 2) AS case_fatality_after,
	ROUND((deaths_after/cases_after - deaths_before/cases_before) * 100, 2) As case_fatality_change,
    ROUND((cases_per_million_after - cases_per_million_before) / cases_per_million_before * 100, 2) AS cases_per_million_percent_change,
    ROUND((deaths_per_million_after - deaths_per_million_before) / deaths_per_million_before * 100, 2) AS deaths_per_million_percent_change
FROM pivoted
WHERE population > 1e6 
	AND cases_per_million_before > 5000
	AND ROUND((cases_per_million_after - cases_per_million_before) / cases_per_million_before * 100, 2) > -20
    AND ROUND((deaths_per_million_after - deaths_per_million_before) / deaths_per_million_before * 100, 2) > -20
ORDER BY cases_per_million_percent_change DESC;
