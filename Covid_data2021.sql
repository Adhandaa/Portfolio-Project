select * from covid_deaths 
order by 3,4;

select * from covid_vaccination
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths order by 1,2;

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location = 'United States'
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulation
from covid_deaths
where location = 'United States'
order by 1,2;


select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected 
from covid_deaths
group by location, population
order by PercentagePopulationInfected desc;

select location, MAX(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Let's break things down by CONTINENT
-- showing continents with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global numbers

select SUM(new_cases) as total_cases ,SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from covid_deaths
where continent is not null
-- group by date
order by 1,2;


with pop_vs_vac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 from pop_vs_vac;
 
-- Temp Table

-- drop table if exists PercentagePopulationVaccinated;

create table PercentagePopulationVaccinated (
	continent varchar(255),
	location varchar(255),
	date date,
	population numeric,
	new_vaccination numeric,
	RollingPeopleVaccinated numeric
); 

insert into PercentagePopulationVaccinated (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)

select *, (RollingPeopleVaccinated/population)*100 from PercentagePopulationVaccinated;

-- creating view to store data for later visuzlization

-- create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths as dea
join covid_vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentagePopulationVaccinated;


