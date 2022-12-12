-- UPDATE portfolio_project_covid.covid_vacs_2021 SET date = str_to_date(date, "%m/%d/%Y")
-- ALTER TABLE x Modify column y datatype  

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    portfolio_project_covid.covid_deaths_2021
ORDER BY 1 , 2;

-- total cases vs total deaths
-- showing likelihood of dying from covid in your country 
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    portfolio_project_covid.covid_deaths_2021
WHERE
    location LIKE 'a%'
ORDER BY 1 , 2;

-- Total cases vs Pop
-- shows % of population who caught covid
SELECT 
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS infected_percentage
FROM
    portfolio_project_covid.covid_deaths_2021
ORDER BY 1 , 2;

-- countries with highest infection rate compared to population
SELECT 
    location,
    MAX(total_cases) AS highest_total_cases,
    population,
    MAX((total_cases / population)) * 100 AS highest_infected_percentage
FROM
    portfolio_project_covid.covid_deaths_2021
GROUP BY location , population
ORDER BY highest_infected_percentage DESC;

-- Countries with Highest Death Count per Population
SELECT 
    location,
    MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    portfolio_project_covid.covid_deaths_2021
WHERE
    continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Showing contintents with the highest death count per population
SELECT 
    continent,
    MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    portfolio_project_covid.covid_deaths_2021
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
    portfolio_project_covid.covid_deaths_2021
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

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
CREATE TABLE portfolio_project_covid.PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

Insert into portfolio_project_covid.PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date;

SELECT 
    *, (RollingPeopleVaccinated / Population) * 100
FROM
    portfolio_project_covid.PercentPopulationVaccinated;

-- CREATE VIEW FOR LATER
CREATE VIEW portfolio_project_covid.PercentPopulationVaccinatedVIEW as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project_covid.covid_deaths_2021 dea
Join portfolio_project_covid.covid_vacs_2021 vac
	On dea.location = vac.location
	and dea.date = vac.date;
    
CREATE VIEW portfolio_project_covid.GlobalNumbersVIEW AS
    SELECT 
        SUM(new_cases) AS total_cases,
        SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
        SUM(CAST(new_deaths AS SIGNED)) / SUM(New_Cases) * 100 AS DeathPercentage
    FROM
        portfolio_project_covid.covid_deaths_2021
    WHERE
        continent IS NOT NULL;

CREATE VIEW portfolio_project_covid.HighestDeathsVIEW AS
    SELECT 
        location,
        MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
    FROM
        portfolio_project_covid.covid_deaths_2021
    WHERE
        continent IS NOT NULL
    GROUP BY Location
    ORDER BY TotalDeathCount DESC;

CREATE VIEW portfolio_project_covid.HighestDeathsContinentVIEW AS
    SELECT 
        continent,
        SUM(CAST(new_deaths AS SIGNED)) AS TotalDeathCount
    FROM
        portfolio_project_covid.covid_deaths_2021
    WHERE
        continent IS NOT NULL
            AND location NOT IN ('World' , 'European Union', 'International')
    GROUP BY continent
    ORDER BY TotalDeathCount DESC;

CREATE VIEW portfolio_project_covid.InfectionsVIEW AS
    SELECT 
        Location,
        Population,
        MAX(total_cases) AS HighestInfectionCount,
        MAX((total_cases / population)) * 100 AS PercentPopulationInfected
    FROM
        portfolio_project_covid.covid_deaths_2021
    GROUP BY Location , Population
    ORDER BY PercentPopulationInfected DESC;

CREATE VIEW portfolio_project_covid.HighestInfectionsVIEW AS
    SELECT 
        Location,
        Population,
        date,
        MAX(total_cases) AS HighestInfectionCount,
        MAX((total_cases / population)) * 100 AS PercentPopulationInfected
    FROM
        portfolio_project_covid.covid_deaths_2021
    GROUP BY Location , Population , date
    ORDER BY PercentPopulationInfected DESC
