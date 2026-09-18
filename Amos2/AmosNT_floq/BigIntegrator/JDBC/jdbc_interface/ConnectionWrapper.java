/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2003 Martin Hansson, UDBL
 * $RCSfile: ConnectionWrapper.java,v $
 * $Revision: 1.1 $ $Date: 2012/03/21 10:23:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: The connection wrapper manages the connection to a database,
 * ===========================================================================
 * $Log: ConnectionWrapper.java,v $
 * Revision 1.1  2012/03/21 10:23:05  minzh812
 * *** empty log message ***
 *
 * Revision 1.15  2010/10/06 16:42:40  torer
 * Removed hack
 *
 * Revision 1.14  2009/12/09 15:15:10  torer
 * Bug in statement cache
 *
 * Revision 1.13  2008/08/08 05:10:03  torer
 * Optional own statement cache per connection
 *
 * Revision 1.12  2008/08/06 11:20:04  torer
 * Explicit closing of scans
 *
 * Revision 1.11  2008/07/21 20:11:46  torer
 * Cache ad hoc statements too since MySQL leaks
 *
 * Revision 1.10  2008/07/17 18:05:28  torer
 * Ad hoc statements not cached to avoid memory overflow
 *
 * Revision 1.9  2008/07/17 17:48:26  torer
 * 1. Removed obsolete code
 * 2. Allowed AmosQL function SQL to process updates too. 
 *    Returns # affected rows.
 * 3. Added statement cache
 *
 * Revision 1.8  2007/10/04 09:41:12  torer
 * *** empty log message ***
 *
 * Revision 1.7  2006/11/06 19:54:57  torer
 * Error message when using not opened JDBC connection
 *
 ****************************************************************************/
package jdbc_interface;

import callin.*;
import callout.*;
import java.sql.*;
import java.util.Hashtable;
import java.util.Vector;

public class ConnectionWrapper {

    /**
     * No Java objects are preserved between calls from Amos, so the only way 
     * to keep objects present is by maintaining static references to them.
     */
    protected static Hashtable wrappers = new Hashtable();
    protected boolean USE_STATEMENT_CACHE = true;
    protected Hashtable preparedStatements = new Hashtable();
    protected boolean tracePrinting = false;
    protected Oid datasource;
    protected java.sql.Connection conn;
    protected String url, user, pass;

    public ConnectionWrapper()
	throws AmosException { 
	this.datasource = datasource;
	conn = null;
    }

    /**
     * Creates a new connection wrapper representing a connection for the
     * datasource object <code>datasource</code>.
     * The connection wrapper can then be retrieved by calling <code>
     * getConnectionWrapper
     */
    public ConnectionWrapper(Oid datasource) throws AmosException {
	this();
    
	wrappers.put(new Integer(datasource.getID()), this); 
    }

    /**
     * Retrieves the <code>ConnectionWrapper</code> from static storage
     * which is associated with the datasource <code>datasource</code>
     */
    private int conncounter=0;
    public static ConnectionWrapper getConnectionWrapper(Oid datasource)
	throws SQLException, AmosException {
	Integer Id = new Integer(datasource.getID());
	ConnectionWrapper cw;
        cw = (ConnectionWrapper)wrappers.get(Id);
	if (cw == null) 
	    throw new AmosException("No connection wrapper for "+datasource);
	else
	    return cw;
    }

    /**
     * Creates a connection to the database at <code>url</code> with a given
     * username and password
     */
    public void connect(String url, String user, String pass)
	throws SQLException, AmosException {
	if ( conn != null)
	    throw new AmosException(this+" is already connected to "+conn);
	this.url=url; this.user=user; this.pass=pass;
	conn = DriverManager.getConnection(url, user, pass);
    }

    /**
     * Creates a connection to the database at <code>url</code> with default
     * username and password
     */
    public void connect(String url) throws SQLException, AmosException {
	if ( conn != null)
	    throw new AmosException(this+" is already connected to "+url);
	this.url=url; this.user=null; this.pass=null;
	conn = DriverManager.getConnection(url);
    }

