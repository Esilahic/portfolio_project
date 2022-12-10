-- Queries used for Tableau Project

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

CREATE VIEW portfolio_project_covid.HighestDeathsContinentVIEW as
Select continent, SUM(cast(new_deaths as signed)) as TotalDeathCount
From portfolio_project_covid.covid_deaths_2021
Where continent is NOT null 
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc;

CREATE VIEW portfolio_project_covid.InfectionsVIEW as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio_project_covid.covid_deaths_2021
Group by Location, Population
order by PercentPopulationInfected desc;

CREATE VIEW portfolio_project_covid.HighestInfectionsVIEW as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio_project_covid.covid_deaths_2021
Group by Location, Population, date
order by PercentPopulationInfected desc