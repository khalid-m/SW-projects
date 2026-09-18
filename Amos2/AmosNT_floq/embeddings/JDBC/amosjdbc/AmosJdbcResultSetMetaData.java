/*
 * Created on 2004.10.02
 *
 * 
 */
package amosjdbc;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Hashtable;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcResultSetMetaData extends AmosJdbcObject implements ResultSetMetaData {

    
    private Hashtable columns;
    
    /**
     * @param columns
     * 
     */
    public AmosJdbcResultSetMetaData(Hashtable columns) {
        //init
        this.columns=columns;
        
    }
    
    /**
     * @see java.sql.ResultSetMetaData#getCatalogName(int)
     */
    public String getCatalogName(int column) throws SQLException {
        throw DriverNotCapable();
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnClassName(int)
     */
    public String getColumnClassName(int column) throws SQLException {
        throw WrongAPI();
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnCount()
     */
    public int getColumnCount() throws SQLException {
        return columns.size();
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnDisplaySize(int)
     */
    public int getColumnDisplaySize(int column) throws SQLException {
        //Not supported so allways returning 10
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.displaySize;
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnLabel(int)
     */
    public String getColumnLabel(int column) throws SQLException {
        //Not supported so returning column name
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.name;
    }

    /**
     * 
     * @see java.sql.ResultSetMetaData#getColumnName(int)
     */
    public String getColumnName(int column) throws SQLException {
        
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.name;
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnType(int)
     */
    public int getColumnType(int column) throws SQLException {
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.type;
    }

    /**
     * @see java.sql.ResultSetMetaData#getColumnTypeName(int)
     */
    public String getColumnTypeName(int column) throws SQLException {
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.typeName;
    }

    /**
     * @see java.sql.ResultSetMetaData#getPrecision(int)
     */
    public int getPrecision(int column) throws SQLException {
        //not supported. allways set to 0
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.precision;
    }

    /**
     * @see java.sql.ResultSetMetaData#getScale(int)
     */
    public int getScale(int column) throws SQLException {
        //not supported. allways set to 0
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.scale;
        
    }

    /**
     * @see java.sql.ResultSetMetaData#getSchemaName(int)
     */
    public String getSchemaName(int column) throws SQLException {
        //Not supported so allways returning ""
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.schemaName;
    }

    /**
     * @see java.sql.ResultSetMetaData#getTableName(int)
     */
    public String getTableName(int column) throws SQLException {
        //Not supported so allways returning ""
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.tableName;
    }

    /**
     * @see java.sql.ResultSetMetaData#isAutoIncrement(int)
     */
    public boolean isAutoIncrement(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.autoIncrement;
    }

    /**
     * @see java.sql.ResultSetMetaData#isCaseSensitive(int)
     */
    public boolean isCaseSensitive(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.caseSensitive;
    }

    /**
     * @see java.sql.ResultSetMetaData#isCurrency(int)
     */
    public boolean isCurrency(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.currency;
    }

    /**
     * @see java.sql.ResultSetMetaData#isDefinitelyWritable(int)
     */
    public boolean isDefinitelyWritable(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.definitelyWritable;
    }

    /**
     * @see java.sql.ResultSetMetaData#isNullable(int)
     */
    public int isNullable(int column) throws SQLException {
        //Not supported so allways returning columnNullableUnknown
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.nullable;
    }

    /**
     * @see java.sql.ResultSetMetaData#isReadOnly(int)
     */
    public boolean isReadOnly(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.readOnly;
    }

    /**
     * @see java.sql.ResultSetMetaData#isSearchable(int)
     */
    public boolean isSearchable(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.searchable;
    }

    /**
     * @see java.sql.ResultSetMetaData#isSigned(int)
     */
    public boolean isSigned(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.signed;
    }

    /**
     * @see java.sql.ResultSetMetaData#isWritable(int)
     */
    public boolean isWritable(int column) throws SQLException {
        //Not supported so allways returning false
        AmosJdbcColumn col = (AmosJdbcColumn) columns.get(new Integer(column));
        return col.writable;
    }

}
