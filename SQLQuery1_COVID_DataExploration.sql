
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select data that im going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Likelihood of death by COVID by country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%brazil%'
order by 1,2


-- Looking at total cases vs population
-- Highlights percentage of population with COVID

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by population, location
order by PercentPopulationInfected desc


--Highlighting countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--**Highlighting continents with highest death count per population**

--select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount desc

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

-- Showcases daily cases and deaths globally
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Showcases overall cases and deaths globally
select SUM(new_cases) as total_cases, SUM(convert(int, new_deaths)) as total_deaths, SUM(convert(int, new_deaths))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at total population vs vaccinations

select dth.continent, dth.location, vac.date, dth.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vac
	on dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null
order by 2,3


-- Highlights amount of people vaccinated per day and adds to the total vaccinatd by country.

Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By (TotalPeopleVaccinated) in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dth.continent is not null  
)
Select *, (TotalPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentVaccinated
Create Table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date

Select *, (TotalPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentVaccinated




-- Creating View to store data for later visualizations

Create View PercentVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dth.Location Order by dth.location, dth.Date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
where dea.continent is not null 
	
	
	
	
	
	
	
	
