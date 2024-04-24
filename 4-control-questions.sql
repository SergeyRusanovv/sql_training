-- 1
CREATE TABLE test_numeric (
    measurement numeric(5, 2),
    description text
);

-- ERROR:  numeric field overflow
-- DETAIL:  A field with precision 5, scale 2 must round to an absolute value less than 10^3.
-- Эта команда выдает ошибку переполнения числового поля, поле с заданной точностью и масштабом должны быть округлены до значения меньше 10^3
INSERT INTO test_numeric
    VALUES ( 999.9999, 'Какое-то измерение');
-- Округлит до 999.90
INSERT INTO test_numeric
    VALUES ( 999.9009, 'Еще одно измерение');
-- Округлит до 999.11
INSERT INTO test_numeric
    VALUES ( 999.1111, 'И еще измерение');
-- Округлит до 999.00
INSERT INTO test_numeric
    VALUES ( 998.9999, 'И еще одно');

-- 2
CREATE TABLE test_numeric
(
    measurement numeric,
    description text
);

-- Все ниже написанные команды сохранили число в БД в неизменном виде
INSERT INTO test_numeric
VALUES (
    1234567890.0987654321,
    'Точность 20 знаков, масштаб 10 знаков'
);

INSERT INTO test_numeric
VALUES (
    1.5,
    'Точность 2 знака, масштаб 1 знак'
);

INSERT INTO test_numeric
VALUES (
    0.12345678901234567890,
    'Точность 21 знак, масштаб 20 знаков'
);
INSERT INTO test_numeric
VALUES (
    1234567890,
    'Точность 10 знаков, масштаб 0 знаков (целое число)'
);


-- 3
-- True. NaN - not a number(не число)
SELECT 'NaN'::numeric > 10000;


-- 4
-- False
SELECT '5e-324'::double precision > '4e-324'::double precision;

-- 4.94065645841247e-324
SELECT '5e-324'::double precision;

-- 4.94065645841247e-324
SELECT '4e-324'::double precision;


-- 5
-- True
SELECT 'Inf'::double precision > 1E+308;

-- False
SELECT 'Inf'::double precision > 1E-307;


-- 6
-- NaN
SELECT 0.0 * 'Inf'::real;

-- True
SELECT 'NaN'::real > 'Inf'::real;


-- 7
CREATE TABLE test_serial
(
    id serial,
    name text
);

INSERT INTO test_serial (name) VALUES ('Вишневая');
INSERT INTO test_serial (name) VALUES ('Грушевая');
INSERT INTO test_serial (name) VALUES ('Зеленая');
INSERT INTO test_serial ( id, name ) VALUES (10, 'Прохладная');
INSERT INTO test_serial ( name ) VALUES ('Луговая');


-- 8
CREATE TABLE test_serial
(
    id serial PRIMARY KEY,
    name text
);
INSERT INTO test_serial ( name ) VALUES ('Вишневая');
INSERT INTO test_serial ( id, name ) VALUES (2, 'Прохладная');
INSERT INTO test_serial ( name ) VALUES ('Грушевая');
INSERT INTO test_serial ( name ) VALUES ('Зеленая');
DELETE FROM test_serial WHERE id = 4;
INSERT INTO test_serial (name) VALUES ('Луговая');


-- 11
SELECT current_time;
SELECT current_time::time(0);
SELECT current_time::time(3);

SELECT current_timestamp;
SELECT current_timestamp::timestamp(0);
SELECT current_timestamp::timestamp(3);

SELECT interval '1 day'::intarval;
SELECT interval '1 day'::intarval(0);
SELECT interval '1 day'::intarval(3);


-- 12
SELECT '24-04-2024'::date;
SET datestyle TO 'MDY';
SET datestyle TO DEFAULT;
SELECT '24-04-2024'::timestamp;

-- 13
-- Для изменения форматы даты
PGDATESTYLE="Postgres" psql -d "название БД" -U имя-пользователя

-- 14
-- Для перезапуска серва PostgreSQL
sudo systemctl restart postgresql

-- 15
-- Приведение даты и времени к тексту
SELECT to_char(current_timestamp, 'mi:ss');
SELECT to_char(current_timestamp, 'dd');

-- 18
-- Получим тип interval(промежуток или интервал)
SELECT ('2016-09-16'::date - '2016-09-01'::date);


-- 19
--  479 days 12:29:28.358988
SELECT (current_timestamp - '2023-01-01'::timestamp)
AS new_date;


-- 20
-- Прибавляем один месяц к текущей дате
SELECT (current_timestamp + '1 mon'::interval) AS new_date;

-- 21
-- 2024-02-29 00:00:00
SELECT ( '2024-01-31'::date + '1 mon'::interval ) AS new_date;
-- 2024-03-29 00:00:00
SELECT ( '2024-02-29'::date + '1 mon'::interval ) AS new_date;


-- 22
SHOW intervalstyle - для показа
SET intervalstyle *
-- sql_standard, postgres, postgres_verbose, iso_8601


-- 23
SELECT ( '2016-09-16'::date - '2015-09-01'::date );
SELECT ( '2016-09-16'::timestamp - '2015-09-01'::timestamp );
-- На выхоже получаем 381 и 381 days соответсвенно. Такой результат из-за разного форматиования вывода


