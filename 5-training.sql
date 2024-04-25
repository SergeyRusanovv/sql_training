CREATE TABLE students(
    record_book numeric(5) NOT NULL,
    name text NOT NULL,
    doc_ser numeric(4),
    doc_num numeric(6),
    PRIMARY KEY (record_book)
);

CREATE TABLE progress(
    record_book numeric(5) NOT NULL,
    subject text NOT NULL,
    acad_year text NOT NULL,
    term numeric(1) NOT NULL CHECK (term = 1 OR term = 2),
    mark numeric(1) NOT NULL CHECK (mark >= 3 AND mark <= 5)
    DEFAULT 5,
    FOREIGN KEY (record_book)
    REFERENCES students (record_book)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

SET search_path TO bookings; -- установка другой схемы


ALTER TABLE aircrafts ADD COLUMN speed integer;
UPDATE aircrafts SET speed = 807 WHERE aircraft_code = '733';
UPDATE aircrafts SET speed = 851 WHERE aircraft_code = '763';
UPDATE aircrafts SET speed = 905 WHERE aircraft_code = '773';
UPDATE aircrafts SET speed = 840
    WHERE aircraft_code IN ( '319', '320', '321' );
UPDATE aircrafts SET speed = 786 WHERE aircraft_code = 'CR2';
UPDATE aircrafts SET speed = 341 WHERE aircraft_code = 'CN1';
UPDATE aircrafts SET speed = 830 WHERE aircraft_code = 'SU9';

ALTER TABLE aircrafts ALTER COLUMN speed SET NOT NULL;
ALTER TABLE aircrafts ADD CHECK( speed >= 300 );

ALTER TABLE aircrafts ALTER COLUMN speed DROP NOT NULL;
ALTER TABLE aircrafts DROP CONSTRAINT aircrafts_speed_check;

ALTER TABLE aircrafts DROP COLUMN speed;

ALTER TABLE airports
    ALTER COLUMN longitude SET DATA TYPE numeric( 5,2 ),
    ALTER COLUMN latitude SET DATA TYPE numeric( 5,2 );

CREATE TABLE fare_conditions
(
    fare_conditions_code integer,
    fare_conditions_name varchar( 10 ) NOT NULL,
    PRIMARY KEY ( fare_conditions_code )
);


ALTER TABLE seats
    DROP CONSTRAINT seats_fare_conditions_check,
    ALTER COLUMN fare_conditions SET DATA TYPE integer
    USING ( CASE WHEN fare_conditions = 'Economy' THEN 1
                WHEN fare_conditions = 'Business' THEN 2
                ELSE 3
            END
);

ALTER TABLE seats
    RENAME COLUMN fare_conditions TO fare_conditions_code;

-- Создание представлений
CREATE VIEW seats_by_fare_cond AS
    SELECT aircraft_code,fare_conditions_code, count( * )
    FROM seats
    GROUP BY aircraft_code, fare_conditions_code
    ORDER BY aircraft_code, fare_conditions_code;

DROP VIEW seats_by_fare_cond;

CREATE OR REPLACE VIEW seats_by_fare_cond AS
    SELECT aircraft_code,fare_conditions_code, count( * ) AS num_seats
    FROM seats
    GROUP BY aircraft_code, fare_conditions_code
    ORDER BY aircraft_code, fare_conditions_code;

CREATE OR REPLACE VIEW seats_by_fare_cond (code, fare_cond, num_seats) AS
    SELECT aircraft_code,fare_conditions_code, count( * )
    FROM seats
    GROUP BY aircraft_code, fare_conditions_code
    ORDER BY aircraft_code, fare_conditions_code;

DROP VIEW IF EXISTS flights_v;

-- Отличаются тем, что представление будет предзаполнено (если выбрнао WITH DATA)
CREATE MATERIALIZED VIEW [ IF NOT EXISTS ] имя-мат-представления
    [ ( имя-столбца [, ...] ) ]
    AS запрос
    [ WITH [ NO ] DATA ];

--  Обновление представления
REFRESH MATERIALIZED VIEW [ CONCURRENTLY ] name
    [ WITH [ NO ] DATA ]

REFRESH MATERIALIZED VIEW routes;
DROP MATERIALIZED VIEW routes;

-- Посмотреть имена схем
SHOW search_path;

-- Посомтреть текщую схему
SELECT current_schema;


-- 17
CREATE VIEW airports_names AS
SELECT airport_code, airport_name, city
FROM airports;
SELECT * FROM airports_names;

CREATE VIEW siberian_airports AS
SELECT * FROM airports
WHERE city = 'Новосибирск' OR city = 'Кемерово';
SELECT * FROM siberian_airports;


-- 18
ALTER TABLE aircrafts ADD COLUMN specifications jsonb;
UPDATE aircrafts
SET specifications =
'{ "crew": 2, "engines": { "type": "IAE V2500", "num": 2}}'::jsonb
WHERE aircraft_code = '320';

SELECT model, specifications
FROM aircrafts
WHERE aircraft_code = '320';

SELECT model, specifications->'engines' AS engines
FROM aircrafts
WHERE aircraft_code = '320';

SELECT model, specifications #> '{ engines, type }'
FROM aircrafts
WHERE aircraft_code = '320';