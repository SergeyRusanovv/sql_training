-- 1
ALTER TABLE aircrafts_log ADD COLUMN curr_time timestamp;

WITH add_row AS
( INSERT INTO aircrafts_tmp
SELECT * FROM aircrafts
RETURNING *
)
INSERT INTO aircrafts_log
    SELECT add_row.aircraft_code, add_row.model, add_row.range,
    current_timestamp, 'INSERT', current_timestamp
    FROM add_row;

-- 2
WITH add_row AS
( INSERT INTO aircrafts_tmp
    SELECT * FROM aircrafts
    RETURNING aircraft_code, model, range,
    current_timestamp, 'INSERT'
)
INSERT INTO aircrafts_log
SELECT aircraft_code, model, range, current_timestamp, 'INSERT'
FROM add_row;

-- 3
INSERT INTO aircrafts_tmp SELECT * FROM aircrafts RETURNING *;


-- 4
CREATE TEMP TABLE seats_copy AS SELECT * FROM seats WITH NO DATA;

WITH add_row AS (INSERT INTO seats_copy
    SELECT * FROM seats
        LIMIT 5
        OFFSET 7

             ON CONFLICT DO NOTHING
                 RETURNING *)
INSERT INTO seats_copy SELECT * FROM add_row;

-- 5
WITH add_row AS (INSERT INTO seats_copy
    SELECT * FROM seats
        LIMIT 5
        OFFSET 7

             ON CONFLICT aircraft_code DO UPDATE SET aircraft_code = aircraft_code + 1
                 WHERE aircraft_code = 319
                 RETURNING *)
INSERT INTO seats_copy SELECT * FROM add_row;

-- 6
COPY aircrafts_tmp FROM STDIN WITH ( FORMAT csv );\.

-- 7
COPY aircrafts_tmp
FROM '/home/postgres/aircrafts_tmp.csv' WITH ( FORMAT csv );

-- 8
SELECT flight_no, flight_id, departure_city,
        arrival_city, scheduled_departure
FROM flights_v
WHERE scheduled_departure
    BETWEEN bookings.now() AND bookings.now() + INTERVAL '15 days'
        AND ( departure_city, arrival_city ) IN
        ( ( 'Красноярск', 'Москва' ),
            ( 'Москва', 'Сочи'),
            ( 'Сочи', 'Москва' ),
            ( 'Сочи', 'Красноярск' )
        )
ORDER BY departure_city, arrival_city, scheduled_departure;

WITH sell_tickets AS
( INSERT INTO ticket_flights_tmp
    ( ticket_no, flight_id, fare_conditions, amount )
    VALUES  ( '1234567890123', 13829, 'Economy', 10500 ),
            ( '1234567890123', 4728, 'Economy', 3400 ),
            ( '1234567890123', 30523, 'Economy', 3400 ),
            ( '1234567890123', 7757, 'Economy', 3400 ),
            ( '1234567890123', 30829, 'Economy', 12800 )
    RETURNING *
)
UPDATE tickets_directions td
    SET last_ticket_time = current_timestamp,
        tickets_num = tickets_num +
            ( SELECT count( * )
                FROM sell_tickets st, flights_v f
                WHERE st.flight_id = f.flight_id
                    AND f.departure_city = td.departure_city
                    AND f.arrival_city = td.arrival_city
            )
WHERE ( td.departure_city, td.arrival_city ) IN
    ( SELECT departure_city, arrival_city
        FROM flights_v
        WHERE flight_id IN ( SELECT flight_id FROM sell_tickets )
);

-- 9
DELETE FROM aircrafts_tmp
WHERE (model LIKE 'Boeing%' OR model LIKE 'Airbus%')
AND aircraft_code IN (
    SELECT aircraft_code
    FROM (
        SELECT aircraft_code, model,
               ROW_NUMBER() OVER (PARTITION BY LEFT(model, STRPOS(model, ' ') - 1) ORDER BY seats_num) AS row_num
        FROM (
            SELECT a.aircraft_code, a.model, COUNT(*) AS seats_num
            FROM aircrafts_tmp a
            JOIN seats s ON a.aircraft_code = s.aircraft_code
            GROUP BY a.aircraft_code, a.model
        ) AS seat_counts
    ) AS ranked_models
    WHERE row_num = 1
)
RETURNING *;

