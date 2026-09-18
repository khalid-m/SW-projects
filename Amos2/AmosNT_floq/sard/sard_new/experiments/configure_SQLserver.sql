SELECT * FROM sys.configurations ORDER BY name ;
GO

SELECT * FROM sys.configurations where 
configuration_id=1544 or configuration_id=1543;
GO



sp_configure 'show advanced options', 1;
GO
RECONFIGURE;

sp_configure 'max server memory', 2 147 483 647;
RECONFIGURE;
GO

sp_configure 'min server memory', 100000000;
RECONFIGURE;
GO



CHECKPOINT;

DBCC DROPCLEANBUFFERS returns:

