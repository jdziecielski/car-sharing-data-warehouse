USE CarSharing
GO

bulk insert dbo.CITIES from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\CITIES.txt' with (fieldterminator=';')
bulk insert dbo.CARS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\CARS.txt' with (fieldterminator=';')
bulk insert dbo.USERS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\USERS.txt' with (fieldterminator=';')
bulk insert dbo.EQUIPMENTS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\EQUIPMENTS.txt' with (fieldterminator=';')
bulk insert dbo.RENTALS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\RENTALS_TIME.txt' with (fieldterminator=';')
bulk insert dbo.WEATHERS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\WEATHERS.txt' with (fieldterminator=';')
bulk insert dbo.PAYMENTS from 'C:\Users\kamil\OneDrive\Dokumenty\Data Warehouses\DATABASE\T1\PAYMENTS.txt' with (fieldterminator=';')
