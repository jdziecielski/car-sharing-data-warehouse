USE CarSharing
GO

CREATE TABLE EQUIPMENTS (
equipment_id int not null primary key,
heated_seat int,
ventilated_seats int,
ABS int,
automatic_stability_control int,
air_conditioning int,
GPS int,
android_auto int,
apple_carplay int,
transmission varchar(20)
);

CREATE TABLE CARS (
VIN_number varchar(17) NOT NULL PRIMARY KEY,
make varchar(50),
model varchar(50),
prod_year int,
engine_power int,
type varchar(50),
equipment_id int references EQUIPMENTS
);

CREATE TABLE CITIES (
city_id int not null primary key,
city_name varchar(50),
voivodeship varchar(50),
population int,
area int
);

CREATE TABLE USERS (
user_id int primary key,
user_name varchar(50),
email varchar(50),
phone int,
age int,
gender varchar(10)
);

CREATE TABLE RENTALS (
rental_id int primary key,
VIN_number varchar(17) references CARS,
city_id int references CITIES,
user_id int references USERS,
"datetime" datetime,
distance float
);


CREATE TABLE PAYMENTS (
payment_id int not null primary key,
rental_id int references RENTALS,
amount float,
date date,
method varchar(50)
);



CREATE TABLE WEATHERS (
wheather_id int not null primary key,
city_id int references CITIES,
clouds float,
rain float,
avg_temp int,
date date
);


