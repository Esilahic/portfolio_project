-- Standardize Date Format
ALTER TABLE data_cleaning.nh
MODIFY COLUMN SaleDate DATE;

-- Populate Property Address data
SELECT 
    *
FROM
    data_cleaning.nh
ORDER BY ParcelID;

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    data_cleaning.nh a
        JOIN
    data_cleaning.nh b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE
    a.PropertyAddress IS NULL;
    
UPDATE data_cleaning.nh a
        JOIN
    data_cleaning.nh b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
    SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS Address
FROM
    data_cleaning.nh;

ALTER TABLE data_cleaning.nh
Add PropertySplitAddress Nvarchar(255);

UPDATE data_cleaning.nh 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        POSITION(',' IN PropertyAddress) - 1);

ALTER TABLE data_cleaning.nh
Add PropertySplitCity Nvarchar(255);

UPDATE data_cleaning.nh 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        POSITION(',' IN PropertyAddress) + 1,
        LENGTH(PropertyAddress));

SELECT 
    OwnerAddress
FROM
    data_cleaning.nh;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
            ',',
            1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 1),
            ',',
            1)
FROM
    data_cleaning.nh;

ALTER TABLE data_cleaning.nh
Add OwnerSplitAddress Nvarchar(255);

UPDATE data_cleaning.nh 
SET 
    OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE data_cleaning.nh
Add OwnerSplitCity Nvarchar(255);

UPDATE data_cleaning.nh 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
            ',',
            1);

ALTER TABLE data_cleaning.nh
Add OwnerSplitState Nvarchar(255);

UPDATE data_cleaning.nh 
SET 
    OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 1),
            ',',
            1);

SELECT 
    *
FROM
    data_cleaning.nh;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    data_cleaning.nh
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    data_cleaning.nh;


UPDATE data_cleaning.nh 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- Remove Duplicates

WITH cte AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num 
From
	data_cleaning.nh
 )
-- delete FROM data_cleaning.nh USING data_cleaning.nh JOIN cte ON data_cleaning.nh.ParcelID = cte.ParcelID where cte.row_num > 1;
select *
from cte
where row_num > 1;
-- Delete Unused Columns

SELECT 
    *
FROM
    data_cleaning.nh;

ALTER TABLE data_cleaning.nh
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict
