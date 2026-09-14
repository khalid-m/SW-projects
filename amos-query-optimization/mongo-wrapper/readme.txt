1. Compile MongoDB driver and wrapper
  installMongo.cmd

2. Download MongoDB from 
http://www.it.uu.se/research/group/udbl/software/mongodb-win32-x86_64-2008plus-2.4.8.zip

Unzip to some directory, e.g. 
%HOMEDRIVE%%HOMEPATH%\mongodb-win32-x86_64-2008plus-2.4.8

Rename folder to
%HOMEDRIVE%%HOMEPATH%\mongodb

3. Make MongoDB database folder named
%HOMEDRIVE%%HOMEPATH%\data\db

4. Goto folder %HOMEDRIVE%%HOMEPATH%\mongodb\bin and run there 
   the MongoDB server by:
 mongod --dbpath %HOMEDRIVE%%HOMEPATH%/data/db

NOTICE: The server is stopped by typing CTRL-C in the shell where the
server is running.

5. Run amos with MongoDB wrapper in a separate shell in this directory:
amos2 MongoWrapper.dmp

/* Load MongoDB wrapper */
/* Make a connection to local MongoDB server*/
set :mongo_conn = mongo_connect("127.0.0.1"); /* Localhost */

/* Create a new namespace 'tutorial.person' and add records: */
mongo_put(:mongo_conn, "tutorial.person", {"Name": "Olle", "age": 55});
mongo_put(:mongo_conn, "tutorial.person", {"Name": "George", "age": 27});
mongo_put(:mongo_conn, "tutorial.person", {"Name": "Johan", "age": 27});

/* Get a record from the database: */
mongo_get(:mongo_conn, "tutorial.person", {"age": 27});

/* Get all records in "tutorial.person": */
mongo_get(:mongo_conn, "tutorial.person", empty_record());

/* Delete two objects: */
mongo_del(:mongo_conn, "tutorial.person", {"age": 27});

/* Check what's left: */
mongo_get(:mongo_conn, "tutorial.person", empty_record());

/* Delete the remaining objects: */
mongo_del(:mongo_conn, "tutorial.person", empty_record());

/* Check that nothing is left: */
mongo_get(:mongo_conn, "tutorial.person", empty_record());

