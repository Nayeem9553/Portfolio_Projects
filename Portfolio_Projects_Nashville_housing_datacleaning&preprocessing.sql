select *
FROM Portfolio_Project_03.dbo.Nashville_Housing

--1. Standardize Date Format
Select SalesDateConverted, CONVERT(Date, SaleDate)
FROM Portfolio_Project_03.dbo.Nashville_Housing

UPDATE Nashville_Housing 
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville_Housing 
ADD SalesDateConverted Date;

UPDATE Nashville_Housing 
SET SalesDateConverted = CONVERT(Date,SaleDate)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2. Populate Property Address data, fill gaps

Select *
FROM Portfolio_Project_03.dbo.Nashville_Housing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_03.dbo.Nashville_Housing a
JOIN Portfolio_Project_03.dbo.Nashville_Housing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is NULL
	 
UPDATE a
SET  PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress) --The ISNULL() ensures that if a.PropertyAddress is NULL, it gets replaced by b.PropertyAddress.
FROM Portfolio_Project_03.dbo.Nashville_Housing a
JOIN Portfolio_Project_03.dbo.Nashville_Housing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE a.PropertyAddress is 

----this return 0 now
SELECT COUNT(*) AS RemainingNulls
FROM Portfolio_Project_03.dbo.Nashville_Housing
WHERE PropertyAddress IS NULL;

	    
-------------------3.     Breaking out Addresses into individual columns----------------------------------------------------------------------------------
--"delemeter is a thing that  differentiates different columns or data, here the address and city is seperated by comma, we will use substring or char index"


Select PropertyAddress
FROM Portfolio_Project_03.dbo.Nashville_Housing

--now starts the filling process
Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address 
, SUBSTRING (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
--CHARINDEX(',', PropertyAddress) --where is the comma (a number as index)

FROM Portfolio_Project_03.dbo.Nashville_Housing

--adding address in the database
ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing 
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Portfolio_Project_03.dbo.Nashville_Housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

--adding city to the database
ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing  
ADD PropertySplitCity NVARCHAR(255);

UPDATE Portfolio_Project_03.dbo.Nashville_Housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- selecting everything after
SELECT *
FROM Portfolio_Project_03.dbo.Nashville_Housing


SELECT OwnerAddress --[Address, City, State] we want to split them by using Parce-name, easier than substring
FROM Portfolio_Project_03.dbo.Nashville_Housing
----PARSENAME only looks for periods (.) not comma, it also does things backwards
SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) 
FROM Portfolio_Project_03.dbo.Nashville_Housing


ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing 
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE Portfolio_Project_03.dbo.Nashville_Housing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing 
ADD OwnerSplitCity NVARCHAR(255);
UPDATE Portfolio_Project_03.dbo.Nashville_Housing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing 
ADD OwnerSplitState NVARCHAR(255);
UPDATE Portfolio_Project_03.dbo.Nashville_Housing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1) 

SELECT * 
FROM Portfolio_Project_03.dbo.Nashville_Housing

-- 4.   sold as vacant field(changing Y and N to Yes and No)

SElECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as count_vacant
FROM Portfolio_Project_03.dbo.Nashville_Housing
GROUP By SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,  CASE WHEN SoldAsVacant = 'Y' then 'Yes'  
	    WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio_Project_03.dbo.Nashville_Housing


UPDATE Portfolio_Project_03.dbo.Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'  
	    WHEN SoldAsVacant = 'N' then 'No'
		ELSE SoldAsVacant  -- As it is
		END
SELECT SoldAsVacant
FROM Portfolio_Project_03.dbo.Nashville_Housing
-------------------------------------------------------------------------------------------------------------------------------------------------------
--5. Removing Duplicates

DROP TABLE IF EXISTS backup_Nashville_Housing
SELECT *
INTO backup_Nashville_Housing
FROM Portfolio_Project_03.dbo.Nashville_Housing;

---deleteing
WITH Row_num_cte AS (
    SELECT 
        UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM Portfolio_Project_03.dbo.Nashville_Housing
)
DELETE nh
FROM Portfolio_Project_03.dbo.Nashville_Housing AS nh
JOIN Row_num_cte AS cte
    ON nh.UniqueID = cte.UniqueID
WHERE cte.row_num > 1;

---verify
SELECT ParcelID, PropertyAddress, COUNT(*) AS RecordCount
FROM Portfolio_Project_03.dbo.Nashville_Housing
GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
HAVING COUNT(*) > 1;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--6.   Deleting unused columns

SELECT *
FROM Portfolio_Project_03.dbo.Nashville_Housing


ALTER TABLE Portfolio_Project_03.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, taxDistrict, PropertyAddress

