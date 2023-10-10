SQL QUERIES

-- I HAVE WORKED ON COVID DATASET THAT COMPRISES OF TWO TABLES WHICH WE 
-- WILL USE TO QUERY TO GAIN INSIGHTS. FIRST WE START OF CHECKING THE 
-- CONTENTS OF THE TABLES WE ARE WORKING. I USED GOOGLE BIGQUERY TO RUN 
-- THE SQL QUERIES. PLEASE FIND MY QUERY SECTION BELOW:




-- CHECKING THE TABLE1
SELECT *
FROM `Portfolio_COVID.covid_deaths`
ORDER BY 3,4

-- CHECKING THE TABLE2
SELECT *
FROM `Portfolio_COVID.covid_vaccinations`
ORDER BY 3,4


SELECT location, date, total_cases,new_cases, total_deaths, population
FROM `Portfolio_COVID.covid_deaths`
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM `Portfolio_COVID.covid_deaths`
WHERE location like'%States%'
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION HAS GOT COVID
SELECT location,date,total_cases, Population,(total_cases/Population)*100 as PercentPopulationInfected
FROM `Portfolio_COVID.covid_deaths`
WHERE location like'India'
ORDER BY 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location,population,max(total_cases) as HighestInfectionCount, max((total_cases/Population)*100) as PercentPopulationInfected
FROM `Portfolio_COVID.covid_deaths`
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT 
SELECT Location,MAX(total_deaths) as TotalDeathCounts
FROM `Portfolio_COVID.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC


-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT 
SELECT location,MAX(cast(total_death as int)) as TotalDeathCounts
FROM `Portfolio_COVID.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM `Portfolio_COVID.covid_deaths`
WHERE continent IS NOT NULL
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
FROM `Portfolio_COVID.covid_deaths` AS dea
JOIN `Portfolio_COVID.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- ROLLING SUM OF VACCINATIONS
WITH popvsvac 
AS(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `Portfolio_COVID.covid_deaths` AS dea
JOIN `Portfolio_COVID.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS fraction FROM popvsvac


-- TEMP TABLE
CREATE OR REPLACE TABLE Portfolio_COVID.PercentPopulationVaccinated
(
  Continent String,
  Location String,
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
);

-- DML STATEMENTS REQUIRE PAYMENT IN BIGQUERY SO WE SKIP THIS PART
INSERT INTO Portfolio_COVID.PercentPopulationVaccinated(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `Portfolio_COVID.covid_deaths` AS dea
JOIN `Portfolio_COVID.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
);

SELECT *,(RollingPeopleVaccinated/population)*100 AS fraction FROM PercentPopulationVaccinated

-- VIEW FOR LATER VISUALIZATION
CREATE VIEW Portfolio_COVID.PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM `Portfolio_COVID.covid_deaths` AS dea
JOIN `Portfolio_COVID.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