-- 10
INSERT INTO seats ( aircraft_code, seat_no, fare_conditions )
    SELECT aircraft_code, seat_row || letter, fare_condition
        FROM
        ( VALUES    ( 'SU9', 3, 20, 'F' ),
                    ( '773', 5, 30, 'I' ),
                    ( '763', 4, 25, 'H' ),
                    ( '733', 3, 20, 'F' ),
                    ( '320', 5, 25, 'F' ),
                    ( '321', 4, 20, 'F' ),
                    ( '319', 3, 20, 'F' ),
                    ( 'CN1', 0, 10, 'B' ),
                    ( 'CR2', 2, 15, 'D' )
        ) AS aircraft_info ( aircraft_code, max_seat_row_business,
                            max_seat_row_economy, max_letter )
        CROSS JOIN
            ( VALUES ( 'Business' ), ( 'Economy' )
            ) AS fare_conditions (fare_condition )
        CROSS JOIN
        ( VALUES ( '1' ), ( '2' ), ( '3' ), ( '4' ), ( '5' ),
                ( '6' ), ( '7' ), ( '8' ), ( '9' ), ( '10' ),
                ( '11' ), ( '12' ), ( '13' ), ( '14' ), ( '15' ),
                ( '16' ), ( '17' ), ( '18' ), ( '19' ), ( '20' ),
                ( '21' ), ( '22' ), ( '23' ), ( '24' ), ( '25' ),
                ( '26' ), ( '27' ), ( '28' ), ( '29' ), ( '30' )
        ) AS seat_rows ( seat_row )
        CROSS JOIN
        ( VALUES    ( 'A' ), ( 'B' ), ( 'C' ), ( 'D' ), ( 'E' ),
                    ( 'F' ), ( 'G' ), ( 'H' ), ( 'I' )
        ) AS letters ( letter )
        WHERE
        CASE WHEN fare_condition = 'Business'
            THEN seat_row::integer <= max_seat_row_business
            WHEN fare_condition = 'Economy'
            THEN seat_row::integer > max_seat_row_business
                AND seat_row::integer <= max_seat_row_economy
        END
        AND letter <= max_letter;


INSERT INTO seats ( aircraft_code, seat_no, fare_conditions )
    SELECT aircraft_code, seat_row || letter, fare_condition
        FROM
        ( VALUES    ( 'SU9', 3, 20, 'F' ),
                    ( '773', 5, 30, 'I' ),
                    ( '763', 4, 25, 'H' ),
                    ( '733', 3, 20, 'F' ),
                    ( '320', 5, 25, 'F' ),
                    ( '321', 4, 20, 'F' ),
                    ( '319', 3, 20, 'F' ),
                    ( 'CN1', 0, 10, 'B' ),
                    ( 'CR2', 2, 15, 'D' )
        ) AS aircraft_info ( aircraft_code, max_seat_row_business,
                            max_seat_row_economy, max_letter )
        CROSS JOIN
            ( VALUES ( 'Business' ), ( 'Economy' )
            ) AS fare_conditions (fare_condition )
        CROSS JOIN
        ( VALUES generate_series(1, 30)
        ) AS seat_rows ( seat_row )
        CROSS JOIN
        ( VALUES    ( 'A' ), ( 'B' ), ( 'C' ), ( 'D' ), ( 'E' ),
                    ( 'F' ), ( 'G' ), ( 'H' ), ( 'I' )
        ) AS letters ( letter )
        WHERE
        CASE WHEN fare_condition = 'Business'
            THEN seat_row::integer <= max_seat_row_business
            WHEN fare_condition = 'Economy'
            THEN seat_row::integer > max_seat_row_business
                AND seat_row::integer <= max_seat_row_economy
        END
        AND letter <= max_letter;