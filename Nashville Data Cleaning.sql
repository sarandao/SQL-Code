SELECT *
FROM housing 

-- Populate Property Address Data -- 

SELECT PropertyAddress
FROM housing 
WHERE PropertyAddress is null 

SELECT *
FROM housing 
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing AS a 
JOIN housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing AS a 
JOIN housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null 

-- Breaking out Address Into Individual Columbs (Addres, City, State) --

SELECT PropertyAddress
FROM housing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress -1)) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress 1)) LEN(PropertyAddress)) AS Address, 
FROM housing

SELECT * 
FROM housing 

SELECT OwnerAddress
FROM housing 

SELECT 
PARSNAME(REPLACE(OwnerAddress, ',' , '.' , 3))
PARSNAME(REPLACE(OwnerAddress, ',' , '.' , 2))
PARSNAME(REPLACE(OwnerAddress, ',' , '.' , 1))
FROM housing 

-- Change Y and N and No in "Sold as Vacant" -- 

SELECT Distinct(SoldAsVacant)
FROM housing 
GROUP BY SoldAsVacant 
ORDER BY 2 

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
FROM housing


-- Remove duplicates -- 

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
			PropertyAddress, 
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY 
				UniqueID
                )row_num
FROM housing 
ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE 
WHERE row_num > 1
-- ORDER BY PropertyAddress

-- Delete unused columns -- 

SELECT *
FROM housing 

ALTER TABLE housing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

ALTER TABLE housing
DROP COLUMN SaleDate