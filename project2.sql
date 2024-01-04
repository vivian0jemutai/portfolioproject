SELECT * FROM portfolioproject.`covid deaths - copy`
order by 3,4;
 -- select data  to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.`covid deaths - copy`
order by 1,2;
-- total_cases vs deaths
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as deathpercentage
FROM portfolioproject.`covid deaths - copy`
where location like '%andorra%'
order by 1,2;
-- total_cases vs population
SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as casepercent
FROM portfolioproject.`covid deaths - copy`
where location like 'algeria%'
order by 1,2;

-- countries with highest infection 
SELECT location, population,  max((total_cases)) as  highest_infection, max((total_cases/population))*100 as percentpopulationinfected
FROM portfolioproject.`covid deaths - copy`
-- where location like 'algeria%'
group by location, population
order by percentpopulationinfected desc ;

-- countries with highest deathcount per population
SELECT location, population,  max(cast(total_deaths as signed)) as  highest_deaths, max((total_deaths/population))*100 as percentpopulationdeaths
FROM portfolioproject.`covid deaths - copy`
-- where location like 'algeria%'
group by location, population
order by percentpopulationdeaths desc;

-- by continents
SELECT continent, max(total_deaths) as  highest_deaths, max((total_deaths/population))*100 as percentpopulationdeaths
FROM portfolioproject.`covid deaths - copy`
where continent is not null
group by continent
order by percentpopulationdeaths desc;
-- population vs vaccination using cte
with PopvsVac (continent, location, date, population, new_vaccinations, peoplevaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast( vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
 , (peoplevaccinated/popuLation)*100 
FROM portfolioproject.`covid deaths - copy` dea
join portfolioproject.`covid vaccination - copy` vac
on dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null
)
select*
from popvsvac;

-- temporary table
drop table if exists percentpopulationvaccinated;
create table percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
population numeric,
date date,
new_vaccinations numeric,
peoplevaccinated numeric
);


insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.population, dea.date new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
-- , (peoplevaccinated/popuLation)*100 
FROM portfolioproject.`covid deaths - copy` dea
join portfolioproject.`covid vaccination - copy` vac
on dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null;

select*
from peoplevaccinated;


-- creating view
create view peoplevaccinated as
select dea.continent, dea.location, dea.population, dea.date new_vaccinations,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as peoplevaccinated
-- , (peoplevaccinated/popuLation)*100 
FROM portfolioproject.`covid deaths - copy` dea
join portfolioproject.`covid vaccination - copy` vac
on dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null;








