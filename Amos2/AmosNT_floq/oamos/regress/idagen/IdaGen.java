//Title:        Generator
//Version:
//Copyright:    Copyright (c) 1999
//Author:       Timour Katchaounov
//Company:
//Description:

/* The schema:
create table emp (
  name   varchar (20)   NULL,
  salary number  (10, 0) NULL,
  ssn    number  (10, 0) primary key,
  hobby  varchar (20)   NULL,
  age    number  (10, 0) NULL,
  dept   varchar (20)   NULL
);
*/

import java.sql.*;
import sun.jdbc.odbc.*;
import java.io.*;
import java.util.Random;
import java.lang.*;

public class IdaGen {

  /****************************************************************************
   * Main
   ***************************************************************************/
  static public void main(String[] args) {
  	IdaGen  gen = new IdaGen();
    // Defaults
  	int     tuples   = 20;
    String  DSN      = "IDADS";
    String  empTable = "IDAEMP";
    String  command  = "dump";

    if (args.length > 0)      command = args[0];
    if (args.length > 1)      tuples = java.lang.Integer.parseInt(args[1]);
    if (args.length > 2)      DSN = args[2];
    if (args.length > 3)      empTable = args[3];
    if (args.length > 4)      help();

	  try {
	    gen.dbConnect(DSN);
      if (command.equalsIgnoreCase("create")) {
        gen.createTable(empTable);
        gen.deleteAll(empTable);
	      gen.populateTable(empTable, tuples);
      } else if (command.equalsIgnoreCase("delete")) {
        gen.deleteTable(empTable);
      } else if (command.equalsIgnoreCase("dump")) {
        gen.dumpTable(empTable);
      } else
        help();
  	} catch (Exception e) {
	    System.out.println(e);
	  }
  }

  /****************************************************************************
   * Connects to the database
   ***************************************************************************/
  public void dbConnect(String DSN) throws SQLException {
	  // Set logging
  	//DriverManager.setLogStream(System.out);

    try {
      Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");  //loads the driver
    } catch (java.lang.ClassNotFoundException e) {
	    System.out.println(e);
    }

	  // Connect to the local database
    //m_conn = DriverManager.getConnection(m_url, m_user, m_pass);
    m_conn = DriverManager.getConnection(m_url + DSN);
    System.out.println("Connected to MS Access via ODBC.\nDSN = " + DSN);
  }

  /****************************************************************************
   * Counts how many tuples there are in a table.
   * @param tableName The name of a table to process.
   * @return the number of tuples.
   ***************************************************************************/
  public int countTuples(String tableName) {
    Statement cntstmt;
    ResultSet rset;
    int nTuples = 0;

    try {
      cntstmt = m_conn.createStatement();
      rset = cntstmt.executeQuery("select count(*) from " + tableName);
      rset.next();
      nTuples = rset.getInt(1);
    } catch (SQLException e) {
      System.out.println("countTuples: " + e);
    }
    return nTuples;
  }


  /****************************************************************************
   * Deletes all employee tuples
   * @param tableName The name of a table to process.
   * @param colSize Number of bytes in the DATA column (if any).
   ***************************************************************************/
  public void createTable(String tableName) throws SQLException {
    Statement stmt = m_conn.createStatement();
    String    sql;
    int       rows;

    // first drop the table, just in case
    deleteTable(tableName);

    try {
      // create a table, with or without a data field
      sql =     "CREATE TABLE " + tableName + " ("     +
                "  name   TEXT,"                       +
                "  salary INTEGER,"                    +
                "  ssn    INTEGER CONSTRAINT constr PRIMARY KEY,"  +
                "  hobby  TEXT,"                       +
                "  age    INTEGER,"                    +
                "  dept   TEXT)";

      System.out.println(sql);
      
      rows = stmt.executeUpdate(sql);
      m_conn.commit();
      System.out.println("Created table: " + tableName);
    } catch (SQLException e) {
      System.out.println("createTable: " + e);
    }
  }


  /****************************************************************************
   * Deletes a table
   * @param tableName The name of a table to delete.
   ***************************************************************************/
  public void deleteTable(String tableName) {
    Statement stmt;

    try {
      stmt = m_conn.createStatement();
      stmt.executeUpdate("drop table " + tableName);
      System.out.println("Deleted table: " + tableName);
    } catch (SQLException e) {
      // Do nothing here, table may not exist
    }
  }


