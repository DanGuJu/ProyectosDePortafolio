/*
Exploracion de datos de Coronavirus 
Habilidades usadas: Joins, Expresiones de tabla comun (CTE's), Tablas temporales, Funciones de windows, 
Funciones de agregacion, Creando vistas (View), Convirtiendo tipos de datos
*/

Select *
From DatosCovid..CovidMuertes
Where continent is not null 
order by 3,4


-- Seleccionar datos para empezar a analizar

Select Location, date, total_cases, new_cases, total_mueths, population
From DatosCovid..CovidMuertes
Where continent is not null 
order by 1,2


-- Casos Totales vs Muertes Totales
-- Muestra que probabilidad hay de morir si contraes covid en tu pais

Select Location, date, total_cases,total_mueths, (total_mueths/total_cases)*100 as PorcentajeMuerte
From DatosCovid..CovidMuertes
Where location like '%states%'
and continent is not null 
order by 1,2


-- Casos Totales vs Poblacion
-- Muestra el porcentaje de la poblacion infectada con Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PorcentajeDePersonasInfectadas
From DatosCovid..CovidMuertes
--Where location like '%states%'
order by 1,2


-- Paises con tasas mas altas de infeccion comparados con la poblacion

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PorcentajeDePersonasInfectadas
From DatosCovid..CovidMuertes
Group by Location, Population
order by PorcentajeDePersonasInfectadas desc


-- Paises con mas cantidad de muertes respecto a la poblacion total

Select Location, MAX(cast(Total_mueths as int)) as MuertesTotalesPoblacion
From DatosCovid..CovidMuertes
Where continent is not null 
Group by Location
order by MuertesTotalesPoblacion desc



-- Analizando Datos por continente

-- Mostrando continentes con mas muertes respecto a poblacion

Select continent, MAX(cast(Total_mueths as int)) as MuertesTotalesPoblacion
From DatosCovid..CovidMuertes
Where continent is not null 
Group by continent
order by MuertesTotalesPoblacion desc



-- Datos Globales

Select SUM(new_cases) as total_cases, SUM(cast(new_mueths as int)) as total_mueths, SUM(cast(new_mueths as int))/SUM(New_Cases)*100 as PorcentajeMuerte
From DatosCovid..CovidMuertes
where continent is not null 
--Group By date
order by 1,2



-- Poblacion Total vs Vacunaciones
-- Muestra el porcentage de poblacion que ha recibido por lo menos una vacuna Covid

Select mue.continent, mue.location, mue.date, mue.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by mue.Location Order by mue.location, mue.Date) as VacunasNuevasMasTotales
From DatosCovid..CovidMuertes mue
Join DatosCovid..CovidVaccinations vac
	On mue.location = vac.location
	and mue.date = vac.date
where mue.continent is not null 
order by 2,3


-- Usando CTE para realizar calculos en Partition By, en el query anterior

With PobvsVac (Continent, Location, Date, Population, New_Vaccinations, VacunasNuevasMasTotales)
as
(
Select mue.continent, mue.location, mue.date, mue.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by mue.Location Order by mue.location, mue.Date) as VacunasNuevasMasTotales
From DatosCovid..CovidMuertes mue
Join DatosCovid..CovidVaccinations vac
	On mue.location = vac.location
	and mue.date = vac.date
where mue.continent is not null 
)
Select *, (VacunasNuevasMasTotales/Population)*100
From PobvsVac



-- Empleando Tablas Temporales para calcular en Partition By, en query anterior

DROP Table if exists #PorcentajePoblacionVacunada
Create Table #PorcentajePoblacionVacunada
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VacunasNuevasMasTotales numeric
)

Insert into #PorcentajePoblacionVacunada
Select mue.continent, mue.location, mue.date, mue.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by mue.Location Order by mue.location, mue.Date) as VacunasNuevasMasTotales
From DatosCovid..CovidMuertes mue
Join DatosCovid..CovidVaccinations vac
	On mue.location = vac.location
	and mue.date = vac.date

Select *, (VacunasNuevasMasTotales/Population)*100
From #PorcentajePoblacionVacunada




-- Creando View para guardar datos para posterior Visualizacion

Create View PorcentajePoblacionVacunada as
Select mue.continent, mue.location, mue.date, mue.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by mue.Location Order by mue.location, mue.Date) as VacunasNuevasMasTotales
From DatosCovid..CovidMuertes mue
Join DatosCovid..CovidVaccinations vac
	On mue.location = vac.location
	and mue.date = vac.date
where mue.continent is not null 

