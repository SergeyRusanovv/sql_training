-- 1
EXPLAIN
    SELECT *
    FROM bookings
    ORDER BY book_ref;

-- 4
EXPLAIN
    SELECT total_amount
    FROM bookings
    ORDER BY total_amount DESC
    LIMIT 5;

-- 5
EXPLAIN
    SELECT city, count( * )
    FROM airports
    GROUP BY city
    HAVING count( * ) > 1;


-- 6
EXPLAIN WITH test AS (SELECT * FROM aircrafts_tmp) SELECT * FROM test;

-- 7
INSERT INTO aircraft_tmp VALUES (520, 'Samolet', 4010);

-- 8
EXPLAIN ANALYZE
SELECT a.aircraft_code AS a_code, a.model,
(   SELECT count( r.aircraft_code )
    FROM routes r
    WHERE r.aircraft_code = a.aircraft_code
    ) AS num_routes
FROM aircrafts a
GROUP BY 1, 2
ORDER BY 3 DESC;


EXPLAIN ANALYZE
SELECT  a.aircraft_code AS a_code, a.model,
        count( r.aircraft_code ) AS num_routes
FROM aircrafts a
    LEFT OUTER JOIN routes r
        ON r.aircraft_code = a.aircraft_code
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 10
EXPLAIN ANALYZE
    SELECT b.book_ref, sum( tf.amount )
    FROM bookings b, tickets t, ticket_flights tf
    WHERE b.book_ref = t.book_ref
        AND t.ticket_no = tf.ticket_no
    GROUP BY 1
    ORDER BY 1;

EXPLAIN ANALYZE
    SELECT book_ref, total_amount
    FROM bookings
    ORDER BY 1;

-- 11
CREATE TEMP TABLE flights_tt AS
SELECT * FROM flights_v;

EXPLAIN ANALYZE
    SELECT * FROM flights_v;
EXPLAIN ANALYZE
    SELECT * FROM flights_tt;

-- 12
EXPLAIN ANALYZE
    SELECT count( * )
        FROM tickets
        WHERE passenger_name = 'IVAN IVANOV';

CREATE INDEX passenger_name_key
    ON tickets ( passenger_name );

-- 13
EXPLAIN ANALYZE
    SELECT num_tickets, count( * ) AS num_bookings
        FROM
        ( SELECT b.book_ref, count( * )
            FROM bookings b, tickets t
            WHERE date_trunc( 'mon', b.book_date ) = '2016-09-01'
            AND t.book_ref = b.book_ref
            GROUP BY b.book_ref
        ) AS count_tickets( book_ref, num_tickets )
GROUP by num_tickets
ORDER BY num_tickets DESC;

-- 14
CREATE TABLE nulls AS
    SELECT num::integer, 'TEXT' || num::text AS txt
        FROM generate_series( 1, 200000 ) AS gen_ser( num );

-- 16
EXPLAIN
    SELECT a.model, count( * )
        FROM aircrafts a, seats s
        WHERE a.aircraft_code = s.aircraft_code
        GROUP BY a.aircraft_code;