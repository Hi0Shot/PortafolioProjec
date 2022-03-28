select *
From PortafolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Standarize Data Format



select SaleDateConverted, CONVERT(date,SaleDate)
From PortafolioProject.dbo.NashvilleHousing

Update PortafolioProject.dbo.NashvilleHousing
SET	SaleDate = CONVERT(Date, SaleDate)		

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update PortafolioProject.dbo.NashvilleHousing
SET	SaleDateConverted = CONVERT(Date, SaleDate)


----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortafolioProject..NashvilleHousing
-- Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortafolioProject.dbo.NashvilleHousing a
JOIN PortafolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortafolioProject.dbo.NashvilleHousing a 
JOIN PortafolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortafolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM PortafolioProject.dbo.NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------

-- Creating new Column (City and Address)


ALTER TABLE PortafolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortafolioProject.dbo.NashvilleHousing
SET	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortafolioProject.dbo.NashvilleHousing
SET	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


----------------------------------------------------------------------------------------------------------------------------

-- Split OwnerAddress use different commands


select OwnerAddress
From PortafolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM PortafolioProject.dbo.NashvilleHousing





ALTER TABLE PortafolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortafolioProject.dbo.NashvilleHousing
SET	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortafolioProject.dbo.NashvilleHousing
SET	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortafolioProject.dbo.NashvilleHousing
SET	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)



select *
From PortafolioProject..NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortafolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortafolioProject.dbo.NashvilleHousing



UPDATE PortafolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


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

From PortafolioProject.dbo.NashvilleHousing
-- Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
-- Order By PropertyAddress


-- Delete Unused Columns 

Select *
From PortafolioProject.dbo.NashvilleHousing


ALTER TABLE PortafolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortafolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

