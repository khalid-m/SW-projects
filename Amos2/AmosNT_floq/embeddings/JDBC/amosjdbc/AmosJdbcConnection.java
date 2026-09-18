/*
 * Created on 2004.10.02
 *
 * 
 */
package amosjdbc;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Savepoint;
import java.sql.Statement;
import java.util.Map;
import java.util.Properties;

import callin.*;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcConnection extends AmosJdbcObject implements Connection {

    private callin.Connection theConnection;
    private boolean autoCommit;
    private boolean clientserver;
    private boolean connectionClosed;
    private boolean readOnly;
    private int transactionIsolation;
    private String url;
    

    /**
     * @param driver
     * @param info
     * 
     */
    public AmosJdbcConnection(AmosJdbcDriver driver,Properties info) {
        
        //initialize everything
        autoCommit=true;
        clientserver=false;
        connectionClosed=false;
        readOnly=false;
        transactionIsolation=TRANSACTION_SERIALIZABLE;
        url=driver.url;
        
        //FIXME!!!!bad FIX IT!!!
        try{
            if (driver.firsttime)
            {
                callin.Connection.initializeAmos(info.getProperty("directory")+info.getProperty("dumpfile"));
                driver.firsttime=false;
            }
            
            if (info.getProperty("dbName","").compareTo("")==0)
            {
                    theConnection = new callin.Connection("");
            }
            else
            {
                if (info.getProperty("nameServerHost")==null)
                {
                    //System.out.println("Connecting to nameserver: "+info.getProperty("dbName"));
                    theConnection = new callin.Connection(info.getProperty("dbName"));
                }
                else
                {
                    theConnection = new callin.Connection(info.getProperty("dbName"),info.getProperty("nameServerHost"));
                }
                clientserver=true;
            }    
        }
        catch (AmosException e)
        {
            System.out.println("Error:"+e);
        }
    }
    
  
    /**
     *  
     * @see java.sql.Connection#clearWarnings()
     */
    public void clearWarnings() throws SQLException {
        // TODO nothing while there is no warnings

    }

    /**
     * Destructor
     * @see java.lang.Object#finalize()
     */
    public synchronized void finalize()
    {
        try {
            this.close();
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
    
    /**
     * 
     * @see java.sql.Connection#close()
     */
    public synchronized void close() throws SQLException {

        if (traceOn()) {
            trace("Closing connection");
        }

        connectionClosed=true;
        
        try {
            theConnection.disconnect();
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }

    }

    /**
     * 
     * @see java.sql.Connection#commit()
     */
    public void commit() throws SQLException {
        
        if (traceOn()) {
            trace("Commiting");
        }
        
        try {
            theConnection.commit();
        } catch (AmosException e) {
            
            throw new SQLException(e.toString());
        }
    }

    /**
     * 
     * @see java.sql.Connection#createStatement()
     */
    public Statement createStatement() throws SQLException {
        if (traceOn()) {
            trace("Creating new AmosJdbcStatement");
        }

        // Create a new Statement object
        AmosJdbcStatement stmt = new AmosJdbcStatement(theConnection,this);

        return stmt;
    }

    /**
     * 
     * @see java.sql.Connection#createStatement(int, int)
     */
    public Statement createStatement(int resultSetType, int resultSetConcurrency)
            throws SQLException {
        // TODO Java 2.0 API - ignoring
        
        throw WrongAPI();
        //return null;
    }

    /**
     *  
     * @see java.sql.Connection#getAutoCommit()
     */
    public boolean getAutoCommit() throws SQLException {
        return autoCommit;
    }

    /**
     * 
     * @see java.sql.Connection#getCatalog()
     */
    public String getCatalog() throws SQLException {
        
        // TODO No idea about such things in Amos
        return null;
    }

    /**
     * 
     * @see java.sql.Connection#getMetaData()
     */
    public DatabaseMetaData getMetaData() throws SQLException {

        AmosJdbcDatabaseMetaData dbmd = new AmosJdbcDatabaseMetaData (theConnection,url);

        return dbmd;
    }

    /**
     * @see java.sql.Connection#getTypeMap()
     */
    public Map getTypeMap() throws SQLException {
        // TODO Java 2.0 API - ignoring
        return null;
    }

    /**
     * 
     * @see java.sql.Connection#getTransactionIsolation()
     */
    public int getTransactionIsolation() throws SQLException {
        return transactionIsolation;
    }

    /**
     * 
     * @see java.sql.Connection#getWarnings()
     */
    public SQLWarning getWarnings() throws SQLException {
        // TODO No warnings... yet 
        return null;
    }

    /**
     * 
     * @see java.sql.Connection#isClosed()
     */
    public boolean isClosed() throws SQLException {
        return connectionClosed;
    }

    /**
     * 
     * @see java.sql.Connection#isReadOnly()
     */
    public boolean isReadOnly() throws SQLException {
        return readOnly;
    }

    /**
     * As SQL Front uses pure sql as input there is no translation
     * Returning original SQL string. 
     * @see java.sql.Connection#nativeSQL(java.lang.String)
     */
    public String nativeSQL(String sql) throws SQLException {
       
        if (traceOn()) {
            trace("Creating native sql string");
        }
                
        return sql;
    }

    /**
     * 
     * @see java.sql.Connection#prepareCall(java.lang.String)
     */
    public CallableStatement prepareCall(String sql) throws SQLException {
        
        if (traceOn()) {
            trace("@prepareCall (sql=" + sql + ")");
        }
        
        // TODO No idea about AMOS support!
        AmosJdbcCallableStatement clst = new AmosJdbcCallableStatement(sql); 
        return clst;
    }

    /**
     * 
     * @see java.sql.Connection#prepareCall(java.lang.String, int, int)
     */
    public CallableStatement prepareCall(String sql, int resultSetType,
            int resultSetConcurrency) throws SQLException {
        // TODO Java 2.0 API -ignoring
        
        throw DriverNotCapable();
        //return null;
    }

    /**
     * 
     * @see java.sql.Connection#prepareStatement(java.lang.String)
     */
    public synchronized PreparedStatement prepareStatement(String sql) throws SQLException {
        if (traceOn()) {
            trace("@prepareStatement (sql=" + sql + ")");
        }

        // Create a new PreparedStatement object
        AmosJdbcPreparedStatement ps = new AmosJdbcPreparedStatement(sql,theConnection,this);

        return ps;
    }

    /**
     * 
     * @see java.sql.Connection#prepareStatement(java.lang.String, int, int)
     */
    public PreparedStatement prepareStatement(String sql, int resultSetType,
            int resultSetConcurrency) throws SQLException {
        // TODO Java 2.0 API - ignoring
        
        throw DriverNotCapable();
        //return null;
    }

    /**
     * 
     * @see java.sql.Connection#rollback()
     */
    public void rollback() throws SQLException {

        if (traceOn()) {
            trace("Rollback");
        }
        
        try {
            theConnection.rollback();
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }

    }

    /**
     * 
     * @see java.sql.Connection#setAutoCommit(boolean)
     */
    public void setAutoCommit(boolean autoCommit) throws SQLException {
        if (traceOn()) {
            trace("@setAutoCommit (autoCommit=" + autoCommit + ")");
        }
        if (clientserver==false)
            this.autoCommit=autoCommit;
    }

    /**
     * 
     * @see java.sql.Connection#setCatalog(java.lang.String)
     */
    public void setCatalog(String catalog) throws SQLException {
        // TODO No idea about such things in Amos

    }

    /**
     * 
     * @see java.sql.Connection#setReadOnly(boolean)
     */
    public void setReadOnly(boolean readOnly) throws SQLException {
        
        if (autoCommit) 
        {
            this.readOnly=readOnly;
        }
        else
        {
            // TODO Needs a better solution
            throw new SQLException("Connot do that in the middle of transaction");
        }
    }

    /**
     * 
     * @see java.sql.Connection#setTypeMap(java.util.Map)
     */
    public void setTypeMap(Map map) throws SQLException {
        // TODO Java 2.0 API - ignoring

    }

    /**
     * 
     * @see java.sql.Connection#setTransactionIsolation(int)
     */
    public void setTransactionIsolation(int level) throws SQLException {
        if (traceOn()) {
            trace("@setTransactionIsolation (level=" + level + ")");
        }
        
        // TODO check it with Tore!
        // Throw an exception if the transaction isolation is being
        // changed to something different
        if (level != TRANSACTION_READ_COMMITTED) {
            throw DriverNotCapable();
        }
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#getHoldability()
     */
    public int getHoldability() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#setHoldability(int)
     */
    public void setHoldability(int arg0) throws SQLException {
        // TODO Auto-generated method stub
        
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint()
     */
    public Savepoint setSavepoint() throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#releaseSavepoint(java.sql.Savepoint)
     */
    public void releaseSavepoint(Savepoint arg0) throws SQLException {
        // TODO Auto-generated method stub
        
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#rollback(java.sql.Savepoint)
     */
    public void rollback(Savepoint arg0) throws SQLException {
        // TODO Auto-generated method stub
        
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#createStatement(int, int, int)
     */
    public Statement createStatement(int arg0, int arg1, int arg2) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#prepareCall(java.lang.String, int, int, int)
     */
    public CallableStatement prepareCall(String arg0, int arg1, int arg2, int arg3) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int)
     */
    public PreparedStatement prepareStatement(String arg0, int arg1) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int, int, int)
     */
    public PreparedStatement prepareStatement(String arg0, int arg1, int arg2, int arg3) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, int[])
     */
    public PreparedStatement prepareStatement(String arg0, int[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#setSavepoint(java.lang.String)
     */
    public Savepoint setSavepoint(String arg0) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }


    /* (non-Javadoc)
     * @see java.sql.Connection#prepareStatement(java.lang.String, java.lang.String[])
     */
    public PreparedStatement prepareStatement(String arg0, String[] arg1) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }

}
