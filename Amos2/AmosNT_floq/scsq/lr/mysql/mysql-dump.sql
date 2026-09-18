-- MySQL dump 10.13  Distrib 5.1.34, for pc-linux-gnu (i686)
--
-- Host: localhost    Database: lr
-- ------------------------------------------------------
-- Server version	5.1.34

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accident_remove_order`
--

DROP TABLE IF EXISTS `accident_remove_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accident_remove_order` (
  `xway` tinyint(4) NOT NULL,
  `min` smallint(6) NOT NULL,
  PRIMARY KEY (`xway`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accidents`
--

DROP TABLE IF EXISTS `accidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accidents` (
  `xway` tinyint(4) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `direction` tinyint(1) NOT NULL,
  `time` smallint(6) NOT NULL,
  `min` smallint(6) NOT NULL,
  PRIMARY KEY (`xway`,`segment`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collided_cars`
--

DROP TABLE IF EXISTS `collided_cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collided_cars` (
  `vid` int(11) NOT NULL,
  `nr_stopped` int(11) NOT NULL,
  PRIMARY KEY (`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='temporary table for storing collided cars in accident_check';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collided_cars_temp`
--

DROP TABLE IF EXISTS `collided_cars_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collided_cars_temp` (
  `vid` int(11) NOT NULL,
  `index` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`vid`,`index`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='temporary table for calculating collided_cars content';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `historical_toll`
--

DROP TABLE IF EXISTS `historical_toll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `historical_toll` (
  `vid` int(10) unsigned NOT NULL,
  `day` tinyint(3) unsigned NOT NULL,
  `xway` tinyint(3) unsigned NOT NULL,
  `toll` decimal(9,1) unsigned NOT NULL,
  PRIMARY KEY (`vid`,`day`,`xway`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=1 COMMENT='historical toll data input';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `min_test`
--

DROP TABLE IF EXISTS `min_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `min_test` (
  `old` int(11) NOT NULL,
  `new` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `output_accident_alert`
--

DROP TABLE IF EXISTS `output_accident_alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `output_accident_alert` (
  `time` smallint(6) NOT NULL,
  `emit_time` smallint(6) NOT NULL,
  `vid` int(11) NOT NULL,
  `segment` tinyint(4) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='output: accident alert';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `output_account_balance`
--

DROP TABLE IF EXISTS `output_account_balance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `output_account_balance` (
  `time` smallint(6) NOT NULL,
  `emit_time` smallint(6) NOT NULL,
  `quid` int(11) NOT NULL,
  `lasttime` smallint(6) NOT NULL,
  `balance` decimal(9,1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='output: account balance';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `output_daily_exp`
--

DROP TABLE IF EXISTS `output_daily_exp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `output_daily_exp` (
  `time` smallint(5) unsigned NOT NULL,
  `emit_time` smallint(5) unsigned NOT NULL,
  `quid` int(10) unsigned NOT NULL,
  `expenditure` decimal(9,1) unsigned NOT NULL,
  PRIMARY KEY (`time`,`quid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='output: daily expenditure';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `output_toll_alert`
--

DROP TABLE IF EXISTS `output_toll_alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `output_toll_alert` (
  `time` smallint(6) NOT NULL,
  `emit_time` smallint(6) NOT NULL,
  `vavg` tinyint(4) NOT NULL,
  `toll` int(11) NOT NULL,
  `vid` int(11) NOT NULL,
  PRIMARY KEY (`time`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='output: toll alert';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `print_accidents`
--

DROP TABLE IF EXISTS `print_accidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `print_accidents` (
  `xway` int(11) NOT NULL,
  `segment` int(11) NOT NULL,
  `direction` int(11) NOT NULL,
  `vid` int(11) NOT NULL,
  `time` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sim_time`
--

DROP TABLE IF EXISTS `sim_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sim_time` (
  `sim_minute` tinyint(3) unsigned NOT NULL,
  `sim_second` smallint(6) NOT NULL,
  KEY `new_index` (`sim_minute`),
  KEY `new_index2` (`sim_second`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `smashed_cars`
--

DROP TABLE IF EXISTS `smashed_cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smashed_cars` (
  `vid` int(11) NOT NULL,
  `pos` mediumint(9) DEFAULT NULL,
  `xway` tinyint(4) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `direction` tinyint(1) NOT NULL,
  `lane` tinyint(4) NOT NULL,
  PRIMARY KEY (`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min1`
--

DROP TABLE IF EXISTS `stat_min1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min1` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min2`
--

DROP TABLE IF EXISTS `stat_min2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min2` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min3`
--

DROP TABLE IF EXISTS `stat_min3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min3` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min4`
--

DROP TABLE IF EXISTS `stat_min4`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min4` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min5`
--

DROP TABLE IF EXISTS `stat_min5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min5` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_min6`
--

DROP TABLE IF EXISTS `stat_min6`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_min6` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `vid` int(11) NOT NULL COMMENT 'vehicle id',
  `lav` double NOT NULL DEFAULT '0' COMMENT 'speed of car',
  `number` int(11) NOT NULL DEFAULT '0' COMMENT 'number of cars in segment',
  PRIMARY KEY (`xway`,`dir`,`segment`,`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_lav_cached`
--

DROP TABLE IF EXISTS `stat_lav_cached`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_lav_cached` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `avgv` tinyint(4) NOT NULL,
  PRIMARY KEY (`xway`,`dir`,`segment`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stat_nov`
--

DROP TABLE IF EXISTS `stat_nov_cached`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_nov_cached` (
  `xway` tinyint(4) NOT NULL,
  `dir` tinyint(1) NOT NULL,
  `segment` tinyint(4) NOT NULL,
  `nov` int(11) NOT NULL,
  PRIMARY KEY (`xway`,`dir`,`segment`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='segment statistic of nov table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stopped_cars`
--

DROP TABLE IF EXISTS `stopped_cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stopped_cars` (
  `time` smallint(6) NOT NULL,
  `vid` int(11) NOT NULL,
  `pos` mediumint(9) NOT NULL,
  `xway` tinyint(4) NOT NULL,
  `direction` tinyint(1) NOT NULL,
  `lane` tinyint(4) NOT NULL,
  PRIMARY KEY (`time`,`vid`),
  KEY `new_index` (`pos`,`xway`,`direction`,`lane`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `toll_debug`
--

DROP TABLE IF EXISTS `toll_debug`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `toll_debug` (
  `sec` int(11) DEFAULT NULL,
  `num_cars` int(11) DEFAULT NULL,
  `avgv` int(11) DEFAULT NULL,
  `vid` int(11) DEFAULT NULL,
  `toll` int(11) DEFAULT NULL
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_info`
--

DROP TABLE IF EXISTS `vehicle_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_info` (
  `vid` int(11) NOT NULL,
  `xway` tinyint(3) unsigned NOT NULL,
  `segment` tinyint(3) unsigned NOT NULL,
  `direction` tinyint(1) NOT NULL,
  `pos` mediumint(8) unsigned NOT NULL,
  `balance` decimal(9,1) unsigned NOT NULL,
  `lastupdate` smallint(6) NOT NULL,
  `vav` tinyint(4) NOT NULL,
  `nextexp` decimal(9,1) unsigned NOT NULL,
  PRIMARY KEY (`vid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='info about every car';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-10-12 14:33:54
