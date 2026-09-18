-- phpMyAdmin SQL Dump
-- version 2.11.5
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Oct 06, 2008 at 05:42 PM
-- Server version: 5.0.51
-- PHP Version: 5.2.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `example`
--

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `ad_num` int(5) NOT NULL auto_increment,
  `address` varchar(200) NOT NULL,
  PRIMARY KEY  (`ad_num`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`ad_num`, `address`) VALUES
(1, 'Adres1'),
(2, 'Adres2'),
(3, 'Addr3'),
(4, 'Addr4'),
(5, 'ad5'),
(6, 'ad6');

-- --------------------------------------------------------

--
-- Table structure for table `authors`
--

CREATE TABLE `authors` (
  `AUTHOR_ID` int(11) NOT NULL,
  `name` varchar(50) NOT NULL default '',
  `SURNAME` varchar(50) NOT NULL default '',
  `nationality` varchar(10) NOT NULL,
  `adres` int(5) NOT NULL,
  PRIMARY KEY  (`AUTHOR_ID`,`SURNAME`),
  KEY `aafk` (`adres`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `authors`
--

INSERT INTO `authors` (`AUTHOR_ID`, `name`, `SURNAME`, `nationality`, `adres`) VALUES
(1, 'GREG', 'BARISH', '', 1),
(2, 'TIMOTHY', 'BUDD', '', 2),
(3, 'Yogesh', 'Simmhan', 'IN', 3),
(5, 'Beth', 'Palle', 'En', 4),
(12, 'Dennis', 'Gannon', 'EN', 5);

-- --------------------------------------------------------

--
-- Table structure for table `bookbyauthor`
--

CREATE TABLE `bookbyauthor` (
  `aid` int(5) NOT NULL,
  `familyn` varchar(50) NOT NULL default '',
  `book` int(5) NOT NULL,
  UNIQUE KEY `aid` (`aid`,`familyn`,`book`),
  KEY `aid_2` (`aid`,`familyn`),
  KEY `book_fk` (`book`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `bookbyauthor`
--

INSERT INTO `bookbyauthor` (`aid`, `familyn`, `book`) VALUES
(1, 'BARISH', 1),
(2, 'BUDD', 1),
(3, 'Simmhan', 2),
(5, 'Palle', 2),
(12, 'Gannon', 2);

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE `books` (
  `bookid` int(5) NOT NULL auto_increment,
  `name` varchar(150) NOT NULL default '',
  PRIMARY KEY  (`bookid`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `books`
--

INSERT INTO `books` (`bookid`, `name`) VALUES
(1, 'Databasteknik'),
(2, 'Data Mining');

-- --------------------------------------------------------

--
-- Table structure for table `relatedservices`
--

CREATE TABLE `relatedservices` (
  `EID` varchar(25) NOT NULL,
  `SERVICENR` int(11) NOT NULL,
  `efternamn` varchar(30) NOT NULL,
  `NAME` varchar(50) default NULL,
  PRIMARY KEY  (`EID`),
  KEY `fkra` (`SERVICENR`,`efternamn`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `relatedservices`
--

INSERT INTO `relatedservices` (`EID`, `SERVICENR`, `efternamn`, `NAME`) VALUES
('ABC1234H', 1, 'Barish', 'Issuing a birth certificate'),
('ABC1234I', 2, 'Budd', 'null'),
('edw6r8', 12, 'Gannon', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `salary`
--

CREATE TABLE `salary` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `salary` float NOT NULL,
  PRIMARY KEY  (`salary`),
  KEY `id` (`id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `salary`
--

INSERT INTO `salary` (`id`, `name`, `salary`) VALUES
(1, 'Barish', 2.5),
(2, 'Budd', 2.75),
(12, 'Gannon', 300);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `authors`
--
ALTER TABLE `authors`
  ADD CONSTRAINT `aafk` FOREIGN KEY (`adres`) REFERENCES `address` (`ad_num`);

--
-- Constraints for table `bookbyauthor`
--
ALTER TABLE `bookbyauthor`
  ADD CONSTRAINT `auth_fk` FOREIGN KEY (`aid`, `familyn`) REFERENCES `authors` (`AUTHOR_ID`, `SURNAME`),
  ADD CONSTRAINT `book_fk` FOREIGN KEY (`book`) REFERENCES `books` (`bookid`);

--
-- Constraints for table `relatedservices`
--
ALTER TABLE `relatedservices`
  ADD CONSTRAINT `fkra` FOREIGN KEY (`SERVICENR`) REFERENCES `authors` (`AUTHOR_ID`),
  ADD CONSTRAINT `relatedservices_ibfk_1` FOREIGN KEY (`SERVICENR`, `efternamn`) REFERENCES `authors` (`AUTHOR_ID`, `SURNAME`);

--
-- Constraints for table `salary`
--
ALTER TABLE `salary`
  ADD CONSTRAINT `sal_a_fk` FOREIGN KEY (`id`, `name`) REFERENCES `authors` (`AUTHOR_ID`, `SURNAME`);
