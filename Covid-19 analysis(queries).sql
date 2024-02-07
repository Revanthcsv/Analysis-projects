
/* 
This project was initiated to analyze and visualize critical data related to COVID-19 deaths and vaccinations. Leveraging datasets obtained from worldindata.org, the project aims to provide valuable insights into the pandemic's impact on mortality rates and vaccination efforts across different regions.

The project is structured around two primary datasets: "CovidDeaths" and "CovidVaccinations," each containing comprehensive information about COVID-19 fatalities and vaccination coverage, respectively.

Using SQL queries within MS SQL Server, the project investigates into the datasets to extract meaningful insights and trends. By analyzing factors such as demographic disparities, geographic distribution, and vaccination progress, the project seeks to uncover patterns and correlations within the data.

Furthermore, to facilitate data exploration and presentation, interactive Tableau dashboards named "COVID Deaths" and "COVID Vaccination Tracker" have been developed(the link is in the github bio). These dashboards offer dynamic visualizations that allow users to interactively explore key metrics and trends related to COVID-19 deaths and vaccination rates.

Through the integration of data analysis, SQL querying, and visualization techniques, this project aims to contribute to a deeper understanding of the COVID-19 pandemic's impact and provide valuable insights for public health decision-makers and policymakers.


*/

--Testing datasets--
select *
from CovidDeaths
order by 3,4

select *
from CovidVaccinations
order by 3,4

----Selecting neccesary data----

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2

--Total cases vs Total Deaths(chances of dying due to getting infection)--

SELECT location,date,total_cases,total_deaths,(total_deaths/(cast(total_cases as float)))*100 as  DeathPercentage
FROM CovidDeaths
order by 1,2

--chances of dying due to getting infection in united states--

SELECT location,date,total_cases,total_deaths,(total_deaths/(cast(total_cases as float)))*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--chances of dying due to getting infection in INDIA--

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%INDIA%'
order by 1,2

--Total cases vs population(%)(Shows what percentage of population infected with covid)--

SELECT location,date,total_cases,population,(total_cases/population)*100 as CasesPercent
FROM CovidDeaths
order by 1,2

SELECT location,date,total_cases,population,(total_cases/population)*100 as CasesPercent
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--Countries with highest infection rates with respect to population--

SELECT location,population,max(total_cases) as highestInfected,MAX((total_cases/population))*100 as casesPercent
From CovidDeaths
group by location,population
order by 4 desc

--Countries with highest deaths(along with changing total_deaths datatype to int)--

SELECT location,population,max(cast(total_deaths as int)) as Totaldeath 
From CovidDeaths
where continent is not null
group by location,population
order by 3 desc

--Total Deaths in each continent--

SELECT location as continents,population,max(cast(total_deaths as int)) as Totaldeath 
From CovidDeaths
where continent is null and population is not null
group by location,population
order by 3 desc

--countries with highest deaths from each continent--

WITH RankedCovidDeaths AS (
    SELECT 
        continent as continents, 
        location, 
        total_deaths,
        ROW_NUMBER() OVER (PARTITION BY continent ORDER BY CAST(total_deaths AS INT) DESC) AS RowNum
    FROM CovidDeaths
    WHERE continent IS NOT NULL
)
SELECT continents, location, total_deaths
FROM RankedCovidDeaths
WHERE RowNum = 1;

--GLOBAL NUMBERS--
--Deathpercentage by day w.r.t number of cases--

SELECT date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
Order by 1

--Total deathpercentage--

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
Order by 1

--Total population vs new Vaccinations by date--

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths dea
join CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null 
order by 2,3

----Total population vs total Vaccinations by date--

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as total_vaccinations
FROM CovidDeaths dea
join CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null 
order by 2,3

--Using CTE--

with popvsvac as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as total_vaccinations
FROM CovidDeaths dea
join CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null 

)
select *,(total_vaccinations/population)*100 as percentage
FROM popvsvac

-- highest percentage of vaccinations in each country--

WITH popvsvac AS (
    SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
),
RankedPopVsVac AS (
    SELECT *,ROW_NUMBER() OVER (PARTITION BY location ORDER BY total_vaccinations DESC) AS RowNum
    FROM popvsvac
)
SELECT continent,location,date,population,total_vaccinations,(total_vaccinations / population) * 100 AS percentage
FROM RankedPopVsVac
WHERE RowNum = 1;


--Queries used for Tableau Dashboards(The outputs of each of the queries is made into a excel sheet to make working on tableau easier)


-- 1. Data query

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. pie chart query

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. map query

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.line graph query


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population,date
order by PercentPopulationInfected desc

--5.Covid vacciantions tracker query


select x.continent,x.location,y.Date,population,y.people_vaccinated,people_fully_vaccinated,y.gdp_per_capita,people_fully_vaccinated_per_hundred,people_vaccinated_per_hundred

from CovidDeaths x
join CovidVaccinations y
 on x.location =y.location and x.date=y.date
 where x.location like '%states%'
 order by 2,3 
