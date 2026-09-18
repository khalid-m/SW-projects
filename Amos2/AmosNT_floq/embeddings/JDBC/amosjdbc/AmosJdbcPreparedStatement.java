/*
 * Created on 2004.10.02
 *
 * 
 */
package amosjdbc;

import java.io.InputStream;
import java.io.Reader;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.Array;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.Date;
import java.sql.ParameterMetaData;
import java.sql.PreparedStatement;
import java.sql.Ref;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Hashtable;

/**
 * @author Giedrius Povilavicius
 *
 * Implemented with help of SQL Front. As SQL prepared statements 
 * currently are not supported by AMOS II all the work will be done 
 * by JDBC driver.
 * 
 */
public class AmosJdbcPreparedStatement extends AmosJdbcStatement implements PreparedStatement {

    private String sql;
    private int NumParameters;
    private Hashtable Parameters;
    //private callin.Oid function;
    
    
    /**
     * @param sql
     * @param callinConnection
     * @param connection
     * 
     */
    public AmosJdbcPreparedStatement(String sql,callin.Connection callinConnection,AmosJdbcConnection connection) {

        //init
        super(callinConnection,connection);
        this.sql=sql;
        NumParameters=0;
        
        if (traceOn()) {
            trace("Preparing statement: "+sql);
        }

        //Parsing SQL string and counting ? signs
        for (int i=0;i<sql.length();i++)
        {
            if (sql.charAt(i)=='?') NumParameters++;
        }
        
        //initializing necessary values
        if (NumParameters!=0) 
        {
            Parameters=new Hashtable(NumParameters);
        }
        
    }
    
    
    /**
     * @see java.sql.PreparedStatement#addBatch()
     */
    public void addBatch() throws SQLException {
        throw WrongAPI();

    }


    /**
     * @see java.sql.PreparedStatement#clearParameters()
     */
    public void clearParameters() throws SQLException {
        // no operation needed

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#execute()
     */
    public synchronized boolean execute() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }

  
    /**
     * @see java.sql.PreparedStatement#executeQuery()
     */
    public synchronized ResultSet executeQuery() throws SQLException {
        if (traceOn()) {
            trace("Executing prepared query: "+sql);
        }
       
       String preparedSql=""; 
       int counter=1;
       
       for (int i=0;i<sql.length();i++)
       {
           if (sql.charAt(i)=='?') 
           {
               preparedSql=preparedSql+(String)Parameters.get(new Integer(counter));
               counter++;
           }
           else
           {
               preparedSql=preparedSql+sql.charAt(i);
           }
       }
       
       //System.out.println(preparedSql);
        
       ResultSet res = super.executeQuery(preparedSql);
       return res;
    }

  
    /**
     * @see java.sql.PreparedStatement#executeUpdate()
     */
    public synchronized int executeUpdate() throws SQLException {
        if (traceOn()) {
            trace("Executing prepared update: "+sql);
        }
       
       String preparedSql=""; 
       int counter=1;
       
       for (int i=0;i<sql.length();i++)
       {
           if (sql.charAt(i)=='?') 
           {
               preparedSql=preparedSql+(String)Parameters.get(new Integer(counter));
               counter++;
           }
           else
           {
               preparedSql=preparedSql+sql.charAt(i);
           }
       }
       
       int res = super.executeUpdate(preparedSql);
       return res;
       
    }

    /**
     * @see java.sql.PreparedStatement#getMetaData()
     */
    public ResultSetMetaData getMetaData() throws SQLException {
        throw WrongAPI();
        //return null;
    }

