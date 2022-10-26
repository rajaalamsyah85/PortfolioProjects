/*

	Queries used for Tableau Project

*/



-- 1. 

select sum(convert(float, new_cases)) as total_cases, sum(convert(float, new_deaths)) as total_deaths 
	, sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as death_percentage
from CovidDeaths$
--where location like '%Indonesia%'
where continent is not null 
--group by date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--select sum(convert(float, new_cases)) as total_cases, sum(convert(float, new_deaths)) as total_deaths 
	--, sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as death_percentage
--from CovidDeaths$
--where location like '%Indoensia%'
--where location = 'World'
--group by date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

select location, sum(convert(float, new_deaths)) as total_death_count
from CovidDeaths$
--where location like '%Indoensia%'
where continent is null 
and location not in ('World', 'High income', 'Upper middle income', 
	'Lower middle income', 'European Union' ,'Low income', 'International')
group by location
order by total_death_count desc


-- 3.

select location, population, max(convert(float, total_cases)) as highest_infection_count  
	, max(convert(float, total_cases)/population)*100 as percent_population_infected
from CovidDeaths$
--where location like '%Indonesia%'
group by location, population
order by percent_population_infected desc


-- 4.

select location, population, date, max(convert(float, total_cases)) as highest_infection_count  
	, max(convert(float, total_cases)/population)*100 as percent_population_infected
from CovidDeaths$
--where location like '%Indonesia%'
group by location, population, date
order by percent_population_infected desc