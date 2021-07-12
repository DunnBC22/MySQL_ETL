CREATE SCHEMA IF NOT EXISTS CarConcatenation;
USE CarConcatenation;

CREATE TABLE Audi(
	car_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    manufacturer VARCHAR(10) DEFAULT NULL,
    model VARCHAR(20),
    model_year INT,
    price double,
    transmission VARCHAR(10),
    odometer_miles double,
    fuel_type VARCHAR(10),
    tax double,
    mpg double,
    engine_size double
);

CREATE TABLE BMW LIKE Audi;
CREATE TABLE Benz LIKE Audi;
CREATE TABLE Ford LIKE Audi;
CREATE TABLE Hyundai LIKE Audi;
CREATE TABLE VW LIKE Audi;
CREATE TABLE Toyota LIKE Audi;

# ****INSERT the data into the respective tables here****

SET SQL_SAFE_UPDATES=0;
UPDATE Audi SET manufacturer='Audi';
UPDATE BMW SET manufacturer='BMW';
UPDATE Benz SET manufacturer='Benz';
UPDATE Ford SET manufacturer='Ford';
UPDATE Hyundai SET manufacturer='Hyundai';
UPDATE Toyota SET manufacturer='Toyota';
UPDATE VW SET manufacturer='VW';
SET SQL_SAFE_UPDATES=1;

#Concatenate these tables into one (new) table
CREATE TABLE cars LIKE Audi;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM audi;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM BMW;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM Benz;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM Ford;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM Hyundai;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM Toyota;

INSERT INTO cars (manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size) 
SELECT manufacturer, model, model_year, price, transmission, odometer_miles, fuel_type, tax, mpg, engine_size
FROM VW;

CREATE TABLE manufacturers(
	manu_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    manu_name VARCHAR(12)
);

INSERT INTO manufacturers (manu_name)
SELECT DISTINCT manufacturer FROM cars;

ALTER TABLE manufacturers MODIFY COLUMN manu_id INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE manufacturers MODIFY COLUMN manu_name VARCHAR(12) NOT NULL PRIMARY KEY;

# Replace the manu name with the number from the manufacturers table
SET SQL_SAFE_UPDATES = 0;
CREATE VIEW v_manu_name_to_id AS(
	SELECT
		c.car_id,
        c.manufacturer,
        m.manu_id,
        m.manu_name
    FROM
		cars AS c
    INNER JOIN
		manufacturers AS m
    ON
		m.manu_name=c.manufacturer
);
UPDATE v_manu_name_to_id SET manufacturer=v_manu_name_to_id.manu_id;
SET SQL_SAFE_UPDATES = 1;

# Change column contraints backed to what they should normally be
ALTER TABLE manufacturers MODIFY COLUMN manu_name VARCHAR(12) NOT NULL, DROP PRIMARY KEY;
ALTER TABLE manufacturers MODIFY COLUMN manu_id INT NOT NULL PRIMARY KEY;
#is there a command like SELECT INTO

CREATE TABLE transmissions(
	transmission_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    transmission_name VARCHAR(10) NOT NULL
);

INSERT INTO transmissions (transmission_name)
SELECT DISTINCT transmission FROM cars;

ALTER TABLE transmissions MODIFY COLUMN transmission_id INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE transmissions MODIFY COLUMN transmission_name VARCHAR(10) NOT NULL PRIMARY KEY;

CREATE VIEW v_transmission_name_to_id AS (
	SELECT 
		c.car_id,
        c.transmission,
        t.transmission_id,
        t.transmission_name
    FROM
		cars AS c
    INNER JOIN
		transmissions AS t
    ON
		c.transmission=t.transmission_name
);
UPDATE v_transmission_name_to_id SET transmission=transmission_id;

ALTER TABLE transmissions MODIFY COLUMN transmission_name VARCHAR(10) NOT NULL, DROP PRIMARY KEY;
ALTER TABLE transmissions MODIFY COLUMN transmission_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT;

# model
CREATE TABLE car_models(
	car_model_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    car_model VARCHAR(20)
);

INSERT INTO car_models (car_model)
SELECT DISTINCT model FROM cars;

ALTER TABLE car_models MODIFY COLUMN car_model_id INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE car_models MODIFY COLUMN car_model VARCHAR(20) NOT NULL PRIMARY KEY;

