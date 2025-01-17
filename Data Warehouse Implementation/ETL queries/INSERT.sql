USE CarSharingDW
GO
INSERT INTO dbo.CITY(city_id, city_name, population, area)
SELECT city_id, city_name,
CASE
	WHEN population > 100000 AND population <= 250000 THEN '100000 - 250000'
	WHEN population > 250001 AND population <= 500000 THEN '250001 - 500000'
	WHEN population > 500001 AND population <= 750000 THEN '500001 - 750000'
	WHEN population > 750001 AND population <= 1000000 THEN '750001 - 1000000'
	WHEN population > 1000000 THEN '1000000+'
END AS population,
CASE
	WHEN area > 50 AND area <= 150 THEN '50 - 150'
	WHEN area > 151 AND area <= 250 THEN '151 - 250'
	WHEN area > 251 AND area <= 350 THEN '251 - 350'
	WHEN area > 351 AND area <= 500 THEN '351 - 500'
	WHEN area > 500 THEN '500+'
END AS area
FROM CarSharing.dbo.CITIES


CREATE TABLE #temp_date_table ("date" date, id INT IDENTITY(1,1))
INSERT INTO #temp_date_table ("date") SELECT DISTINCT "date" FROM CarSharing.dbo.WEATHERS ORDER BY "date" ASC

INSERT INTO CarSharingDW.dbo."DATE"(date_id, "date", "year", "month", month_no, day_of_week, day_of_week_no, vacation_month, season)
SELECT id as date_id, "date", YEAR("date") as "year", 
CASE
	WHEN MONTH("date") = 1 THEN 'January'
	WHEN MONTH("date") = 2 THEN 'February'
	WHEN MONTH("date") = 3 THEN 'March'
	WHEN MONTH("date") = 4 THEN 'April'
	WHEN MONTH("date") = 5 THEN 'May'
	WHEN MONTH("date") = 6 THEN 'June'
	WHEN MONTH("date") = 7 THEN 'July'
	WHEN MONTH("date") = 8 THEN 'August'
	WHEN MONTH("date") = 9 THEN 'September'
	WHEN MONTH("date") = 10 THEN 'October'
	WHEN MONTH("date") = 11 THEN 'November'
	WHEN MONTH("date") = 12 THEN 'December'
END as "month", MONTH("date") as month_no, DATENAME(WEEKDAY, "date") as day_of_week, DATEPART(WEEKDAY, "date") as day_of_week_no,
CASE
	WHEN MONTH("date") = 12 THEN 'winter holiday'
	WHEN MONTH("date") = 7 OR MONTH("date") = 8 THEN 'summer holiday'
	WHEN MONTH("date") NOT IN (7, 8, 12) THEN 'non-holiday'
END as vacation_month,
CASE
	WHEN MONTH("date") IN (12, 1, 2) THEN 'winter'
	WHEN MONTH("date") IN (3, 4, 5) THEN 'spring'
	WHEN MONTH("date") IN (6, 7, 8) THEN 'summer'
	WHEN MONTH("date") IN (9, 10, 11) THEN 'autumn'
END
FROM #temp_date_table

DROP TABLE #temp_date_table


INSERT INTO dbo.EQUIPMENT(equipment_id, heated_seats, ventilated_seats, "abs", "asc", gps, air_conditioning, android_auto, apple_carplay, transmission)
SELECT    equipment_id, 
        IIF(heated_seat = 1, 'has', 'does not have') as heated_seats ,
        IIF(ventilated_seats = 1, 'has', 'does not have') as ventilated_seats,
        IIF("abs" = 1, 'has', 'does not have') as "abs",
        IIF("automatic_stability_control" = 1, 'has', 'does not have') as "asc",
        IIF(gps = 1, 'has', 'does not have') as gps,
        IIF(air_conditioning = 1, 'has', 'does not have') as air_conditioning,
        IIF(android_auto = 1, 'has', 'does not have') as android_auto,
        IIF(apple_carplay = 1, 'has', 'does not have') as apple_carplay,
        transmission
FROM CarSharing.dbo.EQUIPMENTS


INSERT INTO dbo."USER"("user_id", gender, age)
SELECT "user_id", gender,
CASE
    WHEN age > 18 AND age <= 25 THEN '18-25'
    WHEN age > 25 AND age <= 33 THEN '26-33'
    WHEN age > 33 AND age <= 41 THEN '34-41'
    WHEN age > 41 AND age <= 49 THEN '42-49'
    WHEN age > 49 AND age <= 57 THEN '50-57'
    WHEN age > 57 THEN '58+'
END AS age
FROM CarSharing.dbo.USERS


INSERT INTO dbo.WEATHER(weather_id, rain, cloud, avg_temp)
SELECT wheather_id,
CASE
    WHEN rain < 30 THEN 'LOW'
    WHEN rain >= 30 AND rain < 50 THEN 'AVERAGE'
    WHEN rain >= 50 THEN 'HIGH'
