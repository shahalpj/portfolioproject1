select *
from portfolioproject..[covid deaths]
where continent is not null
order by 3,4

--select *
--from portfolioproject..[covid vaccinations]
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..[covid deaths]
where continent is not null
order by 1,2

--looking at total cases vs totsl deaths
--show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..[covid deaths]
where location like'%states%'
and continent is not null
order by 1,2

--looking at total cases vs population
--show what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from portfolioproject..[covid deaths]
--where location like'%states%'
order by 1,2

--looking at countries with highest infection rate compare to population

select location, population, max(total_cases)as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..[covid deaths]
--where location like'%states%'
group by location, population
order by percentpopulationinfected desc

--showing countries with the highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..[covid deaths]
--where location like'%states%'
where continent is not null
group by location
order by totaldeathcount desc

--LETS BREAK THINGS DOWN BY CONTINENT

--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..[covid deaths]
--where location like'%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..[covid deaths]
--where location like'%states%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3


-- use cte

with popvsvac (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
 )
 select *, (rollingpeoplevaccinated/population)*100
 from popvsvac



 --temp table 

 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 rollingpeoplevaccinated numeric
 )

 insert into #percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3

 select *, (rollingpeoplevaccinated/population)*100
 from #percentpopulationvaccinated

 --creating view to store data for later visualizations
 create view percentpopulationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rolingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3

	 select *
	 from percentpopulationvaccinated