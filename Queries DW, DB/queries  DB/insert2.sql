USE CarSharing
GO

bulk insert dbo.CITIES from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\CITIES.txt' with (fieldterminator=';')
bulk insert dbo.CARS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\CARS_T2_T1.txt' with (fieldterminator=';')
bulk insert dbo.USERS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\USERS_T2_T1.txt' with (fieldterminator=';')
bulk insert dbo.EQUIPMENTS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\EQUIPMENTS.txt' with (fieldterminator=';')
bulk insert dbo.RENTALS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\RENTALS_TIME_T2_T1.txt' with (fieldterminator=';')
bulk insert dbo.WEATHERS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\WEATHERS_T2_T1.txt' with (fieldterminator=';')
bulk insert dbo.PAYMENTS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T2\PAYMENTS_T2_T1.txt' with (fieldterminator=';')