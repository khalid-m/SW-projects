/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2002 Martin Hansson, UDBL
 * $RCSfile: ResultSetWrapper.java,v $
 * $Revision: 1.1 $ $Date: 2012/03/21 10:23:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: A decorator approach to return rows from a table as tuples.
 * ===========================================================================
 * $Log: ResultSetWrapper.java,v $
 * Revision 1.1  2012/03/21 10:23:05  minzh812
 * *** empty log message ***
 *
 * Revision 1.25  2011/05/18 15:42:18  silvias
 * Fix if values for DATE and TIME Sql types are NULL
 *
 * Revision 1.24  2011/05/12 14:12:50  torer
 * Double Java speed by changing 'Double' to 'double'
 * Avoid using objects in Java!
 *
 * Revision 1.23  2011/05/12 13:23:58  torer
 * Faster implementation of getTuple
 *
 * Revision 1.22  2011/04/18 18:29:53  torer
 * setElem on byte arrays
 *
 * Revision 1.21  2011/04/18 14:44:03  torer
 * Adaptive string buffer size
 *
 * Revision 1.20  2011/04/14 11:03:36  torer
 * Code cleanup
 *
 * Revision 1.19  2011/04/14 08:34:10  torer
 * Smaller JDBC string buffer size
 *
 * Revision 1.18  2011/04/13 15:10:28  torer
 * Larger string buffer
 *
 * Revision 1.17  2011/03/10 13:36:14  silvias
 * Return Amos NIL for the NULL sql values
 *
 * Revision 1.16  2010/12/12 20:29:54  torer
 * Much larger string buffer
 *
 * Revision 1.15  2010/11/23 13:06:04  silvias
 * Return "sql null" instead of 0 for NULL values in integer and double sql type columns
 *
 * Revision 1.14  2010/09/29 14:35:18  silvias
 * Treating TIMESTAMP and DATE by getString
 *
 * Revision 1.13  2010/09/27 15:57:23  silvias
 * *** empty log message ***
 *
 * Revision 1.11  2010/09/11 03:07:47  torer
 * Byte buffer interface for JDBC strings
 *
 * Revision 1.10  2010/09/09 20:09:03  torer
 * Chunked emitting of large strings
 *
 * Revision 1.9  2009/08/10 15:22:52  silvias
 * Addes java.sql.Types.BINARY needed for MS SQL Server's timestamp
 *
 * Revision 1.8  2009/08/04 11:39:35  fred2431
 * * Close the statements in another way to avoid memory leak
 *
 * Revision 1.7  2009/03/09 16:07:00  silvias
 * Added mapping for the data type 'real'; OBS: It works if NULLs are allowed
 *
 * Revision 1.6  2008/08/07 15:37:45  silvias
 * added java.sql.Types.REAL and java.sql.Types.NULL
 *
 * Revision 1.5  2008/08/06 11:20:04  torer
 * Explicit closing of scans
 *
 * Revision 1.4  2008/07/17 17:48:26  torer
 * 1. Removed obsolete code
 * 2. Allowed AmosQL function SQL to process updates too. Returns # affected rows.
 * 3. Added statement cache
 *
 ****************************************************************************/

package jdbc_interface;

import java.sql.*;
import callin.*;
import java.util.Hashtable;

public class ResultSetWrapper {

    protected static final boolean printing = false;

    private static final int INTEGER =1;
    private static final int STRING = 2;
    private static final int DOUBLE = 3;
    private static final int BOOLEAN =4;
    private static final int REAL =5;
    private static final int DATE =6;
    private static final int TIME =7;


    PreparedStatement ps;
    private ResultSet rs;
    private ResultSetMetaData rsmd;
    private int columnSize[];
    private Tuple row=null;
    private int width;
    private int datatypes[];
    protected boolean isOpen;
    protected int rowsAffected=-1;
    /**
     * Provides the mapping between the numerous SQL types and their Java
     * counterparts. The mapping is from strings to integers, where the 
     * integers representing Amos types are static members of this class.
     */
    protected static Hashtable typeMap = new Hashtable();

    static {
	Integer integero = new Integer(INTEGER);
	Integer stringo  = new Integer(STRING);
	Integer doubleo  = new Integer(DOUBLE);
	Integer booleano = new Integer(BOOLEAN);
	Integer realno = new Integer(REAL);
	Integer dateo = new Integer(DATE);
	Integer timeo = new Integer(TIME);
	typeMap.put(new Integer(java.sql.Types.BIGINT),   integero);
	typeMap.put(new Integer(java.sql.Types.BINARY),     stringo);
	typeMap.put(new Integer(java.sql.Types.BIT),      booleano);
	typeMap.put(new Integer(java.sql.Types.CHAR),     stringo);
	typeMap.put(new Integer(java.sql.Types.DATE),     dateo);
	typeMap.put(new Integer(java.sql.Types.TIME),     timeo);
	typeMap.put(new Integer(java.sql.Types.DECIMAL),  doubleo);
	typeMap.put(new Integer(java.sql.Types.TIMESTAMP), dateo);
	typeMap.put(new Integer(java.sql.Types.DOUBLE),   doubleo);
	typeMap.put(new Integer(java.sql.Types.FLOAT),    doubleo);
	typeMap.put(new Integer(java.sql.Types.NULL),    stringo);
	typeMap.put(new Integer(java.sql.Types.REAL),    realno);
	typeMap.put(new Integer(java.sql.Types.INTEGER),  integero);
	typeMap.put(new Integer(java.sql.Types.NUMERIC),  doubleo);
	typeMap.put(new Integer(java.sql.Types.SMALLINT), integero);
	typeMap.put(new Integer(java.sql.Types.TINYINT),  integero);
	typeMap.put(new Integer(java.sql.Types.VARCHAR),  stringo);
	typeMap.put(new Integer(java.sql.Types.LONGVARCHAR),  stringo);
    }

