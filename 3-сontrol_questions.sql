1. Первичный ключ должен быть уникален, а мы пытаемся записать
в БД строку с первичным ключом, который у нас уже существует.

2. SELECT * FROM aircrafts ORDER BY range DESC


3. UPDATE aircrafts
        SET range = range * 2
        WHERE model = 'Sukhoi SuperJet-100';

    SELECT * FROM aircrafts
        WHERE model = 'Sukhoi SuperJet-100';

4. DELETE FROM aircrafts WHERE model = 'example';
        OR
    DELETE FROM aircrafts WHERE model = 'Boeing 777-300';
    DELETE FROM aircrafts WHERE model = 'Boeing 777-300';

