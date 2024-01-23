SELECT *
FROM covid19..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM covid19..CovidVaccinations
--order by 3,4

--select Data that we are going to be used
 select location, date, total_cases, new_cases,total_deaths, population
 from covid19..CovidDeaths
 where continent is not null
 order by 1,2

 --Looking at Total Cases vs Total Deaths

 select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
 from covid19..CovidDeaths
 where location like '%india%'
 and continent is not null
 order by 1,2

 --looking at the Total Cases vs Population
 --shows what percentage of population got covid

 select location, date, population,total_cases, (total_cases/population)*100 as DeathPercentages
 from covid19..CovidDeaths
 --where location like '%india%'
 where continent is not null
 order by 1,2

 --Looking at country with highest infection rate compared to population

 select location, population,MAX (total_cases) as HighestInfectionCount,MAX ((total_cases/population))*100 as PercentPopulationInfected
 from covid19..CovidDeaths
 --where location like '%india%'
 where continent is not null
 Group by location,population
 order by PercentPopulationInfected desc

 --showing country with Highest Death Count Per population

 select location,MAX (cast (total_deaths as int)) as TotalDeathCount
 from covid19..CovidDeaths
 --where location like '%india%'
 where continent is not null
 Group by location,population
 order by TotalDeathCount desc


 --Let's Break Thing Down By CONTINENT

select continent,MAX (cast (total_deaths as int)) as TotalDeathCount
from covid19..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--showing continent with the highest death count per population

select continent,MAX (cast (total_deaths as int)) as TotalDeathCount
from covid19..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
select   SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
 from covid19..CovidDeaths
 --where location like '%india%'
 where continent is not null
 --group by date
 order by 1,2


 --Looking at total population vs total vaccinations
  --Shows Percentage of Population that has recieved at least one Covid Vaccine
 --select *
 --from covid19..CovidDeaths dea
 --join covid19..CovidVaccinations vac
	--on  dea.location=vac.location
	--and dea.date= vac.date

	--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 --from covid19..CovidDeaths dea
 --join covid19..CovidVaccinations vac
	--on  dea.location=vac.location
	--and dea.date= vac.date
	--where dea.continent is not null
	--order by 2,3

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid19..CovidDeaths dea
Join covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

