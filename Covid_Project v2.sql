
select *
From PortafolioProject..CovidDeaths
Where continent is not null 
Order by 3,4

--select *
--From PortafolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortafolioProject..CovidDeaths
Where continent is not null 
order by 1,2 


-- Looking at total cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
From PortafolioProject..CovidDeaths
where location like '%colomb%'
and continent is not null 
order by 1,2 

-- Looking at total cases vs population
-- Show what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 AS GotCovidPercentage
From PortafolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at countries with highest infaction rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS PercentPopulationInfected
From PortafolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as HighestDeathsCount
From PortafolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null 
Group by location
order by HighestDeathsCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents qith the highest death count per population

select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From PortafolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount Desc

--GLOBAL NUMBERS 

select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathsPercentage
From PortafolioProject..CovidDeaths
--where location like '%colomb%'
where continent is not null
--group by date
order by 1,2 

-- Looking at total Population vs Vaccionations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Count number of zeros we have for make sure that works


SELECT COUNT(new_vaccinations) as Number_of_NULL_values
from PortafolioProject..CovidVaccinations
where new_vaccinations = 0

--convert NULL in Zeros

Update PortafolioProject..CovidVaccinations
SET new_vaccinations = 0
Where new_vaccinations IS NULL


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatios numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store for later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortafolioProject..CovidDeaths dea
Join PortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated