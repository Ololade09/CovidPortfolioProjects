  Select *
  from dbo.CovidDeaths
  order by 3,4

  Select *
  from dbo.CovidVaccinations
  order by 3,4

  Select location, date,total_cases, new_cases, total_deaths, population
  From PortfolioProject.dbo.CovidDeaths
  order by 1,2

  -1--Looking at Total Cases vs Total Deaths
   Select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
  From PortfolioProject.dbo.CovidDeaths
  order by 1,2

  -2--Likelihood of deaths in the United Kingdom 
   Select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
  From PortfolioProject.dbo.CovidDeaths
  where location like '%Kingdom%'
  order by 1,2

  -3--Looking at the Total Cases vs Population. i.e the % of the total population affected daily.
     Select location,date,population, total_cases,(total_cases/population)*100 as CasePercentage
	 From CovidDeaths
	 --where location like '%Kingdom%'
	 order by 1,2


 -4--Countries with highest Infection Rate compared to their Population
    Select location,population, max(total_cases) as HihestInfectionCount,Max((total_cases)/population)*100 as PercentPopulationInfected
	 From CovidDeaths
	 --where location like '%Nigeria%'
	 group by location, population
	order by PercentPopulationInfected desc

-5--Countries with the Highest Death Count per Population
Select location,population,max(total_deaths) as HighestDeathCount ,Max((total_deaths)/population)*100 as DeathRatePercent
	 From CovidDeaths
	 --where location like '%Nigeria%'
	 group by location, population
	order by DeathRatePercent desc
	   --OR--
 select location, max(total_deaths) as TotalDeathCount
 from PortfolioProject.dbo.CovidDeaths
 group by location
 order by TotalDeathCount desc

 --There seems to be a problem here as the numbers do not look correct. Checking the data type in the table, we can see the data type for total_deaths os nvarchar 255. To make this accurate, lets change datatype to Integer by 'casting'
 
 select location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject.dbo.CovidDeaths
 group by location
 order by TotalDeathCount desc

 --Lets break this down by continent
 -- Showing continents with the highest death count per population.
  select location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject.dbo.CovidDeaths
 where continent is null
 group by location
 order by TotalDeathCount desc

 --Find the Global numbers
  Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
  from PortfolioProject.dbo.CovidDeaths
  where continent is not null
  group by date
  order by 1,2

  --Now let us work on the CovidVaccinations table. First lets join the two tables

  Select *
  From PortfolioProject.dbo.CovidVaccinations as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  order by 2,3

 -- Total Population vs Vaccination

 Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 2,3

  --Lets do a rolling count to get total vaccinations
  --we use the partition by to break the count by location bcuz we want the count to start over per	new location

  Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  order by 2,3

  --Using CTE 
  With PopvsVac (Continent, Location, Date , Population , New_vaccinations, RollingPeopleVaccinated) as 
  (Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *, (RollingPeopleVaccinated/Population)*100
  from PopvsVac

  --TEMP TABLE 

  Create Table	#PercentPopulationVaccinated
  (
   Continent nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   new_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )
   Insert into #PercentPopulationVaccinated
   Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3
  
  Select *, (RollingPeopleVaccinated/Population)*100
  from #PercentPopulationVaccinated

  --If making any alterations to the table, add the drop table function
  Drop Table if exists #PercentPopulationVaccinated 
  Create Table	#PercentPopulationVaccinated
  (
   Continent nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   new_vaccinations numeric,
   RollingPeopleVaccinated numeric
   )
   Insert into #PercentPopulationVaccinated
   Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  --where dea.continent is not null
  --order by 2,3
  
  Select *, (RollingPeopleVaccinated/Population)*100
  from #PercentPopulationVaccinated

---Creating views to store data for visualizations

Create View PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 From PortfolioProject.dbo.CovidDeaths as dea
  join PortfolioProject.dbo.CovidVaccinations as vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  --order by 2,3

  Create View DeathCountPerContinent as
  select location, max(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject.dbo.CovidDeaths
 where continent is null
 group by location
 --order by TotalDeathCount desc

 Create View PercentPopulationInfected as
  Select location,population, max(total_cases) as HihestInfectionCount,Max((total_cases)/population)*100 as PercentPopulationInfected
	 From CovidDeaths
	 --where location like '%Nigeria%'
	 group by location, population

	 Create View PercentPopulationInfected_UK as
  Select location,population, max(total_cases) as HihestInfectionCount,Max((total_cases)/population)*100 as PercentPopulationInfected
	 From CovidDeaths
	 where location like '%United Kingdom%'
	 group by location, population

	 Create View PercentPopulationInfected_Nigeria as
  Select location,population, max(total_cases) as HihestInfectionCount,Max((total_cases)/population)*100 as PercentPopulationInfected
	 From CovidDeaths
	 where location like '%Nigeria%'
	 group by location, population