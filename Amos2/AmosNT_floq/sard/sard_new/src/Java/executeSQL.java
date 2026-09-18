/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Silvia Stefanova, UDBL
 * $RCSfile: executeSQL.java,v $
 * $State: Exp $ $Locker:  $
 *
 * 
 * ===========================================================================
 * $Log: executeSQL.java,v $
 * Revision 1.5  2013/05/28 13:13:04  silvias
 * *** empty log message ***
 *
 * Revision 1.4  2012/05/19 08:39:55  silvias
 * Return "" for the column size even for DATE type
 *
 * Revision 1.3  2012/03/28 17:36:11  silvias
 * Return "" for the column size if the type is datetime or float
 *
 * Revision 1.2  2010/10/01 08:05:42  silvias
 * *** empty log message ***
 *
 * Revision 1.1  2009/04/16 17:08:48  silvias
 * *** empty log message ***
 *
 * Revision 1.3  2009/03/18 15:31:27  silvias
 * Added a SQL query returning the row number
 *
 * Revision 1.2  2008/09/11 13:10:11  silvias
 * redifine columns to columns4 returning the size and null allowed
 *
 * Revision 1.1  2008/09/05 14:18:53  silvias
 * Overloaded sql functions
 *
 *
 *  *
 ****************************************************************************/
import callin.*;
import callout.*;
import jdbc_interface.*;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.DatabaseMetaData;

public class executeSQL {

      
  /**
   * @param tpl Will be expected to contain:
   * 0. - a datasource object
   * 1. - an SQL query string
   * @return tpl
   * 2. - will emit all rows in the resulting table in a vector
   */
    public void executeQuery(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException, java.io.IOException {

	Oid datasource = tpl.getOidElem(0);
	String   query = tpl.getStringElem(1);
	ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
	ResultSetWrapper rsw = cw.executeQuery(query);
	emitResults(cxt, tpl, 2, rsw);
	rsw.close();
    }


public void rowNumbQuery(CallContext cxt, Tuple tpl) 
	throws AmosException, SQLException,java.io.IOException {

	Oid datasource = tpl.getOidElem(0);
	String table=tpl.getStringElem(1);
	String query = "select *  from " + table;
	ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
	ResultSetWrapper rsw;

	int numRows = 0;

	rsw = cw.executeQuery(query);
	while (rsw.next()) 
	    {
		numRows++;
		Tuple row = rsw.getTuple();
		 {
			tpl.setElem(2, rsw.getTuple());
			tpl.setElem(3,numRows );
			cxt.emit(tpl);
		  }
	    }
	rsw.close();
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
			tpl.setElem(3, rsw.getTuple());
			cxt.emit(tpl);
			      
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
	throws AmosException, SQLException,  java.io.IOException {
      
	Oid datasource = tpl.getOidElem(0);
	String  query = tpl.getStringElem(1);
	Tuple  arguments = tpl.getSeqElem(2);
	ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
        ResultSetWrapper rsw;

	rsw = cw.executeQuery(query,arguments);
	while (rsw.next()) 
	    {
		Tuple row = rsw.getTuple();
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
   * Lists types of columns, ignoring catalog membership. 
   * @param tpl Will be expected to contain:
   * 0. - a database object
   * 1. - a schema name pattern
   * 2. - a table name pattern
   * 3. - a column name pattern
   * @return tpl
   * 4. - The name of the column's type
   * 5. - Name of the column
   * 6. - Size of the column
   * 7. - Null allowed
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
      String typ =rs.getString("TYPE_NAME");      
      if ( typ.equals("date") ||
	   typ.equals("datetime") ||
	   typ.equals("float") ||
	   typ.equals("DATE") ||
	   typ.equals("DATETIME") || 
	   typ.equals("FLOAT") )
	  {    tpl.setElem(6,""); }
      else {  tpl.setElem(6, rs.getInt("COLUMN_SIZE"));};
      if ( typ.equals("int identity")) {tpl.setElem(4,"int"); }
      int nullable = rs.getInt("NULLABLE");
      if (nullable == DatabaseMetaData.columnNullable) {
         tpl.setElem(7, "nullable true");
      } else {
         tpl.setElem(7, "nullable false");
      }
      cxt.emit(tpl);
    }
    rs.close();
  }   

public void getBestRowIdent(CallContext cxt, Tuple tpl)
    throws AmosException, SQLException {
    Oid datasource = tpl.getOidElem(0);
    String catalog       = tpl.getStringElem(1);
    String schema       = tpl.getStringElem(2);
    String table        = tpl.getStringElem(3);
    int scope      =  tpl.getIntElem(4);
    boolean nullable = tpl.getBooleanElem(5);
    ConnectionWrapper cw = ConnectionWrapper.getConnectionWrapper(datasource);
    DatabaseMetaData dbmd = cw.getMetaData();
    ResultSet rs = 
      dbmd.getBestRowIdentifier(catalog, schema, table, scope, nullable);
    while(rs.next()) {
	tpl.setElem(6,rs.getString("COLUMN_NAME"));
        cxt.emit(tpl);
    }
    rs.close();
  }


  protected void emitResults(CallContext cxt, Tuple tpl, int position, ResultSetWrapper rsw) 
    throws AmosException, SQLException, java.io.IOException {
      //System.out.println("emitting {");
    while (rsw.next()) {
      Tuple row = rsw.getTuple();
      tpl.setElem(position, rsw.getTuple());
      cxt.emit(tpl);
    }
    //System.out.println("}");
  }
}


