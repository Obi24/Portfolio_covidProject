select distinct location from CovidDeath
order by 1 asc

select top(10) * from CovidDeath
 
select top(10) location,date,total_cases,new_cases,total_deaths,new_deaths, (new_cases/new_deaths),population
from CovidDeath
where new_deaths > 0

--looking total cases VS total death

--select location,date,cast (total_cases as int),cast (total_deaths as int),(total_deaths/(cast (total_cases as int))* 100 as DeathPercentage
--from CovidDeath

select location,date,population,total_deaths,(total_deaths/population)* 100 as DeathPercentage
from CovidDeath
where location like '%Nigeria%'

--countries with highest infection rate compare to population

--select location , population, max(total_cases) as Highestinfected,max((total_cases/population)* 100) as 
--Percentpopulationinfected
--from [PortfolioProject].dbo.CovidDeath
--group by location,population
--order by Percentpopulationinfected desc

--countries with highest death

--select location, MAX(cast (total_deaths as int)) as TotalDeathCount
--from CovidDeath
--where continent is not null
--group by location
--order by TotalDeathCount desc

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

--Global view

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Percentdeathcount
from CovidDeath
where total_cases <> 0 
--and total_deaths != 0
--and total_cases is not Null  
and total_deaths is not Null
group by date
order by 1 desc


select d.location,d.population,d.date,v.new_vaccinations 
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1,3

select d.location,d.population,d.date,v.new_vaccinations,SUM(convert(int,v.new_vaccinations)) over (partition by d.location) as TotalNewVacc
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1,3


--CTE
with PopVsVacc (location,population,date,new_vaccinations,TotalNewVacc)
as 
(select d.location,d.population,d.date,v.new_vaccinations,SUM(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as TotalNewVacc
--(TotalNewVacc/d.population)* 100 as PercentTotalNewVacc
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null)
--order by 1,3)
select location,population,date,new_vaccinations,TotalNewVacc,(TotalNewVacc/population)* 100 as PercentTotalNewVacc
from PopVsVacc

-- CREATING TEMP TABLE
create table #PopVsVacc2
(location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
TotalNewVacc numeric
)

insert into #PopVsVacc2
select d.location,d.population,d.date,v.new_vaccinations,SUM(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as TotalNewVacc
--(TotalNewVacc/d.population)* 100 as PercentTotalNewVacc
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 1,3

select *,(TotalNewVacc/population)* 100 as TotalNewVacc
from #PopVsVacc2

--STORE PROCEDURE

create procedure PopVsVacc3
as
insert into #PopVsVacc2
select d.location,d.population,d.date,v.new_vaccinations,SUM(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as TotalNewVacc
--(TotalNewVacc/d.population)* 100 as PercentTotalNewVacc
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 1,3

select *,(TotalNewVacc/population)* 100 as TotalNewVacc
from #PopVsVacc2

exec PopVsVacc3

---CREATING VIEWS

create view PopulationVaccinated
as
select d.location,d.population,d.date,v.new_vaccinations,SUM(convert(int,v.new_vaccinations)) over (partition by d.location) as TotalNewVacc
from CovidDeath d
join CovidVaccination v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 1,3

select * from PopulationVaccinated
