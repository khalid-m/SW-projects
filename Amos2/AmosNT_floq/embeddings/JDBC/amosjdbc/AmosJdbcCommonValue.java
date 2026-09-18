/*
 * Created on 2004.10.02
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
public class AmosJdbcCommonValue
    extends         Object
{
   
    private Object data;
    private int internalType;

    /**
     * 
     */
    public AmosJdbcCommonValue()
    {
        data = null;
    }

    /**
     * @param s
     */
    public AmosJdbcCommonValue(String s)
    {
        data = (Object) s;
        internalType = Types.VARCHAR;
    }

    /**
     * @param i
     */
    public AmosJdbcCommonValue(int i)
    {
        data = (Object) new Integer(i);
        internalType = Types.INTEGER;
    }

    /**
     * @param i
     */
    public AmosJdbcCommonValue(Integer i)
    {
        data = (Object) i;
        internalType = Types.INTEGER;
    }

    /**
     * @param b
     */
    public AmosJdbcCommonValue(boolean b)
    {
        data = (Object) new Boolean(b);
        internalType = Types.BIT;
    }
    
    /**
     * @param b
     */
    public AmosJdbcCommonValue(double b)
    {
        data = (Object) new Double(b);
        internalType = Types.DOUBLE;
    }
    
    /**
     * @param b
     */
    public AmosJdbcCommonValue(Object b)
    {
        data = b;
        internalType = Types.OTHER;
    }

    
    /**
     * @return true if the value is null
     */
    public boolean isNull()
    {
        return (data == null);
    }

    /**
     * @return
     * @throws SQLException
     */
    public String getString()
        throws SQLException
    {
        String s;

        // A null value always returns null
        if (data == null) {
            return null;
        }

        switch(internalType) {

        case Types.VARCHAR:
            s = (String) data;
            break;

        case Types.INTEGER:
            s = ((Integer) data).toString();
            break;

        case Types.BIT:
            s= ((Boolean)data).toString();
            break;

        case Types.DOUBLE:
            s= ((Double)data).toString();
            break;
        
        case Types.OTHER:
            s= data.toString();
            break;
            
        default:
            throw new SQLException("Unable to convert data type to String: " +
                                internalType);
        }

        return s;
    }

    
    /**
     * @return
     * @throws SQLException
     */
    public int getInteger()
        throws SQLException
    {
        int i = 0;

        // A null value always returns zero
        if (data == null) {
            return 0;
        }

        switch(internalType) {

        case Types.VARCHAR:
            i = (Integer.valueOf((String) data)).intValue();
            break;

        case Types.INTEGER:
            i = ((Integer) data).intValue();
            break;
            
        case Types.BIT:
            i = ((Boolean) data).booleanValue()?1:0;
            break;
            
        case Types.DOUBLE:
            i = ((Double) data).intValue();
            break;

        default:
            throw new SQLException("Unable to convert data type to Integer: " +
                                internalType);
        }

        return i;
    }

    

    /**
     * @return
     * @throws SQLException
     */
    public boolean getBoolean()
        throws SQLException
    {
        boolean i = false;

        // A null value always returns false
        if (data == null) {
            return false;
        }

        switch(internalType) {

        case Types.VARCHAR:
            i = (Boolean.valueOf((String) data)).booleanValue();
            break;

        case Types.INTEGER:
        	{
            	if (((Integer) data).intValue()==1) i= true;
            	 	else i= false;
        	}
            break;
            
        case Types.BIT:
            i = ((Boolean) data).booleanValue();
            break;
            
        case Types.DOUBLE:
            	if (((Double) data).intValue()==1) i=true;
            	 	else i=false;
            break;

        default:
            throw new SQLException("Unable to convert data type to Boolean: " +
                                internalType);
        }

        return i;
    
    }

    /**
     * @return
     * @throws SQLException
     */
    public double getDouble()
        throws SQLException
    {
        double i = 0;

        // A null value always returns zero
        if (data == null) {
            return 0.0;
        }

        switch(internalType) {

        case Types.VARCHAR:
            i = (Double.valueOf((String) data)).doubleValue();
            break;

        case Types.INTEGER:
            i = (double)((Integer) data).intValue();
            break;
            
        case Types.BIT:
            i = (double)(((Boolean) data).booleanValue()?1:0);
            break;
            
        case Types.DOUBLE:
            i = ((Double) data).doubleValue();
            break;

        default:
            throw new SQLException("Unable to convert data type to Integer: " +
                                internalType);
        }

        return i;
    }
    
    
    /**
     * @return Data object 
     */
    public Object getObject()
    {
       return data;
    }
    

    
    
}

