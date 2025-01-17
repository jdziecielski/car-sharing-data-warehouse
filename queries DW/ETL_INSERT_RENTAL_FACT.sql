USE CarSharingDW
GO

CREATE TABLE tempratingfromcsv(rating int, vin_number varchar(17), "datetime" datetime, city_name varchar(20))
BULK INSERT tempratingfromcsv
FROM 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\RATINGS_TIME.txt'
WITH
(
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1 -- If your CSV file has a header row, set this to 2; otherwise, set it to 1
)

--CREATE TABLE #temp_rating_table(rating float, vin_number varchar(17), "datetime" datetime, city_name varchar(20))
--INSERT INTO #temp_rating_table(rating, vin_number, "datetime", city_name) SELECT rating, vin_number, "datetime", city_name FROM tempratingfromcsv

CREATE TABLE #temp_rating_2(rating_id INT IDENTITY(1, 1), rating int, vin_number varchar(17), "datetime" datetime, city_name varchar(20))
INSERT INTO #temp_rating_2(rating, vin_number, "datetime", city_name)
SELECT rating, vin_number, "datetime", city_name
FROM tempratingfromcsv

DROP TABLE tempratingfromcsv--, #temp_rating_table

CREATE TABLE #temp_rental_rating (rental_id int, rating_id int, rating int)
INSERT INTO #temp_rental_rating(rental_id, rating_id, rating)
SELECT rental_id, rating.rating_id, rating.rating FROM CarSharing.dbo.RENTALS as rentals
left join CITY as cities on rentals.city_id = cities.city_id
left join #temp_rating_2 as rating on rentals."datetime" = rating."datetime" and rentals.VIN_number = rating.vin_number and cities.city_name = rating.city_name

--SELECT * FROM #temp_rental_rating ORDER BY rental_id
DROP TABLE #temp_rating_2

CREATE TABLE #temp_rentals_nominal(rental_id int, amount_category VARCHAR(20), nominal_distance VARCHAR(20))
INSERT INTO #temp_rentals_nominal(rental_id, amount_category, nominal_distance)
SELECT rental_id, 
CASE
	WHEN amount > 1 AND amount <= 35 THEN 'cheap'
	WHEN amount > 35 AND amount <= 70 THEN 'average'
	WHEN amount > 70 THEN 'expensive'
END as amount_category,
CASE
	WHEN distance > 0 AND distance <= 5 THEN '0 - 5'
	WHEN distance > 5 AND distance <= 10 THEN '6 - 10'
	WHEN distance > 10 AND distance <= 15 THEN '11 - 15'
	WHEN distance > 15 AND distance <= 20 THEN '16 - 20'
	WHEN distance > 20 AND distance <= 25 THEN '21 - 25'
	WHEN distance > 25 AND distance <= 30 THEN '26 - 30'
	WHEN distance > 30 THEN '30+'
END as nominal_distance
FROM (SELECT RENTALS.rental_id, distance, amount FROM CarSharing.dbo.RENTALS JOIN CarSharing.dbo.PAYMENTS ON RENTALS.rental_id = PAYMENTS.rental_id) as #temp

CREATE TABLE #temp_rentals_misc(rental_id int, miscellaneous_id int)
INSERT INTO #temp_rentals_misc(rental_id, miscellaneous_id)
SELECT rental_id, miscellaneous_id
FROM #temp_rentals_nominal
join CarSharingDW.dbo.MISCELLANEOUS as misc on #temp_rentals_nominal.amount_category = misc.amount_category and #temp_rentals_nominal.nominal_distance = misc.nominal_distance

DROP TABLE #temp_rentals_nominal

CREATE TABLE #temp_cars_cities(cars_in_cities float, city_id int)
INSERT INTO #temp_cars_cities(cars_in_cities, city_id)
SELECT COUNT(DISTINCT RENTALS.VIN_number) AS cars_in_cities, RENTALS.city_id
FROM carsharing.dbo.RENTALS 
JOIN carsharing.dbo.CARS ON RENTALS.VIN_number = CARS.VIN_number 
JOIN carsharing.dbo.CITIES ON RENTALS.city_id = CITIES.city_id
GROUP BY RENTALS.city_id

