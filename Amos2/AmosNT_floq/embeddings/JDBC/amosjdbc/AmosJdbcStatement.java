/*
 * Created on 2004.10.02
 *
 * 
 */
package amosjdbc;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Statement;

import callin.AmosException;
import callin.Scan;
import callin.Tuple;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcStatement extends AmosJdbcObject implements Statement {
	
	private int QueryTimeout;
	private boolean EscapeProcessing;
	protected int MaxRows;
	private int MaxFieldSize;
	
	protected callin.Connection callinConnection;
	protected AmosJdbcConnection connection;
	protected AmosJdbcResultSet res;
	
	/**
	 * @param parser
	 * @param callinConnection
	 * @param connection
	 * 
	 */
	public AmosJdbcStatement(callin.Connection callinConnection,AmosJdbcConnection connection) {
		
		//Init
		QueryTimeout=0;			//unlimited
		EscapeProcessing=true; 	//by default on
		MaxRows=0; 				//unlimited
		MaxFieldSize=0;			//unlimited
		res=null;
		
		this.callinConnection=callinConnection;
		this.connection=connection;
	}
	
	
	/**
	 * 
	 * @see java.sql.Statement#addBatch(java.lang.String)
	 */
	public void addBatch(String sql) throws SQLException {
		throw WrongAPI();
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#cancel()
	 */
	public void cancel() throws SQLException {
		// TODO Auto-generated method stub
		
	}
	
	/**
	 * 
	 * @see java.sql.Statement#clearBatch()
	 */
	public void clearBatch() throws SQLException {
		
		throw WrongAPI();
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#clearWarnings()
	 */
	public void clearWarnings() throws SQLException {
		// TODO Auto-generated method stub
		
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#close()
	 */
	public void close() throws SQLException {
		//not implemented
		
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#execute(java.lang.String)
	 */
	public synchronized boolean execute(String sql) throws SQLException {
		// TODO Auto-generated method stub
		return false;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#executeBatch()
	 */
	public int[] executeBatch() throws SQLException {
		throw WrongAPI();
		//return null;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#executeQuery(java.lang.String)
	 */
	public synchronized ResultSet executeQuery(String sql) throws SQLException {
		
		if (traceOn()) {
			trace("Executing query: "+sql);
		}
		sql=sql.toLowerCase();
		
		Scan scan;
		callin.Oid func;
		Tuple result;
		
		try {
			
			if (sql.startsWith("amosql:")==false)
			{
				if (sql.startsWith("s")==false)
					throw new SQLException("ExecuteQuery can execute only SELECT sentences!");
				
				
				func = callinConnection.getFunction("charstring.sql->vector");
				
				Tuple argl =  new Tuple();
				argl.setArity(1);
				argl.setElem(0,sql);
				
				//Executing sql
				scan=callinConnection.callFunction(func,argl);
				
				if (connection.getAutoCommit()==true) connection.commit();
				
				res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceSQLFront);
				
			}
			else
			{
				//amosql 
				sql=sql.substring(7);
				System.out.println(sql);
				if (MaxRows==0)
				{
					scan = callinConnection.execute(sql);
					if (connection.getAutoCommit()==true) connection.commit();
				}
				else
				{
					scan = callinConnection.execute(sql,MaxRows);
					if (connection.getAutoCommit()==true) connection.commit();
				}
				res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
			}
			//creating ResultSet class with Scan class
			
			
		} catch (AmosException e) {
			throw new SQLException(e.toString());
		}
		
		return res;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#executeUpdate(java.lang.String)
	 */
	public synchronized int executeUpdate(String sql) throws SQLException {
		if (traceOn()) {
			trace("Executing Update query: "+sql);
		}
		sql.toLowerCase();
		
		int res=0;
		Scan scan;
		callin.Oid func;
		
		
		try {
			if (sql.startsWith("amosql:")==false)
			{
				func = callinConnection.getFunction("charstring.sql->vector");
				
				Tuple argl =  new Tuple();
				argl.setArity(1);
				argl.setElem(0,sql);
				
				//Executing sql
				scan=callinConnection.callFunction(func,argl);
				
				if (connection.getAutoCommit()==true) connection.commit();
				
			}
			else
			{
				//amosql sentence
				sql=sql.substring(7);
				scan = callinConnection.execute(sql);
				if (connection.getAutoCommit()==true) connection.commit();
			}
			
			//HOW to know count of change lines?
			//res = ;
			
		} catch (AmosException e) {
			throw new SQLException(e.toString());
		}
		
		return res;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getConnection()
	 */
	public Connection getConnection() throws SQLException {
		// TODO Easy to implement
		
		throw WrongAPI();
		//return null;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getFetchDirection()
	 */
	public int getFetchDirection() throws SQLException {
		throw WrongAPI();
		//return 0;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getFetchSize()
	 */
	public int getFetchSize() throws SQLException {
		throw WrongAPI();
		//return 0;
	}
	
	/**
	 * @see java.sql.Statement#getMaxFieldSize()
	 */
	public int getMaxFieldSize() throws SQLException {
		
		return MaxFieldSize;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getMaxRows()
	 */
	public int getMaxRows() throws SQLException {
		
		return MaxRows;
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#getMoreResults()
	 */
	public boolean getMoreResults() throws SQLException {
		// TODO Auto-generated method stub
		return false;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getQueryTimeout()
	 */
	public int getQueryTimeout() throws SQLException {
		
		return QueryTimeout;
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#getResultSet()
	 */
	public ResultSet getResultSet() throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getResultSetConcurrency()
	 */
	public int getResultSetConcurrency() throws SQLException {
		throw WrongAPI();
		//return 0;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#getResultSetType()
	 */
	public int getResultSetType() throws SQLException {
		throw WrongAPI();
		//return 0;
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#getUpdateCount()
	 */
	public int getUpdateCount() throws SQLException {
		// TODO Auto-generated method stub
		return 0;
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#getWarnings()
	 */
	public SQLWarning getWarnings() throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}
	
	/* (non-Javadoc)
	 * @see java.sql.Statement#setCursorName(java.lang.String)
	 */
	public void setCursorName(String name) throws SQLException {
		// TODO Auto-generated method stub
		
	}
	
	/**
	 * 
	 * @see java.sql.Statement#setEscapeProcessing(boolean)
	 */
	public void setEscapeProcessing(boolean enable) throws SQLException {
		
		EscapeProcessing=enable;
		
	}
	
	/**
	 * 
	 * @see java.sql.Statement#setFetchDirection(int)
	 */
	public void setFetchDirection(int direction) throws SQLException {
		throw WrongAPI();
		
	}
	
	/**
	 * 
	 * @see java.sql.Statement#setFetchSize(int)
	 */
	public void setFetchSize(int rows) throws SQLException {
		throw WrongAPI();
		
	}
	
	/**
	 * @see java.sql.Statement#setMaxFieldSize(int)
	 */
	public void setMaxFieldSize(int max) throws SQLException {
		MaxFieldSize=max;
	}
	
	/**
	 * 
	 * @see java.sql.Statement#setMaxRows(int)
	 */
	public void setMaxRows(int max) throws SQLException {
		
		MaxRows=max;
		
	}
	
	/**
	 * 
	 * @see java.sql.Statement#setQueryTimeout(int)
	 */
	public void setQueryTimeout(int seconds) throws SQLException {
		
		QueryTimeout=seconds;
		
	}


    /* (non-Javadoc)
     * @see java.sql.Statement#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#getMoreResults(int)
     */
    public boolean getMoreResults(int arg0) throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, int)
     */
    public int executeUpdate(String arg0, int arg1) throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, int)
     */
    public boolean execute(String arg0, int arg1) throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, int[])
     */
    public int executeUpdate(String arg0, int[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, int[])
     */
    public boolean execute(String arg0, int[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#getGeneratedKeys()
     */
    public ResultSet getGeneratedKeys() throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#executeUpdate(java.lang.String, java.lang.String[])
     */
    public int executeUpdate(String arg0, String[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }


    /* (non-Javadoc)
     * @see java.sql.Statement#execute(java.lang.String, java.lang.String[])
     */
    public boolean execute(String arg0, String[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }
	
}
