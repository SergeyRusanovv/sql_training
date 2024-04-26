-- 1
-- вернет общее количество строк в таблице «Билеты».
SELECT count( * ) FROM tickets;
-- вернет количество строк, где в столбце passenger_name есть хотя бы один пробел.
SELECT count( * ) FROM tickets WHERE passenger_name LIKE '% %';
-- вернет количество строк, где в столбце passenger_name есть ровно два пробела.
SELECT count( * ) FROM tickets WHERE passenger_name LIKE '% % %';
-- вернет количество строк, где в столбце passenger_name есть хотя бы один пробел перед знаком процента.
SELECT count( * ) FROM tickets WHERE passenger_name LIKE '% %%';

-- 2
SELECT passenger_name
FROM tickets
WHERE passenger_name LIKE '___ %';

SELECT passenger_name
FROM tickets
WHERE passenger_name LIKE '% _____';

-- 6
SELECT flight_no FROM routes AS r
JOIN aircrafts AS a ON a.aircraft_code = r.aircraft_code
WHERE a.model = 'Боинг 737-300';

-- 7
SELECT DISTINCT departure_city, arrival_city
FROM routes r
JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
WHERE a.model = 'Боинг 777-300' AND departure_city > arrival_city
ORDER BY 1;

-- 8
SELECT * FROM seats AS s
FULL OUTER JOIN aircrafts_data AS ad ON s.aircraft_code = ad.aircraft_code;


-- 9
SELECT count( * )
FROM routes
WHERE departure_city = 'Москва' AND arrival_city = 'Санкт-Петербург';

SELECT departure_city, arrival_city, count( * ) as c
FROM routes
WHERE departure_city = 'Москва' AND arrival_city = 'Санкт-Петербург'
GROUP BY departure_city, arrival_city;


-- 10
SELECT departure_city, count(DISTINCT arrival_city) AS c
FROM routes
GROUP BY departure_city
ORDER BY c DESC;

-- 11
SELECT arrival_city, count(*) AS c
FROM routes
WHERE array_length(days_of_week, 1) = 7 AND departure_city = 'Москва'
GROUP BY arrival_city
ORDER BY c DESC
LIMIT 5;

-- 12
SELECT 'Понедельник' AS day_of_week, count( * ) AS num_flights
FROM routes
WHERE departure_city = 'Москва'
AND days_of_week @> '{ 1 }'::integer[];

SELECT unnest( days_of_week ) AS day_of_week, count( * ) AS num_flights
FROM routes
WHERE departure_city = 'Москва'
GROUP BY day_of_week
ORDER BY day_of_week;

SELECT dw.name_of_day, count( * ) AS num_flights
FROM (
SELECT unnest( days_of_week ) AS num_of_day
FROM routes
WHERE departure_city = 'Москва'
    ) AS r,
    unnest( '{ 1, 2, 3, 4, 5, 6, 7 }'::integer[],
    '{ "Пн.", "Вт.", "Ср.", "Чт.", "Пт.", "Сб.", "Вс."}'::text[]
    ) AS dw( num_of_day, name_of_day )
WHERE r.num_of_day = dw.num_of_day
GROUP BY r.num_of_day, dw.name_of_day
ORDER BY r.num_of_day;

SELECT dw.name_of_day, count(*) AS num_flights
FROM (
    SELECT unnest(days_of_week) AS num_of_day, row_number() OVER () AS ordinality
    FROM routes
    WHERE departure_city = 'Москва'
) AS r
JOIN unnest('{Пн., Вт., Ср., Чт., Пт., Сб., Вс.}'::text[]) WITH ORDINALITY AS dw(name_of_day, ordinality) ON r.num_of_day::int = dw.ordinality
GROUP BY dw.name_of_day, dw.ordinality
ORDER BY dw.ordinality;

-- 13
SELECT f.departure_city, f.arrival_city,
max( tf.amount ), min( tf.amount )
FROM flights_v f
LEFT OUTER JOIN ticket_flights tf ON f.flight_id = tf.flight_id
GROUP BY 1, 2
ORDER BY 1, 2;

-- 14
SELECT
    substring(passenger_name from strpos(passenger_name, ' ') + 1) AS lastname, count( * )
FROM tickets
GROUP BY 1
ORDER BY 2 DESC;

-- 16
SELECT amount FILTER(WHERE amount < 15) / 2 as discount
FROM ticket_flights AS tf
LIMIT 20;

-- 17
SELECT a.aircraft_code, a.model, s.fare_conditions, count(DISTINCT s.seat_no)
    FROM aircrafts AS a
    JOIN seats AS s ON a.aircraft_code = s.aircraft_code
GROUP BY a.aircraft_code, a.model, s.fare_conditions
ORDER BY a.model;


-- 18
SELECT a.aircraft_code, a.model, a.aircraft_code AS r_code,
       COUNT(*) AS num_routes,
       CAST(COUNT(*) AS float) / CAST((SELECT count(*) FROM routes) AS float) as fraction
    FROM aircrafts AS a
    FULL OUTER JOIN routes AS r ON r.aircraft_code = a.aircraft_code
GROUP BY a.aircraft_code, a.model
ORDER BY num_routes DESC;

-- 19
WITH RECURSIVE ranges ( min_sum, max_sum, level)
AS (
    VALUES  ( 0,100000, 1 ),
            ( 100000, 200000, 2 ),
            ( 200000, 300000, 3 )
    UNION
    SELECT min_sum + 100000, max_sum + 100000, level + 1
    FROM ranges
    WHERE max_sum < ( SELECT max( total_amount ) FROM bookings )
)
SELECT * FROM ranges;

