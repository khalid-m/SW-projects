<?php 

/****h* Introduction/create_tables.php
 * NAME
 *		create_tables.php
 * USAGE
 *		Just call this script to create the needed tables in your database
 * AUTHOR
 *		Amir Salihefendic (amix@amix.dk) -
 * 		Every hour, because it's all good.
 * COPYRIGHT
 *		JFL Webcom (http://www.webcom.dk)
 * CREATION DATE
 *		23 nov. 2003
 * HISTORY
 *		6 dec.  2003: Fixed some things. Added more complex regex's.
 *		12 feb. 2004: Fixed some "" things - changed them to ''
 *		19 maj  2004: Rewritten all comments, so they support ROBODOC - kinky stuff :-D
 ****/

/****** create_tables.php/Include_stuff
 * FUNCTION
 *		Include classes and the config file.

 *-----------------------------------------------------------------------------------
 *  Modifications taken place:
 * Added new files to connect and create new database
 * changed the tables names and edited the attributes columns
 * Added NEWID as primary key to 3 tables
 * changed system type to innoDB
 * Daniel Camara
 *-----------------------------------------------------------------------------------
 ****/
$link = mysql_connect('localhost', 'root', '');
if (!$link) {
die('Could not connect: ' . mysql_error());
}

$sql = 'CREATE DATABASE dmoz';
if (mysql_query($sql, $link)) {
echo "Database DMOZ is created successfully...!\n";

} else {
echo 'Error creating database: ' . mysql_error() . "\n";
}


include('src/config.php');
require('src/class_command.php');

Database::connect(); //Connect to the database
 
//Create content_description table
$query = "CREATE TABLE contents (
  externalpage char(100) NOT NULL,
  newid int NOT NULL AUTO_INCREMENT,
  title varchar(100) NOT NULL,
  description varchar(255) NOT NULL,
  ages varchar(100) NOT NULL default '',
  mediadate date NOT NULL default '0000-00-00',
  priority tinyint(2) NOT NULL default '0',
  PRIMARY KEY newid (newid)
) TYPE=InnoDB;\n";
Database::sqlWithoutAnswer($query); //Create :)

//Create content_links table
$query = "CREATE TABLE clinks (
  catid int(8) NOT NULL default '0',
  newid int NOT NULL AUTO_INCREMENT,
  topic varchar(255) NOT NULL,
  type varchar(20) NOT NULL default '',
  resource varchar(100) NOT NULL,
  PRIMARY KEY newid (newid)
) TYPE=InnoDB;\n";
Database::sqlWithoutAnswer($query); //Create :)

//Create structure table
$query = "CREATE TABLE structure (
  catid int(8) NOT NULL default '0',
  name varchar(100) NOT NULL,
  title varchar(255) NOT NULL default '',
  description varchar(255) NOT NULL default '',
  lastupdate datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY catid (catid)
) TYPE=InnoDB;\n";
Database::sqlWithoutAnswer($query); //Create :)

//Create datatypes table
$query = "CREATE TABLE datatypes (
  catid int(8) NOT NULL default '0',
  newid int NOT NULL AUTO_INCREMENT,
  type varchar(20) NOT NULL default '',
  resource varchar(100) NOT NULL,
  PRIMARY KEY newid (newid)
) TYPE=InnoDB;\n";
Database::sqlWithoutAnswer($query); //Create :)

echo "\nCONTENTS,CLINKS,STRUCTURE,& DATATYPES tables in the relational
database (".DMOZ.") have been successfully created!\n";

Database::close(); //Close connection
?>
