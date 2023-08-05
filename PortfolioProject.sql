select *
from Portfolio..CovidDeaths
order by 3,4	

--select *
--from Portfolio..CovidVaccinations
--order by 3,4	

-- Select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- show likelihood  of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at total_cases vs population
-- Show what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM Portfolio..CovidDeaths
WHERE location LIKE '%viet%'
ORDER BY 1,2


-- Looking at the country with hightest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfect
from Portfolio..CovidDeaths
group by location, population
order by PercentPopulationInfect desc

-- showing the country with the highest death coutn per  population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
/*
Tóm lại, đoạn mã SQL này truy vấn dữ liệu COVID-19 từ bảng "CovidDeaths", 
tính toán số lượng tổng số ca tử vong tối đa cho mỗi vị trí và hiển thị 
kết quả theo thứ tự giảm dần của số lượng tổng số ca tử vong. Điều này giúp 
xác định các vị trí đã bị ảnh hưởng nhiều nhất bởi COVID-19 dựa trên số lượng 
tổng số ca tử vong.
*/


-- Let's break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing the contient with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by  TotalDeathCount desc

-- Global numbers

select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
			SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentage
from Portfolio..CovidDeaths
where continent is not null
group by date
order by 1,2 

/*Tóm lại, đoạn mã SQL này tính toán tổng số ca mắc mới,
tổng số ca tử vong mới và tỷ lệ tử vong tích luỹ dựa trên
dữ liệu COVID-19 từ bảng "CovidDeaths", nhóm dữ liệu theo 
ngày và hiển thị kết quả theo thứ tự ngày và tổng số ca mắc mới.
Điều này giúp theo dõi sự phát triển của dịch bệnh theo thời gian.*/

-- Looking at  Total Population vs Vaccination

--USE CTE

with PopvsVac (continent,  location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(convert(int,vac.new_vaccinations)) 
		over (partition by dea.location order by  dea.location, dea.Date)
		as RollingPeopleVaccinated
--		, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
( continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(convert(int,vac.new_vaccinations)) 
		over (partition by dea.location order by  dea.location, dea.Date)
		as RollingPeopleVaccinated
--		, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

-- creating view to store data for later visulizations

create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(convert(int,vac.new_vaccinations)) 
		over (partition by dea.location order by  dea.location, dea.Date)
		as RollingPeopleVaccinated
--		, (RollingPeopleVaccinated/population)*100
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--group by 2,3