-- 20
WITH RECURSIVE ranges ( min_sum, max_sum )
AS (
    VALUES( 0, 100000 )
    UNION ALL
    SELECT min_sum + 100000, max_sum + 100000
    FROM ranges
    WHERE max_sum < ( SELECT max( total_amount ) FROM bookings )
    )
SELECT  r.min_sum,
        r.max_sum,
        count( * )
FROM bookings b
RIGHT OUTER JOIN ranges r
    ON b.total_amount >= r.min_sum
    AND b.total_amount < r.max_sum
GROUP BY r.min_sum, r.max_sum
ORDER BY r.min_sum;

-- 21
SELECT DISTINCT a.city
FROM airports a
WHERE NOT EXISTS (
SELECT * FROM routes r
    WHERE r.departure_city = 'Москва' AND r.arrival_city = a.city)
        AND a.city <> 'Москва'
ORDER BY city;

SELECT city
FROM airports
WHERE city <> 'Москва'
EXCEPT
SELECT arrival_city
FROM routes
WHERE departure_city = 'Москва'
ORDER BY city;


-- 22
SELECT aa.city, aa.airport_code, aa.airport_name
FROM (
    SELECT city, count( * )
    FROM airports
    GROUP BY city
    HAVING count( * ) > 1
    ) AS a
JOIN airports AS aa ON a.city = aa.city
ORDER BY aa.city, aa.airport_name;


-- 23
-- 24
SELECT count( * )
FROM ( SELECT DISTINCT city FROM airports ) AS a1
JOIN ( SELECT DISTINCT city FROM airports ) AS a2
ON a1.city <> a2.city;

WITH city_list AS (SELECT DISTINCT city FROM airports)
SELECT COUNT(*)
FROM city_list AS a1
JOIN city_list AS a2 ON a1.city != a2.city;


-- 24
SELECT * FROM airports
WHERE timezone IN ( 'Asia/Novokuznetsk', 'Asia/Krasnoyarsk' );
SELECT * FROM airports
WHERE timezone = ANY (
VALUES ( 'Asia/Novokuznetsk' ), ( 'Asia/Krasnoyarsk' )
);

SELECT departure_city, count( * )
    FROM routes
    GROUP BY departure_city
    HAVING departure_city IN (
        SELECT city
        FROM airports
        WHERE longitude > 150
)
ORDER BY count DESC;

SELECT departure_city, count( * )
    FROM routes
    GROUP BY departure_city
    HAVING departure_city = ANY (
        SELECT city
        FROM airports
        WHERE longitude > 150)
ORDER BY count DESC;


-- 25
WITH tickets_seats AS (
    SELECT  f.flight_id,
            f.flight_no,
            f.departure_city,
            f.arrival_city,
            f.aircraft_code,
            count(tf.ticket_no) AS fact_passengers,
            (SELECT count(s.seat_no)
                FROM seats s
                WHERE s.aircraft_code = f.aircraft_code
            ) AS total_seats,
            sea.fare_conditions
    FROM flights_v f
    JOIN seats AS sea ON sea.aircraft_code = f.aircraft_code
    JOIN ticket_flights tf ON f.flight_id = tf.flight_id
    WHERE f.status = 'Arrived'
    GROUP BY 1, 2, 3, 4, 5, 8
)
SELECT  ts.departure_city,
        ts.arrival_city,
        ts.fare_conditions,
        sum(ts.fact_passengers) AS sum_pass,
        sum(ts.total_seats) AS sum_seats,
        round(sum(ts.fact_passengers)::numeric / sum(ts.total_seats)::numeric, 2) AS frac
FROM tickets_seats ts
GROUP BY ts.departure_city, ts.arrival_city, ts.fare_conditions
ORDER BY ts.departure_city
LIMIT 15;


-- 26
SELECT s.seat_no, p.passenger_name, p.email
    FROM seats s
    LEFT OUTER JOIN (
        SELECT t.passenger_name, b.seat_no,
        t.contact_data->'email' AS email
        FROM (
            ticket_flights tf
            JOIN tickets t ON tf.ticket_no = t.ticket_no
        )
        JOIN boarding_passes b
            ON tf.ticket_no = b.ticket_no
            AND tf.flight_id = b.flight_id
        WHERE tf.flight_id = 27584
    ) AS p
ON s.seat_no = p.seat_no
WHERE s.aircraft_code = 'SU9'
ORDER BY
    left( s.seat_no, length( s.seat_no ) - 1 )::integer,
    right( s.seat_no, 1 );

WITH test AS (
    SELECT s.seat_no, p.passenger_name, p.email
    FROM seats s
    LEFT OUTER JOIN (
        SELECT t.passenger_name, b.seat_no,
        t.contact_data->'email' AS email
        FROM (
            ticket_flights tf
            JOIN tickets t ON tf.ticket_no = t.ticket_no
        )
        JOIN boarding_passes b
            ON tf.ticket_no = b.ticket_no
            AND tf.flight_id = b.flight_id
        WHERE tf.flight_id = 27584
    ) AS p
ON s.seat_no = p.seat_no
WHERE s.aircraft_code = 'SU9'
)
SELECT seat_no, passenger_name, email
FROM test
ORDER BY
left(seat_no, length(seat_no ) - 1 )::integer,
right(seat_no, 1 );