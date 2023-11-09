SELECT * FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--SELECT * FROM PortfolioProject..covidVaccinations
--order by 3,4;

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases VS Total Deaths
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2

-- Looking at the Total Cases VS Population 
-- Shows what percentage of Population got Covid
SELECT  location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like 'india'
order by 1,2


--countries with Highest infection rate Compaired to Population

SELECT location,population, max(total_cases)as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by location,population
order by PercentPopulationInfected desc
 

 -- Showing Contries With Highest Death Count per Population
 
SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--LETS BREAK THINGS BY CONTINENT
--Showing Continent with Highest Death Count per Population


SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking total population VS Vaccination

--joining the table CovidDeaths and CovidVacinnation

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND	dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND	dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 
FROM PopvsVac





-- USING TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND	dea.date = vac.date
--where dea.continent IS NOT NULL
--order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	AND	dea.date = vac.date
where dea.continent IS NOT NULL
--order by 2,3

SELEcT * from PercentPopulationVaccinated