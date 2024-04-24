-- -------------------- --
-- Bulk Insert from csv --
-- -------------------- --

LOAD DATA INFILE "D:\\Skole\\H2\\Database Prog\\postnumre.csv"
INTO TABLE br_city
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(city_postal_code,city_name);