    /**
     * Severs the connection held by this <code>ConnectionWrapper</code>.
     * The <code>ConnectionWrapper</code> can then be reused for opening
     * connections to other databases.
     */
    public void disconnect() throws AmosException, SQLException {
	if(conn==null) 
	    throw new AmosException("No open database connection for " + 
				    url);
	conn.close();
	datasource = null;
	conn = null;
	url = user = pass = null;
    }

    /**
     * Severs the connection held by this <code>ConnectionWrapper</code> and 
     * removes it from static storage. If an SQLException occurs, the
     * <code>ConnectionWrapper</code> remains.
     */  
    public void close() throws AmosException, SQLException {
	if(conn==null) 
	    throw new AmosException("No open database connection for " + 
				    url);
	conn.close();
	wrappers.remove(new Integer(datasource.getID()));
    }

    public ResultSetWrapper executeQuery(String query)
	throws SQLException, AmosException {
	PreparedStatement ps = producePreparedStatement(query);
	ResultSetWrapper rsw = new ResultSetWrapper(ps);
	return rsw;
    }

    public ResultSetWrapper executeQuery(String query, Tuple args)
	throws SQLException, AmosException {
	PreparedStatement ps =null;
	ps = producePreparedStatement(query);   	
	fillInPreparedStatement(ps, args);   
      	ResultSetWrapper rsw = new ResultSetWrapper(ps);    
	return rsw;
    }

    public int executeUpdate(String update) 
	throws SQLException, AmosException {
	PreparedStatement ps = producePreparedStatement(update);
	return ps.executeUpdate();
    }

    public int executeUpdate(String update, Tuple arguments)
	throws SQLException, AmosException {
	PreparedStatement ps = producePreparedStatement(update);
	fillInPreparedStatement(ps, arguments);
	int result = ps.executeUpdate();
	return result;
    }

    public DatabaseMetaData getMetaData() throws SQLException, AmosException {
	if(conn==null) 
	    throw new AmosException("No open database connection for " + 
				    url);
	return conn.getMetaData(); 
    }

    public void setTracePrinting(boolean mode) { tracePrinting = mode; }

    public String toString() { return "Connection Wrapper for "+datasource; }

    protected void fillInPreparedStatement(PreparedStatement pstmt, Tuple args)
	throws SQLException, AmosException {
	for (int i = 0; i < args.getArity(); i++) {
	    if (args.isString(i)) {
                String used = args.getStringElem(i);
		pstmt.setString(i+1, used);
	    }
	    else if (args.isInteger(i)){
		pstmt.setInt(i+1, args.getIntElem(i));
	    }
	    else if (args.isDouble(i)) {
		double d = args.getDoubleElem(i);
		try { pstmt.setDouble(i+1, d); }
		catch (SQLException sqle) {
		    pstmt.setFloat(i+1,(float)d);
		}
	    }
	    else if (args.isObject(i))
		pstmt.setObject(i+1, args.getOidElem(i));
	    else if (args.isTuple(i))
		throw new AmosException("Wrapper does not support Tuples " +
					"in parametrized query");
	}
    }

    protected PreparedStatement producePreparedStatement(String statement) 
	throws SQLException, AmosException 
    {
	PreparedStatement ps;
	print("preparing :"+statement);
	if(conn==null) 
	    throw new AmosException("No open database connection for " + 
				    url);
        if(USE_STATEMENT_CACHE)
	    { 
		if((ps = (PreparedStatement)preparedStatements.get(statement))
		   == null)
		    {  // Not cached earlier
			// System.out.println("Preparing '" + statement + "'");
			ps = conn.prepareStatement(statement);
			if(statement.indexOf('?')>=0) 
			    // Don't cache ad hoc queries
			    preparedStatements.put(statement, ps);
                        return ps;
		    }
		else return conn.prepareStatement(statement);
	    }
	return conn.prepareStatement(statement);
    }

    protected void print(String s) 
    { if (tracePrinting) System.out.println(s); }

}
