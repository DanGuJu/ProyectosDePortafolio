/*
Limpiando Datos en consutlas SQL
*/


Select *
From ProyectoSQL.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Estandarizando el formato de fechas, para un correcto acomodo por fechas


Select saleDateConverted, CONVERT(Date,SaleDate)
From ProyectoSQL.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Si no se actualiza correctamente

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Llenar los datos de direccion de propiedad (Para los datos que aparecen como Null)

Select *
From ProyectoSQL.dbo.NashvilleHousing
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProyectoSQL.dbo.NashvilleHousing a
JOIN ProyectoSQL.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProyectoSQL.dbo.NashvilleHousing a
JOIN ProyectoSQL.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Descomponiendo "Address" en Columnas Individuales


Select PropertyAddress
From ProyectoSQL.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From ProyectoSQL.dbo.NashvilleHousing

--Separando la direccion de la propiedad

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From ProyectoSQL.dbo.NashvilleHousing





Select OwnerAddress
From ProyectoSQL.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From ProyectoSQL.dbo.NashvilleHousing


--Separando la direccion de la propiedad del propietario
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-- --Separando el estado del propietario
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From ProyectoSQL.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Cambia "Y" y "N" a "Yes" y "No" en el campo "Sold As Vacant" 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProyectoSQL.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProyectoSQL.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remover Duplicados

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From ProyectoSQL.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From ProyectoSQL.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Borrar Columnas no usadas



Select *
From ProyectoSQL.dbo.NashvilleHousing


ALTER TABLE ProyectoSQL.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Limpiar Datos se trata de acomodar, reemplazar, modificar datos para un mejor manejo y que no muestren errores las consultas