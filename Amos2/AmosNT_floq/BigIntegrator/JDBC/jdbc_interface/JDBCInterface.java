/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2002 Martin Hansson, UDBL
 * $RCSfile: JDBCInterface.java,v $
 * $Revision: 1.1 $ $Date: 2012/03/21 10:23:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: The interface part of the JDBC Wrapper. Handles all basic 
 * operations. 
 *
 * ===========================================================================
 * $Log: JDBCInterface.java,v $
 * Revision 1.1  2012/03/21 10:23:05  minzh812
 * *** empty log message ***
 *
 * Revision 1.15  2012/01/26 16:39:49  minzh812
 * adding callSQL function
 *
 * Revision 1.14  2011/04/14 11:47:11  torer
 * Relational wrapper now null tolerant
 *
 * Revision 1.13  2010/09/28 06:33:51  torer
 * Added exception declarations
 *
 * Revision 1.12  2010/09/27 21:27:01  silvias
 * Restore the JDBCInterface since 08.08.2008
 *
 * Revision 1.10  2008/08/08 05:10:03  torer
 * Optional own statement cache per connection
 *
 * Revision 1.9  2008/08/06 11:20:04  torer
 * Explicit closing of scans
 *
 * Revision 1.8  2008/07/21 20:10:30  torer
 * Added stress test function for JDBC queries, TESTSQL
 *
 ****************************************************************************/
package jdbc_interface;

import callin.*;
import callout.*;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.DatabaseMetaData;

public class JDBCInterface {

  public static final boolean DISCARD_NULL_ROWS = false;

  /**
   * Tries to loads a driver class.
   * @param tpl Will be expected to contain:
   * 0. charstring driver - a driver name
   * @exception AmosException is thrown if driver can't be found
   */   
  public void loadDriver(CallContext cxt, Tuple tpl)
    throws AmosException, ClassNotFoundException {
    String driver = tpl.getStringElem(0);
    Class.forName(driver);
  }
  
  /**
   * Connects to a database with a pre-specified driver.
   * @param tpl Will be expected to contain:
   * 0. <code>jdbs_ds ds1</code>     - a database object.
   * 1. <code>charstring url</code>   - the url of the database.
   * 2. <code>charstring usr </code>  - the username.
   * 3. <code>charstring pass</code>  - the password.
   * @return returned in tuple:
   * 4. Will return the same object.
   */
  public void connect(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid    oid  = tpl.getOidElem(0);
    String url  = tpl.getStringElem(1);
    String user = tpl.getStringElem(2);
    String pass = tpl.getStringElem(3);
    new ConnectionWrapper(oid).connect(url, user, pass);
    tpl.setElem(4, oid);
    cxt.emit(tpl);
  }

  /**
   * Connects to a database with a pre-specified driver,
   * using default user name and password.
   * @param tpl Will be expected to contain:
   * 0 <code>jdbs_ds ds1 </code>    - a database object
   * 1 <code>charstring url </code>   - the url of the database
   * @return returned in tuple:
   * 2 <code>jdbs_ds ds1 </code>      - the very same object
   */
  public void connectDefault(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid oid = tpl.getOidElem(0);
    String url = tpl.getStringElem(1);
    new ConnectionWrapper(oid).connect(url);
    tpl.setElem(2, oid);
    cxt.emit(tpl);
  }  

  /**
   * @param tpl will be expected to contain:
   * 0 <code>jdbs_ds ds1</code> - a database object
   * The method will first try to disconnect, and only after 
   * succesfully disconnecting will the connection be removed from 
   * internal storage.
   */
  public void disconnect(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    ConnectionWrapper.getConnectionWrapper(datasource).disconnect();
    tpl.setElem(1, 1);
    cxt.emit(tpl);
  }
  
