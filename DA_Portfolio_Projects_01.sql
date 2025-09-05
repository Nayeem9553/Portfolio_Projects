
----FROM Portfolio_Project_01.[dbo].CovidDeaths
----FROM Portfolio_Project_01..CovidDeaths
----Where continent is not null
----ORDER BY 3,4


--Select location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio_Project_01..CovidDeaths 
--ORDER BY 1,2

-- //TotalCase vs Total Deaths

--Select location, date, total_cases, total_dea ths, (total_deaths/total_cases)* 100 as deathpercentage
--FROM Portfolio_Project_01..CovidDeaths 
--ORDER BY 1,2


-- Shows the percentage of dyng if you contract with covid withn in the mentioned country

--SELECT	Location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)* 100 as DeathPerecentage
--FROM Portfolio_Project_01..CovidDeaths
----WHERE location like '%states%'
--WHERE location like '%desh%'
--ORDER BY 1, 2

-- Looking at total cases vs population
--SELECT Location, date, total_cases, population, (total_cases/population)* 100 as Casepercentage
--FROM Portfolio_Project_01..CovidDeaths
--WHERE Location like '%desh%'
--ORDER BY 1,2

-- Country with Highest infection count 
--SELECT Location, MAX(total_cases), population, MAX((total_cases/population))* 100 as Highest_infection_rate
--FROM Portfolio_Project_01..CovidDeaths
----WHERE Location like '%desh%'
--GROUP BY location, population
--ORDER BY Highest_infection_rate desc
    
-- Highest death count by location/country
--SELECT Location, MAX(cast(total_deaths as int)) as Highest_death_Count
--FROM Portfolio_Project_01..CovidDeaths
----WHERE Location like '%desh%'
--WHERE continent is not null
--GROUP BY location
--ORDER BY Highest_death_Count desc

----Highest death count by continent

--SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Portfolio_Project_01..CovidDeaths
--Where continent is not null
--Group By continent 
--Order By TotalDeathCount desc

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Portfolio_Project_01..CovidDeaths
--Where continent is null
--Group By location 
--Order By TotalDeathCount desc


-- Global NUMBERS
--SELECT date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
--SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
--FROM Portfolio_Project_01..CovidDeaths
--WHERE continent is not null
--GROUP By date 
--ORDER By 1,2

--Looking at total population vs vaccination

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--FROM Portfolio_Project_01..CovidDeaths dea --aliasing
--JOIN Portfolio_Project_01..CovidVaccination vac
--	 ON dea.location = vac.location 
--	and dea.date = vac.date
--Where dea.continent is not null 
--and vac.new_vaccinations is not null

 --Where dea.continent like '%Asia%' 
 --ORDER by new_vaccinations desc 
 --Order by 5 desc
 --Order by 2,3 

--Total population vs vaccinaitons by CTE
--With PopvsVac (Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
--as
--(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- SUM(CONVERT(int , vac.new_vaccinations)) OVER 
-- (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

-- FROM Portfolio_Project_01..CovidDeaths dea 
-- JOIN Portfolio_Project_01..CovidVaccination vac
--	 ON dea.location = vac.location
--	and dea.date = vac.date
-- Where dea.continent is not null 
----Order by 2,3      Order by clause cannot be in there 
--)
--Select *, (RollingPeopleVaccinated/Population)*100
--From PopvsVac

----Temp table
--drop table if exists #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar (255),
--Location nvarchar(255),
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--)


--Insert into #PercentPopulationVaccinated
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- MAX(CONVERT(int , vac.new_vaccinations)) OVER 
-- (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

-- FROM Portfolio_Project_01..CovidDeaths dea 
-- JOIN Portfolio_Project_01..CovidVaccination vac
--	 ON dea.location = vac.location
--	and dea.date = vac.date
-- Where dea.continent is not null 
--Order by 2,3

--Select *, (RollingPeopleVaccinated/Population)*100
--From #PercentPopulationVaccinated

--Creating View to store data for later visualization



 CREATE VIEW PP_Vaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
        (PARTITION BY dea.location ORDER BY dea.date ROWS UNBOUNDED PRECEDING) 
        AS RollingPeopleVaccinated
FROM Portfolio_Project_01..CovidDeaths dea
JOIN Portfolio_Project_01..CovidVaccination vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
