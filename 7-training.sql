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