/*
 * Created on 2004.10.03
 *
 * 
 */
package amosjdbc;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Hashtable;

import callin.AmosException;
import callin.Scan;
import callin.Tuple;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcDatabaseMetaData extends AmosJdbcObject implements DatabaseMetaData {
    
    callin.Connection connection=null;
    String url=null;
    
    
    /**
     * Constructor
     * @param conn
     * @param url
     */
    public AmosJdbcDatabaseMetaData(callin.Connection conn, String url) {
        
        //init
        connection=conn;
        this.url=url;
        
    }
    
    
    
    /**
     * @see java.sql.DatabaseMetaData#allProceduresAreCallable()
     */
    public boolean allProceduresAreCallable() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#allTablesAreSelectable()
     */
    public boolean allTablesAreSelectable() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#dataDefinitionCausesTransactionCommit()
     */
    public boolean dataDefinitionCausesTransactionCommit() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#dataDefinitionIgnoredInTransactions()
     */
    public boolean dataDefinitionIgnoredInTransactions() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#deletesAreDetected(int)
     */
    public boolean deletesAreDetected(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#doesMaxRowSizeIncludeBlobs()
     */
    public boolean doesMaxRowSizeIncludeBlobs() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getBestRowIdentifier(java.lang.String, java.lang.String, java.lang.String, int, boolean)
     */
    public ResultSet getBestRowIdentifier(String catalog, String schema,
            String table, int scope, boolean nullable) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getCatalogs()
     */
    public ResultSet getCatalogs() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getCatalogSeparator()
     */
    public String getCatalogSeparator() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getCatalogTerm()
     */
    public String getCatalogTerm() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getColumnPrivileges(java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getColumnPrivileges(String catalog, String schema,
            String table, String columnNamePattern) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getColumns(java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getColumns(String catalog, String schemaPattern,
            String tableNamePattern, String columnNamePattern)
    throws SQLException {
        
        //creating temporary table
        try {
            //for getColumns
            connection.execute("create type metadataColumns;");
            connection.execute("create function TABLE_CAT(metadataColumns)->charstring as stored;");
            connection.execute("create function TABLE_SCHEM(metadataColumns)->charstring as stored;");
            connection.execute("create function TABLE_NAME(metadataColumns)->charstring as stored;");
            connection.execute("create function COLUMN_NAME(metadataColumns)->charstring as stored;");
            connection.execute("create function DATA_TYPE(metadataColumns)->integer as stored;");
            connection.execute("create function TYPE_NAME(metadataColumns)->charstring as stored;");
            connection.execute("create function COLUMN_SIZE(metadataColumns)->integer as stored;");
            connection.execute("create function BUFFER_LENGTH(metadataColumns)->charstring as stored;");
            connection.execute("create function DECIMAL_DIGITS(metadataColumns)->integer as stored;");
            connection.execute("create function NUM_PREC_RADIX(metadataColumns)->integer as stored;");
            connection.execute("create function NULLABLE(metadataColumns)->integer as stored;");
            connection.execute("create function REMARKS(metadataColumns)->charstring as stored;");
            connection.execute("create function COLUMN_DEF(metadataColumns)->charstring as stored;");
            connection.execute("create function SQL_DATA_TYPE(metadataColumns)->integer as stored;");
            connection.execute("create function SQL_DATETIME_SUB(metadataColumns)->integer as stored;");
            connection.execute("create function CHAR_OCTET_LENGTH(metadataColumns)->integer as stored;");
            connection.execute("create function ORDINAL_POSITION(metadataColumns)->integer as stored;");
            connection.execute("create function IS_NULLABLE(metadataColumns)->charstring as stored;");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        //getting list of tables which match patterns
        Scan scan=null;
        callin.Oid func;
        Tuple result;
        
        try {
            
            String currentSchema = connection.execute("sql_schema();").getRow().getStringElem(0);
            String sql="select name(f) from function f where like(name(f),'*"
                +convertPattern(schemaPattern)+"#"+convertPattern(tableNamePattern)
                +"->*') and kindoffunction(f)=\"stored\";";
            
            scan = connection.execute(sql);
            
            AmosJdbcResultSet res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
            String data,beforehash,afterhash,schema,table;
            int i=1;
            while(res.next())
            {
                //analysing results and getting schema with table names
                data=res.getString(1);
                int hash=data.indexOf('#');
                beforehash=data.substring(0,hash);
                afterhash=data.substring(hash+1);
                schema=data.substring(beforehash.lastIndexOf('.')+1,hash);
                table=afterhash.substring(0,afterhash.indexOf('-'));
                
                //Getting columns for matching tables and schemas
                //System.out.println(schema+" " + table);
                //System.out.println("sql(\"schema "+schema+"\");");
                
                if (schema.equals("")==true)
                    connection.execute("sql(\"schema default\");");
                else
                    connection.execute("sql(\"schema "+schema+"\");");
                
                String columnName,columnType,typeName="";
                int dataType=0;
                
                //getting key columns
                scan = connection.execute("sql_key_columns(\""+table+"\");");
                while (scan.eos()==false)
                {
                    columnName=scan.getRow().getStringElem(0);
                    
                    if (patternMatch(columnName,columnNamePattern))
                    {
                        columnType= scan.getRow().getStringElem(1);
                        //getting data type and type name
                        if (columnType.equals("INTEGER"))
                        {
                            dataType = Types.INTEGER;
                            typeName = columnType;
                        }
                        else if (columnType.equals("VARCHAR"))
                        {
                            dataType = Types.VARCHAR;
                            typeName = columnType;
                        }
                        else if (columnType.equals("FLOAT"))
                        {
                            dataType = Types.DOUBLE;
                            typeName = "DOUBLE";
                        }
                        else
                        {
                            System.out.println(columnType);
                        }
                        
                        //adding to table
                        connection.execute("create metadataColumns (TABLE_CAT, TABLE_SCHEM, TABLE_NAME, COLUMN_NAME," +
                                " DATA_TYPE, TYPE_NAME, COLUMN_SIZE, BUFFER_LENGTH, DECIMAL_DIGITS, NUM_PREC_RADIX," +
                                " NULLABLE, REMARKS, COLUMN_DEF, SQL_DATA_TYPE, SQL_DATETIME_SUB, CHAR_OCTET_LENGTH," +
                                " ORDINAL_POSITION, IS_NULLABLE ) instances :r"+
                                i+" (\"\",\""+schema+"\",\""+
                                table+"\",\""+columnName+"\"," +
                                dataType+",\""+typeName+
                                "\", 1024,\"\",0,10, "+ columnNoNulls +",\"\",\"\",0,0,1024,0,\"NO\");");
                        
                        i++;
                    }
                    scan.nextRow();
                    
                }
                
                //getting nonkey columns
                scan = connection.execute("sql_nonkey_columns(\""+table+"\");");
                while (scan.eos()==false)
                {
                    columnName=scan.getRow().getStringElem(0);
                    
                    if (patternMatch(columnName,columnNamePattern))
                    {
                        columnType= scan.getRow().getStringElem(1);
                        //getting data type and type name
                        if (columnType.equals("INTEGER"))
                        {
                            dataType = Types.INTEGER;
                            typeName = columnType;
                        }
                        else if (columnType.equals("VARCHAR"))
                        {
                            dataType = Types.VARCHAR;
                            typeName = columnType;
                        }
                        else if (columnType.equals("FLOAT"))
                        {
                            dataType = Types.DOUBLE;
                            typeName = "DOUBLE";
                        }
                        else
                        {
                            System.out.println(columnType);
                        }
                        
                        //adding to table
                        connection.execute("create metadataColumns (TABLE_CAT, TABLE_SCHEM, TABLE_NAME, COLUMN_NAME," +
                                " DATA_TYPE, TYPE_NAME, COLUMN_SIZE, BUFFER_LENGTH, DECIMAL_DIGITS, NUM_PREC_RADIX," +
                                " NULLABLE, REMARKS, COLUMN_DEF, SQL_DATA_TYPE, SQL_DATETIME_SUB, CHAR_OCTET_LENGTH," +
                                " ORDINAL_POSITION, IS_NULLABLE ) instances :r"+
                                i+" (\"\",\""+schema+"\",\""+
                                table+"\",\""+columnName+"\"," +
                                dataType+",\""+typeName+
                                "\", 1024,\"\",0,10, "+ columnNoNulls +",\"\",\"\",0,0,1024,0,\"NO\");");
                        
                        i++;
                    }
                    scan.nextRow();
                    
                }
            }
            
            scan=connection.execute("select TABLE_CAT(t), TABLE_SCHEM(t), TABLE_NAME(t)," +
                    " COLUMN_NAME(t), DATA_TYPE(t), TYPE_NAME(t), COLUMN_SIZE(t), BUFFER_LENGTH(t)," +
                    " DECIMAL_DIGITS(t), NUM_PREC_RADIX(t), NULLABLE(t), REMARKS(t), COLUMN_DEF(t)," +
                    " SQL_DATA_TYPE(t), SQL_DATETIME_SUB(t), CHAR_OCTET_LENGTH(t), ORDINAL_POSITION(t)," +
            " IS_NULLABLE(t) from metadataColumns t;");
            
            //destroys temporary objects in AMOS database
            connection.execute("delete type metadataColumns;");
            //restoring original schema
            connection.execute("sql(\"schema "+currentSchema+"\");");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
        
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getConnection()
     */
    public Connection getConnection() throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getCrossReference(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getCrossReference(String primaryCatalog,
            String primarySchema, String primaryTable, String foreignCatalog,
            String foreignSchema, String foreignTable) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDatabaseProductName()
     */
    public String getDatabaseProductName() throws SQLException {
        return AmosJdbcDefine.DBMS_NAME;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDatabaseProductVersion()
     */
    public String getDatabaseProductVersion() throws SQLException {
        
        String version;
        try {
            version = connection.execute("AMOS_VERSION();").getRow().getStringElem(0);
        } catch (AmosException e) {
            throw DriverConnectionError(e.getMessage());
        }
        return version;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDefaultTransactionIsolation()
     */
    public int getDefaultTransactionIsolation() throws SQLException {
        return Connection.TRANSACTION_SERIALIZABLE;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDriverMajorVersion()
     */
    public int getDriverMajorVersion() {
        return AmosJdbcDefine.MAJOR_VERSION;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDriverMinorVersion()
     */
    public int getDriverMinorVersion() {
        return AmosJdbcDefine.MINOR_VERSION;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDriverName()
     */
    public String getDriverName() throws SQLException {
        return "amosjdbc.AmosJdbcDriver";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getDriverVersion()
     */
    public String getDriverVersion() throws SQLException {
        return getDriverMajorVersion()+"."+getDriverMinorVersion();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getExportedKeys(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getExportedKeys(String catalog, String schema, String table)
    throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getExtraNameCharacters()
     */
    public String getExtraNameCharacters() throws SQLException {
        return "";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getIdentifierQuoteString()
     */
    public String getIdentifierQuoteString() throws SQLException {
        return " ";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getImportedKeys(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getImportedKeys(String catalog, String schema, String table)
    throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getIndexInfo(java.lang.String, java.lang.String, java.lang.String, boolean, boolean)
     */
    public ResultSet getIndexInfo(String catalog, String schema, String table,
            boolean unique, boolean approximate) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxBinaryLiteralLength()
     */
    public int getMaxBinaryLiteralLength() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxCatalogNameLength()
     */
    public int getMaxCatalogNameLength() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxCharLiteralLength()
     */
    public int getMaxCharLiteralLength() throws SQLException {
        return 100000; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnNameLength()
     */
    public int getMaxColumnNameLength() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnsInGroupBy()
     */
    public int getMaxColumnsInGroupBy() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnsInIndex()
     */
    public int getMaxColumnsInIndex() throws SQLException {
        return 0;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnsInOrderBy()
     */
    public int getMaxColumnsInOrderBy() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnsInSelect()
     */
    public int getMaxColumnsInSelect() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxColumnsInTable()
     */
    public int getMaxColumnsInTable() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxConnections()
     */
    public int getMaxConnections() throws SQLException {
        return 1;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxCursorNameLength()
     */
    public int getMaxCursorNameLength() throws SQLException {
        return 0;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxIndexLength()
     */
    public int getMaxIndexLength() throws SQLException {
        return 0;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxProcedureNameLength()
     */
    public int getMaxProcedureNameLength() throws SQLException {
        return 0;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxRowSize()
     */
    public int getMaxRowSize() throws SQLException {
        return 100000; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxSchemaNameLength()
     */
    public int getMaxSchemaNameLength() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxStatementLength()
     */
    public int getMaxStatementLength() throws SQLException {
        return 100000; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxStatements()
     */
    public int getMaxStatements() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxTableNameLength()
     */
    public int getMaxTableNameLength() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxTablesInSelect()
     */
    public int getMaxTablesInSelect() throws SQLException {
        return 1024; //just improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getMaxUserNameLength()
     */
    public int getMaxUserNameLength() throws SQLException {
        return 0;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getNumericFunctions()
     */
    public String getNumericFunctions() throws SQLException {
        return "AVG, COUNT, SUM, MAX, MIN";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getPrimaryKeys(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getPrimaryKeys(String catalog, String schema, String table)
    throws SQLException {
        //creating temporary table
        try {
            //for getColumns
            connection.execute("create type metadataPrimaryKeys;");
            connection.execute("create function TABLE_CAT(metadataPrimaryKeys)->charstring as stored;");
            connection.execute("create function TABLE_SCHEM(metadataPrimaryKeys)->charstring as stored;");
            connection.execute("create function TABLE_NAME(metadataPrimaryKeys)->charstring as stored;");
            connection.execute("create function COLUMN_NAME(metadataPrimaryKeys)->charstring as stored;");
            connection.execute("create function KEY_SEQ(metadataPrimaryKeys)->integer as stored;");
            connection.execute("create function PK_NAME(metadataPrimaryKeys)->charstring as stored;");
            
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        Scan scan=null;
        String columnName;
        int i=0;
        
        try {
            
            String currentSchema = connection.execute("sql_schema();").getRow().getStringElem(0);
            
            //Getting columns for matching tables and schemas
            //System.out.println(schema+" " + table);
            //System.out.println("sql(\"schema "+schema+"\");");
            
            if (schema.equals("")==true)
                connection.execute("sql(\"schema default\");");
            else
                connection.execute("sql(\"schema "+schema+"\");");
            
            //getting nonkey columns
            scan = connection.execute("sql_key_columns(\""+table+"\");");
            while (scan.eos()==false)
            {
                columnName=scan.getRow().getStringElem(0);
                
                //adding to table
                connection.execute("create metadataPrimaryKeys (TABLE_CAT, TABLE_SCHEM, TABLE_NAME, COLUMN_NAME," +
                        " KEY_SEQ, PK_NAME) instances :r"+
                        i+" (\"\",\""+schema+"\",\""+
                        table+"\",\""+columnName+"\",0,\"\");");
                
                i++;
                scan.nextRow();
            }
            
            scan=connection.execute("select TABLE_CAT(t), TABLE_SCHEM(t), TABLE_NAME(t)," +
            " COLUMN_NAME(t), KEY_SEQ(t), PK_NAME(t) from metadataPrimaryKeys t;");
            
            //destroys temporary objects in AMOS database
            connection.execute("delete type metadataPrimaryKeys;");
            //restoring original schema
            connection.execute("sql(\"schema "+currentSchema+"\");");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
        
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getProcedureColumns(java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getProcedureColumns(String catalog, String schemaPattern,
            String procedureNamePattern, String columnNamePattern)
    throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getProcedures(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getProcedures(String catalog, String schemaPattern,
            String procedureNamePattern) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getProcedureTerm()
     */
    public String getProcedureTerm() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getSchemas()
     */
    public ResultSet getSchemas() throws SQLException {
        //creating temporary table
        try {
            //for getTables
            connection.execute("create type metadataSchema;");
            connection.execute("create function TABLE_SCHEM(metadataSchema)->charstring as stored;");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        //getting list of tables which match patterns
        Scan scan=null;
        
        String sql="select name(f) from function f where like(name(f),'*#*->*') and kindoffunction(f)=\"stored\";";
        Hashtable hashtable=new Hashtable();
        try {
            scan = connection.execute(sql);
            
            AmosJdbcResultSet res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
            String data,beforehash,schema;
            int i=1;
            while(res.next())
            {
                //analysing results and getting schema with table names
                data=res.getString(1);
                int hash=data.indexOf('#');
                beforehash=data.substring(0,hash);
                schema=data.substring(beforehash.lastIndexOf('.')+1,hash);
                
                if (hashtable.contains(schema)==false) 
                {
                    hashtable.put(new Integer(i),schema);
                    i++;
                }
                
            }
            
            i=1;
            while (hashtable.isEmpty()==false)
            {
                //          saving that data in temporary table to get required ResultSet
                connection.execute("create metadataSchema (TABLE_SCHEM) instances :s"
                        +i+" (\""
                        +(String)hashtable.remove(new Integer(i))+"\");");
                i++;
            }
            scan=connection.execute("select TABLE_SCHEM(t) from metadataSchema t;");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        //destroys temporary objects in AMOS database
        try {
            
            connection.execute("delete type metadataSchema;");
            
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
        
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getSchemaTerm()
     */
    public String getSchemaTerm() throws SQLException {
        return "SCHEMA";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getSearchStringEscape()
     */
    public String getSearchStringEscape() throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getSystemFunctions()
     */
    public String getSystemFunctions() throws SQLException {
        return null;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getSQLKeywords()
     */
    public String getSQLKeywords() throws SQLException {
        return "";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getStringFunctions()
     */
    public String getStringFunctions() throws SQLException {
        return "LIKE";
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getTablePrivileges(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getTablePrivileges(String catalog, String schemaPattern,
            String tableNamePattern) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getTables(java.lang.String, java.lang.String, java.lang.String, java.lang.String[])
     */
    public ResultSet getTables(String catalog, String schemaPattern,
            String tableNamePattern, String[] types) throws SQLException {
        
        
        //creating temporary table
        try {
            //for getTables
            connection.execute("create type metadataTable;");
            connection.execute("create function TABLE_CAT(metadataTable)->charstring as stored;");
            connection.execute("create function TABLE_SCHEM(metadataTable)->charstring as stored;");
            connection.execute("create function TABLE_NAME(metadataTable)->charstring as stored;");
            connection.execute("create function TABLE_TYPE(metadataTable)->charstring as stored;");
            connection.execute("create function REMARKS(metadataTable)->charstring as stored;");
            
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        //getting list of tables which match patterns
        Scan scan=null;
        callin.Oid func;
        Tuple result;
        
        String sql="select name(f) from function f where like(name(f),'*"
            +convertPattern(schemaPattern)+"#"+convertPattern(tableNamePattern)
            +"->*') and kindoffunction(f)=\"stored\";";
        
        try {
            scan = connection.execute(sql);
            
            AmosJdbcResultSet res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
            String data,beforehash,afterhash,schema,table;
            int i=1;
            while(res.next())
            {
                //analysing results and getting schema with table names
                data=res.getString(1);
                int hash=data.indexOf('#');
                beforehash=data.substring(0,hash);
                afterhash=data.substring(hash+1);
                schema=data.substring(beforehash.lastIndexOf('.')+1,hash);
                table=afterhash.substring(0,afterhash.indexOf('-'));
                
                //saving that data in temporary table to get required ResultSet
                if (schemaPattern.equals(""))
                {
                    if (schema.equals(""))
                        connection.execute("create metadataTable (TABLE_CAT,TABLE_SCHEM,TABLE_NAME,TABLE_TYPE,REMARKS) instances :r"
                                +i+" (\"\",\"\",\""
                                +table+"\",\"TABLE\",\"\");");
                }
                else
                {
                    connection.execute("create metadataTable (TABLE_CAT,TABLE_SCHEM,TABLE_NAME,TABLE_TYPE,REMARKS) instances :r"
                            +i+" (\"\",\""
                            +schema+"\",\""
                            +table+"\",\"TABLE\",\"\");");
                }
                i++;
            }
            
            scan=connection.execute("select TABLE_CAT(t),TABLE_SCHEM(t),TABLE_NAME(t),TABLE_TYPE(t),REMARKS(t) from metadataTable t;");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        //destroys temporary objects in AMOS database
        try {
            
            connection.execute("delete type metadataTable;");
            
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getTableTypes()
     */
    public ResultSet getTableTypes() throws SQLException {
        //creating temporary table
        try {
            //for getTables
            connection.execute("create type metadataTableType;");
            connection.execute("create function TABLE_TYPE(metadataTableType)->charstring as stored;");
            connection.execute("create metadataTableType (TABLE_TYPE) instances :t1 (\"TABLE\");");
            
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        
        //getting list of tables which match patterns
        Scan scan=null;
        AmosJdbcResultSet res=null;
        
        String sql="select TABLE_TYPE(f) from metadataTableType f;";
        
        try {
            scan = connection.execute(sql);
            res = new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
            
            //destroys temporary objects in AMOS database
            connection.execute("delete type metadataTableType;");
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
        return res;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getTimeDateFunctions()
     */
    public String getTimeDateFunctions() throws SQLException {
        return "";
    }
    
    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getTypeInfo()
     */
    public ResultSet getTypeInfo() throws SQLException {
        
        Scan scan=null;
        
        //creating temporary table
        try {
            //for getColumns
            connection.execute("create type metadataTypeInfo;");
            connection.execute("create function TYPE_NAME(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function DATA_TYPE(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function PRECISION(metadataTypeInfo)->integer as stored;");
            connection.execute("create function LITERAL_PREFIX(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function LITERAL_SUFFIX(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function CREATE_PARAMS(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function NULLABLE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function CASE_SENSITIVE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function SEARCHABLE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function UNSIGNED_ATTRIBUTE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function FIXED_PREC_SCALE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function AUTO_INCREMENT(metadataTypeInfo)->integer as stored;");
            connection.execute("create function LOCAL_TYPE_NAME(metadataTypeInfo)->charstring as stored;");
            connection.execute("create function MINIMUM_SCALE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function MAXIMUM_SCALE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function SQL_DATA_TYPE(metadataTypeInfo)->integer as stored;");
            connection.execute("create function SQL_DATETIME_SUB(metadataTypeInfo)->integer as stored;");
            connection.execute("create function NUM_PREC_RADIX(metadataTypeInfo)->integer as stored;");
            
            //adding data to table
            
            //bool
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"BOOL\",\"" +
            		Types.BIT+"\",1,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",1,0,0,\"\",1,1,0,0,2);");
            
            //integer
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"INTEGER\",\"" +
            		Types.INTEGER+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //small
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"SMALLINT\",\"" +
            		Types.SMALLINT+"\",10000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //float
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"FLOAT\",\"" +
            		Types.FLOAT+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //double
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"DOUBLE\",\"" +
            		Types.DOUBLE+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //real
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"REAL\",\"" +
            		Types.REAL+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //dec
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"DEC\",\"" +
            		Types.DECIMAL+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            
            //decimal
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"DECIMAL\",\"" +
            		Types.DECIMAL+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //char
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"CHAR\",\"" +
            		Types.CHAR+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",1,"+typeSearchable+",0,0,0,\"\",1,1,0,0,10);");
            
            //varchar
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"VARCHAR\",\"" +
            		Types.VARCHAR+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",1,"+typeSearchable+",0,0,0,\"\",1,1,0,0,10);");
            
            //clob
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"CLOB\",\"" +
            		Types.CLOB+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",1,"+typeSearchable+",0,0,0,\"\",1,1,0,0,10);");
            
            //character
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"CHARACTER\",\"" +
            		Types.CHAR+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",1,"+typeSearchable+",0,0,0,\"\",1,1,0,0,10);");
            
            //numeric
            connection.execute("create metadataTypeInfo (TYPE_NAME, DATA_TYPE, PRECISION, LITERAL_PREFIX, " +
            		"LITERAL_SUFFIX, CREATE_PARAMS, NULLABLE, CASE_SENSITIVE, SEARCHABLE, UNSIGNED_ATTRIBUTE, " +
            		"FIXED_PREC_SCALE, AUTO_INCREMENT, LOCAL_TYPE_NAME, MINIMUM_SCALE, MAXIMUM_SCALE, " +
            		"SQL_DATA_TYPE, SQL_DATETIME_SUB, NUM_PREC_RADIX) instances :r1 (\"NUMERIC\",\"" +
            		Types.NUMERIC+"\",1000000,\"\",\"\",\"\","+typeNoNulls+",0,"+typePredBasic+",0,0,0,\"\",1,1,0,0,10);");
            
            //selecting
            scan=connection.execute("select TYPE_NAME(t), DATA_TYPE(t), PRECISION(t), LITERAL_PREFIX(t), " +
            		"LITERAL_SUFFIX(t), CREATE_PARAMS(t), NULLABLE(t), CASE_SENSITIVE(t), SEARCHABLE(t), " +
            		"UNSIGNED_ATTRIBUTE(t), FIXED_PREC_SCALE(t), AUTO_INCREMENT(t), LOCAL_TYPE_NAME(t), " +
            		"MINIMUM_SCALE(t), MAXIMUM_SCALE(t), SQL_DATA_TYPE(t), SQL_DATETIME_SUB(t), " +
            		"NUM_PREC_RADIX(t) from metadataTypeInfo t;");
            
            //destroys temporary objects in AMOS database
            connection.execute("delete type metadataTypeInfo;");
            
        } catch (AmosException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return new AmosJdbcResultSet(scan,AmosJdbcDefine.sentenceAMOSQL);
        
        
        
        
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getUDTs(java.lang.String, java.lang.String, java.lang.String, int[])
     */
    public ResultSet getUDTs(String catalog, String schemaPattern,
            String typeNamePattern, int[] types) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getURL()
     */
    public String getURL() throws SQLException {
        return url;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getUserName()
     */
    public String getUserName() throws SQLException {
        String user;
        try {
            user = connection.execute("SQL_SCHEMA();").getRow().getStringElem(0);
        } catch (AmosException e) {
            throw DriverConnectionError(e.getMessage());
        }
        return user;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#getVersionColumns(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getVersionColumns(String catalog, String schema,
            String table) throws SQLException {
        throw NotSupportedByDatabase();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#insertsAreDetected(int)
     */
    public boolean insertsAreDetected(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#isCatalogAtStart()
     */
    public boolean isCatalogAtStart() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#isReadOnly()
     */
    public boolean isReadOnly() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#nullPlusNonNullIsNull()
     */
    public boolean nullPlusNonNullIsNull() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#nullsAreSortedAtEnd()
     */
    public boolean nullsAreSortedAtEnd() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#nullsAreSortedAtStart()
     */
    public boolean nullsAreSortedAtStart() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#nullsAreSortedHigh()
     */
    public boolean nullsAreSortedHigh() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#nullsAreSortedLow()
     */
    public boolean nullsAreSortedLow() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#othersDeletesAreVisible(int)
     */
    public boolean othersDeletesAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#othersInsertsAreVisible(int)
     */
    public boolean othersInsertsAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#othersUpdatesAreVisible(int)
     */
    public boolean othersUpdatesAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#ownDeletesAreVisible(int)
     */
    public boolean ownDeletesAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#ownInsertsAreVisible(int)
     */
    public boolean ownInsertsAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#ownUpdatesAreVisible(int)
     */
    public boolean ownUpdatesAreVisible(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesLowerCaseIdentifiers()
     */
    public boolean storesLowerCaseIdentifiers() throws SQLException {
        
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesLowerCaseQuotedIdentifiers()
     */
    public boolean storesLowerCaseQuotedIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesMixedCaseIdentifiers()
     */
    public boolean storesMixedCaseIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesMixedCaseQuotedIdentifiers()
     */
    public boolean storesMixedCaseQuotedIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesUpperCaseIdentifiers()
     */
    public boolean storesUpperCaseIdentifiers() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#storesUpperCaseQuotedIdentifiers()
     */
    public boolean storesUpperCaseQuotedIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsAlterTableWithAddColumn()
     */
    public boolean supportsAlterTableWithAddColumn() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsAlterTableWithDropColumn()
     */
    public boolean supportsAlterTableWithDropColumn() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsANSI92EntryLevelSQL()
     */
    public boolean supportsANSI92EntryLevelSQL() throws SQLException {
        return true; //again improvising
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsANSI92FullSQL()
     */
    public boolean supportsANSI92FullSQL() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsANSI92IntermediateSQL()
     */
    public boolean supportsANSI92IntermediateSQL() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsBatchUpdates()
     */
    public boolean supportsBatchUpdates() throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCatalogsInDataManipulation()
     */
    public boolean supportsCatalogsInDataManipulation() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCatalogsInIndexDefinitions()
     */
    public boolean supportsCatalogsInIndexDefinitions() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCatalogsInPrivilegeDefinitions()
     */
    public boolean supportsCatalogsInPrivilegeDefinitions() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCatalogsInProcedureCalls()
     */
    public boolean supportsCatalogsInProcedureCalls() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCatalogsInTableDefinitions()
     */
    public boolean supportsCatalogsInTableDefinitions() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsColumnAliasing()
     */
    public boolean supportsColumnAliasing() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsConvert()
     */
    public boolean supportsConvert() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsConvert(int, int)
     */
    public boolean supportsConvert(int fromType, int toType)
    throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCoreSQLGrammar()
     */
    public boolean supportsCoreSQLGrammar() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsCorrelatedSubqueries()
     */
    public boolean supportsCorrelatedSubqueries() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsDataDefinitionAndDataManipulationTransactions()
     */
    public boolean supportsDataDefinitionAndDataManipulationTransactions()
    throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsDataManipulationTransactionsOnly()
     */
    public boolean supportsDataManipulationTransactionsOnly()
    throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsDifferentTableCorrelationNames()
     */
    public boolean supportsDifferentTableCorrelationNames() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsExpressionsInOrderBy()
     */
    public boolean supportsExpressionsInOrderBy() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsExtendedSQLGrammar()
     */
    public boolean supportsExtendedSQLGrammar() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsFullOuterJoins()
     */
    public boolean supportsFullOuterJoins() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsGroupBy()
     */
    public boolean supportsGroupBy() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsGroupByBeyondSelect()
     */
    public boolean supportsGroupByBeyondSelect() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsGroupByUnrelated()
     */
    public boolean supportsGroupByUnrelated() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsIntegrityEnhancementFacility()
     */
    public boolean supportsIntegrityEnhancementFacility() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsLikeEscapeClause()
     */
    public boolean supportsLikeEscapeClause() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsLimitedOuterJoins()
     */
    public boolean supportsLimitedOuterJoins() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsMinimumSQLGrammar()
     */
    public boolean supportsMinimumSQLGrammar() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsMixedCaseIdentifiers()
     */
    public boolean supportsMixedCaseIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsMixedCaseQuotedIdentifiers()
     */
    public boolean supportsMixedCaseQuotedIdentifiers() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsMultipleResultSets()
     */
    public boolean supportsMultipleResultSets() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsMultipleTransactions()
     */
    public boolean supportsMultipleTransactions() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsNonNullableColumns()
     */
    public boolean supportsNonNullableColumns() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOpenCursorsAcrossCommit()
     */
    public boolean supportsOpenCursorsAcrossCommit() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOpenCursorsAcrossRollback()
     */
    public boolean supportsOpenCursorsAcrossRollback() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOpenStatementsAcrossCommit()
     */
    public boolean supportsOpenStatementsAcrossCommit() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOpenStatementsAcrossRollback()
     */
    public boolean supportsOpenStatementsAcrossRollback() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOrderByUnrelated()
     */
    public boolean supportsOrderByUnrelated() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsOuterJoins()
     */
    public boolean supportsOuterJoins() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsPositionedDelete()
     */
    public boolean supportsPositionedDelete() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsPositionedUpdate()
     */
    public boolean supportsPositionedUpdate() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsResultSetConcurrency(int, int)
     */
    public boolean supportsResultSetConcurrency(int type, int concurrency)
    throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsResultSetType(int)
     */
    public boolean supportsResultSetType(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSchemasInDataManipulation()
     */
    public boolean supportsSchemasInDataManipulation() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSchemasInIndexDefinitions()
     */
    public boolean supportsSchemasInIndexDefinitions() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSchemasInPrivilegeDefinitions()
     */
    public boolean supportsSchemasInPrivilegeDefinitions() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSchemasInProcedureCalls()
     */
    public boolean supportsSchemasInProcedureCalls() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSchemasInTableDefinitions()
     */
    public boolean supportsSchemasInTableDefinitions() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSelectForUpdate()
     */
    public boolean supportsSelectForUpdate() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsStoredProcedures()
     */
    public boolean supportsStoredProcedures() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSubqueriesInComparisons()
     */
    public boolean supportsSubqueriesInComparisons() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSubqueriesInExists()
     */
    public boolean supportsSubqueriesInExists() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSubqueriesInIns()
     */
    public boolean supportsSubqueriesInIns() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsSubqueriesInQuantifieds()
     */
    public boolean supportsSubqueriesInQuantifieds() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsTableCorrelationNames()
     */
    public boolean supportsTableCorrelationNames() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsTransactionIsolationLevel(int)
     */
    public boolean supportsTransactionIsolationLevel(int level)
    throws SQLException {
        if (level==Connection.TRANSACTION_SERIALIZABLE) return true;
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsTransactions()
     */
    public boolean supportsTransactions() throws SQLException {
        return true;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsUnion()
     */
    public boolean supportsUnion() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#supportsUnionAll()
     */
    public boolean supportsUnionAll() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#updatesAreDetected(int)
     */
    public boolean updatesAreDetected(int type) throws SQLException {
        throw WrongAPI();
    }
    
    /**
     * @see java.sql.DatabaseMetaData#usesLocalFilePerTable()
     */
    public boolean usesLocalFilePerTable() throws SQLException {
        return false;
    }
    
    /**
     * @see java.sql.DatabaseMetaData#usesLocalFiles()
     */
    public boolean usesLocalFiles() throws SQLException {
        return false;
    }
    
    
    /**
     * Converts from Java pattern to AmosQL pattern
     * 
     * @param input - Java type pattern
     * @return AmosQL type pattern
     * 
     */
    private String convertPattern(String input)
    {
        String output="";
        
        for (int i=0;i<input.length();i++)
        {
            if (input.charAt(i)=='%') output=output+'*';
            else if (input.charAt(i)=='_') output=output+'?';
            else output=output+input.charAt(i);
        }
        
        return output;
    }
    
    /**
     * Checks if input matches pattern
     * 
     * @param input - String to check
     * @param pattern - pattern to match
     * @return true if match, false otherwise
     * 
     */
    private boolean patternMatch(String input, String pattern)
    {
        boolean result=true;
        
        int i=0,j=0;
        
        //terrible code but it works... I think
        while (i<pattern.length())
        {
            if (j>=input.length())
            {    
                if (input.length()>=pattern.length())
                {
                    result=false;
                    break;
                }
                if (pattern.charAt(i)!='%') result=false;
                break;	
            }
            if (pattern.charAt(i)=='%')
            {
                i++;
                if (i>=pattern.length())
                {
                    j=input.length();
                    break;
                }       
                    boolean res2=false;
                    for (int tmp=j;tmp<input.length();tmp++)
                    {
                        if (input.charAt(tmp)==pattern.charAt(i))
                        {
                            
                            j=tmp;
                            res2 = patternMatch(input.substring(j),pattern.substring(i));
                            if (res2==true) break;
                        }
                    }
                    if (res2==false)
                    {
                        result=false;
                        break;
                    }
            }
            else if (pattern.charAt(i)=='_')
            {
                
                if (j>=input.length())
                {
                    result = false;
                    break;
                }
            }
            else
            {
                if (pattern.charAt(i)!=input.charAt(j))
                {
                    result=false;
                    break;
                }
            }
            i++;j++;
        }
        
        if (j<input.length()) result = false;
        return result;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getDatabaseMajorVersion()
     */
    public int getDatabaseMajorVersion() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getDatabaseMinorVersion()
     */
    public int getDatabaseMinorVersion() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getJDBCMajorVersion()
     */
    public int getJDBCMajorVersion() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getJDBCMinorVersion()
     */
    public int getJDBCMinorVersion() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSQLStateType()
     */
    public int getSQLStateType() throws SQLException {
        // TODO Auto-generated method stub
        return 0;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#locatorsUpdateCopy()
     */
    public boolean locatorsUpdateCopy() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsGetGeneratedKeys()
     */
    public boolean supportsGetGeneratedKeys() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsMultipleOpenResults()
     */
    public boolean supportsMultipleOpenResults() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsNamedParameters()
     */
    public boolean supportsNamedParameters() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsSavepoints()
     */
    public boolean supportsSavepoints() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsStatementPooling()
     */
    public boolean supportsStatementPooling() throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsResultSetHoldability(int)
     */
    public boolean supportsResultSetHoldability(int arg0) throws SQLException {
        // TODO Auto-generated method stub
        return false;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSuperTables(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getSuperTables(String arg0, String arg1, String arg2) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSuperTypes(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getSuperTypes(String arg0, String arg1, String arg2) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }



    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getAttributes(java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getAttributes(String arg0, String arg1, String arg2, String arg3) throws SQLException {
        // TODO Auto-generated method stub
        return null;
    }
    
    
}
