TRUNCATE historical_toll;

-- LOAD DATA LOCAL INFILE "hist-for-10000-validator.out" INTO TABLE historical_toll FIELDS TERMINATED BY ',';
LOAD DATA LOCAL INFILE "../AmosNT/scsq/lr/data/historical-tolls10-validator.out" INTO TABLE historical_toll FIELDS TERMINATED BY ',';