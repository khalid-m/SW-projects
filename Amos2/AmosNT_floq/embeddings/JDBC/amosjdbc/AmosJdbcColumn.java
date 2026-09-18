


package amosjdbc;

import java.sql.ResultSetMetaData;
import java.sql.Types;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcColumn extends Object
{

    /**
     * Comment for <code>name</code>
     */
    public String name;
    /**
     * Comment for <code>type</code>
     */
    public int type;
    /**
     * Comment for <code>precision</code>
     */
    public int precision;
    /**
     * Comment for <code>scale</code>
     */
    public int scale;
    /**
     * Comment for <code>searchable</code>
     */
    public boolean searchable;
    /**
     * Comment for <code>colNo</code>
     */
    public int colNo;
    /**
     * Comment for <code>displaySize</code>
     */
    public int displaySize;
    /**
     * Comment for <code>schemaName</code>
     */
    public String schemaName;
    /**
     * Comment for <code>tableName</code>
     */
    public String tableName;
    /**
     * Comment for <code>typeName</code>
     */
    public String typeName;
    /**
     * Comment for <code>autoIncrement</code>
     */
    public boolean autoIncrement;
    /**
     * Comment for <code>caseSensitive</code>
     */
    public boolean caseSensitive;
    /**
     * Comment for <code>currency</code>
     */
    public boolean currency;
    /**
     * Comment for <code>definitelyWritable</code>
     */
    public boolean definitelyWritable;
    /**
     * Comment for <code>readOnly</code>
     */
    public boolean readOnly;
    /**
     * Comment for <code>writable</code>
     */
    public boolean writable;
    /**
     * Comment for <code>signed</code>
     */
    public boolean signed;
    /**
     * Comment for <code>nullable</code>
     */
    public int nullable;
    /**
     * @param colNo
     * @param name
     */
    public AmosJdbcColumn(
        int colNo,
        String name)
    {
        this.name = name;
        this.type = Types.OTHER;
        this.typeName=new String("OTHER");
        this.colNo = colNo;
        this.precision = 0;
        this.scale = 0;
        this.displaySize = 10;
        this.schemaName = new String("");
        this.tableName = new String("");
        this.autoIncrement=false;
        this.caseSensitive=false;
        this.currency=false;
        this.definitelyWritable=false;
        this.nullable = ResultSetMetaData.columnNullableUnknown;
        this.searchable=false;
        this.readOnly=false;
        this.writable=false;
        this.signed=false;
    }   
 
}

