-- ---------------------Data Cleaning----------------

SELECT *
FROM portfolio.dbo.NashvilleHousing


------------------- Standardize date format-------------


SELECT SaleDate, CONVERT(date,SaleDate) 
FROM portfolio.dbo.NashvilleHousing
 
ALTER TABLE  NashvilleHousing
ADD SaleDateNew date; 

UPDATE NashvilleHousing
SET SaleDateNew = CONVERT(date,SaleDAte)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate


---------------- Formatting Property Address-------------

SELECT PropertyAddress
FROM portfolio.dbo.NashvilleHousing
WHERE PropertyAddress is null

  -- looking for a way to find any way to populate the property address


SELECT *
FROM portfolio.dbo.NashvilleHousing
ORDER BY ParcelID 

	-- We'll inner join itself and fill missing values with matching parcell id with different unique id

SELECT a.PropertyAddress,b.PropertyAddress,a.ParcelID,b.ParcelID
FROM portfolio.dbo.NashvilleHousing as a
JOIN portfolio.dbo.NashvilleHousing as b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT ISNULL(a.PropertyAddress,b.PropertyAddress) --will populate a's null places with b's values 
FROM portfolio.dbo.NashvilleHousing as a
JOIN portfolio.dbo.NashvilleHousing as b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE  a
SET  a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM portfolio.dbo.NashvilleHousing as a
JOIN portfolio.dbo.NashvilleHousing as b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

	--check if it worked

SELECT PropertyAddress
FROM portfolio.dbo.NashvilleHousing
where PropertyAddress is null



-----------------Segrigating Address parts(address,city,state)--------------------

SELECT PropertyAddress
FROM portfolio.dbo.NashvilleHousing

	-- two ways of doing it. 
	-- First using Substring
	-- Second using Parse name
	

	-- Modifying Property Address format

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) )as State 
		-- SUBSTRING(var_name, start_index, end_index)
FROM portfolio.dbo.NashvilleHousing


		--Add split data to new col

Alter Table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress) )



SELECT PropertySplitAddress,PropertySplitCity
FROM portfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress



			--Modifying Owner Address format


SELECT OwnerAddress
FROM portfolio.dbo.NashvilleHousing

--Parse name only operates on '.' so, need to replace ',' with '.'
-- also it words right to left 

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM portfolio.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),2)
FROM portfolio.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM portfolio.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerAddressNew Nvarchar(255);

Alter table NashvilleHousing
Add OwnerCity Nvarchar(255);


Alter table NashvilleHousing
Add OwnerState Nvarchar(255);


Update NashvilleHousing
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select OwnerAddressNew,OwnerCity,OwnerState
FROM portfolio.dbo.NashvilleHousing



Alter table NashvilleHousing
DROP column OwnerAddress



--------------------------Cleaning 'SoldAsVacant' Col-------------------------------


SELECT  DISTINCT (SoldAsVacant),Count(SoldAsVacant)
FROM portfolio.dbo.NashvilleHousing
Group by  SoldAsVacant
Order by 2

SELECT SoldAsVacant,
	case when SoldAsVacant='Y' THEN 'Yes'
		 when SoldAsVacant='N' THEN 'No'
		 else SoldAsVacant
		 END
FROM portfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant='Y' THEN 'Yes'
						when SoldAsVacant='N' THEN 'No'
						 else SoldAsVacant
						 END



---------------------------------Remove Duplicates----------------------------------------------------------

--Using CTE to use Windows function Row_number() and
--adding up duplicate row number count

WITH RowNumCTE As(
 SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertySplitAddress,SalePrice,SaleDateNew,LegalReference,OwnerName
	ORDER BY UniqueID
	) row_num 
 FROM portfolio.dbo.NashvilleHousing)

SELECT * 
FROM RowNumCTE
WHERE row_num >1

--delete them 
WITH RowNumCTE As(
 SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertySplitAddress,SalePrice,SaleDateNew,LegalReference,OwnerName
	ORDER BY UniqueID
	) row_num 
 FROM portfolio.dbo.NashvilleHousing)

Delete  
FROM RowNumCTE
WHERE row_num >1



------------------------------------------------------------------------------- 
