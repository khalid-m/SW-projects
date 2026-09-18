metadb.sql is to set up a toy meta database.

metadb_s.sql is to set up a small size of meta database(e.g. 100 machine installations and 200 sensors).
-> 1 machineinstallation has 2 sensorinstallations. 1 location has 20 machines, 40 sensors


metadb_m.sql is to set up a middle size of meta database(e.g. 200 machine installations and 400 sensors).
-> 1 machineinstallation has 2 sensorinstallations. 1 location has 40 machines, 80 sensors


metadb_l.sql is to set up a large size of meta database(e.g. 500 machine installations and 1000 sensors).
-> 1 machineinstallation has 2 sensorinstallations. 1 location has 100 machines, 200 sensors

commands to grant privileges to user "regress" and password "regress"

GRANT ALL PRIVILEGES ON metadb_s.* TO regress @'%' IDENTIFIED BY 'regress'; 

GRANT ALL PRIVILEGES ON metadb_m.* TO regress @'%' IDENTIFIED BY 'regress'; 

GRANT ALL PRIVILEGES ON metadb_l.* TO regress @'%' IDENTIFIED BY 'regress'; 