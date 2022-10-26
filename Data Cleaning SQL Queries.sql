/*

	Cleaning Data in SQL Queries

*/


select *
from NashvilleHousing$


-----------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(date, SaleDate)
from NashvilleHousing$


update NashvilleHousing$
set SaleDate = convert(date, SaleDate)




-- If doesn't update properly

alter table NashvilleHousing$
add SaleDateConverted date;


update NashvilleHousing$
set SaleDateConverted = convert(date, SaleDate)





-----------------------------------------------------------

-- Populate Property Address Data

select *
from NashvilleHousing$
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing$ a
join NashvilleHousing$ b
on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null


update a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing$ a
join NashvilleHousing$ b
on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null





-----------------------------------------------------------

-- Breaking out Property Address and Owner Address into Individual Columns (Address, City) and (Address, City, State)

select *
from NashvilleHousing$


select substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
	, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City 
from NashvilleHousing$


-- Adding new Column PropertySplitAddress and PropertySplitCity

alter table NashvilleHousing$
add PropertySplitAddress nvarchar(255);


update NashvilleHousing$
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)


alter table NashvilleHousing$
add PropertySplitCity nvarchar(255);


update NashvilleHousing$
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))


select *
from NashvilleHousing$





select OwnerAddress
from NashvilleHousing$


select parsename(replace(Owneraddress, ',', '.'), 3)
	, parsename(replace(Owneraddress, ',', '.'), 2)
	, parsename(replace(Owneraddress, ',', '.'), 1)
from NashvilleHousing$


-- Adding New Column OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState

alter table NashvilleHousing$
add OwnerSplitAddress nvarchar(255);


update NashvilleHousing$
set OwnerSplitAddress = parsename(replace(Owneraddress, ',', '.'), 3)


alter table NashvilleHousing$
add OwnerSplitCity nvarchar(255);


update NashvilleHousing$
set OwnerSplitCity = parsename(replace(Owneraddress, ',', '.'), 2)


alter table NashvilleHousing$
add OwnerSplitState nvarchar(255);


update NashvilleHousing$
set OwnerSplitState = parsename(replace(Owneraddress, ',', '.'), 1)


select *
from NashvilleHousing$





-----------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select *
from NashvilleHousing$


select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing$
group by SoldAsVacant
order by 2


select SoldAsVacant
	, case when SoldAsVacant = 'Y' then 'Yes'
		   when SoldAsVacant = 'N' then 'No'
		   else SoldAsVacant
	  end
from NashvilleHousing$


update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
				   end





-----------------------------------------------------------

-- Remove Duplicates

select *
from NashvilleHousing$


-- Check for Duplicate Data
with RowNumCTE as(
select *,
	row_number() over(
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 LegalReference
		order by UniqueID
	) row_num
from NashvilleHousing$
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Duplicate Data

with RowNumCTE as(
select *,
	row_number() over(
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 LegalReference
		order by UniqueID
	) row_num
from NashvilleHousing$
)
delete
from RowNumCTE
where row_num > 1


select *
from NashvilleHousing$





-----------------------------------------------------------

-- Drop Unused Column

select *
from NashvilleHousing$


alter table NashvilleHousing$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




