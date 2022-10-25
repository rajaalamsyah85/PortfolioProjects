/*

	Covid 19 Data Exploration

	Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



-- Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths)/convert(float,total_cases)*100 as death_percentage
from CovidDeaths$
where location like '%Indonesia%' 
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Show what percentage of population got covid
select location, date, total_cases, population, convert(float, total_cases)/(population)*100 as infected_population_percentage
from CovidDeaths$
where continent is not null
order by 1,2


-- Countries with highest infection rate compared to population
select location, population, max(convert(float, total_cases)) as highest_infection, max(convert(float, total_cases)/population)*100 as infected_population_percentage
from CovidDeaths$
where continent is not null
group by location, population
order by infected_population_percentage desc


-- Countries with highest death count per population
select location, max(convert(float, total_deaths)) as total_death_count
from CovidDeaths$
where continent is not null
group by location
order by total_death_count desc



-- Breaking things down by continent

-- Showing continents with the highest death per count population
select continent, max(convert(float, total_deaths)) as total_death_count
from CovidDeaths$
where continent is not null
group by continent
order by total_death_count desc


-- Global Numbers

select sum(convert(float, new_cases)) as total_cases, sum(convert(float, new_deaths)) as total_deaths,
	sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as death_percentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vacinations
-- Shows percentage of population that has received at least one covid vaccine 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(convert(float, cv.new_vaccinations)) over (partition by cd.location, cd.date) as rolling_people_vaccinated
--,	(rolling_people_vaccinated/cd.population)*100	
from CovidDeaths$ cd
inner join CovidVaccinations$ cv
on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- Using CTE to perform calculation on partition by in previous query
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(convert(float, cv.new_vaccinations)) over (partition by cd.location, cd.date) as rolling_people_vaccinated
--,	(rolling_people_vaccinated/cd.population)*100	
from CovidDeaths$ cd
inner join CovidVaccinations$ cv
on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac


-- Using temp table to perform calculation on partition by in previous query

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric,
)


insert into #percent_population_vaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(convert(float, cv.new_vaccinations)) over (partition by cd.location, cd.date) as rolling_people_vaccinated
--,	(rolling_people_vaccinated/cd.population)*100	
from CovidDeaths$ cd
inner join CovidVaccinations$ cv
on cd.location = cv.location
	and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated



-- Creating view to store data for later visualizations

create view percent_population_vaccinated_visualization as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(convert(float, cv.new_vaccinations)) over (partition by cd.location, cd.date) as rolling_people_vaccinated
--,	(rolling_people_vaccinated/cd.population)*100	
from CovidDeaths$ cd
inner join CovidVaccinations$ cv
on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null



