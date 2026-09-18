Start MS SQL SERVER:
- run "SQL Server Configuration Manager", 
- select "SQL Server Services" on left pane,
- right-click "SQL Server (MSSSQLSERVER)" on the right pane,
- select "Start" from context menu

(once per installation) Create "rdfstore" database:
- run "SQL Server Management Studio"
- connect to the instance of SQL Server using default credentials
- in Object Explorer, under <PC NAME> / Security / Logins, create (if not exists) login with name "guest" and password "guest"
- ibid, under <PC NAME> / Databases, create create database "rdfstore" with owner "guest"

- run setup_ms.cmd <chunksize>, e.g.

setup_ms 1608


Use run_ms.cmd to run SSDM with MS SQL Server back-end