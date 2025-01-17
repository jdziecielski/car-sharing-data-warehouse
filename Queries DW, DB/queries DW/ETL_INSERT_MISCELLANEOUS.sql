USE CarSharingDW
GO

INSERT INTO CarSharingDW.dbo.MISCELLANEOUS
SELECT amount_category, nominal_distance
FROM
(
	VALUES
		('cheap'),
		('average'),
		('expensive')
)
as amount(amount_category),
(
	VALUES
	('0 - 5'),
	('6 - 10'),
	('11 - 15'),
	('16 - 20'),
	('21 - 25'),
	('26 - 30'),
	('30+')
)
as distance(nominal_distance)
--FROM (SELECT RENTALS.rental_id, distance, amount FROM CarSharing.dbo.RENTALS JOIN CarSharing.dbo.PAYMENTS ON RENTALS.rental_id = PAYMENTS.rental_id) as #temp
SET IDENTITY_INSERT CarSharingDW.dbo.MISCELLANEOUS ON;
GO
INSERT INTO CarSharingDW.dbo.MISCELLANEOUS(miscellaneous_id, amount_category, nominal_distance)
VALUES (-1, NULL, NULL)
GO

--SET IDENTITY_INSERT CarSharingDW.dbo.MISCELLANEOUS OFF;
