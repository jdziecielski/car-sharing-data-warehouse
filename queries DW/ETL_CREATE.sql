USE CarSharingDW

CREATE TABLE CAR (
car_id int not null primary key,
vin_number varchar(17),
make varchar(20),
model varchar(20)
);

CREATE TABLE CITY (
city_id int IDENTITY(1, 1) primary key,
city_name varchar(20),
population varchar(50),
area varchar (50),
insertion_date datetime,
deactivation_date datetime,
is_current varchar(3)
);

CREATE TABLE WEATHER (
weather_id int not null primary key,
rain varchar(20),
cloud varchar(20),
avg_temp varchar(20)
);

CREATE TABLE "DATE" (
date_id int identity(1,1) primary key,
"date" date,
year numeric,
month varchar(20),
month_no int,
day_of_week varchar(20),
day_of_week_no int,
vacation_month varchar(20),
season varchar(20)
);

CREATE TABLE "TIME" (
time_id int IDENTITY(1,1) primary key,
"time" time,
"hour" int,
"minute" int,
"second" int,
time_of_day varchar(20)	--morning, afternoon, evening, night
)

CREATE TABLE MISCELLANEOUS (
miscellaneous_id int IDENTITY(1, 1) primary key,
amount_category varchar(20),
nominal_distance varchar(20)
);

CREATE TABLE RATING (
rating_id int not null primary key,
rating varchar(20)
);

CREATE TABLE "USER" (
"user_id" int not null primary key,
gender varchar(6),
age varchar(6)
);

CREATE TABLE EQUIPMENT (
equipment_id int IDENTITY(1, 1) primary key,
heated_seats varchar(20),
ventilated_seats varchar(20),
"abs" varchar(20),
"asc" varchar(20),
gps varchar(20),
air_conditioning varchar(20),
android_auto varchar(20),
apple_carplay varchar(20),
transmission varchar(20)
);

CREATE TABLE RENTAL (
--rental_id int primary key,
city_id int references CITY,
car_id int references CAR,
weather_id int references WEATHER,
date_id int references "date",
time_id int references "time",
rating_id int references RATING,
equipment_id int references EQUIPMENT,
"user_id" int references "USER",
miscellaneous_id int references MISCELLANEOUS,
ratio_population_to_cars float,
ratio_area_to_cars float,
ratio_male_to_female float,
distance float,
numerical_rating int,
amount money

CONSTRAINT rental_id PRIMARY KEY (
		city_id,
		car_id, 
		weather_id, 
		date_id,
		time_id,
		rating_id, 
		equipment_id, 
		"user_id",
		miscellaneous_id
		)
);