--SELECT  DISTINCT C.city_id, COUNT(DISTINCT (CASE WHEN  U.gender = 'male' THEN R."user_id" END)) AS men, COUNT(DISTINCT (CASE WHEN  U.gender = 'female' THEN R."user_id" END)) AS women
--FROM carsharing.dbo.USERS AS U
--JOIN carsharing.dbo.RENTALS R ON R.user_id = U.user_id
--JOIN carsharing.dbo.CITIES C ON C.city_id = R.city_id
--GROUP BY U.gender, C.city_id

CREATE TABLE #tempmen(city_id int, men int)
INSERT INTO #tempmen(city_id, men)
SELECT C.city_id, COUNT(DISTINCT R."user_id")
FROM carsharing.dbo.USERS AS U
JOIN carsharing.dbo.RENTALS R ON R.user_id = U.user_id
JOIN carsharing.dbo.CITIES C ON C.city_id = R.city_id
WHERE gender = 'male'
GROUP BY U.gender, C.city_id

CREATE TABLE #tempwomen(city_id int, women int)
INSERT INTO #tempwomen(city_id, women)
SELECT C.city_id, COUNT(DISTINCT R."user_id")
FROM carsharing.dbo.USERS AS U
JOIN carsharing.dbo.RENTALS R ON R.user_id = U.user_id
JOIN carsharing.dbo.CITIES C ON C.city_id = R.city_id
WHERE gender = 'female'
GROUP BY U.gender, C.city_id

CREATE TABLE #tempgender(city_id int, men int, female int)
INSERT INTO #tempgender(city_id, men, female)
SELECT m.city_id, m.men, f.women
FROM #tempmen as m
JOIN #tempwomen f ON m.city_id = f.city_id

DROP TABLE #tempwomen, #tempmen


CREATE TABLE #temp_rental(rental_id int,
ratio_population_to_cars float,
ratio_area_to_cars float,
ratio_male_to_female float,
distance float,
numerical_rating int,
amount money)