  /**
   * @param tpl Will be expected to contain:
   * 0. - a datasource object
   * 1. - an SQL query string
   * @return tpl
   * 2. - will emit all rows in the resulting table in a vector
   */
    public void executeQuery(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException, java.io.IOException  {

	Oid datasource = tpl.getOidElem(0);
	String   query = tpl.getStringElem(1);
	ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
	ResultSetWrapper rsw = cw.executeQuery(query);
	emitResults(cxt, tpl, 2, rsw);
	rsw.close();
    }

    public void callSQL(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException, java.io.IOException  {

    }

    public void testExecuteQuery(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException, java.io.IOException {
	Oid datasource = tpl.getOidElem(0);
	String   query = tpl.getStringElem(1);
	int rpt = tpl.getIntElem(2);

	ConnectionWrapper 
	    cw = ConnectionWrapper.getConnectionWrapper(datasource);
        ResultSetWrapper rsw;
	while(rpt>0)
	    {
		rsw = cw.executeQuery(query);
		while (rsw.next()) 
		    {
			Tuple row = rsw.getTuple();
			if (!DISCARD_NULL_ROWS || !rsw.wasNull()) 
			    {
				tpl.setElem(3, rsw.getTuple());
				cxt.emit(tpl);
			    }
		    }
		rsw.close();
		rpt--;
	    }
    }

    /**
   * @param tpl Will be expected to contain:
   * 0. - a database object
   * 1. - an SQL query string where some elements are '?'.
   * 2. - a vector of arguments
   * @return tpl
   * 3. - will emit all rows in the resulting table in a vector.
   */
    public void executeParametrizedQuery(CallContext cxt, Tuple tpl)
	throws AmosException, SQLException, java.io.IOException  {
      
	Oid datasource = tpl.getOidElem(0);
	String  query = tpl.getStringElem(1);
	Tuple  arguments = tpl.getSeqElem(2);
	ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
        ResultSetWrapper rsw;

	rsw = cw.executeQuery(query,arguments);
	while (rsw.next()) 
	    {
		Tuple row = rsw.getTuple();
		if (!DISCARD_NULL_ROWS || !rsw.wasNull()) 
		    {
			tpl.setElem(3, rsw.getTuple());
			cxt.emit(tpl);
		    }
	    }
	rsw.close();
        rsw = null;
    }

 /**
   * @param tpl Will be expected to contain:
   * 0. - a database object
   * 1. - an SQL query string containing an SQL INSERT, UPDATE or 
   *      DELETE statement.
   * @return tpl
   * 2. - either the row count for INSERT, UPDATE or DELETE statements,
   *      or 0 for SQL statements that return nothing.
   */
  public void executeUpdate(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String   query = tpl.getStringElem(1);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    int res = cw.executeUpdate(query);
    tpl.setElem(2, res);
    cxt.emit(tpl);
  }

  /**
   * @param tpl Will be expected to contain:
   * 0. - a database object
   * 1. - an SQL query string containing an SQL INSERT, UPDATE or 
   *      DELETE statement.
   * 2. - a vector of arguments
   * @return tpl
   * 3. - either the row count for INSERT, UPDATE or DELETE statements,
   *      or 0 for SQL statements that return nothing.
   */
   public void executeParametrizedUpdate(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String update = tpl.getStringElem(1);
    Tuple arguments = tpl.getSeqElem(2);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    int res = cw.executeUpdate(update, arguments);
    tpl.setElem(3, res);
    cxt.emit(tpl);
  }

  /**
   * @param tpl Will be expected to contain:
   * 0. <code>jdbs_ds ds1</code> - a database object
   * @return tpl
   * 1. <code>charstring tableName</code> - A name of a table.
   * 2. <code>charstribng tableCatalog</code> - The catalog name, if any
   * 3. <code>charstring tableSchema</code> - The table schema, if any
   * 4. <code>charstring tableType</code> - The table type
   */
  public void tables(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    ResultSet tables = cw.getMetaData().getTables(null, null, null, null);
    while(tables.next()) {
      String tableCatalog = tables.getString(1);
      String tableSchema = tables.getString(2);
      String tableName = tables.getString(3);
      String tableType = tables.getString(4);
      if (tableCatalog == null) tableCatalog = ""; // may be null
      if (tableSchema == null) tableSchema = "";   // may be null
      if (tableType == null) tableType = "";   // may be null
      tpl.setElem(1, tableName);
      tpl.setElem(2, tableCatalog);
      tpl.setElem(3, tableSchema);
      tpl.setElem(4, tableType);
      cxt.emit(tpl);
    }
    tables.close();
  }

  /**
   * @param tpl Will be expected to contain:
   * 0. <code>jdbs_ds ds1</code> - a database object
   * 1. A table Name Pattern
   * @return tpl
   * 2. <code>charstring tableName</code> - A name of a table.
   * 3. <code>charstring tableCatalog</code> - The catalog name, if any
   * 4. <code>charstring tableSchema</code> - The table schema, if any
   * 5. <code>charstring tableType</code> - The table type
   */
  public void tablesByName(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String tableNamePattern = tpl.getStringElem(1);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    ResultSet tables = 
      cw.getMetaData().getTables(null, null, tableNamePattern, null);
    while(tables.next()) {
      String tableCatalog = tables.getString(1);
      String tableSchema = tables.getString(2);
      String tableName = tables.getString(3);
      String tableType = tables.getString(3);
      if (tableCatalog == null) tableCatalog = ""; // may be null
      if (tableSchema == null) tableSchema = "";   // may be null
      tpl.setElem(2, tableName);
      tpl.setElem(3, tableCatalog);
      tpl.setElem(4, tableSchema);
      tpl.setElem(5, tableType);
      cxt.emit(tpl);
    }
    tables.close();
  }

  /**
   * Lists types of columns, ignoring catalog membership. 
   * @param tpl Will be expected to contain:
   * 0. - a database object
   * 1. - a schema name pattern
   * 2. - a table name pattern
   * 3. - a column name pattern
   * @return tpl
   * 4. - The name of the column's type
   * 5. - Name of the column
   */
  public void columns(CallContext cxt, Tuple tpl) 
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    ResultSet rs = dbmd.getColumns(null, tpl.getStringElem(1), 
				   tpl.getStringElem(2), tpl.getStringElem(3));
    while(rs.next()) {
      tpl.setElem(4, rs.getString("TYPE_NAME"));
      tpl.setElem(5, rs.getString("COLUMN_NAME"));
      cxt.emit(tpl);
    }
    rs.close();
  }

  /**
   * Lists the columns that constitute the primary key to a table. 
   * If none is defined, the whole row is considered primary key.
   * @param tpl Will be expected to contain:
   * 0. - a database object 
   * 1. - a catalog name; "" retrieves those without a catalog; nil means drop
   *      catalog name from the selection criteria
   * 2. - a schema name; "" retrieves those without a schema
   * 3. - the table name
   * @return tpl
   * 4. - Name of the column
   * 5. - Name of the constraint, if no name is "unnamed"
   */
    public void primaryKeys(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException 
    {
	Oid datasource = tpl.getOidElem(0);
	String catalogName = null;
	if (tpl.isString(1)) catalogName = tpl.getStringElem(1);
	String schemaName = tpl.getStringElem(2);
	String tableName = tpl.getStringElem(3);
	ConnectionWrapper 
	    cw = ConnectionWrapper.getConnectionWrapper(datasource);
	DatabaseMetaData dbmd = cw.getMetaData();
	ResultSet rs = dbmd.getPrimaryKeys(catalogName, schemaName, tableName);
	while (rs.next()) 
	    {
		tpl.setElem(4, rs.getString("COLUMN_NAME").toLowerCase());
		String constraintName = rs.getString("PK_NAME").toLowerCase();
		if (constraintName == null)
		    constraintName = "unnamed";
		tpl.setElem(5, constraintName);
		cxt.emit(tpl);
	    }
	rs.close();
    }

  public void getCrossReference(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String tableName = tpl.getStringElem(1);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    ResultSet rs = dbmd.getCrossReference(null, "", tableName,
					  null, "", tpl.getStringElem(2));
    while(rs.next()) {
      tpl.setElem(3, rs.getString("PKCOLUMN_NAME"));
      tpl.setElem(4, rs.getString("FKCOLUMN_NAME"));
      cxt.emit(tpl);
    }
    rs.close();
  }
	
/**
   * Gets a description of the primary key columns that are referenced by a 
   * table's foreign key columns (the primary keys imported by a table). 
   * The fn definition in AmosQL is overloaded on the number of arguments.
   * @param tpl Will be expected to contain:
   * 0. - the database object 
   * 1. - the table name
   * alt. add.
   * 2. - the schema name 
   * 3. - the catalog name
   * @return tpl
   * 2. - Name of the referenced table.
   * 3. - Primary key column name.
   * 4. - Foreign key column name being exported.
   */
  public void getImportedKeys(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
      ResultSet rs = null;  
      Oid datasource = tpl.getOidElem(0);
      String tableName = null;
      String catalogName = null;
      String schemaName = null;       
      int index;
      ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
      DatabaseMetaData dbmd = cw.getMetaData();
      index = tpl.getArity() - 3;
    if (index == 2){
	tableName = tpl.getStringElem(1);
	rs = dbmd.getImportedKeys(null, "", tableName);    
    }else{
	catalogName = tpl.getStringElem(1);
	schemaName = tpl.getStringElem(2);
	tableName = tpl.getStringElem(3);
	rs = dbmd.getImportedKeys(catalogName, schemaName, tableName);
    }
    while(rs.next()) {	
	tpl.setElem(index,rs.getString("PKTABLE_NAME"));
	tpl.setElem(index+1,rs.getString("PKCOLUMN_NAME"));
	tpl.setElem(index+2,rs.getString("FKCOLUMN_NAME"));
	cxt.emit(tpl);
    }
    rs.close();
  }		 
	
/**
   * Gets a description of the foreign key columns that reference a 
   * table's primary key columns (the foreign keys exported by a table). 
   * @param tpl Will be expected to contain:
   * 0. - the database object 
   * 1. - the table name
   * @return tpl
   * 2. - primary key column name 
   * 3. - foreign key table name
   * 4. - foreign key column name being exported 
   */
  public void getExportedKeys(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String tableName = tpl.getStringElem(1);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    ResultSet rs = dbmd.getExportedKeys(null, "", tableName);
    while(rs.next()) {
      tpl.setElem(2,rs.getString("PKCOLUMN_NAME"));
      tpl.setElem(3,rs.getString("FKTABLE_NAME"));
      tpl.setElem(4,rs.getString("FKCOLUMN_NAME"));
      cxt.emit(tpl);
    }
    rs.close();
  }		  
	
/**
   * Gets a description of a table's indices and statistics. 
   * They are ordered by NON_UNIQUE, TYPE, INDEX_NAME, and ORDINAL_POSITION.
   * table's primary key columns (the foreign keys exported by a table).
   * @param tpl Will be expected to contain:
   * 0. the datasource object 
   * 1. the schema name
   * 2. the table name  
   * 3. unique - when true, return only indices for unique values; 
   *    when false, return indices regardless of whether unique or not
   * 4. approximate - when true, result is allowed to reflect approximate 
   *    or out of data values; when false, results are requested to be accurate
   * @return tpl
   * 5. table catalog (may be null) 
   * 6. TYPE - index type: 
   *      - tableIndexStatistic - this identifies table statistics that are 
   *        returned in conjuction with a table's index descriptions
   *      - tableIndexClustered - this is a clustered index 
   *      - tableIndexHashed - this is a hashed index 
   *      - tableIndexOther - this is some other style of index 
   * 7. cardinality - When TYPE is tableIndexStatistic, then this is the number
   *    of rows in the table; otherwise, it is the number of unique values in
   *    the index. 
   */
  public void getIndexInfo(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String schema       = tpl.getStringElem(1);
    String table        = tpl.getStringElem(2);
    boolean unique      = tpl.getBooleanElem(3);
    boolean approximate = tpl.getBooleanElem(4);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    ResultSet rs = 
      dbmd.getIndexInfo(null, schema, table, unique, approximate);
    while(rs.next()) {
      switch (rs.getShort("TYPE")) {
      case DatabaseMetaData.tableIndexStatistic:
	tpl.setElem(5,"tableIndexStatistic");
	break;
      case DatabaseMetaData.tableIndexClustered:
	tpl.setElem(5,"tableIndexClustered");
	break;
      case DatabaseMetaData.tableIndexHashed:
	tpl.setElem(5,"tableIndexHashed");
	break;
      case DatabaseMetaData.tableIndexOther:
	tpl.setElem(5,"tableIndexOther");
	break;
      }
      tpl.setElem(6,rs.getInt("CARDINALITY"));
      cxt.emit(tpl);
    }
    rs.close();
  }

  public void getMaxIndexLength(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    tpl.setElem(1, dbmd.getMaxIndexLength());
    cxt.emit(tpl);
  }

  public void setTracePrinting(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
      Oid datasource = tpl.getOidElem(0);
      boolean mode = tpl.getBooleanElem(1);
      ConnectionWrapper.getConnectionWrapper(datasource).setTracePrinting(mode);
      cxt.emit(tpl);
  }


  protected void emitResults(CallContext cxt, Tuple tpl, int position, 
			     ResultSetWrapper rsw) 
    throws AmosException, SQLException, java.io.IOException  {
      //System.out.println("emitting {");
    while (rsw.next()) {
      Tuple row = rsw.getTuple();
      if (!DISCARD_NULL_ROWS || !rsw.wasNull()) {
	tpl.setElem(position, rsw.getTuple());
	cxt.emit(tpl);
      }
    }
    //System.out.println("}");
  }
}


