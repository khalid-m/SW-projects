<?php 

/****** start_script.php/set_time_limit
 * FUNCTION
 *		Set maximum execution time to none
 ****/
set_time_limit(0);

/****** start_script.php/Include_stuff
 * FUNCTION
 *		Include classes and the config file.
 ****/
include('src/config.php');
require('src/class_command.php');
require('src/class_clean.php');
require('src/class_parse.php');
require('src/class_download.php');

/****** start_script.php/Common_calls
 * FUNCTION
 *		Common calls: connect to the database
 *		Create the objects:
 *			check_url (checks a specific URL)
 *			downloadfile (downloads files)
 *			clean_xml (cleans the XML files)
 *			parse_xml_structure
 *			parse_xml_content
 ****/
Database::connect(); //Connect to the database
$filecheck = new CheckURL; //Create a object that can check a specific URL
$file = new DownloadExtractFile; //Create a new object
$clean_xml = new CleanXML;
$parse_structure = new ParseXMLStructure; //Create a new object
$parse_content = new ParseXMLContent;


/****** start_script.php/Check_for_updates
 * FUNCTION
 *		This section download the headers for the structure file. 
 *		Then it checks when the file was last modified.
 *		at last it compares it with the users last update.
 ****/
if(CHECK_FOR_UPDATES) {
	Basic::printToConsole('CHECKING FOR UPDATES...');
	$filecheck->downloadHeaders('http://rdf.dmoz.org/rdf/structure.example.txt'); //Download headers from a URL 
	$filecheck->lastModified(); //Run the function that finds when the URL(document) was last modified.
	$filecheck->lastModifiedCompare(); //Compare the DMOZ file, with your last updated
	Basic::printToConsole("OK. Ready for an update!\n");
}

/****** start_script.php/Structure_file
 * SECTION
 *		Calls that handle the DMOZ structure file	
 ****/

/****** Structure_file/Download
 * FUNCTION
 *		Download the structure file	
 ****/
if(STRUCTURE_DOWNLOAD_AND_EXTRACT) {
	$file->setDownloadSpeed(DOWNLOAD_SPEED); //Set download speed
	$file->setFilename(FILE_RDF_STRUCTURE); //Set the filename
	$file->delete(); //Delete the old file - if it's there
	$file->setPath('http://rdf.dmoz.org/rdf/structure.example.txt'); //Set path of what file it is downloading.
	$file->download(); //Start the download
	$file->extract(); //Extract the file
}

/****** Structure_file/Clean_xml
 * FUNCTION
 *		Clean the structure file! (dirty xml - we don't like it :D)	
 ****/
if(STRUCTURE_CLEAN) {
	$clean_xml->cleanFile(FILE_RDF_STRUCTURE);
}

/****** Structure_file/Parse_and_insert
 * FUNCTION
 *		Parse and insert the structure RDF file into a database	
 ****/
if(STRUCTURE_PARSE_N_INSERT) {
	$parse_structure->setStartTime(); //Start time
	$parse_structure->setXMLFile(FILE_RDF_STRUCTURE); //Set what XML file to parse
	$parse_structure->startParse(); //Start parsing the document
}

/****** start_script.php/Content_file
 * SECTION 
 *		Calls that handle the DMOZ content file	
 ****/

/****** Content_file/Download
 * FUNCTION
 *		 Download the content file	
 ****/
if(CONTENT_DOWNLOAD_AND_EXTRACT) {
	$file->setFilename(FILE_RDF_CONTENT); //Set the filename
	$file->delete(); //Delete the old file - if it's there
	$file->setPath('http://rdf.dmoz.org/rdf/content.example.txt'); //Set path of what file it is downloading.
	$file->download(); //Start the download
	$file->extract(); //Extract the file
}

/****** Content_file/Clean_xml
 * FUNCTION
 *		 Clean the content file! (dirty xml - we don't like it :D)	
 ****/
if(CONTENT_CLEAN) {
	$clean_xml->cleanFile(FILE_RDF_CONTENT);
}

/****** Content_file/Parse_and_insert
 * FUNCTION
 *		 Parse and insert the content RDF file into a database	
 ****/
if(CONTENT_PARSE_N_INSERT) {
	$parse_content->setStartTime(); //Start time
	$parse_content->setXMLFile(FILE_RDF_CONTENT); //Set what XML file to parse
	$parse_content->startParse(); //Start parsing the document
}

//Write to a lastupdate.data file
$filecheck->writeLastUpdate();

Basic::printToConsole('FINISHED!');

Database::close(); //Close connection
?> 
