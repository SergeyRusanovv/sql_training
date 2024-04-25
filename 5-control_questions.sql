-- 1
CREATE TABLE students
(
    record_book numeric( 5 ) NOT NULL,
    name text NOT NULL,
    doc_ser numeric( 4 ),
    doc_num numeric( 6 ),
    who_adds_row text DEFAULT current_user, -- добавление текущего пользователя автоматически при команде INSERT
    PRIMARY KEY ( record_book )
);

INSERT INTO students ( record_book, name, doc_ser, doc_num )
VALUES ( 12300, 'Иванов Иван Иванович', 0402, 543281 );

-- Добавление столбца в котором автоматически добавляется текущее время при добавление новой записи
ALTER TABLE students ADD COLUMN added_time time DEFAULT current_time;


-- 2
ALTER TABLE progress ADD COLUMN test_form char;

ALTER TABLE progress
ADD CHECK (
    ( test_form = 'экзамен' AND mark IN ( 3, 4, 5 ) )
    OR
    ( test_form = 'зачет' AND mark IN ( 0, 1 ) )
);

INSERT INTO progress (record_book, subject, acad_year, term, mark, test_form)
VALUES (12300, 'sdffs', 'ethe', 1, 0, 'зачет');

ALTER TABLE progress DROP CONSTRAINT progress_mark_check;


-- 3
ALTER TABLE progress ALTER COLUMN term DROP NOT NULL;
ALTER TABLE progress ALTER COLUMN mark DROP NOT NULL;


-- 4
INSERT INTO progress ( record_book, subject, acad_year, term )
VALUES ( 12300, 'Физика', '2016/2017',1 );


-- 5
ALTER TABLE students ADD CONSTRAINT uniq_doc_ser UNIQUE (doc_ser);
ALTER TABLE students ADD CONSTRAINT uniq_doc_num UNIQUE (doc_num);
INSERT INTO students VALUES (1230, 'HDJHDK', 400, null);
INSERT INTO students VALUES (12306, 'HDJHDK', null, null);


-- 6
CREATE TABLE students
(
    record_book numeric( 5 ) NOT NULL UNIQUE,
    name text NOT NULL,
    doc_ser numeric( 4 ),
    doc_num numeric( 6 ),
    PRIMARY KEY ( doc_ser, doc_num )
);

CREATE TABLE progress
(
    doc_ser numeric( 4 ),
    doc_num numeric( 6 ),
    subject text NOT NULL,
    acad_year text NOT NULL,
    term numeric( 1 ) NOT NULL CHECK ( term = 1 OR term = 2 ),
    mark numeric( 1 ) NOT NULL CHECK ( mark >= 3 AND mark <= 5 )
    DEFAULT 5,
    FOREIGN KEY ( doc_ser, doc_num )
        REFERENCES students ( doc_ser, doc_num )
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- 8
ALTER TABLE progress
    ALTER COLUMN subject
        SET DATA TYPE integer
        USING subject::integer;

ALTER TABLE progress ADD COLUMN subject_id integer;
ALTER TABLE progress ADD FOREIGN KEY (subject_id) REFERENCES subject (subject_id);
INSERT INTO progress (doc_ser, doc_num, acad_year, term, mark, subject_id) VALUES (1234, 56789, 2020/2021, 1, 4, 1);


-- 9
ALTER TABLE students ADD CHECK (name != '');
-- ПРоверка что у меня есть обезатльно один непробельный символ (trim удаляет пробелы)
ALTER TABLE students ADD CHECK (length(trim(name)) > 0);


-- 10
ALTER TABLE progress DROP CONSTRAINT progress_doc_ser_doc_num_fkey;
ALTER TABLE students ALTER COLUMN doc_ser SET DATA TYPE char(4), ALTER COLUMN doc_num SET DATA TYPE char(5);
ALTER TABLE students ADD CONSTRAINT progress_doc_ser_doc_num_fkey
    FOREIGN KEY (doc_ser, doc_num)
        REFERENCES students(doc_ser, doc_num)
        ON UPDATE CASCADE ON DELETE CASCADE;


-- 12
ALTER TABLE airports RENAME TO test_rename;


-- 13
DROP TABLE airports;


-- 14
CREATE VIEW subj AS SELECT * FROM subject;
INSERT INTO subj (subject) VALUES ('Информатика');


