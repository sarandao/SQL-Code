SELECT *
FROM Covid.deaths
WHERE location = "united states"

SELECT *
FROM Covid.vaccinations

-- Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid.deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid.deaths
WHERE Location LIKE "%states%"
ORDER BY 1,2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
FROM Covid.deaths
-- WHERE location LIKE '%states%' 
ORDER BY 1,2

-- Looking at Countries with Higest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid.deaths
-- WHERE location LIKE '%states%' 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death County per Population 

SELECT Location, MAX(Total_deaths) AS TotalDeathCount
FROM Covid.deaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- break things down by continent 

SELECT continent, MAX(Total_deaths) AS TotalDeathCount
FROM Covid.deaths
WHERE continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- showing continents with the higest death count per population 

SELECT continent, MAX(Total_deaths) AS TotalDeathCount
FROM Covid.deaths
WHERE continent is not null 
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS

SELECT date, SUM(New_cases), SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM Covid.deaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

-- Looking at Total Populaton vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM Covid.deaths AS dea
JOIN Covid.vaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid.deaths AS dea
JOIN Covid.vaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null 
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE 

DROP TABLE if exists
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid.deaths AS dea
JOIN Covid.vaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null 
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 

-- creating view to store data for later visualizations 

Create View PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid.deaths AS dea
JOIN Covid.vaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated 