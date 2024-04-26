SELECT * FROM aircrafts WHERE model LIKE 'Airbus%';
SELECT * FROM aircrafts
    WHERE model NOT LIKE 'Airbus%'
    AND model NOT LIKE 'Boeing%';

SELECT * FROM airports WHERE airport_name LIKE '___';
SELECT * FROM aircrafts WHERE model !~ '300$';
SELECT * FROM aircrafts WHERE range BETWEEN 3000 AND 6000;
SELECT model, range, range / 1.609 AS miles FROM aircrafts;
SELECT model, range, round( range / 1.609, 2 ) AS miles FROM aircrafts; -- ограничение на 2 знака после запятой
SELECT * FROM aircrafts ORDER BY range DESC;
SELECT DISTINCT timezone FROM airports ORDER BY 1;

SELECT airport_name, city, longitude
FROM airports
ORDER BY longitude DESC
LIMIT 3;

SELECT model, range,
CASE WHEN range < 2000 THEN 'Ближнемагистральный'
     WHEN range < 5000 THEN 'Среднемагистральный'
     ELSE 'Дальнемагистральный'
END AS type
FROM aircrafts
ORDER BY model;

SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions
FROM seats AS s
JOIN aircrafts AS a
    ON s.aircraft_code = a.aircraft_code
WHERE a.model ~ '^Cessna'
ORDER BY s.seat_no;

SELECT s.seat_no, s.fare_conditions
FROM seats AS s
    JOIN aircrafts AS a ON s.aircraft_code = a.aircraft_code
WHERE a.model ~ '^Cessna'
ORDER BY s.seat_no;

SELECT count( * )
FROM airports a1, airports a2
WHERE a1.city <> a2.city;

SELECT count( * )
FROM airports a1
JOIN airports a2 ON a1.city <> a2.city;

SELECT count( * )
FROM airports a1 CROSS JOIN airports a2
WHERE a1.city <> a2.city;

SELECT a.aircraft_code AS a_code,
    a.model,
    r.aircraft_code AS r_code,
    count( r.aircraft_code ) AS num_routes
FROM aircrafts a
LEFT OUTER JOIN routes r ON r.aircraft_code = a.aircraft_code
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

SELECT arrival_city FROM routes
WHERE departure_city = 'Москва'
UNION
SELECT arrival_city FROM routes
WHERE departure_city = 'Санкт-Петербург'
ORDER BY arrival_city;

SELECT arrival_city FROM routes
WHERE departure_city = 'Москва'
INTERSECT
SELECT arrival_city FROM routes
WHERE departure_city = 'Санкт-Петербург'
ORDER BY arrival_city;

SELECT arrival_city FROM routes
WHERE departure_city = 'Санкт-Петербург'
EXCEPT
SELECT arrival_city FROM routes
WHERE departure_city = 'Москва'
ORDER BY arrival_city;

SELECT avg( total_amount ) FROM bookings;
SELECT max( total_amount ) FROM bookings;
SELECT min( total_amount ) FROM bookings;

SELECT array_length( days_of_week, 1 ) AS days_per_week,
count( * ) AS num_routes
FROM routes
GROUP BY days_per_week
ORDER BY 1 desc;

SELECT departure_city, count( * )
FROM routes
GROUP BY departure_city
HAVING count( * ) >= 15
ORDER BY count DESC;

SELECT city, count( * )
FROM airports
GROUP BY city
HAVING count( * ) > 1;


SELECT b.book_ref, b.book_date,
extract( 'month' from b.book_date ) AS month,
extract( 'day' from b.book_date ) AS day,
count(*) OVER (
        PARTITION BY date_trunc( 'month', b.book_date )
        ORDER BY b.book_date
    ) AS count
FROM ticket_flights tf
    JOIN tickets t ON tf.ticket_no = t.ticket_no
    JOIN bookings b ON t.book_ref = b.book_ref
WHERE tf.flight_id = 1
ORDER BY b.book_date;

count( * ) OVER (
    PARTITION BY date_trunc( 'month', b.book_date )
    ORDER BY b.book_date
) AS count

SELECT airport_name, city, round( latitude::numeric, 2 ) AS ltd, timezone,
    rank() OVER (
        PARTITION BY timezone
        ORDER BY latitude DESC
        )
FROM airports
WHERE timezone IN ( 'Asia/Irkutsk', 'Asia/Krasnoyarsk' )
ORDER BY timezone, rank;


SELECT airport_name, city, timezone, latitude,
    first_value( latitude ) OVER tz AS first_in_timezone,
    latitude - first_value( latitude ) OVER tz AS delta,
    rank() OVER tz
FROM airports
WHERE timezone IN ( 'Asia/Irkutsk', 'Asia/Krasnoyarsk' )
WINDOW tz AS ( PARTITION BY timezone ORDER BY latitude DESC )
ORDER BY timezone, rank;

SELECT count( * ) FROM bookings
WHERE total_amount >
    ( SELECT avg( total_amount ) FROM bookings );


SELECT flight_no, departure_city, arrival_city
FROM routes
WHERE departure_city IN (
        SELECT city
        FROM airports
        WHERE timezone ~ 'Krasnoyarsk'
        )
AND arrival_city IN (
        SELECT city
        FROM airports
        WHERE timezone ~ 'Krasnoyarsk'
);

SELECT airport_name, city, longitude
FROM airports
WHERE longitude IN (
        ( SELECT max( longitude ) FROM airports ),
        ( SELECT min( longitude ) FROM airports )
        )
ORDER BY longitude;

SELECT DISTINCT a.city
FROM airports a
WHERE NOT EXISTS (
    SELECT * FROM routes r
    WHERE r.departure_city = 'Москва'
        AND r.arrival_city = a.city
    )
AND a.city <> 'Москва'
ORDER BY city;

SELECT a.model,
    ( SELECT count( * )
        FROM seats s
        WHERE s.aircraft_code = a.aircraft_code
        AND s.fare_conditions = 'Business'
    ) AS business,
    ( SELECT count( * )
        FROM seats s
        WHERE s.aircraft_code = a.aircraft_code
        AND s.fare_conditions = 'Comfort'
    ) AS comfort,
    ( SELECT count( * )
        FROM seats s
        WHERE s.aircraft_code = a.aircraft_code
        AND s.fare_conditions = 'Economy'
    ) AS economy
FROM aircrafts a
ORDER BY 1;


SELECT s2.model,
    string_agg(
        s2.fare_conditions || ' (' || s2.num || ')', ', ')
FROM (
        SELECT a.model, s.fare_conditions, count( * ) AS num
        FROM aircrafts a
            JOIN seats s ON a.aircraft_code = s.aircraft_code
        GROUP BY 1, 2
        ORDER BY 1, 2
        ) AS s2
GROUP BY s2.model
ORDER BY s2.model;

SELECT departure_airport, departure_city, count( * )
FROM routes
GROUP BY departure_airport, departure_city
HAVING departure_airport IN (
        SELECT airport_code
        FROM airports
        WHERE longitude > 150
    )
ORDER BY count DESC;

WITH RECURSIVE ranges ( min_sum, max_sum ) AS
    ( VALUES ( 0, 100000 )
    UNION ALL
    SELECT min_sum + 100000, max_sum + 100000
        FROM ranges
        WHERE max_sum <
                    ( SELECT max( total_amount ) FROM bookings )
        )
SELECT * FROM ranges;
