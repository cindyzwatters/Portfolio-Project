USE covid;

 -- SELECT *
 -- FROM covid_deaths
 -- WHERE continent is null
 -- ORDER BY location, date;

 -- Looking at overall covid deaths data
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM covid_deaths
ORDER BY location, date;


 -- Looking at total cases vs. total deaths
SELECT 
	location, 
	date, 
	total_cases,  
	total_deaths,
	ROUND(((total_deaths/total_cases) * 100),2) as Death_Percentage
FROM covid_deaths
WHERE location = 'United States'
ORDER BY location, date;


 -- Looking at cases vs. population in US only
SELECT
	location,
	date,
	total_cases,
	population,
	ROUND(((total_cases/population) * 100),2) AS Infection_Rate
FROM covid_deaths
WHERE location = 'United States'
ORDER by location, date;


 -- Worldwide data
SELECT
	location,
	date,
	total_cases,
	population,
	ROUND(((total_cases/population) * 100),2) AS Infection_Rate
FROM covid_deaths
WHERE continent is not null
ORDER by location, date;

 -- Looking for countries w/highest infection rate compared to population
 SELECT
	location,
	MAX(total_cases) AS highest_infection_count,
	population,
	ROUND(((MAX(total_cases)/population) * 100),2) AS Infection_Rate_Percent
FROM covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infection_Rate_Percent DESC;


 -- Looking at countries w/highest death rate compared to population
 SELECT
	location,
	MAX(CAST(total_deaths as INT)) AS highest_death_count,
	population,
	ROUND(((MAX(CAST(total_deaths AS INT))/population) * 100),2) AS Death_Rate_Percent
FROM covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Death_Rate_Percent DESC;


 -- Grouping highest death count based on continent
 SELECT
	location,
	MAX(CAST(total_deaths as INT)) AS highest_death_count
FROM covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY highest_death_count DESC;


 -- Grouping highest infection count based on continent
SELECT
	location,
	MAX(CAST(total_cases as INT)) AS highest_infect_count
FROM covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY highest_infect_count DESC;

-- Grouping for Tableau Use - World Data
CREATE VIEW v_world_infection AS
SELECT
	location,
	MAX(CAST(total_cases as INT)) AS highest_infect_count
FROM covid_deaths
WHERE continent is null
GROUP BY location;

 -- Global Numbers
 SELECT 
	date, 
	SUM(new_cases) as total_cases,  
	SUM(CAST(new_deaths as int)) as total_deaths,
	ROUND(SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100,2) as total_death_percent
FROM covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY date;

 -- US only
 SELECT 
	date, 
	SUM(new_cases) as total_cases,  
	SUM(CAST(new_deaths as int)) as total_deaths,
	ROUND(SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100,2) as total_death_percent
FROM covid_deaths
WHERE location = 'United States'
GROUP BY date
ORDER BY date;

 -- Creating View for US data only for Tableau use
CREATE VIEW v_US_Deaths AS
( SELECT 
	date, 
	SUM(new_cases) as total_cases,  
	SUM(CAST(new_deaths as int)) as total_deaths,
	ROUND(SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100,2) as total_death_percent
FROM covid_deaths
WHERE location = 'United States'
GROUP BY date);

 -- Worldwide overall
 SELECT 
	NULLIF(SUM(new_cases),0) as total_cases,  
	SUM(CAST(new_deaths as int)) as total_deaths,
	ROUND(SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0) * 100,2) as total_death_percent
FROM covid_deaths
WHERE continent is not null;

 -- Looking at population vs vaccinations using CTE
WITH Pop_V_Vaccine AS
(SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location, d.date) as Rolling_People_Vaccinated
FROM covid_deaths d
		JOIN 
	covid_vaccines v ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent is not null
)
SELECT
	*,
	ROUND((Rolling_People_Vaccinated/population) * 100,2) as Vac_vs_Pop
FROM 
	Pop_V_Vaccine
ORDER BY location, date;


 -- TEMP Table
 DROP TABLE IF EXISTS #percent_population_vaccinated
 CREATE TABLE #percent_population_vaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	population numeric,
	new_vaccinations numeric,
	Rolling_People_Vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location, d.date) as Rolling_People_Vaccinated
FROM covid_deaths d
		JOIN 
	covid_vaccines v ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent is not null;


SELECT
	*,
	ROUND((Rolling_People_Vaccinated/population) * 100,2) as Vac_vs_Pop
FROM 
	#percent_population_vaccinated
ORDER BY location, date;



-- CREATING VIEWS FOR TABLEAU USE
CREATE VIEW v_percent_population_vaccinated AS
(SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(INT, v.new_vaccinations)) OVER (PARTITION BY d.location, d.date) as Rolling_People_Vaccinated
FROM covid_deaths d
		JOIN 
	covid_vaccines v ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent is not null
);
