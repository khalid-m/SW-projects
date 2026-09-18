/*Needed permission for the user 'relaod':
	1) Create table permissions, drop table permissions
	2) Create stored procedure, delete stored procedure

*/
  
CREATE PROCEDURE example_db.dropTables
AS
  BEGIN
	declare @tname Varchar(80), @dtype Varchar(40);
	declare @c_name Varchar(100);
	declare @dropq NVarchar(100);
	declare procc cursor for select name,type_desc from sys.Tables;
	open procc
	FETCH NEXT FROM procc INTO @tname,@dtype
	WHILE @@FETCH_STATUS = 0
	 begin
	   set @c_name='example_db.' + @tname;
	   IF EXISTS(SELECT 1 FROM sys.tables where name=@tname and @dtype='USER_TABLE')
	     begin
			set @dropq='drop table ' + @c_name ;
		    exec sp_executesql @dropq
		 end
		FETCH NEXT FROM procc INTO @tname,@dtype;
       end;
	close procc;
	deallocate procc;
  END;

CREATE PROCEDURE example_db.dropProc
AS
  BEGIN
	declare @name Varchar(80);
	declare @c_name Varchar(100);
	declare @dropq NVarchar(100);
	declare procc cursor for select name from sys.procedures;
	open procc
	FETCH NEXT FROM procc INTO @name
	WHILE @@FETCH_STATUS = 0
	 begin
	   set @c_name='example_db.' + @name;
	   IF (@name != 'dropProc')
	    IF EXISTS(SELECT 1 FROM sys.procedures where name=@name)
	     begin
			set @dropq='drop procedure ' + @c_name;
		    exec sp_executesql @dropq
		 end
		FETCH NEXT FROM procc INTO @name;
       end;
	close procc;
	deallocate procc;
  END;
  
