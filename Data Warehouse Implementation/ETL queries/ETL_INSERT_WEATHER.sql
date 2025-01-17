USE CarSharingDW
GO

CREATE TABLE #temp_weather(weather_id INT IDENTITY(1,1) primary key, rain VARCHAR(20), cloud VARCHAR(20), avg_temp VARCHAR(20))
INSERT INTO #temp_weather
SELECT
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
    WHEN avg_temp < 8 THEN 'LOW'
    WHEN avg_temp >= 8 AND avg_temp <= 19 THEN 'AVERAGE'
    WHEN avg_temp > 19 THEN 'HIGH'
END AS avg_temp
FROM CarSharing.dbo.WEATHERS

SET IDENTITY_INSERT #temp_weather ON;
GO
INSERT INTO #temp_weather(weather_id, rain, cloud, avg_temp)
VALUES (-1, NULL, NULL, NULL)


MERGE INTO WEATHER AS W
	USING #temp_weather as T
	ON T.weather_id = W.weather_id
	WHEN NOT MATCHED BY TARGET THEN
		INSERT VALUES (T.weather_id, T.rain, T.cloud, T.avg_temp)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;


DROP TABLE #temp_weather
