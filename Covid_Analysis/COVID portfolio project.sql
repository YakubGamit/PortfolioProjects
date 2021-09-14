select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations 
--order by 3,4

---Select the data that I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

---Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like 'India' and
continent is not null
order by 1,2


--- Total Cases vs Population
--- Shows how much percent of population got infected

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where continent is not null
---where Location like 'India'
order by 1,2

---Countries with highest infection rate compared with population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as 
PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
---where Location like 'India'
where continent is not null
group by Location,population
order by PopulationInfectedPercentage desc

---summary by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
---where Location like 'India'
where continent is null
group by location
order by TotalDeathCount desc


---Showing with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
---where Location like 'India'
where continent is not null
group by Location
order by TotalDeathCount desc


---Showing continent with highest death rate

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
---where Location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc

---GLOBAL NUMBERS

Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


---USE CTE
with PopvsVac (Continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

---Temp Table

DROP Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

---creating view to store data for visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
