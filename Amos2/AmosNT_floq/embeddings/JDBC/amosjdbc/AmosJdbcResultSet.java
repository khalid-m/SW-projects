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
import java.sql.Ref;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.SQLWarning;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Map;
import callin.*;


/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcResultSet extends AmosJdbcObject implements ResultSet {
    
    private Scan scan;
    private boolean BeforeFirstRow;
    private int NumColumns=0;
    private Hashtable columns;
    private int sentenceType;
    
    /**
     * @param scan
     */
    public AmosJdbcResultSet(Scan scan, int sentenceType) {
        
        //init
        this.scan = scan;
        this.sentenceType=sentenceType;
        
        try {
            //creating column information only if there 
            //is at least one result line
            if (scan.eos()==false)
            {
              	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
              		NumColumns = scan.getRow().getArity();
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	NumColumns = scan.getRow().getSeqElem(0).getArity();
                }
                
                columns = new Hashtable(); 
                AmosJdbcColumn column;
                String typename=null;
                                
                for (int i=1;i<=NumColumns;i++)
                {
                    column= new AmosJdbcColumn(i,"Column "+i);
                    
                    if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                    {
                    	typename=scan.getRow().getOidElem(i-1).getTypename();
                    }
                    else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                    {
                    	typename=scan.getRow().getSeqElem(0).getOidElem(i-1).getTypename();
                    }
                    
                                        
                    if (typename.equalsIgnoreCase("CHARSTRING"))
                    {
                        column.type=Types.VARCHAR; 
                        column.typeName="VARCHAR";
                        column.displaySize =AmosJdbcDefine.MAX_VARCHAR_LEN;
                        column.scale=0;
                    }
                    else if (typename.equalsIgnoreCase("INTEGER"))
                    {
                        column.type=Types.INTEGER;
                        column.typeName="INTEGER";
                        column.displaySize=11;
                        column.precision=10;
                        column.signed=true;
                                                
                    }
                    else if (typename.equalsIgnoreCase("REAL"))
                    {
                        column.type=Types.DOUBLE;
                        column.typeName="DOUBLE";
                        column.displaySize=22;
                        column.precision=53;
                        column.signed=true;
                    }
                    else if (typename.equalsIgnoreCase("BOOLEAN"))
                    {
                        column.type=Types.BIT;
                        column.typeName="BOOLEAN";
                        column.displaySize=6;
                    }
                                        
                    columns.put(new Integer(i),column);
                    
                }
            }
        } catch (AmosException e) {
            //FIXME
            e.printStackTrace();
        }
        
        BeforeFirstRow=true;
    }
    
    /**
     * @see java.sql.ResultSet#absolute(int)
     */
    public boolean absolute(int row) throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#afterLast()
     */
    public void afterLast() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#beforeFirst()
     */
    public void beforeFirst() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#cancelRowUpdates()
     */
    public void cancelRowUpdates() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#clearWarnings()
     */
    public void clearWarnings() throws SQLException {
        // not implemented
    }
    
    /**
     * @see java.sql.ResultSet#close()
     */
    public void close() throws SQLException {
        
        try {
            scan.closeScan();
        } catch (AmosException e) {
            
            throw new SQLException(e.toString());
        }
    }
    
    /**
     * @see java.sql.ResultSet#deleteRow()
     */
    public void deleteRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#findColumn(java.lang.String)
     */
    public int findColumn(String columnName) throws SQLException {
        int index=0;
        AmosJdbcColumn column;
        
        if (traceOn()) {
            trace("Finding column: \""+columnName+"\"");
        }
        
        Enumeration columnList = columns.elements();
        while (columnList.hasMoreElements())
        {
            
            column = (AmosJdbcColumn) columnList.nextElement();
            if (column.name.equalsIgnoreCase(columnName)) 
            {
                index=column.colNo;
                break;
            }
        }
        
        if (index==0) throw new SQLException("Column \""+columnName+"\" not found" ); 
        
        return index;
    }
    
    /**
     * @see java.sql.ResultSet#first()
     */
    public boolean first() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#getArray(int)
     */
    public Array getArray(int i) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getArray(java.lang.String)
     */
    public Array getArray(String colName) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getAsciiStream(int)
     */
    public InputStream getAsciiStream(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getAsciiStream(java.lang.String)
     */
    public InputStream getAsciiStream(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getBigDecimal(int)
     */
    public BigDecimal getBigDecimal(int columnIndex) throws SQLException {
        return new BigDecimal(getDouble(columnIndex)); 
    }
    
    /**
     * @see java.sql.ResultSet#getBigDecimal(int, int)
     */
    public BigDecimal getBigDecimal(int columnIndex, int scale)
    throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getBigDecimal(java.lang.String)
     */
    public BigDecimal getBigDecimal(String columnName) throws SQLException {
        return new BigDecimal(getDouble(columnName));
    }
    
    /**
     * @see java.sql.ResultSet#getBigDecimal(java.lang.String, int)
     */
    public BigDecimal getBigDecimal(String columnName, int scale)
    throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getBinaryStream(int)
     */
    public InputStream getBinaryStream(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getBinaryStream(java.lang.String)
     */
    public InputStream getBinaryStream(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getByte(int)
     */
    public byte getByte(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getByte(java.lang.String)
     */
    public byte getByte(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getBytes(int)
     */
    public byte[] getBytes(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getBytes(java.lang.String)
     */
    public byte[] getBytes(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getBlob(int)
     */
    public Blob getBlob(int i) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getBlob(java.lang.String)
     */
    public Blob getBlob(String colName) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getBoolean(int)
     */
    public boolean getBoolean(int columnIndex) throws SQLException {
        if (traceOn()) {
            trace("Getting boolean "+columnIndex+" from current row");
        }
        
        Tuple tuple;
        boolean result;
        AmosJdbcCommonValue value = null;
        
        try {
            tuple = scan.getRow();
            value = getValue(tuple, (columnIndex-1));
            result = value.getBoolean();
            
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }
        
        return result;
    }
    
    /**
     * @see java.sql.ResultSet#getBoolean(java.lang.String)
     */
    public boolean getBoolean(String columnName) throws SQLException {
        if (traceOn()) {
            trace("Getting boolean \""+columnName+"\" from current row");
        }
        return getBoolean(findColumn(columnName));
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getCharacterStream(int)
     */
    public Reader getCharacterStream(int columnIndex) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getCharacterStream(java.lang.String)
     */
    public Reader getCharacterStream(String columnName) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getClob(int)
     */
    public Clob getClob(int i) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getClob(java.lang.String)
     */
    public Clob getClob(String colName) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getConcurrency()
     */
    public int getConcurrency() throws SQLException {
        throw WrongAPI();
        //return 0;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getCursorName()
     */
    public String getCursorName() throws SQLException {
        throw DriverNotCapable();
    }
    
    /**
     * @see java.sql.ResultSet#getDate(int)
     */
    public Date getDate(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getDate(int, java.util.Calendar)
     */
    public Date getDate(int columnIndex, Calendar cal) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getDate(java.lang.String)
     */
    public Date getDate(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getDate(java.lang.String, java.util.Calendar)
     */
    public Date getDate(String columnName, Calendar cal) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getDouble(int)
     */
    public double getDouble(int columnIndex) throws SQLException {
        if (traceOn()) {
            trace("Getting double "+columnIndex+" from current row");
        }
        
        Tuple tuple;
        double result=0.0;
        AmosJdbcCommonValue value =null;
        
        try {
            tuple = scan.getRow();
            value = getValue(tuple, (columnIndex-1));
            result = value.getDouble();
         
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }
        
        return result;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getDouble(java.lang.String)
     */
    public double getDouble(String columnName) throws SQLException {
        
        if (traceOn()) {
            trace("Getting double \""+columnName+"\" from current row");
        }
        return getDouble(findColumn(columnName));
    }
    
    /**
     * @see java.sql.ResultSet#getFetchDirection()
     */
    public int getFetchDirection() throws SQLException {
        throw WrongAPI();
        //return 0;
    }
    
    /**
     * @see java.sql.ResultSet#getFetchSize()
     */
    public int getFetchSize() throws SQLException {
        throw WrongAPI();
        //return 0;
    }
    
    /**
     * @see java.sql.ResultSet#getFloat(int)
     */
    public float getFloat(int columnIndex) throws SQLException {
        return (float)getDouble(columnIndex);
    }
    
    /**
     * @see java.sql.ResultSet#getFloat(java.lang.String)
     */
    public float getFloat(String columnName) throws SQLException {
        return (float)getDouble(columnName);
    }
    
    /**
     * @see java.sql.ResultSet#getInt(int)
     */
    public int getInt(int columnIndex) throws SQLException {
        if (traceOn()) {
            trace("Getting int "+columnIndex+" from current row");
        }
        
        Tuple tuple;
        int result=0;
        AmosJdbcCommonValue value=null;
        
        try {
            tuple = scan.getRow();
            value = getValue(tuple, (columnIndex-1));
            result = value.getInteger();
            
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }
        
        return result;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getInt(java.lang.String)
     */
    public int getInt(String columnName) throws SQLException {
        
        if (traceOn()) {
            trace("Getting int \""+columnName+"\" from current row");
        }
        
        return getInt(findColumn(columnName));
    }
    
    /**
     * @see java.sql.ResultSet#getLong(int)
     */
    public long getLong(int columnIndex) throws SQLException {
       
        return (long) getInt(columnIndex);
    }
    
    /**
     * @see java.sql.ResultSet#getLong(java.lang.String)
     */
    public long getLong(String columnName) throws SQLException {
        if (traceOn()) {
            trace("Getting long \""+columnName+"\" from current row");
        }
        
        return getInt(findColumn(columnName));
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getMetaData()
     */
    public ResultSetMetaData getMetaData() throws SQLException {
        
        return new AmosJdbcResultSetMetaData(columns);
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getObject(int)
     */
    public Object getObject(int columnIndex) throws SQLException {
        if (traceOn()) {
            trace("Getting Object "+columnIndex+" from current row");
        }
        
        Tuple tuple;
        Object result;
        AmosJdbcCommonValue value= null;
        
        try {
            tuple = scan.getRow();
            value = getValue(tuple, (columnIndex-1));
            result = value.getObject();
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }
        
        return result;
    }
    
    /**
     * @see java.sql.ResultSet#getObject(int, java.util.Map)
     */
    public Object getObject(int i, Map map) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getObject(java.lang.String)
     */
    public Object getObject(String columnName) throws SQLException {
        if (traceOn()) {
            trace("Getting Object from column \""+columnName+"\"");
        }
        return getObject(findColumn(columnName));
    }
    
    /**
     * @see java.sql.ResultSet#getObject(java.lang.String, java.util.Map)
     */
    public Object getObject(String colName, Map map) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getRef(int)
     */
    public Ref getRef(int i) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getRef(java.lang.String)
     */
    public Ref getRef(String colName) throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getRow()
     */
    public int getRow() throws SQLException {
        throw WrongAPI();
        //return 0;
    }
    
    /**
     * @see java.sql.ResultSet#getShort(int)
     */
    public short getShort(int columnIndex) throws SQLException {
        return (short) getInt(columnIndex);
    }
    
    /**
     * @see java.sql.ResultSet#getShort(java.lang.String)
     */
    public short getShort(String columnName) throws SQLException {
        return (short) getInt(columnName);
    }
    
    /**
     * @see java.sql.ResultSet#getStatement()
     */
    public Statement getStatement() throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getString(int)
     */
    public String getString(int columnIndex) throws SQLException {
        if (traceOn()) {
            trace("Getting string "+columnIndex+" from current row");
        }
        
        Tuple tuple;
        String result=null;
        AmosJdbcCommonValue value=null;
        
        try {
            tuple = scan.getRow();
            value = getValue(tuple, (columnIndex-1));
            result = value.getString();
            
        } catch (AmosException e) {
            throw new SQLException(e.toString());
        }
        
        return result;
    }
    
    /**
     * @see java.sql.ResultSet#getString(java.lang.String)
     */
    public String getString(String columnName) throws SQLException {
        
        if (traceOn()) {
            trace("Getting String from column \""+columnName+"\"");
        }
        return getString(findColumn(columnName));
    }
    
    /**
     * @see java.sql.ResultSet#getTime(int)
     */
    public Time getTime(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getTime(int, java.util.Calendar)
     */
    public Time getTime(int columnIndex, Calendar cal) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getTime(java.lang.String)
     */
    public Time getTime(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getTime(java.lang.String, java.util.Calendar)
     */
    public Time getTime(String columnName, Calendar cal) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getTimestamp(int)
     */
    public Timestamp getTimestamp(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getTimestamp(int, java.util.Calendar)
     */
    public Timestamp getTimestamp(int columnIndex, Calendar cal)
    throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     *  
     * @see java.sql.ResultSet#getTimestamp(java.lang.String)
     */
    public Timestamp getTimestamp(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * 
     * @see java.sql.ResultSet#getTimestamp(java.lang.String, java.util.Calendar)
     */
    public Timestamp getTimestamp(String columnName, Calendar cal)
    throws SQLException {
        throw WrongAPI();
        //return null;
    }
    
    /**
     * @see java.sql.ResultSet#getType()
     */
    public int getType() throws SQLException {
        throw WrongAPI();
        //return 0;
    }
    
    /**
     * @param columnIndex
     * @return
     * @throws SQLException
     * 
     * @see java.sql.ResultSet#getUnicodeStream(java.lang.String)
     */
    public InputStream getUnicodeStream(int columnIndex) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getUnicodeStream(java.lang.String)
     */
    public InputStream getUnicodeStream(String columnName) throws SQLException {
        throw DataTypeNotSupported();
    }
    
    /**
     * @see java.sql.ResultSet#getWarnings()
     */
    public SQLWarning getWarnings() throws SQLException {
        
        return null;
    }
    
    /**
     * @see java.sql.ResultSet#insertRow()
     */
    public void insertRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#isAfterLast()
     */
    public boolean isAfterLast() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#isBeforeFirst()
     */
    public boolean isBeforeFirst() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#isFirst()
     */
    public boolean isFirst() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#isLast()
     */
    public boolean isLast() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#last()
     */
    public boolean last() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#moveToCurrentRow()
     */
    public void moveToCurrentRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#moveToInsertRow()
     */
    public void moveToInsertRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#next()
     */
    public boolean next() throws SQLException {
        if (traceOn()) {
            trace("Next row");
        }
        
        if (scan.eos()==false) 
        {
            try {
                if (!BeforeFirstRow)
                {
                    scan.nextRow();
                }
                else BeforeFirstRow=false;
                if (scan.eos()) return false;
                return true;
            } catch (AmosException e) {
                throw new SQLException("s"+e.toString());
            }
            
        }
        return false;
    }
    
    /**
     * @see java.sql.ResultSet#previous()
     */
    public boolean previous() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#refreshRow()
     */
    public void refreshRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#relative(int)
     */
    public boolean relative(int rows) throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#rowDeleted()
     */
    public boolean rowDeleted() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#rowInserted()
     */
    public boolean rowInserted() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#rowUpdated()
     */
    public boolean rowUpdated() throws SQLException {
        throw WrongAPI();
        //return false;
    }
    
    /**
     * @see java.sql.ResultSet#setFetchDirection(int)
     */
    public void setFetchDirection(int direction) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#setFetchSize(int)
     */
    public void setFetchSize(int rows) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateAsciiStream(int, java.io.InputStream, int)
     */
    public void updateAsciiStream(int columnIndex, InputStream x, int length)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateAsciiStream(java.lang.String, java.io.InputStream, int)
     */
    public void updateAsciiStream(String columnName, InputStream x, int length)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBigDecimal(int, java.math.BigDecimal)
     */
    public void updateBigDecimal(int columnIndex, BigDecimal x)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBigDecimal(java.lang.String, java.math.BigDecimal)
     */
    public void updateBigDecimal(String columnName, BigDecimal x)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBinaryStream(int, java.io.InputStream, int)
     */
    public void updateBinaryStream(int columnIndex, InputStream x, int length)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBinaryStream(java.lang.String, java.io.InputStream, int)
     */
    public void updateBinaryStream(String columnName, InputStream x, int length)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateByte(int, byte)
     */
    public void updateByte(int columnIndex, byte x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateByte(java.lang.String, byte)
     */
    public void updateByte(String columnName, byte x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBytes(int, byte[])
     */
    public void updateBytes(int columnIndex, byte[] x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBytes(java.lang.String, byte[])
     */
    public void updateBytes(String columnName, byte[] x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBoolean(int, boolean)
     */
    public void updateBoolean(int columnIndex, boolean x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateBoolean(java.lang.String, boolean)
     */
    public void updateBoolean(String columnName, boolean x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateCharacterStream(int, java.io.Reader, int)
     */
    public void updateCharacterStream(int columnIndex, Reader x, int length)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateCharacterStream(java.lang.String, java.io.Reader, int)
     */
    public void updateCharacterStream(String columnName, Reader reader,
            int length) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateDate(int, java.sql.Date)
     */
    public void updateDate(int columnIndex, Date x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateDate(java.lang.String, java.sql.Date)
     */
    public void updateDate(String columnName, Date x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateDouble(int, double)
     */
    public void updateDouble(int columnIndex, double x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateDouble(java.lang.String, double)
     */
    public void updateDouble(String columnName, double x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateFloat(int, float)
     */
    public void updateFloat(int columnIndex, float x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateFloat(java.lang.String, float)
     */
    public void updateFloat(String columnName, float x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateInt(int, int)
     */
    public void updateInt(int columnIndex, int x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateInt(java.lang.String, int)
     */
    public void updateInt(String columnName, int x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateLong(int, long)
     */
    public void updateLong(int columnIndex, long x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateLong(java.lang.String, long)
     */
    public void updateLong(String columnName, long x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateNull(int)
     */
    public void updateNull(int columnIndex) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateNull(java.lang.String)
     */
    public void updateNull(String columnName) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateObject(int, java.lang.Object)
     */
    public void updateObject(int columnIndex, Object x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateObject(int, java.lang.Object, int)
     */
    public void updateObject(int columnIndex, Object x, int scale)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateObject(java.lang.String, java.lang.Object)
     */
    public void updateObject(String columnName, Object x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateObject(java.lang.String, java.lang.Object, int)
     */
    public void updateObject(String columnName, Object x, int scale)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateRow()
     */
    public void updateRow() throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateShort(int, short)
     */
    public void updateShort(int columnIndex, short x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * @see java.sql.ResultSet#updateShort(java.lang.String, short)
     */
    public void updateShort(String columnName, short x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateString(int, java.lang.String)
     */
    public void updateString(int columnIndex, String x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateString(java.lang.String, java.lang.String)
     */
    public void updateString(String columnName, String x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateTime(int, java.sql.Time)
     */
    public void updateTime(int columnIndex, Time x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateTime(java.lang.String, java.sql.Time)
     */
    public void updateTime(String columnName, Time x) throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateTimestamp(int, java.sql.Timestamp)
     */
    public void updateTimestamp(int columnIndex, Timestamp x)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#updateTimestamp(java.lang.String, java.sql.Timestamp)
     */
    public void updateTimestamp(String columnName, Timestamp x)
    throws SQLException {
        throw WrongAPI();
        
    }
    
    /**
     * 
     * @see java.sql.ResultSet#wasNull()
     */
    public boolean wasNull() throws SQLException {
        //look like AMOS returns row only if its not equal nil
        return false;
    }
    
    private AmosJdbcCommonValue getValue(Tuple tuple, int index)
    {
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(index+1));
        AmosJdbcCommonValue value = null; 
        
        try {
            switch (col.type)
            {
            case Types.INTEGER:
              	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
                	value = new AmosJdbcCommonValue(tuple.getIntElem(index));
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	value = new AmosJdbcCommonValue(tuple.getSeqElem(0).getIntElem(index));
                }
                
            break;
            case Types.VARCHAR:
            	
            	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
                	value = new AmosJdbcCommonValue(tuple.getStringElem(index));
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	value = new AmosJdbcCommonValue(tuple.getSeqElem(0).getStringElem(index));
                }
            	
            break;
            case Types.DOUBLE:
             	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
                	value = new AmosJdbcCommonValue(tuple.getDoubleElem(index));
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	value = new AmosJdbcCommonValue(tuple.getSeqElem(0).getDoubleElem(index));
                }
            break;
            case Types.BIT:
             	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
                	value = new AmosJdbcCommonValue(tuple.getbooleanElem(index));
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	value = new AmosJdbcCommonValue(tuple.getSeqElem(0).getbooleanElem(index));
                }
            break;
            case Types.OTHER:
             	if (sentenceType==AmosJdbcDefine.sentenceAMOSQL)
                {
                	value = new AmosJdbcCommonValue(tuple.getElem(index));
                }
                else if (sentenceType==AmosJdbcDefine.sentenceSQLFront)
                {
                	value = new AmosJdbcCommonValue(tuple.getSeqElem(0).getElem(index));
                }
                
            break;
            
            default:
                
            }
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        return value;
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#getURL(int)
     */
    public URL getURL(int arg0) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateArray(int, java.sql.Array)
     */
    public void updateArray(int arg0, Array arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateBlob(int, java.sql.Blob)
     */
    public void updateBlob(int arg0, Blob arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateClob(int, java.sql.Clob)
     */
    public void updateClob(int arg0, Clob arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateRef(int, java.sql.Ref)
     */
    public void updateRef(int arg0, Ref arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#getURL(java.lang.String)
     */
    public URL getURL(String arg0) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateArray(java.lang.String, java.sql.Array)
     */
    public void updateArray(String arg0, Array arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateBlob(java.lang.String, java.sql.Blob)
     */
    public void updateBlob(String arg0, Blob arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateClob(java.lang.String, java.sql.Clob)
     */
    public void updateClob(String arg0, Clob arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }

    /* (non-Javadoc)
     * @see java.sql.ResultSet#updateRef(java.lang.String, java.sql.Ref)
     */
    public void updateRef(String arg0, Ref arg1) throws SQLException {
        // TODO Auto-generated method stub
        
    }
    
}
