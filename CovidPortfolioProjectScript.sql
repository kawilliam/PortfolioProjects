SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
order by 3,4

-- SELECT *
-- FROM PortfolioProject.dbo.CovidVaccinations
-- order by 3,4

-- Select Data that is going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows percentage of you dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%canada%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population that got Covid

SELECT location, date, total_cases, population , (CAST(total_cases AS FLOAT)/population)*100 as InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%canada%'
order by 1,2


-- Looking at Coutries with highest infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/population))*100 as InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%canada%'
GROUP BY location, population
order by InfectionPercentage DESC 


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%canada%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc


SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%canada%'
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- GLOBAL NUMBERS
-- This gives the amount of cases globally per day in the amount of deaths globally per day as well as the percentage of deaths per day

SELECT date, SUM(new_cases) as GlobalCases, SUM(new_deaths) as GlobalDeaths, (CAST((SUM(new_deaths)) AS FLOAT)/SUM(new_cases))*100 as GlobalDeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%canada%'
WHERE continent is not NULL
GROUP BY date 
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinatedPerDay
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 2,3
	


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinatedPerDay)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinatedPerDay
	FROM PortfolioProject.dbo.CovidDeaths dea
	JOIN PortfolioProject.dbo.CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not NULL 
	--ORDER BY 2,3
)
SELECT *, (CONVERT (FLOAT, TotalVaccinatedPerDay)/Population)*100 as PopulationPercentVaccinated
FROM PopvsVac




-- TEMP TABLE


DROP Table IF exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
	Contient varchar(255),
	Location varchar(255),
	Date date,
	Population bigint,
	New_vaccinations bigint,
	TotalVaccinatedPerDay bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinatedPerDay
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL 
--ORDER BY 2,3

SELECT *, (CONVERT (FLOAT, TotalVaccinatedPerDay)/Population)*100 as PopulationPercentVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


USE PortfolioProject;

CREATE View PopulationVaccinatedPerDay as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVaccinatedPerDay
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not NULL 
--ORDER BY 2,3



