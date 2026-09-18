import java.sql.*;
import java.util.Properties;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.PrintStream;



/**
 This program regression tests the Amos II Jdbc driver
 Giedrius Povilavicius, 2004
 
 */
public class JdbcTest {
 
    /**
     * Comment for <code>ErrorOccurred</code>
     */
    public static boolean ErrorOccurred=false;
    
    /**
     * Comment for <code>conn</code>
     */
    public static Connection conn=null;
    
    
    /**
     * @param argv
     * @throws Exception
     */
    public static void main(String argv[]) throws Exception
    {
        System.out.println("Starting Amos II JDBC driver test...");
        
        try {
            OutputStream outFile = new FileOutputStream("traceinfo.txt");
            PrintStream outStream = new PrintStream(outFile,true);
            DriverManager.setLogStream(outStream);
            System.out.println("Tracing is on (see \"traceinfo.txt\")...");
        }
        catch (Exception e)
        {
            System.out.println("Tracing initialisation failed...");
        }
        
        
        try {
           
            //registering driver class
            Class.forName("amosjdbc.AmosJdbcDriver").newInstance(); 
            
            
            //connecting
            Properties info = new Properties();
            info.setProperty("dumpfile","amos2.dmp");
            info.setProperty("directory",argv[0]);
            
            //info.setProperty("dbName","server");
            //info.setProperty("nameServerHost","127.0.0.1");
     
            conn = DriverManager.getConnection("jdbc:amos:///amos2",info);
            
            
            new CreateTableTest().Test();
            new InsertTest().Test();
            new SelectTest().Test();
            new PreparedStatementIterationTest().Test();
            new CommitRollbackTest().Test();
            new DatabaseMetaDataTest().Test();

        }
        catch(Exception e)
        {
            System.out.println(e.getMessage());
            e.printStackTrace();
            ErrorOccurred=true;
        }
        finally
        {
            if(ErrorOccurred)
            {
                System.out.println("*****************************************************************");
                System.out.println("********** Amos II JDBC driver regression test error ************");
                System.out.println("*****************************************************************");
            }
            else System.out.println("Amos II JDBC driver regression test OK!");
        }}
    

}  // ends class JdbcTest

class Regression extends JdbcTest
{
    /**
     * @throws Exception
     */
    public void Test() throws Exception
    {
        System.out.print("[Testing "+tag()+" ...");
        if(CodeOK()) System.out.println("OK]");
        else
        {
            System.out.println("NOT OK]");
            ErrorOccurred = true;
        }
    }
    String tag() {return  "undefined";}
    /**
     * @return
     * @throws Exception
     */
    public boolean CodeOK() throws Exception
    {
        System.out.println("No Tester defined!");
        return false;
    }
}


class CreateTableTest extends Regression
{
    public String tag(){return "simple create table sentence";}
    public boolean CodeOK() throws Exception
    {
        
        Statement stmt = conn.createStatement();
        int res = stmt.executeUpdate("schema testing;");
        res = stmt.executeUpdate("create table test (a varchar, b integer,c real, d boolean,  primary key(a));");

        res = stmt.executeUpdate("schema default;");
        res = stmt.executeUpdate("create table test12 (a varchar, b integer,c real, d boolean);");

        res = stmt.executeUpdate("schema testing2;");
        res = stmt.executeUpdate("create table test (a varchar, b integer,c real, d boolean);");

        res = stmt.executeUpdate("schema testing2;");
        res = stmt.executeUpdate("create table test2 (labasa varchar, b integer,c real, d boolean);");

        
        return true;
    }
}

class InsertTest extends Regression
{
    public String tag(){return "some insert sentences";}
    public boolean CodeOK() throws Exception
    /**
     This method illustrates how to execute insert sentence
     */
    {
        
        Statement stmt = conn.createStatement(); 
        int res = stmt.executeUpdate("insert into test values('value1',1,1.1,1);");
        res = stmt.executeUpdate("insert into test values('value2',2,2.2,0);");
        res = stmt.executeUpdate("insert into test values('value3',3,3.3,1);");
        res = stmt.executeUpdate("insert into test values('value4',4,4.4,0);");
        return true;

    }
}


