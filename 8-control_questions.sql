-- 2
SELECT count( * )
FROM tickets
WHERE passenger_name = 'IVAN IVANOV';

CREATE INDEX passenger_name ON tickets (passenger_name);

-- 3
CREATE INDEX ON ticket_flights (fare_conditions);

SELECT count( * )
FROM ticket_flights
WHERE fare_conditions = 'Comfort';

SELECT count( * )
FROM ticket_flights
WHERE fare_conditions = 'Business';

-- 8
CREATE INDEX bookings_total_amount_key
ON bookings ( total_amount );

SELECT *
FROM bookings
WHERE total_amount > 1000000
ORDER BY book_date DESC;


-- 9
CREATE INDEX tickets_pass_name
ON tickets ( passenger_name text_pattern_ops );