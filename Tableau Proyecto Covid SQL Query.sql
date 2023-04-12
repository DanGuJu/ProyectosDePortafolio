/*
Consultas usadas en el Projecto de Datos de Covid en Tableau
*/



-- 1. Realizamos la tabla de Datos Globales (Casos Totales, Muertes Totales, Porcentaje)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as PorcentajeMuerte
From DatosCovid..CovidMuertes
where continent is not null 
order by 1,2

-- Hacemos un checkeo de los datos obtenidos en el archivo de "Sql Exploracion de datos Covid"


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as PorcentajeMuerte
From DatosCovid..CovidMuertes
where location = 'World'
order by 1,2


-- 2.  Obtenemos las tablas para las graficas de "Muertes por continente", excluimos lugares que no son de algun continente

Select location, SUM(cast(new_deaths as int)) as MuertesTotalesPoblacion
From DatosCovid..CovidMuertes
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by MuertesTotalesPoblacion desc


-- 3. Obtenemos las tablas para obtener los datos de poblacion infectada, agrupada por paises y respecto a la poblacion infectada

Select Location, Population, MAX(total_cases) as ConteoMayorInfeccion,  Max((total_cases/population))*100 as PorcentajePoblacionInfectada
From DatosCovid..CovidMuertes
Group by Location, Population
order by PorcentajePoblacionInfectada desc


-- 4. Usamos las tablas para graficar los datos de cantidad de infectados respecto a paises y hacer una proyeccion a futuro


Select Location, Population,date, MAX(total_cases) as ConteoMayorInfeccion,  Max((total_cases/population))*100 as PorcentajePoblacionInfectada
From DatosCovid..CovidMuertes
Group by Location, Population, date
order by PorcentajePoblacionInfectada desc
