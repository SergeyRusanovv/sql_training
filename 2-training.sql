CREATE TABLE aircrafts(
    aircraft_code char(3) NOT NULL,
    model text NOT NULL,
    range integer NOT NULL,
    CHECK (range > 0),
    PRIMARY KEY (aircraft_code)
);


DROP TABLE aircrafts;


INSERT INTO aircrafts (aircraft_code, model, range)
    VALUES ('SU9', 'Sukhoi SuperJet-100', 3000);


INSERT INTO aircrafts (aircraft_code, model, range)
    VALUES  ('773', 'Boeing 777-300', 11100),
            ('763', 'Boeing 767-300', 7900),
            ('733', 'Boeing 737-300', 4200),
            ('320', 'Airbus A320-200', 5700),
            ('321', 'Airbus A321-200', 5600),
            ('319', 'Airbus A319-100', 6700),
            ('CN1', 'Cessna 208 Caravan', 1200),
            ('CR2', 'Bombardier CRJ-200', 2700);


SELECT model, aircraft_code, range
    FROM aircrafts
    ORDER BY model;


SELECT model, aircraft_code, range
    FROM aircrafts
    WHERE range >= 4000 AND range <= 6000;


UPDATE aircrafts
    SET range = 3500
    WHERE aircraft_code = 'SU9';


DELETE FROM aircrafts
    WHERE aircraft_code = 'CN1';


DELETE FROM aircrafts
    WHERE range > 10000 OR range < 3000;


DELETE FROM aircrafts;


CREATE TABLE seats
    (
    aircraft_code char(3) NOT NULL,
    seat_no varchar(4) NOT NULL,
    fare_conditions varchar(10) NOT NULL,
    CHECK
        (fare_conditions IN ('Economy', 'Comfort', 'Business')),
    PRIMARY KEY (aircraft_code, seat_no),
    FOREIGN KEY (aircraft_code)
    REFERENCES aircrafts (aircraft_code)
    ON DELETE CASCADE
);


INSERT INTO seats VALUES
    ('SU9', '1A', 'Business'),
    ('SU9', '1B', 'Business'),
    ('SU9', '10A', 'Economy'),
    ('SU9', '10B', 'Economy'),
    ('SU9', '10F', 'Economy'),
    ('SU9', '20F', 'Economy');


INSERT INTO seats VALUES
    ('773', '1A', 'Business'),
    ('773', '1B', 'Business'),
    ('773', '10A', 'Economy'),
    ('773', '10B', 'Economy'),
    ('773', '10F', 'Economy'),
    ('773', '20F', 'Economy');


SELECT aircraft_code, count(*) FROM seats
    GROUP BY aircraft_code;


SELECT aircraft_code, count(*) FROM seats
    GROUP BY aircraft_code
    ORDER BY count;


SELECT aircraft_code, fare_conditions, count(*)
    FROM seats
    GROUP BY aircraft_code, fare_conditions
    ORDER BY aircraft_code, fare_conditions;