/*
Data exploration - Covid19
Showcasing skills: JOINS, CTE, TEMP TABLES, CREATING VIEWS, CONVERTING DATA TYPES
*/


--Confirm data was imported correctly

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL --the continents Africa, Europe, Asia, etc have NULL in continent column
ORDER BY location,date

SELECT *
FROM CovidVaccinations
ORDER BY location,date


--Select the data to start with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date


--Total_cases vs total_deaths
--Shows the probability of death if one contracts C-19 in Kenya, sub Kenya with any other location

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location = 'Kenya'
ORDER BY date


--Looking at total cases vs population
--Shows the percentage of population that contracted C-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM CovidDeaths
--WHERE location = 'Kenya'
ORDER BY date


--Locations with highest infection rates compared to population

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS infection_rate
FROM CovidDeaths
WHERE continent IS NOT NULL -- and location = 'Kenya'
GROUP BY location, population
ORDER BY infection_rate DESC


--Locations with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Kenya'
GROUP BY location, population
ORDER BY total_death_count DESC


--BREAK DOWN BY CONTINENT
-- Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Kenya'
GROUP BY continent
ORDER BY total_death_count DESC


--GLOBAL NUMBERS
--Per day

SELECT date, SUM(CAST (new_cases as int)) AS total_cases, SUM(CAST (new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


--Aggregate global number as at Feb 2023

SELECT SUM(CAST (new_cases as int)) AS total_cases, SUM(CAST (new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL


--Use CovidDeaths & CovidVaccinations combined

--Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
--(rolling_count_vaccinations/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location = 'Kenya'
ORDER BY location, date


--USE CTE(common table expression) to calculate the rolling_count using PARTITION BY 

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_count_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(rolling_count_vaccinations/population)*100 AS vaccinated_population_percent
FROM PopvsVac


--Using TEMP Table to calculate the rolling_count

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count_vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
ORDER BY location, date

SELECT *,(rolling_count_vaccinations/population)*100 AS vaccinated_population_percent
FROM #PercentPopulationVaccinated
--WHERE location='Kenya'


--Creating Views to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

--Queries for Tableau Viz

--Total global numbers

SELECT SUM(CAST(new_cases as int)) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(CAST(new_cases as int))*100 AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

--Aggregate numbers per location

SELECT location, SUM(CAST(new_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
--WHERE location = 'Kenya'
GROUP BY location
ORDER BY total_death_count DESC

--Aggregate numbers per socioeconomic classes

SELECT location, SUM(CAST(new_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International','Europe','Asia','North America','South America','Africa','Oceania')
--WHERE location = 'Kenya'
GROUP BY location
ORDER BY total_death_count DESC

--Infections per location/country

SELECT location, population, MAX(total_cases) as highest_infection_count,  MAX((total_cases/population))*100 as population_infected_percent
FROM CovidDeaths
--Where location = 'Kenya'
GROUP BY Location, Population
ORDER BY population_infected_percent DESC

--Infections per continent

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 as population_infected_percent
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
--Where location = 'Kenya'
GROUP BY Location, Population
ORDER BY population_infected_percent DESC

--Infections per location by date

SELECT location, population, date, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 as population_infected_percent
FROM CovidDeaths
--Where location = 'Kenya'
WHERE continent IS NOT NULL --excludes numbers for continents
GROUP BY location, population, date
ORDER BY population_infected_percent DESC
