--Queries destinated for Tableau Project
--1st query : 
Select Sum(new_cases) as TotalCases, sum(Cast(new_deaths as int )) as TotalDeaths, (sum(Cast(new_deaths as int ))/sum(new_cases) ) *100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2 
-- Just a double check based off the data provided
--This query includes "International"  Location

--2nd Query :
--Note that in the 1st query we didn't include the numbers with contint = null, so we need to stay consistent
--We take  World , international and European union  out as they are not included in the above query 
--European Union is part of Europe
Select location, sum(Cast(new_deaths as int )) as TotalDeaths
from dbo.CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeaths desc             

--3rd Query :
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--4th Query: let's add the dimension of time to our analysis 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