INSERT INTO #temp_rental(rental_id, ratio_population_to_cars, ratio_area_to_cars, ratio_male_to_female, distance, numerical_rating, amount)
SELECT  rentals.rental_id,
		ROUND((CITIES."population"/ CAST(#temp_cars_cities.cars_in_cities AS FLOAT)), 0) as ratio_population_to_cars,
		ROUND((CITIES.area/ CAST(#temp_cars_cities.cars_in_cities AS FLOAT)), 0) as ratio_area_to_cars,
		ROUND(CAST(men as FLOAT)/female, 2) as ratio_male_to_female,
		distance as distance,
		0 as numerical_rating,
		amount as amount

FROM CarSharing.dbo.RENTALS as rentals
LEFT JOIN CarSharingDW.dbo."USER" ON RENTALS."user_id" = "USER"."user_id"
LEFT JOIN CarSharing.dbo.CITIES ON RENTALS.city_id = CITIES.city_id
LEFT JOIN #temp_cars_cities ON RENTALS.city_id = #temp_cars_cities.city_id
LEFT JOIN CarSharing.dbo.PAYMENTS ON RENTALS.rental_id = PAYMENTS.payment_id
LEFT JOIN #tempgender ON RENTALS.city_id = #tempgender.city_id

DROP TABLE #temp_cars_cities
DROP TABLE #tempgender

CREATE TABLE #final_rental_fact (--rental_id int,
city_id int,
car_id int,
weather_id int,
date_id int,
time_id int,
rating_id int,
equipment_id int,
"user_id" int,
miscellaneous_id int,
ratio_population_to_cars float,
ratio_area_to_cars float,
ratio_male_to_female float,
distance float,
numerical_rating int,
amount money,
is_current VARCHAR(3),
city_name VARCHAR(20)
--CONSTRAINT rental_id PRIMARY KEY (
--        city_id,
--        car_id, 
--        weather_id, 
--        date_id, 
--        rating_id, 
--        equipment_id, 
--        "user_id",
--        miscellaneous_id
--        )
);

INSERT INTO #final_rental_fact(--rental_id,
			city_id,
			car_id,
			weather_id,
			date_id,
			time_id,
			rating_id,
			equipment_id,
			"user_id",
			miscellaneous_id,
			ratio_population_to_cars,
			ratio_area_to_cars,
			ratio_male_to_female,
			distance,
			numerical_rating,
			amount,
			is_current,
			city_name
			)
select --source_rentals.rental_id,
dim_city.city_id, dim_car.car_id, dim_weather.weather_id, dim_date.date_id, dim_time.time_id, dim_rating.rating_id, dim_equip.equipment_id, dim_user."user_id", dim_misc.miscellaneous_id, cars_cities.ratio_population_to_cars, cars_cities.ratio_area_to_cars, cars_cities.ratio_male_to_female, source_rentals.distance, source_rating.rating, source_payments.amount, dim_city.is_current, dim_city.city_name
from CarSharing.dbo.RENTALS as source_rentals
left join CarSharing.dbo.CARS as source_cars on source_rentals.VIN_number = source_cars.VIN_number
join CarSharingDW.dbo.CAR as dim_car on dim_car.vin_number = source_cars.VIN_number
left join CarSharing.dbo.EQUIPMENTS as source_equip on source_cars.equipment_id = source_equip.equipment_id
join CarSharingDW.dbo.EQUIPMENT as dim_equip on source_equip.equipment_id = dim_equip.equipment_id
left join CarSharing.dbo.USERS as source_users on source_rentals."user_id" = source_users."user_id"
left join CarSharingDW.dbo."USER" as dim_user on source_users."user_id" = dim_user."user_id"
left join CarSharing.dbo.PAYMENTS as source_payments on source_rentals.rental_id = source_payments.rental_id
left join CarSharing.dbo.CITIES as source_cities on source_rentals.city_id = source_cities.city_id
left join CarSharingDW.dbo.CITY as dim_city on source_cities.city_id = dim_city.city_id and source_rentals."datetime" BETWEEN dim_city.insertion_date AND ISNULL(dim_city.deactivation_date, CURRENT_TIMESTAMP)
left join CarSharing.dbo.WEATHERS as source_weathers on source_cities.city_id = source_weathers.city_id and CAST(source_rentals."datetime" as date) = source_weathers."date"
left join CarSharingDW.dbo.WEATHER as dim_weather on source_weathers.wheather_id = dim_weather.weather_id
left join CarSharingDW.dbo."DATE" as dim_date on CAST(source_rentals."datetime" as date) = dim_date."date"
left join #temp_rentals_misc as dim_misc on source_rentals.rental_id = dim_misc.rental_id
left join #temp_rental_rating as source_rating on source_rentals.rental_id = source_rating.rental_id
left join CarSharingDW.dbo.RATING as dim_rating on source_rating.rating_id = dim_rating.rating_id
left join #temp_rental as cars_cities on source_rentals.rental_id = cars_cities.rental_id
left join CarSharingDW.dbo."TIME" as dim_time on CAST(source_rentals."datetime" as time) = dim_time."time"

--SELECT * FROM #final_rental_fact ORDER BY date_id
--SELECT rental_id, city_id, car_id, weather_id, date_id, rating_id, equipment_id, "user_id", miscellaneous_id, COUNT(*) as "count" from #final_rental_fact 
--GROUP BY rental_id, city_id, car_id, weather_id, date_id, rating_id, equipment_id, "user_id", miscellaneous_id ORDER BY rental_id

DROP TABLE #temp_rental, #temp_rentals_misc, #temp_rental_rating

MERGE INTO RENTAL as TT
	USING #final_rental_fact as ST
		ON  --TT.rental_id = ST.rental_id
			TT.city_id = ST.city_id
		AND TT.car_id = ST.car_id
		AND TT.weather_id = ST.weather_id
		AND TT.date_id = ST.date_id
		AND TT.time_id = ST.time_id
		AND TT.rating_id = ST.rating_id
		AND TT.equipment_id = ST.equipment_id
		AND TT."user_id" = ST."user_id"
		AND TT.miscellaneous_id = ST.miscellaneous_id
		WHEN NOT MATCHED THEN
			INSERT VALUES (--ST.rental_id,
							ISNULL(ST.city_id, -1),
							ISNULL(ST.car_id, -1),
							ISNULL(ST.weather_id, -1),
							ISNULL(ST.date_id, -1),
							ISNULL(ST.time_id, -1),
							ISNULL(ST.rating_id, -1),
							ISNULL(ST.equipment_id, -1),
							ISNULL(ST."user_id", -1),
							ISNULL(ST.miscellaneous_id, -1), 
			ST.ratio_population_to_cars, ST.ratio_area_to_cars, ST.ratio_male_to_female, ST.distance, ST.numerical_rating, ST.amount)
		WHEN NOT MATCHED BY Source THEN
			DELETE;

DROP TABLE #final_rental_fact

SELECT * FROM RENTAL ORDER BY city_id