    /**
     * @see java.sql.PreparedStatement#setArray(int, java.sql.Array)
     */
    public void setArray(int i, Array x) throws SQLException {
        throw WrongAPI();

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setAsciiStream(int, java.io.InputStream, int)
     */
    public void setAsciiStream(int parameterIndex, InputStream x, int length)
            throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setBigDecimal(int, java.math.BigDecimal)
     */
    public void setBigDecimal(int parameterIndex, BigDecimal x)
            throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setBinaryStream(int, java.io.InputStream, int)
     */
    public void setBinaryStream(int parameterIndex, InputStream x, int length)
            throws SQLException {
        // TODO Auto-generated method stub

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setByte(int, byte)
     */
    public void setByte(int parameterIndex, byte x) throws SQLException {
        // TODO Auto-generated method stub

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setBytes(int, byte[])
     */
    public void setBytes(int parameterIndex, byte[] x) throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setBlob(int, java.sql.Blob)
     */
    public void setBlob(int i, Blob x) throws SQLException {
        throw WrongAPI();

    }

    /**
     * @see java.sql.PreparedStatement#setBoolean(int, boolean)
     */
    public void setBoolean(int parameterIndex, boolean x) throws SQLException {
        if (x)
            Parameters.put(new Integer(parameterIndex),"1");
        else
            Parameters.put(new Integer(parameterIndex),"0");
    }

    /**
     * @see java.sql.PreparedStatement#setCharacterStream(int, java.io.Reader, int)
     */
    public void setCharacterStream(int parameterIndex, Reader reader, int length)
            throws SQLException {
        throw WrongAPI();

    }

    /**
     * @see java.sql.PreparedStatement#setClob(int, java.sql.Clob)
     */
    public void setClob(int i, Clob x) throws SQLException {
        throw WrongAPI();

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setDate(int, java.sql.Date)
     */
    public void setDate(int parameterIndex, Date x) throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setDate(int, java.sql.Date, java.util.Calendar)
     */
    public void setDate(int parameterIndex, Date x, Calendar cal)
            throws SQLException {
        throw WrongAPI();

    }

    /**
     * @see java.sql.PreparedStatement#setDouble(int, double)
     */
    public void setDouble(int parameterIndex, double x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));    
    }

    /**
     * @see java.sql.PreparedStatement#setFloat(int, float)
     */
    public void setFloat(int parameterIndex, float x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));    

    }

    /**
     * @see java.sql.PreparedStatement#setInt(int, int)
     */
    public void setInt(int parameterIndex, int x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));
    }

    /**
     * @see java.sql.PreparedStatement#setLong(int, long)
     */
    public void setLong(int parameterIndex, long x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));

    }


    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setNull(int, int)
     */
    public void setNull(int parameterIndex, int sqlType) throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setNull(int, int, java.lang.String)
     */
    public void setNull(int paramIndex, int sqlType, String typeName)
            throws SQLException {
        throw WrongAPI();

    }

    /**
     * @see java.sql.PreparedStatement#setObject(int, java.lang.Object)
     */
    public void setObject(int parameterIndex, Object x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),x.toString());    
    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setObject(int, java.lang.Object, int)
     */
    public void setObject(int parameterIndex, Object x, int targetSqlType)
            throws SQLException {
        // TODO Auto-generated method stub

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setObject(int, java.lang.Object, int, int)
     */
    public void setObject(int parameterIndex, Object x, int targetSqlType,
            int scale) throws SQLException {
        // TODO Auto-generated method stub

    }


    /**
     * @see java.sql.PreparedStatement#setRef(int, java.sql.Ref)
     */
    public void setRef(int i, Ref x) throws SQLException {
        throw WrongAPI();

    }

    /**
     * @see java.sql.PreparedStatement#setShort(int, short)
     */
    public void setShort(int parameterIndex, short x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),String.valueOf(x));    
    }

    /**
     * @see java.sql.PreparedStatement#setString(int, java.lang.String)
     */
    public void setString(int parameterIndex, String x) throws SQLException {
        Parameters.put(new Integer(parameterIndex),"\'"+x+"\'");    
    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setTime(int, java.sql.Time)
     */
    public void setTime(int parameterIndex, Time x) throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setTime(int, java.sql.Time, java.util.Calendar)
     */
    public void setTime(int parameterIndex, Time x, Calendar cal)
            throws SQLException {
        throw WrongAPI();

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setTimestamp(int, java.sql.Timestamp)
     */
    public void setTimestamp(int parameterIndex, Timestamp x)
            throws SQLException {
        // TODO Auto-generated method stub

    }

    /**
     * @see java.sql.PreparedStatement#setTimestamp(int, java.sql.Timestamp, java.util.Calendar)
     */
    public void setTimestamp(int parameterIndex, Timestamp x, Calendar cal)
            throws SQLException {
        throw WrongAPI();

    }

    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setUnicodeStream(int, java.io.InputStream, int)
     */
    public void setUnicodeStream(int parameterIndex, InputStream x, int length)
            throws SQLException {
        // TODO Auto-generated method stub

    }


    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#setURL(int, java.net.URL)
     */
    public void setURL(int arg0, URL arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }


    /* (non-Javadoc)
     * @see java.sql.PreparedStatement#getParameterMetaData()
     */
    public ParameterMetaData getParameterMetaData() throws SQLException {
        // TODO Auto-generated method stub
        return null;
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
