-- Nashville Housing Data Cleaning

-- USE PortfolioProject;

Select * From NashvilleHousing;


-- Updating Sale Date for readability

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing;

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

Select SaleDate, SaleDateConverted
From NashvilleHousing;


-- Populate Property Address Data

Select *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ];


-- Breaking up address into individual columns (Street address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT
	SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1) as StreetAddress,
	SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
-- CHARINDEX(',',PropertyAddress)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add StreetAddress NVARCHAR(255);

Update NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress,1, CharIndex(',',PropertyAddress) -1);

ALTER TABLE NashvilleHousing
Add City NVARCHAR(55);

Update NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) + 1, LEN(PropertyAddress));


-- Cleaning up owner city/street address
SELECT OwnerAddress
FROM NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT
	PARSENAME(Replace(OwnerAddress, ',','.'),1) as State,
	PARSENAME(Replace(OwnerAddress, ',','.'),2) as City,
	PARSENAME(Replace(OwnerAddress, ',','.'),3) as StreetAddress
FROM
	NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerStreetAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerCity NVARCHAR(55);

Update NashvilleHousing
SET OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'),2);

ALTER TABLE NashvilleHousing
Add OwnerState NVARCHAR(55);

Update NashvilleHousing
SET OwnerState = PARSENAME(Replace(OwnerAddress, ',','.'),1);

SELECT OwnerStreetAddress, OwnerCity, OwnerState
FROM NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID;


-- Change Y/N to Yes/No in 'Sold As Vacant Field'
SELECT DISTINCT (SoldasVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

SELECT SoldasVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = 	
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;

SELECT DISTINCT (SoldasVacant), Count(SoldAsVacant) as ConditionCount
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;


-- Removing Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress;

-- testing
-- SELECT *
-- FROM NashvilleHousing;


-- Delete unused columns
SELECT *
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate