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

CREATE TABLE #temp_rating_table(rating INT, vin_number varchar(17), "datetime" datetime, city_name varchar(20))
INSERT INTO #temp_rating_table(rating, vin_number, "datetime", city_name) SELECT rating, vin_number, "datetime", city_name FROM tempratingfromcsv

CREATE TABLE #temp_rating_2(rating_id INT IDENTITY(1, 1), rating VARCHAR(20))
INSERT INTO #temp_rating_2(rating)
SELECT 
CASE
    WHEN rating < 2 THEN 'low'
    WHEN rating >= 2 and rating < 4 THEN 'average'
    WHEN rating >= 4 THEN 'high'
END AS rating
FROM #temp_rating_table

SET IDENTITY_INSERT #temp_rating_2 ON;
GO
INSERT INTO #temp_rating_2(rating_id, rating)
VALUES (-1, NULL)
GO

MERGE INTO RATING as TT
	USING #temp_rating_2 as ST
		ON TT.rating_id = ST.rating_id
		--AND TT.gender = ST.gender
		--AND TT.age = ST.age
		WHEN NOT MATCHED THEN
			INSERT VALUES (ST.rating_id, ST.rating)
		WHEN NOT MATCHED BY Source THEN
			DELETE;

drop table tempratingfromcsv
drop table #temp_rating_table
drop table #temp_rating_2