class PreparedStatementIterationTest extends Regression
{
    public String tag(){return "prepared statement and iteration through resultset";}
    public boolean CodeOK() throws Exception
    {

        int i=0;
        PreparedStatement prepstmt = conn.prepareStatement("SELECT * FROM test WHERE ( b > ? ) and (a=?)");
        
        prepstmt.setInt(1,0);
        prepstmt.setString(2,"value4");
        ResultSet res = prepstmt.executeQuery();

        while (res.next()) // While there are more rows in the resultset
        {
            String str; 
            str = res.getString(1);   // Get 1st element (enumerated 1 and up) in row as a string
            i++;
        }
        
        int j=0;
        prepstmt.setInt(1,11110);
        ResultSet res2 = prepstmt.executeQuery();

        while (res2.next()) // While there are more rows in the resultset
        {
            String str; 
            str = res2.getString(1);   // Get 1st element (enumerated 1 and up) in row as a string
            j++;
        }

        
        if((i>0)&&(j==0)) return true;
        return false;
    }
}


class SelectTest  extends Regression
{
    public String tag(){return "simple select sentence";}
    public boolean CodeOK() throws Exception
    {
        int i=0;
        
        Statement stmt = conn.createStatement();
        ResultSet res2 = stmt.executeQuery("select * from test;");

        while (res2.next())
        {
        	i++;
        }
        if (i!=4) return false;
        return true;
    }
}

class CommitRollbackTest extends Regression
{
    public String tag(){return "commit/rollback support";}
    public boolean CodeOK() throws Exception
    {
       
        Statement stmt = conn.createStatement();
        conn.setAutoCommit(false); //because by default true
        
        int res = stmt.executeUpdate ("insert into test values('value5',5,5.5,0);");
        conn.rollback();
        ResultSet res2 = stmt.executeQuery("select * from test where b=5;");

        if (res2.next()) 
            {
            	res = stmt.executeUpdate ("delete from test where b=5;");
            	return false;
            }
        res = stmt.executeUpdate ("insert into test values('value5',5,5.5,0);");
        conn.commit();
        conn.rollback();
        res2 = stmt.executeQuery("select * from test where b=5;");
       
        if (res2.next()==false)
            {
            	res = stmt.executeUpdate ("delete from test where b=5;");
            	return false;
            }
        if (res2.next()) 
            {
            	res = stmt.executeUpdate ("delete from test where b=5;");
            	return false;
            }
        
        return true;
    }
}

class DatabaseMetaDataTest  extends Regression
{
    public String tag(){return "DatabaseMetaData class ";}
    public boolean CodeOK() throws Exception
    {
        int i=0;
        DatabaseMetaData meta=conn.getMetaData();

        //testing getTables
        ResultSet res = meta.getTables("","%","%",null);
        while (res.next())
        {
        	i++;
        }
        if (i==0) return false;
        
        //testing getTableTypes
        res = meta.getTableTypes();
        res.next();
      	if (res.getString(1).equals("TABLE")!=true) return false;

      	//testing getSchemas
      	i=0;
        res = meta.getSchemas();
        while (res.next())
        {
        	i++;
        }
        if (i==0) return false;
        
        
        //testing getColumns
        i=0;
        res = meta.getColumns("","%","%","%");
        while (res.next())
        {
        	i++;
        }
        if (i!=16) return false;

        //testing primary keys
        i=0;
        res = meta.getPrimaryKeys("","testing","test");
        while (res.next())
        {
            i++;
        }
        if (i==0) return false;
        
        //testing type info
        i=0;
        res = meta.getTypeInfo();
        while (res.next())
        {
//            System.out.println(res.getString(1)+" "+res.getString(2)
//                    +" "+res.getString(3)+" "+res.getString(4));
            i++;
        }
        if (i==0) return false;
        
        
        //getting amosII version
        //System.out.println(meta.getDatabaseProductVersion());
        //getting current user name == schema
        //System.out.println(meta.getUserName());
        
        return true;
    }
}

