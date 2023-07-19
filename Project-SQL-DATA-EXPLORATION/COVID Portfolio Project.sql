SELECT *
FROM  PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM  PortfolioProject..CovidVaccinations
--WHERE continent is not NULL
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM  PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in Portugal
-- Shows the likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM  PortfolioProject..CovidDeaths
WHERE location like 'portugal' and continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
FROM  PortfolioProject..CovidDeaths
WHERE location like 'portugal' and continent is not NULL
ORDER BY 1,2

-- Looking at countries with the hiest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfection
FROM  PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfection DESC

-- Showing Countries with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's Break Things Down By Continent
-- correct way (example north america + canada)

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- will miss some data for example canada 
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
-- by date
SELECT date,
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       CASE
           WHEN SUM(new_cases) = 0 THEN 0 -- Handle divide by zero case
           ELSE SUM(new_deaths) / SUM(new_cases) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- total
SELECT 
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       CASE
           WHEN SUM(new_cases) = 0 THEN 0 -- Handle divide by zero case
           ELSE SUM(new_deaths) / SUM(new_cases) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- Join CovidDeaths and CovidVaccination
SELECT *
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- simulating rolling count for new_vaccionations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accumulated_people_vaccinated
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


-- Using CTE (common table expression)

WITH PopulationvsVaccination (continent, location,date, population, new_vaccinations, accumulated_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accumulated_people_vaccinated
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
)
select *, (accumulated_people_vaccinated/population) * 100 as percentage_acc_people_vaccinated
from PopulationvsVaccination

-- Using TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated --useful if you plan modifying the table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Accumulated_people_vaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accumulated_people_vaccinated
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

select *, (Accumulated_people_vaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating View to store later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as accumulated_people_vaccinated
FROM  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

-- now we can query from this view
SELECT *
FROM PercentPopulationVaccinated