-- Data Cleaning

-- Format the saledate into DATE format
ALTER TABLE PortfolioProject..NashvileHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject..NashvileHousing
-----------------------------------------------------------------------

-- Populate property address null data
-- First let's check if there are nulls in the adress column
Select *
From PortfolioProject..NashvileHousing
Where PropertyAddress is NULL

-- We can fill in the data with rows that have simillar ParcelID 
-- We can see here that properties that have simillar ParcelIDs have the same adress:
Select ParcelID,PropertyAddress
From PortfolioProject..NashvileHousing
Order by ParcelID

-- We want to papulate null address data with the row that have the same ParcelID but different UniqueID
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvileHousing a 
JOIN PortfolioProject..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvileHousing a 
JOIN PortfolioProject..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-- Verify it is done:
Select ParcelID,PropertyAddress
From PortfolioProject..NashvileHousing
Where PropertyAddress is NULL
-----------------------------------------------------------------------

-- Each property address contains the street address and city address seperated by comma
Select PropertyAddress
From PortfolioProject..NashvileHousing

Select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Adress,
		SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
From PortfolioProject..NashvileHousing

--Let's add 2 new columns 
ALTER TABLE PortfolioProject..NashvileHousing
ADD PropertyStreetAdress Varchar(255);

ALTER TABLE PortfolioProject..NashvileHousing
ADD PropertyCityAdress Varchar(255);

-- Populate the columns with data
UPDATE PortfolioProject..NashvileHousing
SET PropertyStreetAdress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

UPDATE PortfolioProject..NashvileHousing
SET PropertyCityAdress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Verify it is done:
Select PropertyStreetAdress,PropertyCityAdress
From PortfolioProject..NashvileHousing
-----------------------------------------------------------------------

--Each owner address contains the street address, city address and the state seperated by commas
Select OwnerAddress
From PortfolioProject..NashvileHousing

--This time i'll use different method to split the values
Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as OwnerStreetAdress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as OwnerCityAdress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as OwnerStateAdress
From PortfolioProject..NashvileHousing

--Let's add 3 new columns 
ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerStreetAdress Varchar(255);

ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerCityAdress Varchar(255);

ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerStateAdress Varchar(255);

-- Populate the columns with data
UPDATE PortfolioProject..NashvileHousing
SET OwnerStreetAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

UPDATE PortfolioProject..NashvileHousing
SET OwnerCityAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

UPDATE PortfolioProject..NashvileHousing
SET OwnerStateAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Verify it is done:
Select OwnerStreetAdress,OwnerCityAdress,OwnerStateAdress
From PortfolioProject..NashvileHousing
-----------------------------------------------------------------------

-- SoldAsVacant column has 4 different optional values ('Y'='Yes','N'='No') 
-- Let's convert it into 2 options, I will use the most used ones
Select Distinct(SoldAsVacant), count(SoldAsVacant) as countnumber
From PortfolioProject..NashvileHousing
Group by SoldAsVacant
Order by countnumber

-- 'Y' will turn into 'Yes and 'N' into 'No'
Select SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END
From PortfolioProject..NashvileHousing

Update PortfolioProject..NashvileHousing 
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant 
	  END
From PortfolioProject..NashvileHousing

-- Verify it is done:
Select Distinct(SoldAsVacant), count(SoldAsVacant) as countnumber
From PortfolioProject..NashvileHousing
Group by SoldAsVacant
Order by countnumber
-----------------------------------------------------------------------

-- Remove Duplicates
--Let's verify that UniqueID is actually unique and not duplicating data

WITH RowNumCTE AS (
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER By
						UniqueID ) as RowNum
From PortfolioProject..NashvileHousing )
Select *
From RowNumCTE
Where RowNum >1

-- It seems like there are 104 duplicates, let's delete them
WITH RowNumCTE AS (
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER By
						UniqueID ) as RowNum
From PortfolioProject..NashvileHousing )
DELETE
From RowNumCTE
Where RowNum >1

-- Verify it is done:
WITH RowNumCTE AS (
Select *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER By
						UniqueID ) as RowNum
From PortfolioProject..NashvileHousing )
Select *
From RowNumCTE
Where RowNum >1
-----------------------------------------------------------------------

-- Check the unused columns
Select OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
From PortfolioProject..NashvileHousing

-- Delete unused columns
ALTER TABLE PortfolioProject..NashvileHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
-----------------------------------------------------------------------

--The clean data set:
Select *
From PortfolioProject..NashvileHousing
Order by UniqueID 
