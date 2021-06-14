/* COVID 19 Data Exploration

	Skills used : Join, CTE's, Temp Tables, Windows Functions, Creating Views, Converting Datatypes	

*/

select * 
from portfolio_project.dbo.covid_death
where continent is not null
order by continent

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases,total_deaths, population 
from portfolio_project.dbo.covid_death
where continent is not null
order by location, date

-- Looking at total case vs total deaths
-- Shows likelyhood of dying if infected by COVID in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project.dbo.covid_death
where location like '%India%'
order by location, date


-- Looking at total cases vs population

select  location, date, total_cases, population, (total_cases/population)*100 as casse_percentage 
from portfolio_project.dbo.covid_death
where location like 'India'
order by location, date

-- Looking at countries with highiest Infection Rate compared to population

select  location, MAX(total_cases) as highiest_infection_rate, population, MAX((total_cases/population))*100 as casse_percentage 
from portfolio_project.dbo.covid_death
group by location, population
order by casse_percentage desc

-- Showing countries with highiest Death count per population


select  location,  MAX(cast(total_deaths as int)) as total_death_count
from portfolio_project.dbo.covid_death
where continent is not null
group by location
order by total_death_count desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


select  continent, MAX(cast(total_deaths as int)) as total_death_count
from portfolio_project.dbo.covid_death
where continent is not null
group by continent
order by total_death_count desc

-- GLOBAL NUMBERS

-- Global Death percentage per day

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from portfolio_project.dbo.covid_death
where continent is not null
group by date
order by 1,2

--Total Death percentage Globally 

select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from portfolio_project.dbo.covid_death
where continent is not null

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from portfolio_project.dbo.covid_death dea
	join portfolio_project.dbo.covid_vaccination vac
	on  dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Using Temp Table to perform Calculation on Partition By in previous query


drop table temp
create table temp
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccination numeric,
total_vaccinated numeric
)
insert into temp
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from portfolio_project.dbo.covid_death dea
	join portfolio_project.dbo.covid_vaccination vac
	on  dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null

select *,(total_vaccinated/population)*100
from temp


-- Creating View to store data for visualization

create view total_vaccinated_percentage 
as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from portfolio_project.dbo.covid_death dea
	join portfolio_project.dbo.covid_vaccination vac
	on  dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null