END AS rain,
CASE
    WHEN clouds < 65 THEN 'LOW'
    WHEN clouds >= 65 AND clouds < 70 THEN 'AVERAGE'
    WHEN clouds >= 70 THEN 'HIGH'
END AS cloud,
CASE
    WHEN avg_temp <= 8 THEN 'LOW'
    WHEN avg_temp > 9 AND avg_temp <= 19 THEN 'AVERAGE'
    WHEN avg_temp > 19 THEN 'HIGH'
END AS avg_temp
FROM CarSharing.dbo.WEATHERS


CREATE TABLE #temp_cars_table ("VIN_number" VARCHAR(17), make VARCHAR(50), model VARCHAR(50), id INT IDENTITY(1,1))
INSERT INTO #temp_cars_table ("VIN_number", make, model) SELECT VIN_number, make, model FROM CarSharing.dbo.CARS

INSERT INTO CarSharingDW.dbo.CAR(car_id, vin_number, make, model)
SELECT id, VIN_number, make, model
FROM #temp_cars_table

DROP TABLE #temp_cars_table


INSERT INTO CarSharingDW.dbo.MISCELLANEOUS(miscellaneous_id, amount_category, nominal_distance)
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


CREATE TABLE tempratingfromcsv(rating int, vin_number varchar(17), "date" date, city_name varchar(20))
BULK INSERT tempratingfromcsv
FROM 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\RATINGS_T2_T1.txt'
WITH
(
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- If your CSV file has a header row, set this to 2; otherwise, set it to 1
)

CREATE TABLE #temp_rating_table(id INT IDENTITY(1, 1), rating INT, vin_number varchar(17), "date" date, city_name varchar(20))
INSERT INTO #temp_rating_table(rating, vin_number, "date", city_name) SELECT rating, vin_number, "date", city_name FROM tempratingfromcsv


INSERT INTO RATING(rating_id, rating)
SELECT id, 
CASE
    WHEN rating < 2 THEN 'low'
    WHEN rating >= 2 and rating < 4 THEN 'average'
    WHEN rating >= 4 THEN 'high'
END AS rating
FROM #temp_rating_table

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

create table #temprating_rental(rental_id int, rating_id int, rating int)
insert into #temprating_rental(rental_id, rating_id, rating)
select DISTINCT rental_id, id, rating
from carsharing.dbo.RENTALS R
RIGHT JOIN #temp_rating_table ON R.VIN_number = #temp_rating_table.vin_number --AND R."date" = #temp_rating_table."date"

INSERT INTO dbo.RENTAL(rental_id, city_id, car_id, weather_id, date_id, rating_id, equipment_id, "user_id", miscellaneous_id,
ratio_population_to_cars, ratio_area_to_cars, ratio_male_to_female, distance, numerical_rating, amount)
	SELECT  RENTALS.rental_id, 
			RENTALS.city_id as city_id, 
			car_id,
			WEATHERS.wheather_id as weather_id,
			date_id,
			null as rating_id,
			equipment_id,
			"USER"."user_id" as "user_id",
			RENTALS.rental_id as miscellaneous_id,
			ROUND((CITIES."population"/ CAST(#temp_cars_cities.cars_in_cities AS FLOAT)), 0) as ratio_population_to_cars,
			ROUND((CITIES.area/ CAST(#temp_cars_cities.cars_in_cities AS FLOAT)), 0) as ratio_area_to_cars,
			ROUND(CAST(men as FLOAT)/female, 2) as ratio_male_to_female,
			distance as distance,
			null as numerical_rating,
			amount as amount
FROM CarSharing.dbo.RENTALS
LEFT JOIN CarSharingDW.dbo.CAR ON RENTALS.VIN_number = CAR.vin_number
LEFT JOIN CarSharing.dbo.WEATHERS ON RENTALS.city_id = WEATHERS.city_id
LEFT JOIN CarSharingDW.dbo."DATE" ON RENTALS."date" = "DATE"."date"
LEFT JOIN CarSharing.dbo.CARS ON RENTALS.VIN_number = CARS.vin_number
LEFT JOIN CarSharingDW.dbo."USER" ON RENTALS."user_id" = "USER"."user_id"
LEFT JOIN CarSharing.dbo.CITIES ON RENTALS.city_id = CITIES.city_id
LEFT JOIN #temp_cars_cities ON RENTALS.city_id = #temp_cars_cities.city_id
LEFT JOIN CarSharing.dbo.PAYMENTS ON RENTALS.rental_id = PAYMENTS.payment_id
LEFT JOIN #tempgender ON RENTALS.city_id = #tempgender.city_id
--LEFT JOIN #temprating_rental ON RENTALS.rental_id = #temprating_rental.rental_id
WHERE WEATHERS."date" = RENTALS."date"

--SELECT COUNT(DISTINCT id) FROM #temp_rating_table

SELECT * FROM RENTAL
drop table #temp_rating_table
drop table #temp_cars_cities
drop table #tempgender
drop table #temprating_rental
drop table tempratingfromcsv