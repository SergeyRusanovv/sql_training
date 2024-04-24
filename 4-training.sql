CREATE TABLE databases ( is_open_source boolean, dbms_name text );
INSERT INTO databases
    VALUES (TRUE, 'PostgreSQL');
INSERT INTO databases
    VALUES (FALSE, 'Oracle');
INSERT INTO databases
    VALUES (TRUE, 'MySQL');
INSERT INTO databases
    VALUES (FALSE, 'MS SQL Server');


CREATE TABLE pilots (
    pilot_name text,
    schedule integer[]
);


INSERT INTO pilots
    VALUES ('Ivan', '{ 1, 3, 5, 6, 7 }'::integer[]),
            ('Petr', '{ 1, 2, 5, 7}'::integer[]),
            ('Pavel', '{ 2, 5}'::integer[]),
            ('Boris', '{ 3, 5, 6}'::integer[]);


-- Добавление элемента в конец массива
UPDATE pilots
    SET schedule = schedule || 7
    WHERE pilot_name = 'Boris';


UPDATE pilots
SET schedule = array_append(schedule, 6)
WHERE pilot_name = 'Pavel';


-- Добавление элемента в конец массива
UPDATE pilots
    SET schedule = array_prepend(1, schedule)
    WHERE pilot_name = 'Pavel';


-- Добавление элемента в начало массива. 5 - значение а не индекс
UPDATE pilots
    SET schedule = array_remove(schedule, 5)
    WHERE pilot_name = 'Ivan';


-- Изменение по индексам. Первому элементу соответствует индекс 1!!!!
UPDATE pilots
    SET schedule[1] = 2, schedule[2] = 3
    WHERE pilot_name = 'Petr';


-- Запись, эквивалентная выше. Используются slices
UPDATE pilots
    SET schedule[1:2] = ARRAY[2, 3]
    WHERE pilot_name = 'Petr';


-- Если в массиве есть значение 3
SELECT * FROM pilots
        WHERE array_position(schedule, 3) IS NOT NULL;


-- @> - говорит о том что элементы правого массива содержаться в левом массиве
SELECT * FROM pilots
    WHERE schedule @> '{1, 7}'::integer[];


-- Оператор && смотрит наличие общих элементов у массивов (здесь от 1 до 2 вхождений)
SELECT * FROM pilots
    WHERE schedule && ARRAY[ 2, 5 ];


-- Запись, противоположная вышенаписанной
SELECT * FROM pilots
    WHERE NOT (schedule && ARRAY[2, 5]);


CREATE TABLE pilot_hobbies
(
    pilot_name text,
    hobbies jsonb
);



-- Вставка данных с типом jsonb
INSERT INTO pilot_hobbies
VALUES (
    'Ivan', '{"sports": ["футбол", "плавание"], "home_lib": true, "trips": }'::jsonb),
    ('Petr', '{"sports": [ "теннис", "плавание"], "home_lib": true, "trips": 2}'::jsonb),
    ('Pavel', '{"sports": [ "плавание"], "home_lib": false, "trips": 4}'::jsonb),
    ('Boris', '{"sports": ["футбол", "плавание", "теннис"], "home_lib": true, "trips": 0}'::jsonb
);


-- Выбрать тех у кого в спорте есть значение футбол. -> для обращения к конкретному ключу json обьекта
SELECT * FROM pilot_hobbies
WHERE hobbies @> '{"sports": ["футбол"]}'::jsonb;
        OR
SELECT pilot_name, hobbies->'sports' AS sports
FROM pilot_hobbies
WHERE hobbies->'sports' @> '["футбол"]'::jsonb;



SELECT count( * )
FROM pilot_hobbies
WHERE hobbies ? 'sports';


-- Обновление данных
UPDATE pilot_hobbies
SET hobbies = hobbies || '{ "sports": [ "хоккей" ] }'
WHERE pilot_name = 'Boris';


-- В функции jsonb_set sports - это ключ, а 1 - индекс куда вставляется обьект (нумерация с 0), футбол - то что вставляемcontrol.sql
UPDATE pilot_hobbies
SET hobbies = jsonb_set( hobbies, '{ sports, 1 }', '"футбол"' )
WHERE pilot_name = 'Boris';