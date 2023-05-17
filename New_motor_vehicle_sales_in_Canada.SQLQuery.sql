/*This table is from statcan.gc.ca an open data source
https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=2010000101&pickMembers%5B0%5D=1.1&pickMembers%5B1%5D=2.1&pickMembers%5B2%5D=3.1&pickMembers%5B3%5D=5.1&cubeTimeFrame.startMonth=01&cubeTimeFrame.startYear=1946&cubeTimeFrame.endMonth=02&cubeTimeFrame.endYear=2023&referencePeriods=19460101%2C20230201
It represents new motor vehicle sales in Canada by sales volume, manufacturing country and the type of the vehicles starting from 1946 to present days...*/
----------------------------------------------------------------
/*a brief look into the table in order to clean it*/

Select*
From[dbo].[New_motor_vhicle_sales_in_Canada]

----------------------------------------------------------------
/*making new tables which will make analyzing the data easier.
The first table will repesent the sold vehicle by numbers, the second one is for the value in dollars for the same vehicles
and the last one will be a table that combines the previous two, where retreving a certain data will be more convinient*/ 

Select Left(REF_DATE,Charindex('-',REF_DATE)-1) as Year, REF_DATE as Date, GEO as Province, Vehicle_type, Origin_of_manufacture, VALUE as Units_sold into Unit_sold
From[dbo].[New_motor_vhicle_sales_in_Canada]
Where Sales = 'Units' and Seasonal_adjustment = 'Unadjusted'

/*How did Canadian new motor vehicle sales look like in the past decade?*/

Select top 10 Year, SUM(Units_sold) as Total_motor_vehicle_sales_in_a_particuler_year
From Unit_sold
Where Province='Canada' and Vehicle_type='Total, new motor vehicles' and Origin_of_manufacture='Total, country of manufacture' and Year not like '2023'
Group by Year
Order by Year desc

/*the number of sold vehicles in Cananda increased year over year in the past decade (except 2018, which have seen a slight decrease) until 2019 where the sales number dropped 
in 2020 to less than 1.6m vehicles and started fluctuating the following 2 years. 
(althogh the dataset doesn't provide any reason for a sudden decline in the sales volume in 2020, but we can assume that it was due to Covid-19).
I excluded 2023 data, sinc we don't have a data for a full year yet.*/

/*Which country/region made the most cars/trucks that sold in Canada between 2013 and 2023?*/

Select Top 33 Year,sum(units_sold)as Total_motor_vehicle_sales_in_a_particuler_year,Origin_of_manufacture
From Unit_sold
Where Vehicle_type='Passenger cars' and Province = 'Canada' and Origin_of_manufacture not like 'Total, country of manufacture' and  Origin_of_manufacture not like'Total, overseas'
Group by Origin_of_manufacture , Year
Order by Year desc, Total_motor_vehicle_sales_in_a_particuler_year desc

Select Top 22 Year,sum(units_sold)as Total_motor_vehicle_sales_in_a_particuler_year,Origin_of_manufacture
From Unit_sold
Where Vehicle_type='Trucks' and Province = 'Canada' and Origin_of_manufacture not like 'Total, country of manufacture'
Group by Origin_of_manufacture , Year
Order by Year desc, Total_motor_vehicle_sales_in_a_particuler_year desc

/* In the last decade (including first two months of the current year 2023),the North American manufacturers kept their position as the most passenger cars
and Trucks seller*/

----------------------------------------------------------------------------------------------------

Select Left(REF_DATE,Charindex('-',REF_DATE)-1) as Year,REF_DATE as Date, GEO as Province, Vehicle_type, Origin_of_manufacture, VALUE as Value_in_thousand_dollars into Sales_in_dollars
From[dbo].[New_motor_vhicle_sales_in_Canada]
Where Sales='Dollars'

/*Which manufacturer had the most revenue from selling cars/trucks last decade?*/

Select  Year,sum(Value_in_thousand_dollars)as Value_of_the_sold_vehicles_in_thousand_dollars,Origin_of_manufacture
From Sales_in_dollars
Where Vehicle_type='Passenger cars' and Province = 'Canada' and Origin_of_manufacture not like 'Total, country of manufacture' and Year between 2013 and 2023
Group by Origin_of_manufacture , Year
Order by Year desc, Value_of_the_sold_vehicles_in_thousand_dollars desc

Select  Year,sum(Value_in_thousand_dollars)as Value_of_the_sold_vehicles_in_thousand_dollars,Origin_of_manufacture
From Sales_in_dollars
Where Vehicle_type='Trucks' and Province = 'Canada' and Origin_of_manufacture not like 'Total, country of manufacture' and Year between 2013 and 2023
Group by Origin_of_manufacture , Year
Order by Year desc, Value_of_the_sold_vehicles_in_thousand_dollars desc

/*the north American manufacturers had the highest revenue in the same period (between 2013 and 2023) for both passenger cars and Trucks*/

------------------------------------------------------------------------------------------------------------
/*What was the average car/truck price in Canadain provinces in 2022, and which province spent the most on average for a single car/truck?*/

Select SU.Year,SU.Vehicle_type,SU.Province,sum(SD.Value_in_thousand_dollars) as Value_in_thousand_dollars,sum(SU.Units_sold) as Units_sold,avg(SD.Value_in_thousand_dollars/SU.Units_sold) as Average_vehicle_price_in_thousand_dollars
From Unit_sold as SU
Inner join Sales_in_dollars as SD
On SU.Date=SD.Date and SU.Vehicle_type=SD.Vehicle_type and SU.Province=SD.Province and SU.Vehicle_type=SD.Vehicle_type and SU.Origin_of_manufacture=SD.Origin_of_manufacture and SU.Year=SD.Year
Where SU.Year='2022' and SU.Origin_of_manufacture='Total, country of manufacture' and SU.Vehicle_type='Passenger cars' and SU.Vehicle_type not like 'Total, new motor vehicles'
group by SU.Year, SU.Vehicle_type,SU.Province
Order by Average_vehicle_price_in_thousand_dollars desc

Select SU.Year,SU.Vehicle_type,SU.Province,sum(SD.Value_in_thousand_dollars) as Value_in_thousand_dollars,sum(SU.Units_sold) as Units_sold,avg(SD.Value_in_thousand_dollars/SU.Units_sold) as Average_vehicle_price_in_thousand_dollars
From Unit_sold as SU
Inner join Sales_in_dollars as SD
On SU.Date=SD.Date and SU.Vehicle_type=SD.Vehicle_type and SU.Province=SD.Province and SU.Vehicle_type=SD.Vehicle_type and SU.Origin_of_manufacture=SD.Origin_of_manufacture and SU.Year=SD.Year
Where SU.Year='2022' and SU.Origin_of_manufacture='Total, country of manufacture' and SU.Vehicle_type='Trucks' and SU.Vehicle_type not like 'Total, new motor vehicles'
group by SU.Year, SU.Vehicle_type,SU.Province
Order by Average_vehicle_price_in_thousand_dollars desc

/*In 2022 average passenger car costed 41 thousand dollars and the average truck costed 53 thousands in Canada.
The British Colomians spent the most on passnger cars 46 thousands, followed by Albertans and Ontarians who both spent 42 thousands dollars in average for a passenger car.
On the Other hand The Albertans spent the most on the trucks with 58 thousand on average per truck, followed by Saskatchewenians and manitobans who spent 57 and 56 thousands
respectively*/
------------------------------------------------------------------------------------------------------------