CREATE VIEW v_cm_name_to_id AS (
	SELECT
		c.car_id,
        c.model,
        cm.car_model_id,
        cm.car_model
    FROM
		cars AS c
    INNER JOIN
		car_models AS cm
    ON
		c.model=cm.car_model
);
UPDATE v_cm_name_to_id SET model=car_model_id;

ALTER TABLE car_models MODIFY COLUMN car_model VARCHAR(20) NOT NULL, DROP PRIMARY KEY;
ALTER TABLE car_models MODIFY COLUMN car_model_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT;

# model_year
CREATE TABLE model_years (
	model_year_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	actual_model_year INT NOT NULL
);

INSERT INTO model_years (actual_model_year)
SELECT DISTINCT model_year FROM CarConcatenation.cars;

ALTER TABLE model_years MODIFY COLUMN model_year_id INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE model_years MODIFY COLUMN actual_model_year INT NOT NULL PRIMARY KEY;

CREATE VIEW v_model_year_to_id AS (
	SELECT
		c.car_id,
        c.model_year,
        my.model_year_id,
        my.actual_model_year
    FROM
		cars AS c
    INNER JOIN
		model_years AS my
    ON
		c.model_year=my.actual_model_year
);
SET SQL_SAFE_UPDATES = 0;
UPDATE v_model_year_to_id SET model_year=model_year_id;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE model_years MODIFY COLUMN actual_model_year INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE model_years MODIFY COLUMN model_year_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT;

# fuel_type
CREATE TABLE fuel_types (
	fuel_type_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	actual_fuel_type VARCHAR(9)
);

INSERT INTO fuel_types(actual_fuel_type)
SELECT DISTINCT fuel_type FROM cars;

ALTER TABLE fuel_types MODIFY COLUMN fuel_type_id INT NOT NULL, DROP PRIMARY KEY;
ALTER TABLE fuel_types MODIFY COLUMN actual_fuel_type VARCHAR(9) PRIMARY KEY;

CREATE VIEW v_fuel_type AS (
	SELECT
		c.car_id,
        c.fuel_type,
        f.fuel_type_id,
        f.actual_fuel_type
    FROM
		cars AS c
    INNER JOIN
		fuel_types AS f
    ON
		c.fuel_type=f.actual_fuel_type
);
SET SQL_SAFE_UPDATES = 0;
UPDATE v_fuel_type SET fuel_type=fuel_type_id;
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE fuel_types MODIFY COLUMN actual_fuel_type VARCHAR(9), DROP PRIMARY KEY;
ALTER TABLE fuel_types MODIFY COLUMN fuel_type_id INT NOT NULL PRIMARY KEY auto_increment;

# Drop the unnecessary tables (each individual manu table)
DROP TABLE IF EXISTS Audi;
DROP TABLE IF EXISTS Benz;
DROP TABLE IF EXISTS BMW;
DROP TABLE IF EXISTS Ford;
DROP TABLE IF EXISTS Hyundai;
DROP TABLE IF EXISTS Toyota;
DROP TABLE IF EXISTS VW;

# Change data types for the future foreign keys
ALTER TABLE cars MODIFY COLUMN fuel_type INT;
ALTER TABLE cars MODIFY COLUMN model INT;
ALTER TABLE cars MODIFY COLUMN manufacturer INT;
ALTER TABLE cars MODIFY COLUMN transmission INT;

# ALTER TABLE users ADD CONSTRAINT fk_grade_id FOREIGN KEY (grade_id) REFERENCES grades(id);
ALTER TABLE cars ADD CONSTRAINT FOREIGN KEY (fuel_type) REFERENCES fuel_types(fuel_type_id);
ALTER TABLE cars ADD CONSTRAINT FOREIGN KEY (model) REFERENCES car_models(car_model_id);
ALTER TABLE cars ADD CONSTRAINT FOREIGN KEY (model_year) REFERENCES model_years(model_year_id);
ALTER TABLE cars ADD CONSTRAINT FOREIGN KEY (manufacturer) REFERENCES manufacturers(manu_id);
ALTER TABLE cars ADD CONSTRAINT FOREIGN KEY (transmission) REFERENCES transmissions(transmission_id);