  /****************************************************************************
   * Deletes all employee tuples
   * @param tableName The name of a table to delete from.
   ***************************************************************************/
  public void deleteAll(String tableName) {
    Statement stmt;
    int       rows;

    rows = countTuples(tableName);

    try {
      stmt = m_conn.createStatement();
      stmt.executeUpdate("delete from " + tableName);
    } catch (SQLException e) {
      System.out.println("deleteAll: " + e);
    }
    System.out.println("Deleted: " + rows + " rows.");
  }


  /****************************************************************************
   * Generates tupCount employee tuples in the EMP table.
   * @param tupCount Number of tuples to generate
   ***************************************************************************/
  public void populateTable(String tableName, int tupCount) throws SQLException {
	  Statement         modstmt = m_conn.createStatement();
  	int               rows = 0;
  	PreparedStatement stmt = null;
  	Random    rnd;
  	int       ssnmin;
  	int       ssnmax;

    double    coeff = 100.0 / tupCount;
    int       completed_new = 0;
    int       completed_old = 0;
    long      startTime = 0;
    long      endTime = 0;
    double    totalTime = 0;

	  // table variables
    String    sqlInsert;
    String    name;
    int       salary;
	  int       ssn;
    String    hobby;
    int       age;
    String    dept;

    sqlInsert = "insert into " + tableName + " values (?, ?, ?, ?, ?, ?)";
    try {
      stmt = m_conn.prepareStatement(sqlInsert);
    } catch (SQLException e) {
      System.out.println("prepare: " + e);
    }

    // Generate data for the insert statement
    rnd    = new Random();
    ssnmin = tupCount / 2;
    ssnmax = tupCount + ssnmin;

    System.out.println("Generating " + tableName + " tuples.");
    System.out.println(ssnmin + " <= " + "SSN" + " < " + ssnmax);

    startTime = java.lang.System.currentTimeMillis();
    for (int i = 0; i < tupCount; i++) {
      name   = m_nm + i;
      salary = i%100;
      ssn    = ssnmin + i;
      hobby  = m_hb + i;
      // generate a radndom age between 18 and 70
      age = Math.round((70 - 18) * rnd.nextFloat() + 18);
      // select the employee dept
      if      (ssn < (3 * tupCount / 4))   dept = m_d1;
      else if (ssn < tupCount)             dept = m_d2;
      else if (ssn < (5 * tupCount / 4))   dept = m_d1;
      else                                 dept = m_d2;

      try {
        stmt.setString(1, name);
        stmt.setInt   (2, salary);
        stmt.setInt   (3, ssn);
        stmt.setString(4, hobby);
        stmt.setInt   (5, age);
        stmt.setString(6, dept);
      } catch (SQLException e) {
        System.out.println("set value: " + e);
      }

      try {
        stmt.executeUpdate();
      } catch (SQLException e) {
        System.out.println("update: " + e);
      }

      completed_new = (int)(coeff * i);
      if ((completed_new > completed_old) && ((completed_new % 10) == 0)) {
        m_conn.commit();
        //System.out.print(completed_new + "% ");
        //System.out.flush();
        completed_old = completed_new;
      }
    }
    m_conn.commit();
    endTime = java.lang.System.currentTimeMillis();
    totalTime = (double)(endTime - startTime) / 1000.0;

    System.out.println(
      "\nGenerated: " + countTuples(tableName) + " rows.\n" +
      "Total time: " + totalTime + "\n" +
      "Seconds per tuple insert: " + (totalTime / tupCount)
    );
  }

  /****************************************************************************
   * Prints a help message and exits
   ***************************************************************************/
  static public void help() {
    System.out.println(
      "Usage: IdaGen [command [tuples [DSN [table]]]\n" +
      "command := {create | delete | dump}"
    );
    java.lang.System.exit(0);
  }


  /****************************************************************************
   * Dumps all generated tuples
   ***************************************************************************/
  public void dumpTable(String tableName) throws SQLException {
    Statement stmt = m_conn.createStatement();
    ResultSet rset = stmt.executeQuery("select * from " + tableName);
    int       cols = rset.getMetaData().getColumnCount();

    while (rset.next()) {
      for (int i = 1; i <= cols; i++)
      System.out.print(rset.getString(i) + " ");
      System.out.println();
    }
  }


  //////////////////////////////////////////////////////////////////////////////

  // Connection constants
  private String  m_url = "jdbc:odbc:";
  //private String  m_user = "amos";
  //private String  m_pass = "amos";

 // Generated data prefixes
  private String  m_nm = "EmpNAME";
  private String  m_hb = "EmpHOBBY";
  private String  m_d1 = "IDA";
  private String  m_d2 = "Other";

  private Connection  m_conn;
}
