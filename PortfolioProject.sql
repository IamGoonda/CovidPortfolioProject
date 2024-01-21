SELECT * 
FROM PortfolioProject.dbo.coviddeathsfixed1

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
----

SELECT location, observation_date, total_cases, total_deaths, (convert(float,total_deaths) / (NULLIF(convert(float,total_cases),0)))*100 AS Mortality_Rate
FROM PortfolioProject.dbo.CovidDeathsFixed1
WHERE location like 'india'
ORDER BY 1,2

-- Highest infection per contury 

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX(cast(total_cases as float)/ population)*100 AS Infection_Rate
FROM PortfolioProject.dbo.CovidDeathsFixed1
WHERE continent is not null
GROUP BY location, population
ORDER BY Infection_Rate desc

-- Death Count / Continent

SELECT location, SUM(new_deaths) as Death_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1
WHERE continent is null
GROUP BY location
ORDER BY Death_Count desc

--THIS DOESNT INCLUDE WORLD 
--SELECT continent, SUM(new_deaths) as Death_Count
--FROM PortfolioProject.dbo.CovidDeathsFixed1
--WHERE continent is not null
--GROUP BY continent
--ORDER BY Death_Count desc


-- Death Count / Country

SELECT location, SUM(new_deaths) as Death_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1
WHERE continent is not null
GROUP BY location
ORDER BY Death_Count desc

-- Cases count per day / world

SELECT observation_date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Death_Count, (SUM(CAST(new_deaths as float)) / SUM(new_cases))*100 as Mortality_Rate
FROM PortfolioProject.dbo.CovidDeathsFixed1
WHERE continent is not null
GROUP BY observation_date
ORDER BY 1


-- Total population vs Vaccinations

SELECT deaths.location, deaths.observation_date, deaths.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.observation_date) as Rolling_Vaccinations_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1 deaths
Join PortfolioProject.dbo.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.observation_date = vac.observation_date
WHERE deaths.continent is not null
ORDER BY 1, 2

-- 

WITH Vaccinations_Per_Pop (location, observation_date, population, new_vaccinations, rolling_vaccinations_count)
AS
(
SELECT deaths.location, deaths.observation_date, deaths.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.observation_date) as Rolling_Vaccinations_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1 deaths
Join PortfolioProject.dbo.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.observation_date = vac.observation_date
WHERE deaths.continent is not null
)
SELECT *, (rolling_vaccinations_count/population)*100 as Percent_Pop_Vaccinated
FROM Vaccinations_Per_Pop
ORDER BY 1,2

-- TEMP TABLE for above query

DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Location varchar(255),
Observation_date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations_count numeric
)

INSERT INTO #PercentPopVaccinated
SELECT deaths.location, deaths.observation_date, deaths.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.observation_date) as Rolling_Vaccinations_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1 deaths
Join PortfolioProject.dbo.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.observation_date = vac.observation_date
WHERE deaths.continent is not null

SELECT *, (rolling_vaccinations_count/population)*100 as Percent_Pop_Vaccinated
FROM #PercentPopVaccinated
ORDER BY 1,2

-- View for visualizations
USE PortfolioProject
GO
CREATE VIEW Percent_Population_Vaccinated as
SELECT deaths.location, deaths.observation_date, deaths.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) OVER (Partition by deaths.location ORDER BY deaths.location, deaths.observation_date) as Rolling_Vaccinations_Count
FROM PortfolioProject.dbo.CovidDeathsFixed1 deaths
Join PortfolioProject.dbo.CovidVaccinations vac
	ON deaths.location = vac.location
	AND deaths.observation_date = vac.observation_date
WHERE deaths.continent is not null




