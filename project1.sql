select * from [portfolio project] ..coviddeath
where continent is null
--select data we are going to be using 

select location , date,total_cases,new_cases,total_deaths,population
from [portfolio project]..coviddeath
order by 1,2

--locking for total cases vs total deaths
--shows the percentage of deaths to cases in your country you want

select location , date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentgedeaths
from [portfolio project]..coviddeath
where location like '%states'
order by 1,2

--locking at total cases vs population
--shows what percentage of population got covid in each country
select location , date,population,total_cases,(total_cases/population)*100 as casespercentage
from [portfolio project]..coviddeath
where location like '%states%'
order by 1,2

--looking at the countrieswith highest infection rate compareed to population
select location ,population,max(total_cases) as maxtotalcases,max((total_cases/population)*100)as maxcasespercentage
from [portfolio project]..coviddeath
where location like '%%'
group by location,population
order by 4 desc

--shows country with highest percentage of deaths per population 
select location ,population,max(total_deaths) as maxtotaldeaths,max((total_deaths/population)*100)as maxdeathspercentage
from [portfolio project]..coviddeath
where location like '%%'
group by location,population
order by 4 desc

--shows country with highest percentage of deaths per cases
select location ,max(cast(total_deaths as int)) as maxtotaldeaths,max(total_cases) as maxtotalcases,max((total_deaths/total_cases)*100)as maxdeathspercentage
from [portfolio project]..coviddeath
where location like '%%' and continent is not null
group by location
order by 2 desc

--shows country with highest percentage of death count per cases and per population 
select location ,max(cast(total_deaths as int)) as maxtotaldeaths,max(total_cases) as maxtotalcases,max((cast(total_deaths as int)/total_cases)*100)as maxdeathspercentage
from [portfolio project]..coviddeath
where continent is null
group by location
order by 2 desc

--showing the percentage of the count of deaths per population
select date,population,total_cases,total_deaths ,(total_cases/population)*100 as casespercentage
from [portfolio project]..coviddeath
--where location like '%states%'
where continent is not null
order by 1,2

--showing the info about total cases and deaths in world daily 
select date,sum(new_cases) as sumcases,sum(cast(new_deaths as int)) as sumdeaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as percentagede_wo
from [portfolio project]..coviddeath
where continent is not null
group by date
order by 1,2
.
--showing the info total cases and deaths by covid in world  
select sum(new_cases) as sumcases,sum(cast(new_deaths as int)) as sumdeaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as percentagede_wo
from [portfolio project]..coviddeath
where continent is not null
--group by date
order by 1,2


--showing percentage of vaccinations per total population 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as acceleration_vac
from [portfolio project]..coviddeath dea 
join [portfolio project]..[covidvaccinations] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null and dea.location like '%alb%'
order by 2,3

--using cte
with vacperpop (continent,lovation,date,population,new_vaccinations,acceleration_vac)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as acceleration_vac
from [portfolio project]..coviddeath dea 
join [portfolio project]..[covidvaccinations] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null and dea.location like '%alb%'
--order by 2,3
)

select * ,(acceleration_vac/population)*100 as vacperpop
from vacperpop

--using temp table
drop table if exists #vacper
create table #vacper
(
continent nvarchar(255),
location nvarchar(255),
dates int,
population numeric,
new_vaccinations numeric,
acceleration_vac numeric
)

insert into  #vacper 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as acceleration_vac
from [portfolio project]..coviddeath dea 
join [portfolio project]..[covidvaccinations] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null

select * ,(acceleration_vac/population)*100 as vacperpop
from #vacper

--create view to use it in visualization data later
create view vacperpop 
as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.date) as acceleration_vac
from [portfolio project]..coviddeath dea 
join [portfolio project]..[covidvaccinations] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 


