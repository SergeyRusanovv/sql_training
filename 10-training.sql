EXPLAIN SELECT *
    FROM aircrafts;

EXPLAIN ( COSTS OFF ) SELECT *
    FROM aircrafts;

EXPLAIN SELECT *
    FROM aircrafts
    WHERE model ~ 'Air';

EXPLAIN SELECT *
        FROM aircrafts
        ORDER BY aircraft_code;

EXPLAIN SELECT *
    FROM bookings
    ORDER BY book_ref;

EXPLAIN SELECT *
FROM bookings
WHERE book_ref > '0000FF' AND book_ref < '000FFF'
ORDER BY book_ref;

EXPLAIN SELECT *
FROM seats
WHERE aircraft_code = 'SU9';

EXPLAIN SELECT book_ref
FROM bookings
WHERE book_ref < '000FFF'
ORDER BY book_ref;

EXPLAIN SELECT count( * )
FROM seats
WHERE aircraft_code = 'SU9';

EXPLAIN SELECT avg( total_amount )
FROM bookings;



EXPLAIN SELECT a.aircraft_code,
a.model,
s.seat_no,
s.fare_conditions
FROM seats s
JOIN aircrafts a ON s.aircraft_code = a.aircraft_code
WHERE a.model ~ '^Аэр'
ORDER BY s.seat_no;

EXPLAIN SELECT  r.flight_no,
                r.departure_airport_name,
                r.arrival_airport_name,
                a.model
FROM routes r
JOIN aircrafts a ON r.aircraft_code = a.aircraft_code
ORDER BY flight_no;

EXPLAIN SELECT  t.ticket_no,
                t.passenger_name,
                tf.flight_id,
                tf.amount
FROM tickets t
JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
ORDER BY t.ticket_no;

EXPLAIN ANALYZE
SELECT  t.ticket_no,
        t.passenger_name,
        tf.flight_id,
        tf.amount
FROM tickets t
JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
WHERE amount > 50000
ORDER BY t.ticket_no;
