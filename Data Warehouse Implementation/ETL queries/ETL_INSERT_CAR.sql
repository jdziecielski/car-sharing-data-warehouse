USE CarSharingDW
GO

CREATE TABLE #temp_cars (car_id int identity(1,1) primary key, "VIN_number" VARCHAR(17), make VARCHAR(50), model VARCHAR(50))
INSERT INTO #temp_cars ("VIN_number", make, model) SELECT VIN_number, make, model FROM CarSharing.dbo.CARS

SET IDENTITY_INSERT #temp_cars ON;
GO
INSERT INTO #temp_cars(car_id, vin_number, make, model)
VALUES (-1, NULL, NULL, NULL)
GO

MERGE INTO CAR AS C
	USING #temp_cars as T
	ON T.car_id = C.car_id
	WHEN NOT MATCHED BY TARGET THEN
		INSERT VALUES (T.car_id, T.vin_number, T.make, T.model)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

DROP TABLE #temp_cars
