-- 01 DATA PREPARATION
-- Preparation for the importing of and staging tables for the data from the CovidDeaths.csv and CovidVaccinations.csv files 

-- Tables for raw data

-- Creating table for deaths data
CREATE TABLE CovidProject.CovidDeaths_Raw(
	date TEXT,
    location TEXT,
    new_cases TEXT,
    new_deaths TEXT,
    total_cases TEXT,
    total_deaths TEXT,
    weekly_cases TEXT,
    weekly_deaths TEXT,
	biweekly_cases TEXT,
    biweekly_deaths TEXT
    );
    
-- Creating table for vaccinations data
CREATE TABLE CovidProject.CovidVaccinations_Raw(
	location TEXT,
	iso_code TEXT,
	date TEXT,
	total_vaccinations TEXT,
	people_vaccinated TEXT,
	people_fully_vaccinated TEXT,
	total_boosters TEXT,
	daily_vaccinations_raw TEXT,
	daily_vaccinations TEXT,
	total_vaccinations_per_hundred TEXT,
	people_vaccinated_per_hundred TEXT,
	people_fully_vaccinated_per_hundred TEXT,
	total_boosters_per_hundred TEXT,
	daily_vaccinations_per_million TEXT,
	daily_people_vaccinated TEXT,
	daily_people_vaccinated_per_hundred TEXT
    );
    
-- Creating table for population data
CREATE TABLE CovidProject.Populations_Raw(
	entity TEXT,
	iso_code TEXT,
    year TEXT,
    population TEXT,
    source TEXT
    );
    
-- Data inserted into tables using terminal/ MySQL server directly

    
    
-- Tables for staging

-- Creating and populating deaths staging table
CREATE TABLE CovidProject.CovidDeaths_Staging LIKE CovidProject.CovidDeaths_Raw;

INSERT INTO CovidProject.CovidDeaths_Staging SELECT * FROM CovidProject.CovidDeaths_Raw;

-- Dealing with empty strings from CSV file
UPDATE CovidProject.CovidDeaths_Staging
SET
	date = NULLIF(date, ''),
    location = NULLIF(location, ''),
    new_cases = NULLIF(new_cases, ''),
    new_deaths = NULLIF(new_deaths, ''),
    total_cases = NULLIF(total_cases, ''),
    total_deaths = NULLIF(total_deaths, ''),
    weekly_cases = NULLIF(weekly_cases, ''),
    weekly_deaths = NULLIF(weekly_deaths, ''),
	biweekly_cases = NULLIF(biweekly_cases, ''),
    biweekly_deaths = NULLIF(REPLACE(biweekly_deaths, '\r', ''), '');
-- Last column includes carriage returns as well as empty strings that need to be handled

-- Creating and populating vaccinations staging table
CREATE TABLE CovidProject.CovidVaccinations_Staging LIKE CovidProject.CovidVaccinations_Raw;

INSERT INTO CovidProject.CovidVaccinations_Staging SELECT * FROM CovidProject.CovidVaccinations_Raw;

-- Dealing with empty strings from CSV file
UPDATE CovidProject.CovidVaccinations_Staging
SET
	location = NULLIF(location, ''),
	iso_code = NULLIF(iso_code, ''),
	date = NULLIF(date, ''),
	total_vaccinations = NULLIF(total_vaccinations, ''),
	people_vaccinated = NULLIF(people_vaccinated, ''),
	people_fully_vaccinated = NULLIF(people_fully_vaccinated, ''),
	total_boosters = NULLIF(total_boosters, ''),
	daily_vaccinations_raw = NULLIF(daily_vaccinations_raw, ''),
	daily_vaccinations = NULLIF(daily_vaccinations, ''),
	total_vaccinations_per_hundred = NULLIF(total_vaccinations_per_hundred, ''),
	people_vaccinated_per_hundred = NULLIF(people_vaccinated_per_hundred, ''),
	people_fully_vaccinated_per_hundred = NULLIF(people_fully_vaccinated_per_hundred, ''),
	total_boosters_per_hundred = NULLIF(total_boosters_per_hundred, ''),
	daily_vaccinations_per_million = NULLIF(daily_vaccinations_per_million, ''),
	daily_people_vaccinated = NULLIF(daily_people_vaccinated, ''),
	daily_people_vaccinated_per_hundred = NULLIF(REPLACE(daily_people_vaccinated_per_hundred, '\r', ''), '');

-- Creating and populating populations staging table
CREATE TABLE CovidProject.Populations_Staging LIKE CovidProject.Populations_Raw;

INSERT INTO CovidProject.Populations_Staging SELECT * FROM CovidProject.Populations_Raw;

-- Dealing with empty strings from CSV file
UPDATE CovidProject.Populations_Staging
SET
	entity = NULLIF(entity, ''),
	iso_code = NULLIF(iso_code, ''),
    year = NULLIF(year, ''),
    population = NULLIF(population, ''),
    source = NULLIF(REPLACE(source, '\r', ''), '');
