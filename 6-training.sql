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