--This is a practice project

--Looking at Total Cases Vs Total Deaths
--shows likelihood of dying from covid in your country

select location, date, total_cases, total_deaths, total_deaths/cast(total_cases as float)*100 as DeathPercentage
from master..['covid deaths dataset$']
where location in ('United States', 'India')
order by 1, 2

--Looking for countries with Highest Infection Rate compared to population
select location, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as InfectionPercentage
from master..['covid deaths dataset$']
where continent is not null
group by location, population
order by InfectionPercentage desc

--Looking for countries with Highest Death Count compared to population
select location, max(cast(total_deaths as int)) as HighestDeathCount, (max(total_deaths)/population)*100 as DeathPercentage
from master..['covid deaths dataset$']
where continent is not null
group by location, population
order by HighestDeathCount desc, location, DeathPercentage desc


--Now let's break it down by continents
select continent, max(cast(total_cases as float)) as HighestInfectionCount, max(cast(total_deaths as int)) as HighestDeathCount
from master..['covid deaths dataset$']
where continent is not null
group by continent
order by HighestInfectionCount desc


--Lets look at Global Figures through time
select date, sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths0, (sum(new_deaths)/nullif(sum(new_cases), 0))*100 as DeathPercentage
from master..['covid deaths dataset$']
where continent is not null
group by date
order by date


--World Figures
select sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (sum(new_deaths)/nullif(sum(new_cases), 0))*100 as DeathPercentage
from master..['covid deaths dataset$']
where continent is not null

--Second Table

select *
from master..CovidVaccinations$

--Looking at Total Population vs Vaccinations
----Left Join
----Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from master..['covid deaths dataset$']  dea
left join master..CovidVaccinations$ vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopVsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated	
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from master..['covid deaths dataset$']  dea
left join master..CovidVaccinations$ vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from #PercentPopulationVaccinated


--Creating view to store data for later visualisation

Create view PercentPopVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from master..['covid deaths dataset$']  dea
left join master..CovidVaccinations$ vac
	on dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
