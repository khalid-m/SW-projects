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
) ENGINE=MEMORY DEFAULT CHARSET=latin1 COMMENT='output: daily expenditure';
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `sim_time`
--

DROP TABLE IF EXISTS `sim_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sim_time` (
  `Now` TIME  NOT NULL,
  KEY `new_index` (`Now`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='tIME sIM';
/*!40101 SET character_set_client = @saved_cs_client */;




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
