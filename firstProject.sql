Select *
From coviddeaths
where continent is not null
order by 3,4;


--Select *
--From covidvaccinations;

--Select Data that we are going to be using
Select location, date_date, total_cases, new_cases, total_deaths, population
From coviddeaths
order by 1,2;

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying  if you contract covid in your country
Select location, date_date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddeaths
where location like '%Bosnia%'
order by 1,2;

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From coviddeaths
Group by Location, Population
order by InfectionPercentage desc;

--
Select Location, Population, date_date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From coviddeaths
Group by Location, Population, date_date
order by InfectionPercentage desc;
--

--Showing countries with highest death count per population
/*Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
where continent is not null
Group by Location
order by TotalDeathCount desc; */

--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
where continent is null
Group by location
order by TotalDeathCount desc;

--Showing continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From coviddeaths
where continent is null
Group by location
order by TotalDeathCount desc;

--GLOBAL NUMBERS
Select date_date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From coviddeaths
where continent is not null
group by date_date
order by 1,2;

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From coviddeaths
where continent is not null
--group by date_date
order by 1,2;

Select location, SUM(new_deaths) as TotalDeathCount
From coviddeaths
where continent is null
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc;

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date_date, dea.population, vac.new_vaccinations
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date_date = vac.date_date
where dea.continent is not null
order by 2, 3;

Select dea.continent, dea.location, dea.date_date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (Partition by dea.location order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date_date = vac.date_date
where dea.continent is not null
order by 2, 3;

--USE CTE
With PopvsVac (continent, location, date_date, population, new_vaccinations, RollingPeopleVaccinated) as (
Select dea.continent, dea.location, dea.date_date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (Partition by dea.location order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date_date = vac.date_date
where dea.continent is not null
--order by 2, 3
)
Select  Continent, Location, date_date, Population, New_Vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/Population)*100
From PopvsVac
--Select  p.((RollingPeopleVaccinated/population)*100) 
--from PopvsVac p;

--TEMP TABLE
--DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent varchar2(255),
Location varchar2(255),
date_date date,
Population number(38),
New_vaccinations number(38),
RollingPeopleVaccinated number(38)
)
Select * from PercentPopulationVaccinated;


Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date_date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (Partition by dea.location order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date_date = vac.date_date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 
from PercentPopulationVaccinated;

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date_date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (Partition by dea.location order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
    On dea.location = vac.location
    and dea.date_date = vac.date_date
where dea.continent is not null;
--order by 2, 3

Select * 
From PercentPopulationVaccinatedView;







