SELECT *
FROM CovidDeath
ORDER BY 3,4

SELECT *
FROM CovidVacinaations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1,2

--Likelihood that you die if you contract Covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE Location like '%cana%'
ORDER BY 1,2

-- Total cases vs the population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Infection_percentage
FROM CovidDeath
WHERE Location like '%States%'
ORDER BY 1,2

-- Countries with the highest infection rate
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS Infection_percentage
FROM CovidDeath
--WHERE Location like '%States%'
GROUP BY population, location
ORDER BY Infection_percentage DESC

-- Countries with the highest death count per population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeath
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC

-- Breakdown thing to continent
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeath
--WHERE Location like '%States%'
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC

-- GLOBAL FIGURES
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS DeathPercent 
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Polulation vs Vacinnation
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
FROM CovidDeath dea
JOIN CovidVacinaations vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH popvsvac(continent,location,date,population,new_vacinations,TotalVac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
FROM CovidDeath dea
JOIN CovidVacinaations vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
select *, (TotalVac/population)*100 AS PercentVacinated
FROM popvsvac

-- Temp Table
DROP TABLE IF EXISTS #PercentPolulationVacinated
CREATE TABLE #PercentPolulationVacinated
(
continent nvarchar(255),
lovation nvarchar(255),
date datetime,
population numeric,
new_vacccinations numeric,
TotalVac numeric
)
insert into #PercentPolulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
FROM CovidDeath dea
JOIN CovidVacinaations vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select *,(TotalVac/population)*100 AS PercentVacinated
FROM #PercentPolulationVacinated

CREATE VIEW PercentPolulationVacinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalVac
FROM CovidDeath dea
JOIN CovidVacinaations vac
	ON dea.location = vac.location
	AND dea.date = vac. date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPolulationVacinated