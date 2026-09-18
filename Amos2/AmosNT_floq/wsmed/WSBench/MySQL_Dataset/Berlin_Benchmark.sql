CREATE USER 'regress'@'localhost' IDENTIFIED BY 'regress';

GRANT USAGE ON * . * TO 'regress'@'localhost' IDENTIFIED BY 'regress' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

CREATE DATABASE IF NOT EXISTS `benchmark` ;

GRANT ALL PRIVILEGES ON `benchmark` . * TO 'regress'@'localhost';

use benchmark;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/01ProductFeature.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/02ProductType.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/03Producer.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/04Product.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/05ProductTypeProduct.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/06ProductFeatureProduct.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/07Vendor.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/08Offer.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/09Person.sql;

source C:/udbl/AmosNT/wsmed/WSBench/MySQL_Dataset/10Review.sql;

