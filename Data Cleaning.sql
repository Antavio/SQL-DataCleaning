/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [SaleDate]  
  FROM [Portfolio Projects].[dbo].[NashvilleHousing]

--Converting DateTime Field to DateField
SELECT [SaleDate],
	   CONVERT(date,[SaleDate])
FROM [dbo].[NashvilleHousing]


UPDATE [dbo].[NashvilleHousing]
SET [SaleDate] = CONVERT(date,[SaleDate])

ALTER TABLE [dbo].[NashvilleHousing]
ADD ShortSalesDate Date;

UPDATE [dbo].[NashvilleHousing]
SET [ShortSalesDate] = CONVERT(date,[SaleDate])

SELECT [SaleDate],[ShortSalesDate]
       FROM [dbo].[NashvilleHousing];

--Where [PropertyAddress] is Null
SELECT a.[UniqueID ],b.[UniqueID ],a.ParcelID,b.ParcelID, a.PropertyAddress, b.PropertyAddress
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

--Updating Null With Corresponding Values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;


--Splitting Property Address
select [PropertyAddress]
	  ,SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1) AS Address
	  ,SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress])) AS Address

from [dbo].[NashvilleHousing]

 -- Add New columns to the table
 ALTER TABLE [dbo].[NashvilleHousing]
 ADD PropertySplitAddress nvarchar(255),
     PropertySplitCity nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1),
    PropertySplitCity = SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress]))

SELECT * 
FROM [dbo].[NashvilleHousing]
ORDER BY 2

-- Splitting OwnerAddress To Address, City & State 
SELECT 
PARSENAME(REPLACE([OwnerAddress],',','.'),3),
PARSENAME(REPLACE([OwnerAddress],',','.'),2),
PARSENAME(REPLACE([OwnerAddress],',','.'),1)
FROM [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
 ADD OwnerSplitAddress nvarchar(255),
     OwnerSplitCity nvarchar(255),
	 OwnerSplitState nvarchar(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE([OwnerAddress],',','.'),3),
    OwnerSplitCity = PARSENAME(REPLACE([OwnerAddress],',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE([OwnerAddress],',','.'),1);


--Replacing Y with Yes & N with No in the SoldAsVacant column
select SoldAsVacant,
case
    when SoldAsVacant = 'N' THEN 'No'
	when SoldAsVacant = 'Y' THEN 'Yes'
	else SoldAsVacant
end
from [dbo].[NashvilleHousing]
order by 2

update [dbo].[NashvilleHousing]
set [SoldAsVacant] = case
    when SoldAsVacant = 'N' THEN 'No'
	when SoldAsVacant = 'Y' THEN 'Yes'
	else SoldAsVacant
end

select distinct [SoldAsVacant], COUNT([SoldAsVacant]) as Total
from [dbo].[NashvilleHousing]
group by [SoldAsVacant]

select distinct [SoldAsVacant], 
COUNT([SoldAsVacant]) OVER (partition by [SoldAsVacant]) as Total
from [dbo].[NashvilleHousing];

-- Removing Duplicates
WITH DuplicateCTE
AS
(SELECT *,
     ROW_NUMBER() OVER (PARTITION BY [ParcelID],[PropertyAddress],[SaleDate],[SalePrice],[LegalReference] ORDER BY [UniqueID ]) AS row_num
FROM [dbo].[NashvilleHousing])

select *
--DELETE
from DuplicateCTE
where row_num > 1
order by UniqueID

--Removing Unused columns

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN [PropertyAddress], [SaleDate], [OwnerAddress], [TaxDistrict]

SELECT * FROM [dbo].[NashvilleHousing]