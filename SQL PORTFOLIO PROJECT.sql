-- UPDATE portfolio_project_covid.covid_vacs_2021 SET date = str_to_date(date, "%m/%d/%Y")
-- ALTER TABLE x Modify column y datatype  

SELECT 
    location, date, total_cases, new_cases, total_deaths, population
FROM
    portfolio_project_covid.covid_deaths_2021
ORDER BY  1,2;

-- total cases vs total deaths
-- showing likelihood of dying from covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolio_project_covid.covid_deaths_2021
WHERE location like 'a%'
order by 1,2;

-- Total cases vs Pop
-- shows % of population who caught covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
FROM portfolio_project_covid.covid_deaths_2021
order by 1,2;

-- countries with highest infection rate compared to population
SELECT location, max(total_cases) as highest_total_cases, population, max((total_cases/population))*100 as highest_infected_percentage
FROM portfolio_project_covid.covid_deaths_2021
GROUP BY location, population
order by highest_infected_percentage DESC;

-- Countries with Highest Death Count per Population
SELECT location, MAX(CAST(Total_deaths as SIGNED)) as TotalDeathCount
FROM portfolio_project_covid.covid_deaths_2021
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
From portfolio_project_covid.covid_deaths_2021
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project_covid.covid_deaths_2021
where continent is not null 
order by 1,2;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL -- AND vac.new_vaccinations IS NOT NULL
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL -- AND vac.new_vaccinations IS NOT NULL
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- TEMP TABLE PRACTICE
Create Table portfolio_project_covid.PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into portfolio_project_covid.PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100
From portfolio_project_covid.PercentPopulationVaccinated;

-- CREATE VIEW FOR LATER
CREATE VIEW portfolio_project_covid.PercentPopulationVaccinatedVIEW as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date;
    
CREATE VIEW portfolio_project_covid.GlobalNumbersVIEW as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From portfolio_project_covid.covid_deaths_2021
where continent is not null;

CREATE VIEW portfolio_project_covid.HighestDeathsVIEW as
SELECT location, MAX(CAST(Total_deaths as SIGNED)) as TotalDeathCount
FROM portfolio_project_covid.covid_deaths_2021
Where continent is not null 
Group by Location
order by TotalDeathCount desc;
