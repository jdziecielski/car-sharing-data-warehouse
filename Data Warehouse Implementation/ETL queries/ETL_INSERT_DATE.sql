USE CarSharingDW
GO

Declare @StartDate date; 
Declare @EndDate date;
SELECT @StartDate = '2021-01-01', @EndDate = '2025-12-31';
Declare @DateInProcess datetime = @StartDate;

While @DateInProcess <= @EndDate
	Begin
		Insert Into carsharingDW.dbo."DATE"
		( "date", "year", "month", month_no, day_of_week, day_of_week_no, vacation_month, season)
		Values ( 
		  @DateInProcess,		--date
			Cast( Year(@DateInProcess) as int),						--year
			Cast( DATENAME(month, @DateInProcess) as varchar(20)),  --month
			Cast( Month(@DateInProcess) as int),					--month_no
			Cast( DATENAME(dw,@DateInProcess) as varchar(20)),		--day of week
			Cast( DATEPART(dw, @DateInProcess) as int),				--day of week_no
			CASE
				WHEN MONTH(@DateInProcess) = 12 THEN 'winter holiday'
				WHEN MONTH(@DateInProcess) = 7 OR MONTH(@DateInProcess) = 8 THEN 'summer holiday'
				WHEN MONTH(@DateInProcess) NOT IN (7, 8, 12) THEN 'non-holiday'
			END,
			CASE
				WHEN MONTH(@DateInProcess) IN (12, 1, 2) THEN 'winter'
				WHEN MONTH(@DateInProcess) IN (3, 4, 5) THEN 'spring'
				WHEN MONTH(@DateInProcess) IN (6, 7, 8) THEN 'summer'
				WHEN MONTH(@DateInProcess) IN (9, 10, 11) THEN 'autumn'
			END);  
		Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	End
go

SET IDENTITY_INSERT CarSharingDW.dbo."DATE" ON;
GO
INSERT INTO CarSharingDW.dbo."DATE"(date_id, "date", "year", "month", month_no, day_of_week, day_of_week_no, vacation_month, season)
VALUES (-1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
