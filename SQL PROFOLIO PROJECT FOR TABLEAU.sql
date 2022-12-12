-- Queries used for Tableau Project

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
    ORDER BY PercentPopulationInfected DESC;