    /**
     * Creates a new <code>ResultSetWrapper</code> for this particular
     * <code>ResultSet</code>.
     * @param rs The <code>java.sql.ResultSet</code> to be tupleized.
     * @param outerJoin If true, then Tuples containing null will be
     * removed from the result.
     */  
    public ResultSetWrapper(PreparedStatement theps) throws SQLException {
        ps = theps;
	if(ps.execute()) 
	    {   int i, cc;
	    rs = ps.getResultSet();
	    rsmd = rs.getMetaData();
	    cc = rsmd.getColumnCount();
	    columnSize = new int[cc];
	    for(i=0;i<cc;i++) columnSize[i]=19;
	    isOpen = true;
	    }    
        else 
            {
		// Get the update count
		rowsAffected = ps.getUpdateCount() ;
		isOpen = true;
            }
    }
    /**
     * Closes the underlying <code>ResultSet</code>. 
     */
    public void close() throws SQLException {
	try 
	    {
		ps.clearParameters();
		ps.close();
	    }
	catch (SQLException sqle) 
	    {
	    }

	if ( rs!=null )
	    rs.close();
	rs = null;
	ps = null;
	isOpen = false;
    }

    /**
     * Returns the current row as a <code>calling.Tuple</code>. If no Amos II
     * is running a segmentation fault will be raised
     */
    public synchronized Tuple getTuple() throws AmosException, SQLException, 
	java.io.IOException
    {
	if(rowsAffected >= 0)
	    {
		row = new Tuple(1);
		row.setElem(0, rowsAffected);
		return row;
	    }   
	if (!isOpen) throw new AmosException("Result set wrapper is closed.");
        if(row==null)
	    { 
		width = rsmd.getColumnCount();
		row = new Tuple(width);
                datatypes = new int[width];
                for(int i=0;i<width;i++)
		    {
			Integer type = (Integer)
			    typeMap.get(new Integer(rsmd.getColumnType(i+1)));
			if (type == null) 
			    throw new AmosException("Type map incomplete");
			datatypes[i]=type.intValue();
                    }
            }
	for (int i=0; i<width; i++) 
	    {
 
		switch (datatypes[i]) 
		    {
		    case INTEGER:	  
			int inn=rs.getInt(i+1);
			if (!rs.wasNull()) row.setElem(i, inn);
			else row.setElem(i, (Oid)null);
			break;
		    case STRING:
			{
			    int sz=columnSize[i], cs = 0;
			    byte [] buff = new byte[sz];
			    Boolean first = true;
                    
			    java.io.InputStream fin = rs.getAsciiStream(i+1);
                    
			    if(fin != null) 
				for(;;)
				    {
					int size = fin.read(buff);
					if(size==-1) break; // end of stream
					if(first)
					    {
						first = false;
						row.setElem(i, buff, size);
					    }
					else row.addElem(i, buff, size);
					cs = cs + size;
				    }
			    else row.setElem(i, (Oid)null);
			    if(cs > columnSize[i]) columnSize[i] = cs;
			}
			break;
		    case DATE:
			String s = rs.getString(i+1);	
			if (!rs.wasNull()) row.setElem(i, s);
			else row.setElem(i, (Oid)null);
			break;
		    case TIME:
			String st = rs.getString(i+1);	
			if (!rs.wasNull()) row.setElem(i, st);
			else row.setElem(i, (Oid)null);
			break;
		    case DOUBLE:
			double doub = rs.getDouble(i+1);
			if (!rs.wasNull()) row.setElem(i, doub);
			else row.setElem(i, (Oid)null);
			break;
		    case REAL:
			doub = rs.getDouble(i+1);
			if (!rs.wasNull()) row.setElem(i, doub);
			else row.setElem(i, (Oid)null); 
			break;
		    case BOOLEAN:
			row.setElem(i, rs.getBoolean(i+1));
			break;
		    default:
			throw new AmosException("Type map incomplete");
		    }
	    }
	return row;
    }

    public synchronized boolean next() throws SQLException, AmosException {
	if (!isOpen) return false;
	if(rowsAffected >= 0) 
	    {
		isOpen = false; 
		return true;
	    }
	try 
	    {
		boolean next = rs.next();
		return next;
	    }
	catch (SQLException sqle) 
	    { 
		print("Error for "+this); 
		throw sqle;
	    }
    }

    public boolean wasNull() throws SQLException 
    { 
	if(rowsAffected >=0) return false;
	return rs.wasNull(); 
    }  

    protected void print(String s) { if (printing) System.out.println(s); }

}
