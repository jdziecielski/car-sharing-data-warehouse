USE CarSharingDW
GO

INSERT INTO dbo.EQUIPMENT
SELECT
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

SET IDENTITY_INSERT CarSharingDW.dbo.EQUIPMENT ON;
GO
INSERT INTO CarSharingDW.dbo.EQUIPMENT(equipment_id, heated_seats, ventilated_seats, "abs", "asc", gps, air_conditioning, android_auto, apple_carplay, transmission)
VALUES (-1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO