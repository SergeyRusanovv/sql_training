CREATE TEMP TABLE aircrafts_tmp AS
SELECT * FROM aircrafts WITH NO DATA;

ALTER TABLE aircrafts_tmp
ADD PRIMARY KEY ( aircraft_code );
ALTER TABLE aircrafts_tmp
ADD UNIQUE ( model );

CREATE TEMP TABLE aircrafts_log AS
SELECT * FROM aircrafts WITH NO DATA;

ALTER TABLE aircrafts_log
ADD COLUMN when_add timestamp;
ALTER TABLE aircrafts_log
ADD COLUMN operation text;

WITH add_row AS
( INSERT INTO aircrafts_tmp
SELECT * FROM aircrafts
RETURNING *
)
INSERT INTO aircrafts_log
    SELECT add_row.aircraft_code, add_row.model, add_row.range,
    current_timestamp, 'INSERT'
    FROM add_row;

WITH add_row AS
( INSERT INTO aircrafts_tmp
    VALUES ( 'SU9', 'Sukhoi SuperJet-100', 3000 )
    ON CONFLICT DO NOTHING
    RETURNING *
)
INSERT INTO aircrafts_log
    SELECT add_row.aircraft_code, add_row.model, add_row.range,
        current_timestamp, 'INSERT'
    FROM add_row;

INSERT INTO aircrafts_tmp
VALUES ( 'SU9', 'Sukhoi SuperJet-100', 3000 )
ON CONFLICT ( aircraft_code ) DO NOTHING
RETURNING *;

INSERT INTO aircrafts_tmp
    VALUES ( 'SU9', 'Sukhoi SuperJet', 3000 )
    ON CONFLICT ON CONSTRAINT aircrafts_tmp_pkey
    DO UPDATE SET model = excluded.model,
    range = excluded.range
    RETURNING *;


WITH update_row AS
( UPDATE aircrafts_tmp
        SET range = range * 1.2
        WHERE model ~ '^Bom'
        RETURNING *
)
INSERT INTO aircrafts_log
    SELECT ur.aircraft_code, ur.model, ur.range,
        current_timestamp, 'UPDATE'
FROM update_row ur;

CREATE TEMP TABLE tickets_directions AS
SELECT DISTINCT departure_city, arrival_city FROM routes;

ALTER TABLE tickets_directions
    ADD COLUMN last_ticket_time timestamp;

ALTER TABLE tickets_directions
    ADD COLUMN tickets_num integer DEFAULT 0;

CREATE TEMP TABLE ticket_flights_tmp AS
    SELECT * FROM ticket_flights WITH NO DATA;

ALTER TABLE ticket_flights_tmp
    ADD PRIMARY KEY ( ticket_no, flight_id );

WITH sell_ticket AS
( INSERT INTO ticket_flights_tmp
    ( ticket_no, flight_id, fare_conditions, amount )
    VALUES ( '1234567890123', 30829, 'Economy', 12800 )
    RETURNING *
)
UPDATE tickets_directions td
    SET last_ticket_time = current_timestamp,
        tickets_num = tickets_num + 1
WHERE ( td.departure_city, td.arrival_city ) =
    ( SELECT departure_city, arrival_city
        FROM flights_v
        WHERE flight_id = ( SELECT flight_id FROM sell_ticket )
);


WITH min_ranges AS
( SELECT aircraft_code,
        rank() OVER (
            PARTITION BY left( model, 6 )
            ORDER BY range
        ) AS rank
    FROM aircrafts_tmp
    WHERE model ~ '^Аэробус' OR model ~ '^Боинг'
)
DELETE FROM aircrafts_tmp a
    USING min_ranges mr
    WHERE a.aircraft_code = mr.aircraft_code
    AND mr.rank = 1
    RETURNING *;

DELETE FROM aircrafts_tmp;
TRUNCATE aircrafts_tmp; -- Удаляет все строки из таблиц