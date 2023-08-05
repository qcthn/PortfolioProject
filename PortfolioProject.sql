-- Retrieving COVID-19 data from the CovidDeaths table
SELECT *
FROM Portfolio..CovidDeaths
ORDER BY 3, 4;

-- Retrieving specific columns from CovidDeaths table and ordering by location and date
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM Portfolio..CovidDeaths
ORDER BY location, date;

-- looking at total cases vs total deaths
-- show likelihood  of dying if you contract covid in your country
-- Calculating death percentage based on total cases and total deaths for specific locations
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date;


-- Looking at total_cases vs population
-- Show what percentage of population got covid
-- Calculating population percentage affected by COVID-19 cases in specific locations
SELECT
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS PopulationPercentage
FROM Portfolio..CovidDeaths
WHERE location LIKE '%viet%'
ORDER BY location, date;

-- Looking at the country with hightest infection rate compared to population
-- Finding the country with the highest infection rate compared to its population
SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfect
FROM Portfolio..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfect DESC;

-- showing the country with the highest death coutn per  population
-- Identifying the country with the highest death count per population
SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

/*
Tóm lại, đoạn mã SQL này truy vấn dữ liệu COVID-19 từ bảng "CovidDeaths", 
tính toán số lượng tổng số ca tử vong tối đa cho mỗi vị trí và hiển thị 
kết quả theo thứ tự giảm dần của số lượng tổng số ca tử vong. Điều này giúp 
xác định các vị trí đã bị ảnh hưởng nhiều nhất bởi COVID-19 dựa trên số lượng 
tổng số ca tử vong.
*/


-- Let's break things down by continent
-- Aggregating death count by continent
SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- showing the contient with the highest death count per population
-- Determining the continent with the highest death count per population
SELECT
    continent,
    MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers
-- Calculating global COVID-19 statistics
SELECT
    date,
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, TotalCases;

/*Tóm lại, đoạn mã SQL này tính toán tổng số ca mắc mới,
tổng số ca tử vong mới và tỷ lệ tử vong tích luỹ dựa trên
dữ liệu COVID-19 từ bảng "CovidDeaths", nhóm dữ liệu theo 
ngày và hiển thị kết quả theo thứ tự ngày và tổng số ca mắc mới.
Điều này giúp theo dõi sự phát triển của dịch bệnh theo thời gian.*/

-- Looking at  Total Population vs Vaccination

--USE CTE
-- Analyzing total population vs. vaccination data using CTE
WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM Portfolio..CovidDeaths dea
    JOIN Portfolio..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;

--TEMP TABLE
-- Creating a temporary table to store vaccination percentage data
DROP TABLE IF EXISTS #PercentagePopulationVaccinated;
CREATE TABLE #PercentagePopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);
INSERT INTO #PercentagePopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM #PercentagePopulationVaccinated;

-- creating view to store data for later visulizations
-- Creating a view to store data for later visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
