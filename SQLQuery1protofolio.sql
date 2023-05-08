--Select *
--From CovidDeaths$

--Select *
--From CovidVaccinations$

--Select data we are going to use 

--Select location ,date, total_cases,new_cases,total_deaths,population_density
--From CovidDeaths$
--order by 1,2

-- looking at total cases vs total death
--shows the likelihoode of death if you contract covid in your country
Select  location ,date, total_cases,total_deaths, (cast (total_deaths AS money) /cast (total_cases as money) )*100  as DeathPercentage
From CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at total cases vs  Population
-- shows what percentage of population got covid
Select  location ,date,population_density, total_cases, (cast (total_cases AS money) /cast (population_density as money) )*100  as DeathPercentage
From CovidDeaths$
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to popultion 
-- shows what percentage of population got covid
Select  location ,population_density, Max(total_cases)as HighestInffectionCount, Max((cast (total_cases AS money) /cast (population_density as money) )*100)  as PercentPopulationInfected
From CovidDeaths$
Group by location,population_density
order by PercentPopulationInfected Desc


-- shows countries with highest death count
Select  location , Max(cast(total_deaths as int ))as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount Desc

-- Let's break things down By continent
Select   continent, Max(cast(total_deaths as int ))as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount Desc

-- Showing the contienent with the highest death count per population
Select   continent, Max(cast(total_deaths as int ))as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount Desc

--GLOBAL NUMBERS
SET ARITHABORT OFF; --statement ends a query when an overflow or divide-by-zero error occurs during query execution 
SET ANSI_WARNINGS OFF;--We can use it in conjunction with SET ANSI WARNINGS to return NULL
Select  date, sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From CovidDeaths$
where continent is not null
Group By date 
order by 1,2

--Looking at total Population VS Vaccinations
select dea.continent,dea.location,dea.date,dea.population_density
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --Looking at total Population VS Vaccinations

select dea.continent,dea.location,dea.date,dea.population_density 
,SUM(convert (int ,dea.new_cases)) over( partition by dea.location order by 
dea.location ,dea.date) as RollingPepoleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

 --Using CTE
SET ARITHABORT OFF;  
SET ANSI_WARNINGS OFF;
with PopVsVac (continent,location,date,population_density,new_vaccinations,RollingPepoleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,SUM(convert (int ,vac.new_vaccinations)) over(partition by dea.location order by 
dea.location ,dea.date) as RollingPepoleVaccinated
from CovidDeaths$  dea
join CovidVaccinations$  vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPepoleVaccinated/population_density)*100 
from PopVsVac

--Temp Table
--Drop table if exists PercentPopulationVaccinated
 Create Table PercentPopulationVaccinated
 (
 contintent nvarchar(255),
 Location nvarchar(255),
 Date dateTime,
 Population numeric,
 new_Vaccinations numeric,
 RollingPepoleVaccinated numeric
 )

Insert into  PercentPopulationVaccinated 
 select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,SUM(convert (int ,vac.new_vaccinations)) over(partition by dea.location order by 
dea.location ,dea.date) as RollingPepoleVaccinated
from CovidDeaths$  dea
join CovidVaccinations$  vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPepoleVaccinated/Population)*100 
from PercentPopulationVaccinated


--Creating view to store data for later visualizers
Create view RollingPepoleVaccinated as
 select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations
,SUM(convert (int ,vac.new_vaccinations)) over(partition by dea.location order by 
dea.location ,dea.date) as RollingPepoleVaccinated
from CovidDeaths$  dea
join CovidVaccinations$  vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

