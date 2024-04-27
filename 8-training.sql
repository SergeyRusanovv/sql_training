CREATE INDEX
    ON airports ( airport_name );

CREATE INDEX passenger_name
    ON tickets ( passenger_name );

CREATE UNIQUE INDEX aircrafts_unique_model_key
    ON aircrafts ( lower( model ) );

INSERT INTO aircrafts
    VALUES ( '123', 'Cessna 208 CARAVAN', 1300);