-- 24
SELECT ( '20:34:35'::time - interval '1 second' );
SELECT ( '2016-09-16'::date - 1 );


-- 25
-- Более мелкие частицы отбрасываются
SELECT (date_trunc('sec', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('microsecond', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('millisecond', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('min', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('mon', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('dec', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('cent', timestamp '1999-11-27 12:34:56.987654'));
SELECT (date_trunc('mil', timestamp '1999-11-27 12:34:56.987654'));

-- 26
SELECT date_trunc('hour', timestamp '2024-02-16 20:38:40');
SELECT date_trunc('day', timestamp '2001-02-16 20:38:40');
SELECT date_trunc('hour', interval '3 days 02:47:33');


-- 27
-- Извлечение минут, месяцев и т.д из даты
SELECT extract('min' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('microsecond' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('sec' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('millisecond' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('min' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('mon' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('dec' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('cent' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('mil' from timestamp '2024-11-27 12:34:56.123124');
SELECT extract('week' from timestamp '2024-11-27 12:34:56.123124');


-- 28
SELECT extract('hour' from interval '10 days 12:47:31');
SELECT extract('sec' from interval '10 days 12:47:31');


-- 29
-- Все записи одинаковы за исключением последней.
SELECT * FROM databases WHERE NOT is_open_source;
SELECT * FROM databases WHERE is_open_source <> 'yes';
SELECT * FROM databases WHERE is_open_source <> 't';
SELECT * FROM databases WHERE is_open_source <> '1';
SELECT * FROM databases WHERE is_open_source <> 1;


-- 30
CREATE TABLE test_bool
(
    a boolean,
    b text
);

INSERT INTO test_bool VALUES (TRUE, 'yes');
INSERT INTO test_bool VALUES (yes, 'yes'); ---
INSERT INTO test_bool VALUES ('yes', true);
INSERT INTO test_bool VALUES ('yes', TRUE);
INSERT INTO test_bool VALUES ('1', 'true');
INSERT INTO test_bool VALUES (1, 'true'); ---
INSERT INTO test_bool VALUES ('t', 'true');
INSERT INTO test_bool VALUES ('t', truth); ---
INSERT INTO test_bool VALUES (true, true);
INSERT INTO test_bool VALUES (1::boolean, 'true');
INSERT INTO test_bool VALUES (111::boolean, 'true');


-- 31
CREATE TABLE birthdays
(
    person   text NOT NULL,
    birthday date NOT NULL
);
INSERT INTO birthdays VALUES ('Ken Thompson', '1955-03-23');
INSERT INTO birthdays VALUES ('Ben Johnson', '1971-03-19');
INSERT INTO birthdays VALUES ('Andy Gibson', '1987-08-12');

SELECT * FROM birthdays
WHERE extract('mon' from birthday) = 3;

-- кому больше 40 лет на данный момент
SELECT *, birthday + '40 years'::interval
FROM birthdays
WHERE birthday + '40 years'::interval < current_timestamp;

SELECT *, age(birthday) from birthdays;


-- 32
SELECT array_cat(ARRAY[ 1, 2, 3 ], ARRAY[ 3, 5 ]);
SELECT array_remove(ARRAY[ 1, 2, 3 ], 3);


-- 33
CREATE TABLE pilots
(
    pilot_name text,
    schedule integer[],
    meal text[]
);

INSERT INTO pilots
    VALUES ('Ivan', '{1, 3, 5, 6, 7}'::integer[], '{"сосиска", "макароны", "кофе"}'::text[]),
    ('Petr', '{1, 2, 5, 7}'::integer [], '{"котлета", "каша", "кофе"}'::text[]),
    ('Pavel', '{2, 5}'::integer[], '{"сосиска", "каша", "кофе"}'::text[]),
    ('Boris', '{3, 5, 6}'::integer[], '{"котлета", "каша", "чай"}'::text[]);

SELECT * FROM pilots WHERE meal[1] = 'сосиска';

CREATE TABLE pilots (pilot_name text, schedule integer[], meal text[][]);

INSERT INTO pilots
VALUES (
        'Ivan', '{ 1, 3, 5, 6, 7 }'::integer[],'{{"сосиска", "макароны", "кофе"}}'::text[][]),
        ('Petr', '{ 1, 2, 5, 7 }'::integer [], '{{"котлета", "каша", "кофе"}}'::text[][]),
        ('Pavel', '{ 2, 5 }'::integer[], '{{"сосиска", "каша", "кофе"}}'::text[][]),
        ('Boris', '{ 3, 5, 6 }'::integer[], '{{"котлета", "каша", "чай"}}'::text[][]);


-- 34
UPDATE pilot_hobbies
SET hobbies = jsonb_set(hobbies, '{trips}', '10')
WHERE pilot_name = 'Pavel';

UPDATE pilot_hobbies
SET hobbies = jsonb_set( hobbies, '{ home_lib }', 'false' )
WHERE pilot_name = 'Boris';


-- 35
SELECT '{ "sports": "хоккей" }'::jsonb || '{ "trips": 5 }'::jsonb;


-- 36
UPDATE pilot_hobbies
SET hobbies = hobbies || '{"test": 75}'::jsonb WHERE pilot_name = 'Petr';


-- 37
UPDATE pilot_hobbies
SET hobbies = hobbies #- '{test}' WHERE pilot_name = 'Petr';

