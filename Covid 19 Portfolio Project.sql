/* Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */



SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- SELECT DATA TO USE
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases & Total Deaths Death Percentage of Covid In Nigeria
--Likelihood of death if you contract covid 19
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
AND continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Population
--Shows percentage of population that has Covid
SELECT location, date,population, total_cases, (total_cases/population)*100 AS populationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

--Countries with Highest Infection rate compared to Population
--what percentage of your population has got covid?
SELECT location, population, max(total_cases) AS Highest_infectionRate, max((total_cases/population))*100 AS populationPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
GROUP BY population, location
ORDER BY populationPercentage DESC

--Countries with Highest Deathrate by Population
SELECT location, MAX(CAST(total_deaths as INT)) AS Total_Death_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Rate DESC

-- Death rate BASED ON CONTINENT
SELECT location, MAX(CAST(total_deaths as INT)) AS Total_Death_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS  NULL
GROUP BY location
ORDER BY Total_Death_Rate DESC


-- Death rate BASED ON CONTINENT
--Showing Continents with the Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as INT)) AS Total_Death_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Rate DESC


--GLOBAL RESULT

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- COVID VACCINATION 
-- TOTAL POPULATION VS VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USING CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Total_People_Vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Total_People_Vaccinated/population)*100 AS percentage_populated
FROM PopVsVac
ORDER BY percentage_populated DESC


--USING TEMP TABLE


DROP TABLE IF EXISTS #percentagepopulationvaccinated
CREATE TABLE #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_People_Vaccinated numeric)
INSERT INTO #percentagepopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (Total_People_Vaccinated/population)*100 AS percentage_populated_vaccinated
FROM #percentagepopulationvaccinated


--CREATE VIEW FOR VISUALIZATION
CREATE VIEW percentagepopulationvaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as bigint)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS Total_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percentagepopulationvaccinated
