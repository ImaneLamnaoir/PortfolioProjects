--Looking at total cases and total deaths
--This shows the likelihood if you contract covid in your country
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%rope%'
--order by 1,2

--looking at totalCases versus population 
--shows what pourcentage of population got covid
--select location, total_cases , population, (total_cases/population)*100 as Pourcentage_got_covid
--from PortfolioProject..CovidDeaths 
--where location like '%Canada%'
--order by 1

--Looking at countries with highet infection rate
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as percentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location, population
order by percentPopulationInfected DESC

--ShowingCountriesWithHighestDeathCountperPopulation
select location, max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location
order by HighestDeathCount DESC

--Let's break things down by continent
select continent, max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
Group by continent
order by HighestDeathCount DESC


--Global numbers
--on each day the total accross the world
select date, sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
group by date
order by 1,2

--Looking at total population (firstTable) versus vaccination(newTable)
--Let's join our t2o tables
-- when doin so , we should prefix our column with the table alea to avoind confusing queries
--cast (expression as targetType)
--sum  over (partition by ) applies the agregation function on each partition and shows the result for each row the same
-- when u add orderby , it will order the sum withing the ranges of the partition ( cumul)
--still facing a problem with the column new_vaccinations


--use cti
with PopvsVac(location, continent, date, population, new_vaccinations,rollingPeopleVaccinated)
as
(
select dea.location, dea.continent, dea.date, dea.population, dea.new_vaccinations, sum(cast(dea.new_vaccinations as float)) over  ( Partition by dea.location order by dea.date , dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (rollingPeopleVaccinated/population )*100 as rollingppleVaccinatedperpopulation
from PopvsVac
--Note that when u just create an alea , u cant use it to perform calculations over it , then we be using cte
--CTE stands for "Common Table Expression." In SQL, a CTE is a temporary result set that can be referred to within a SELECT, INSERT, UPDATE, or DELETE statement.
--It can be thought of as a named subquery that can be used to simplify complex queries by breaking them down into smaller, 
--more manageable parts. CTEs are defined using the WITH clause and can be used to improve readability and maintainability of complex queries.
--Number of columns in cti should be the same as number of columns in the select statement


--OTHER METHOD temp table
drop table if exists #percentpopulationvaccinated
Create table  #percentpopulationvaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingpeopleVaccinated numeric
)
Insert into #percentpopulationvaccinated
select dea.location, dea.continent, dea.date, dea.population, dea.new_vaccinations, sum(cast(dea.new_vaccinations as float)) over  ( Partition by dea.location order by dea.date , dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

--showing
Select * , (rollingPeopleVaccinated/population )*100 as rollingppleVaccinatedperpopulation
from #percentpopulationvaccinated

--creating a view to store data for later visualisation
create view percentpopulationvaccin as
select dea.location, dea.continent, dea.date, dea.population, dea.new_vaccinations, 
 sum(cast(dea.new_vaccinations as float)) over  ( Partition by dea.location order by dea.date , dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--that view is permanent, we can use this for visualisation later 
-- u can querry this normally
select *
from percentpopulationvaccin
--Voila