--Cleaning Data in SQL Queries 
select *
from nashvillehousingdatafordatacleaning;

------------------------------------
--Populate Property Address data
Select PropertyAddress
from nashvillehousingdatafordatacleaning;

Select *
from nashvillehousingdatafordatacleaning
where PropertyAddress is null;

Select *
from nashvillehousingdatafordatacleaning
order by ParcelID;

/*Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashvillehousingdatafordatacleaning a
JOIN nashvillehousingdatafordatacleaning b
   on a.parcelID = b.parcelID
   AND a.[UniqueID_] <> b.[UniqueID_]
where a.PropertyAddress is null; */

/*
Update a 
--SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
SET PropertyAddress = (SELECT MAX(b.PropertyAddress))
from nashvillehousingdatafordatacleaning a
JOIN nashvillehousingdatafordatacleaning b
   on a.parcelID = b.parcelID
   AND a.[UniqueID_] <> b.[UniqueID_]
where a.PropertyAddress is null; */


update nashvillehousingdatafordatacleaning a
    SET propertyaddress = (SELECT MAX(b.propertyaddress)
                    FROM nashvillehousingdatafordatacleaning b
                    WHERE a.ParcelID = b.ParcelID AND 
                        b.propertyaddress IS NOT NULL
                    )
    where propertyaddress is null;
-------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress 
from nashvillehousingdatafordatacleaning;

select substr(propertyaddress, 1, INSTR(propertyaddress,',') - 1) as address,
substr(propertyaddress, INSTR(propertyaddress,',') + 1, length(propertyaddress) ) as address
from nashvillehousingdatafordatacleaning;

/*ALTER TABLE nashvillehousingdatafordatacleaning
Add PropertySplitAddress Nvarchar(255); */
alter table nashvillehousingdatafordatacleaning
add property_split_address varchar2(128); 

update nashvillehousingdatafordatacleaning
set property_split_address = substr(propertyaddress, 1, INSTR(propertyaddress,',') - 1);

alter table nashvillehousingdatafordatacleaning
add property_split_city varchar2(128);

update nashvillehousingdatafordatacleaning
set property_split_city = substr(propertyaddress, INSTR(propertyaddress,',') + 1, length(propertyaddress) ) 

select * from nashvillehousingdatafordatacleaning;


---------------------------------------------

--Change Y and N in Yes and No in "Sold as Vacant" field

select distinct soldasvacant, count(soldasvacant)
from nashvillehousingdatafordatacleaning
group by soldasvacant
order by 2;

select soldasvacant,
CASE when soldasvacant = 'Y' Then 'Yes'
    when soldasvacant = 'N' Then 'No'
    ELSE soldasvacant
    END
from nashvillehousingdatafordatacleaning;

update nashvillehousingdatafordatacleaning
set soldasvacant = CASE when soldasvacant = 'Y' Then 'Yes'
    when soldasvacant = 'N' Then 'No'
    ELSE soldasvacant
    END;
    
--Remove Duplicates

delete from nashvillehousingdatafordatacleaning  
where uniqueid_ in (select uniqueid_ from ( SELECT
    uniqueid_,
    parcelid,
    propertyaddress,
    saleprice,
    saledate,
    legalreference,
    ROW_NUMBER()
    OVER(PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
         ORDER BY
             uniqueid_
    ) row_num
FROM
    nashvillehousingdatafordatacleaning
)
WHERE row_num > 1
);


-----------------------

--Delete Unused Columns
alter table nashvillehousingdatafordatacleaning
drop (owneraddress, taxdistrict, propertyaddress);

select * from nashvillehousingdatafordatacleaning;








