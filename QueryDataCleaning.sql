/* Cleaning Data */
select *
from Portfolio.dbo.[NashvilleHousingData]

--Standarize Date Format
select SaleDate, convert(Date, SaleDate)
from Portfolio.dbo.NashvilleHousingData

/*Oops Ca marche pas
Update Portfolio.dbo.[NashvilleHousingData]
SET SaleDate= convert(Date, SaleDate)
select SaleDate
from Portfolio.dbo.NashvilleHousingData  */

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD NewSaleDate Date;
 
Update Portfolio.dbo.[NashvilleHousingData]
SET NewSaleDate = CONVERT(Date, SaleDate)

select NewSaleDate 
from Portfolio.dbo.NashvilleHousingData

--Populate PropertyAdress
Select *
From Portfolio.dbo.[NashvilleHousingData]
--Where propertyAddress is Null
order by ParcelID

--We observe that same parcelId=> same ProperetyAdress
--Then We do our copy
Select a.ParcelID , a.PropertyAddress,b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From Portfolio.dbo.[NashvilleHousingData] a
join Portfolio.dbo.[NashvilleHousingData] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

--Let's update the table
Update a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio.dbo.[NashvilleHousingData] a
join Portfolio.dbo.[NashvilleHousingData] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Break out adress into different columns (Adress, city, state)

Select PropertyAddress
from Portfolio.dbo.NashvilleHousingData

select 
SUBSTRING(PropertyAddress,1,(CHARINDEX(',', PropertyAddress ))-1) as Adress,
SUBSTRING(PropertyAddress,(CHARINDEX(',', PropertyAddress ))+1,len(PropertyAddress )) as City
from Portfolio.dbo.NashvilleHousingData

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD NewAdress nvarchar(255);
 
Update Portfolio.dbo.[NashvilleHousingData]
SET NewAdress = SUBSTRING(PropertyAddress,1,(CHARINDEX(',', PropertyAddress ))-1)

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD NewCity nvarchar(255);
 
Update Portfolio.dbo.[NashvilleHousingData]
SET NewCity = SUBSTRING(PropertyAddress,(CHARINDEX(',', PropertyAddress ))+1,len(PropertyAddress ))

Select  
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio.dbo.NashvilleHousingData

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD NewOwnerAdress nvarchar(255);
 
Update Portfolio.dbo.[NashvilleHousingData]
SET NewOwnerAdress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD NewCityAdressOwner nvarchar(255);
 
Update Portfolio.dbo.[NashvilleHousingData]
SET NewCityAdressOwner = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table Portfolio.dbo.[NashvilleHousingData]
ADD AdressOwnerState nvarchar(255);
 
Update Portfolio.dbo.[NashvilleHousingData]
SET AdressOwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * 
from Portfolio.dbo.[NashvilleHousingData]

--Replace Y and N to Yes and No in "Soldasvacant" field
Select distinct(SoldAsVacant) , count(SoldAsVacant)
from Portfolio.dbo.[NashvilleHousingData]
group by SoldAsVacant
order by 2

Select SoldAsVacant,  
case when SoldAsVacant ='Y'  then 'Yes'
     when SoldAsVacant ='N'  then 'No'
	 Else SoldAsVacant
	 end 
from Portfolio.dbo.[NashvilleHousingData]

Update NashvilleHousingData
set SoldAsVacant = case when SoldAsVacant ='Y'  then 'Yes'
     when SoldAsVacant ='N'  then 'No'
	 Else SoldAsVacant
	 end 
--Remove duplicates
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

From Portfolio.dbo.[NashvilleHousingData]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
-- Delete Unused Columns



Select *
From Portfolio.dbo.[NashvilleHousingData]


ALTER TABLE Portfolio.dbo.[NashvilleHousingData]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
