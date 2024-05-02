-- 1
LOCK TABLE aircrafts_tmp
    IN ACCESS EXCLUSIVE MODE;

SELECT *
FROM aircrafts_tmp
    WHERE model ~ '^Air'
    FOR UPDATE;

-- 2
BEGIN;
SELECT *
    FROM aircrafts_tmp
    WHERE range < 2000;

UPDATE aircrafts_tmp
    SET range = 2100
    WHERE aircraft_code = 'CN1';

UPDATE aircrafts_tmp
    SET range = 1900
    WHERE aircraft_code = 'CR2';

-- 2
BEGIN;

SELECT *
    FROM aircrafts_tmp
    WHERE range < 2000;

UPDATE aircrafts_tmp
    SET range = 2100
    WHERE aircraft_code = 'CN1';

UPDATE aircrafts_tmp
    SET range = 1900
    WHERE aircraft_code = 'CR2';

-- 3

UPDATE aircrafts_tmp
    SET range = range + 200
    WHERE aircraft_code = 'CR2';

UPDATE aircrafts_tmp
    SET range = 2100
    WHERE aircraft_code = 'CR2';

UPDATE aircrafts_tmp
    SET range = 2500
    WHERE aircraft_code = 'CR2';

-- 10
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT *
FROM ticket_flights
WHERE flight_id = 13881;

INSERT INTO bookings ( book_ref, book_date, total_amount )
VALUES ( 'ABC123', bookings.now(), 0 );

INSERT INTO tickets
( ticket_no, book_ref, passenger_id, passenger_name )
VALUES ( '9991234567890', 'ABC123', '1234 123456', 'IVAN PETROV' );

INSERT INTO ticket_flights
( ticket_no, flight_id, fare_conditions, amount )
VALUES ( '9991234567890', 13881, 'Business', 12500 );

UPDATE bookings
SET total_amount = 12500
WHERE book_ref = 'ABC123';

COMMIT;

