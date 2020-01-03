
use mysql;
SELECT 'Creating cdc user...' AS ' ';
CREATE USER 'cdc_user'@'localhost' IDENTIFIED BY 'cdc_passwd';
CREATE USER 'cdc_user'@'%' IDENTIFIED BY 'cdc_passwd';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'cdc_user'@'%';
GRANT ALL PRIVILEGES ON securities_master.* TO 'cdc_user'@'%';
ALTER USER 'cdc_user'@'%' IDENTIFIED WITH mysql_native_password BY 'cdc_passwd';
FLUSH PRIVILEGES;

SELECT 'Creating Securities Master...' AS ' ';
CREATE DATABASE if not exists securities_master;

SELECT 'Creating S&P 500 base table...' AS ' ';
use securities_master;
create TABLE if not exists `sp500_stocks` (
  `symbol` varchar(32) NOT NULL,
  `name` varchar(255),
  `sector` varchar(255),
  `sub_industry` varchar(255),
  `hq_location` varchar(255),
  `date_added` varchar(255),
  `date_founded` varchar(255),
  PRIMARY KEY (`symbol`)
);

/* show tables;
 if(@vdate_added, '', NULL, STR_TO_DATE(@vdate_added,'%c/%e/%y')),
*/
SELECT 'Loading S&P 500 base table...' AS ' ';
LOAD DATA INFILE '/scripts/sp500_stocks.csv' INTO TABLE sp500_stocks
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(symbol, name, sector, sub_industry, hq_location, @vdate_added, @vdate_founded)
SET
date_added = nullif(@vdate_added, ''),
date_founded = nullif(@vdate_founded, '')
;

select (select count(*) from sp500_stocks) as 'Rows inserted into S&P 500 table: ';

/*symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient
A,1999-12-23,47.5,50.0,47.44,49.75,33.2918,1544700,0.0,1.0*/
SELECT 'Creating Dow stocks historic table...' AS ' ';
CREATE TABLE if not exists `dow_stocks_historic_daily_price` (
  `symbol` varchar(32) NOT NULL,
  `date` varchar(255) NOT NULL,
  `open_price` decimal(19,2) NULL,
  `high_price` decimal(19,2) NULL,
  `low_price` decimal(19,2) NULL,
  `close_price` decimal(19,2) NULL,
  `adjusted_close_price` decimal(19,2) NULL,
  `volume` bigint NULL,
  `dividend_amount` decimal(19,2) NULL,
  `split_coefficient` decimal(19,2) NULL,
  PRIMARY KEY (`symbol`, `date`)
) DEFAULT CHARSET=utf8;

SELECT 'Loading Dow stocks historic table...' AS ' ';
LOAD DATA INFILE '/scripts/consolidated-dow-stocks-historic-data.csv' INTO TABLE dow_stocks_historic_daily_price
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select (select count(*) from dow_stocks_historic_daily_price) as 'Rows inserted into Dow history table: ';

SELECT 'All DB Updates Completed!' AS ' ';



