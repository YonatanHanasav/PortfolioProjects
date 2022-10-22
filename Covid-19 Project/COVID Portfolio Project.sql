--Data Exploration

-- Select the data that we are going to be using
Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Total cases vs total deaths
-- Shows the likelihood of dying if you get infected by covid in your country
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where location = 'Israel' and continent is not null
Order by 2

-- Total cases vs population
-- Shows what percentage of population got infected by covid
Select location,date,population,total_cases,(total_cases/population)*100 as PercentInfected 
From PortfolioProject..CovidDeaths
Where location = 'Israel' and continent is not null
Order by 2

-- Percent of infected people by date of each country
Select location, population, date, ISNULL(HighestInfectionCount, 0 ) as HighestInfectionCount , ISNULL(PercentInfected, 0 ) as  PercentInfected
From (
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentInfected 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population, date
) a
Order by PercentInfected desc 





-- Countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfected 
From PortfolioProject..CovidDeaths
Where continent is not null and population is not null
Group by location,population
Having MAX(total_cases) is not null
Order by PercentInfected desc

--  Countries with highest death count per population
Select location,MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
Order by 2 desc

-- Breaking down to continents
-- Total death count of each continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null and location in (select continent from PortfolioProject..CovidDeaths)
Group by location
Order by TotalDeathCount desc


-- Let's check global numbers of infected people dying from Covid
Select date, SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths,
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as InfectedDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Total global numbers
Select SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths,
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as InfectedDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total population vs vaccinations per date
-- Need to use CTE for the calculations
With PopvsVac(continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths as dea 
	Join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinations/population)*100 as VaccinatedPopulationPercentage
From PopvsVac



-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
With PopvsVac(continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths as dea 
	Join PortfolioProject..CovidVaccinations as vac 
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinations/population)*100 as VaccinatedPopulationPercentage
From PopvsVac


