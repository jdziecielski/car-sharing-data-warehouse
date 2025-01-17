USE CarSharingDW
GO

DECLARE @StartTime time = '00:00:00';
DECLARE @EndTime time = '23:59:59';
DECLARE @i INT = 0;

DECLARE @TimeInProcess time = @StartTime;

WHILE (@i < 86400)
	BEGIN
		INSERT INTO carsharingDW.dbo."TIME"("time", "hour", "minute", "second", time_of_day)
		VALUES (
			@TimeInProcess,
			CAST(DATEPART(hh, @TimeInProcess) AS INT), --hour
			CAST(DATEPART(mi, @TimeInProcess) AS INT), --minute
			CAST(DATEPART(ss, @TimeInProcess) AS INT), --second
			CASE
				WHEN DATEPART(hh, @TimeInProcess) >= 6 AND DATEPART(hh, @TimeInProcess) < 12 then 'morning'
				WHEN DATEPART(hh, @TimeInProcess)>= 12 and DATEPART(hh, @TimeInProcess) < 18 then 'afternoon'
				WHEN DATEPART(hh, @TimeInProcess) >= 18 and DATEPART(hh, @TimeInProcess) < 22 then 'evening'
				WHEN (DATEPART(hh, @TimeInProcess) >= 22 and DATEPART(hh, @TimeInProcess) <= 24) 
					or (DATEPART(hh, @TimeInProcess) >= 0 and DATEPART(hh, @TimeInProcess) < 6) then 'night'
			END
			);
		SET @TimeInProcess = DATEADD(ss, 1, @TimeInProcess);
		SET @i = @i + 1;
	END
GO

SET IDENTITY_INSERT CarSharingDW.dbo."TIME" ON;
GO
INSERT INTO CarSharingDW.dbo."TIME"(time_id, "time", "hour", "minute", "second", time_of_day)
VALUES (-1, NULL, NULL, NULL, NULL, NULL)