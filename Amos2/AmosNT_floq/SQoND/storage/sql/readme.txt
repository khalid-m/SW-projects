OBTAINING TEST DATA FILES
=========================

Populate the database by dowloading the file in:

http://user.it.uu.se/~udbl/ssdm/bistab/bistab100.zip 

and unpack it to, e.g., C:/temp/bisbab100. 

Then set environment variable RDFDATA to the file containg the
RDF-data to load:

set RDFDATA="C:/temp/bistab100/bistab100V2.ttl"


PREPARING DUMP FILES FOR BULKLOADING
====================================

  pushd bulkloader

  create directory path specified as part of :dumpfileprefix in settings.osql

  ssdm "dumper.lsp" "../../matWrapper/master.lsp" -o "csvdump_ttl(<chunksize>,'<filename>');" -o "quit;"  

    E.g. ssdm "dumper.lsp" "../../matWrapper/master.lsp" -o "csvdump_ttl(1608, getenv('RDFDATA'));" -o "quit;"    

  popd


MYSQL PREPARATIONS
==================
(once per installation) 

Create the database schema in MYSQL with the
following command to the MYSQL console:

create database rdfstore;

setup.cmd <chunksize> 
  e.g. setup.cmd 1608

Run all queries with:

run.cmd

or 

runmat.cmd if .MAT files are to be (directly) looded


MS SQL SERVER PREPARATIONS
==========================
(once per installation)

For MSSQL you muste create an account with SQL login name 'guest' and
password 'guest'.

'guest' must have access to a database with name 'rdfstore'.

'guest' should have a 'bulkadmin' server role set by server administrator in

<ServerName> / Security / Logins / guest / Properties / Server Roles

Create the database schema by running

setup_ms 1608

If it fails you have to reregister the password for 'guest'.

Run all queries with:

run_ms.cmd

or 

runmat_ms.cmd if .MAT files are to be (directly) looded



POPULATING THE DATABASE
=======================
(same with both backends)

OPTION 1. Bulk loading

  rdf:load(getenv('RDFDATA'),true);

OPTION 2. Direct loading

  rdf:bulkload(true);



NOTE:

In order to read .MAT files linked from .TTL file, matWrapper project needs to be compiled first.

Follow the instructions in ../matWrapper/readme.txt









