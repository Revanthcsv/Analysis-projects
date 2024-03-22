----checking the data

select top(100) *
from housing

select *
from housing

------------------------------------------------------------------------------------------

--Standardizing Date Format

select SaleDate,CONVERT(date,SaleDate)
from housing

UPDATE housing
set SaleDate=CONVERT(date,SaleDate)

ALTER TABLE housing
add SaleDateconverted Date

UPDATE housing
set SaleDateconverted=CONVERT(date,SaleDate)

----------------------------------------------------------------------------------------------

--Populating Property Address data()

Select *
from housing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from housing a
join housing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from housing a
join housing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------

--breaking Propertyaddress 

select PropertyAddress
from housing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address2
from housing

ALTER TABLE housing
add Propertyadd Nvarchar(255)

UPDATE housing
set Propertyadd=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE housing
add Propertycity Nvarchar(255)

UPDATE housing
set Propertycity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

---------------------------------------------------------------------------------------------

--Breaking owneraddress

select OwnerAddress
from housing

select PARSENAME(replace(OwnerAddress,',','.'),3),PARSENAME(replace(OwnerAddress,',','.'),2),PARSENAME(replace(OwnerAddress,',','.'),1)
from housing

ALTER TABLE housing
add owneradd Nvarchar(255)

UPDATE housing
set owneradd=PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE housing
add ownercity Nvarchar(255)

UPDATE housing
set ownercity=PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE housing
add Ownerstate Nvarchar(255)

UPDATE housing
set Ownerstate=PARSENAME(replace(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------

--Changing soldasvacant column

select Distinct(SoldAsVacant),count(SoldAsVacant)
from housing
group by SoldAsVacant

select SoldAsVacant,case when SoldAsVacant='Y' then 'Yes' when SoldAsVacant='N' THEN 'No' else SoldAsVacant end
from housing

update housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes' when SoldAsVacant='N' THEN 'No' else SoldAsVacant end

-----------------------------------------------------------------------------------------------------------

--Removing duplicates

with rownum as(
select *,ROW_NUMBER() over ( partition by parcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueID ) row_num
from housing
)
Select * 
from rownum 
where row_num > 1

with rownum as(
select *,ROW_NUMBER() over ( partition by parcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueID ) row_num
from housing
)
DELETE 
from rownum 
where row_num > 1

---------------------------------------------------------------------------------------------------

--Deleting useless columns

ALTER Table housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER Table housing
DROP COLUMN SaleDate

select *
from housing


