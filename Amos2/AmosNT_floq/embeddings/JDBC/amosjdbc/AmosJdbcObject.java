/*
 * Created on 2004.10.30
 *
 * 
 */
package amosjdbc;

import java.sql.*;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcObject extends Object
{
    
    //--------------------------------------------------------------------
    // traceOn
    // Returns true if tracing (logging) is currently enabled
    //--------------------------------------------------------------------
    
    protected static boolean traceOn()
    {
        return (DriverManager.getLogStream() != null);
    }
    
    //--------------------------------------------------------------------
    // trace
    // Logs the given text to the logging stream provided by the
    // DriverManager
    //--------------------------------------------------------------------
    
    protected static void trace(
            String text)
    {
        if (traceOn()) {
            /** @deprecated */
            (DriverManager.getLogStream()).println(text);
        }
    }
    
 
    /**
     * @return SQLException
     */
    public SQLException DriverNotCapable()
    {
        return new SQLException ("Driver not capable");
    }
    
    /**
     * @return SQLException
     */
    public SQLException WrongAPI()
    {
        return new SQLException ("Java JDBC API 2.0 is not supported");
    }
    
    /**
     * @return SQLException
     */
    
    public SQLException DataTypeNotSupported()
    {
        return new SQLException ("Data type not supported");
    }
    
    /**
     * @return SQLException
     */
    
    public SQLException NotSupportedByDatabase()
    {
        return new SQLException ("This feature is not supported by database");
    }
    
    /**
     * @param error
     * @return SQLException
     */
    
    public SQLException DriverConnectionError(String error)
    {
        return new SQLException ("Error on database side: "+error);
    }
}
