USE CarSharingDW
GO

CREATE TABLE #temp_city(
city_id int IDENTITY(1, 1),
city_name varchar(20),
population varchar(50),
area varchar (50),
insertion_date datetime,
deactivation_date datetime,
is_current VARCHAR(3)
)

INSERT INTO #temp_city
SELECT city_name,
CASE
    WHEN population > 100000 AND population <= 250000 THEN '100000 - 250000'
    WHEN population > 250000 AND population <= 500000 THEN '250001 - 500000'
    WHEN population > 500000 AND population <= 750000 THEN '500001 - 750000'
    WHEN population > 750000 AND population <= 1000000 THEN '750001 - 1000000'
    WHEN population > 1000000 THEN '1000000+'
END AS population,
CASE
    WHEN area > 50 AND area <= 150 THEN '50 - 150'
    WHEN area > 150 AND area <= 250 THEN '151 - 250'
    WHEN area > 250 AND area <= 350 THEN '251 - 350'
    WHEN area > 350 AND area <= 500 THEN '351 - 500'
    WHEN area > 500 THEN '500+'
END AS area,
NULL as insertion_date,
NULL as deactivation_date,
NULL as is_current
FROM CarSharing.dbo.CITIES

--SET IDENTITY_INSERT #temp_city ON;
--GO

--INSERT INTO #temp_city(city_id, city_name, population, area)
--VALUES (-1, NULL, NULL, NULL)
--GO

Declare @EntryDate datetime; 
--SELECT @EntryDate = '2021-01-01 00:00:00';
SELECT @EntryDate = GetDate();


MERGE INTO CITY as TT
	USING #temp_city as ST
		ON TT.city_name = ST.city_name
		WHEN NOT MATCHED THEN
			INSERT VALUES (--ST.city_id,
							ST.city_name,
							ST.population,
							ST.area,
							CASE
							WHEN ST.city_id = -1 THEN NULL
							ELSE @EntryDate END,
							NULL,
							CASE
							WHEN ST.city_id = -1 THEN NULL
							ELSE 'YES' END)
		WHEN MATCHED AND (ST.population <> TT.population OR ST.area <> TT.area) AND TT.is_current = 'YES'
		THEN
			UPDATE 
			SET TT.is_current = 'NO',
				TT.deactivation_date = @EntryDate
		WHEN NOT MATCHED BY Source 
		AND TT.city_name != NULL
			THEN
			UPDATE
			SET TT.is_current = 'NO',
				TT.deactivation_date = @EntryDate;
	


INSERT INTO CITY(city_name, population, area, insertion_date, deactivation_date, is_current)
	SELECT city_name, population, area, @EntryDate, NULL, 'YES' FROM #temp_city
	EXCEPT SELECT city_name, population, area, @EntryDate, NULL, is_current FROM CITY

SET IDENTITY_INSERT CITY ON
--GO

IF NOT EXISTS (SELECT city_id from city where city_id = '-1')
	INSERT INTO CITY(city_id, city_name, population, area, insertion_date, deactivation_date, is_current)
	VALUES (-1, NULL, NULL, NULL, NULL, NULL, NULL)

SET IDENTITY_INSERT CITY OFF

SELECT * FROM #temp_city
SELECT * FROM CITY
DROP TABLE #temp_city
