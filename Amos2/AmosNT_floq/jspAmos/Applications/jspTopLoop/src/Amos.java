package jspAmos;

import callin.*;
import java.util.Vector;

/**
 * <table>
 *   <tr>
 *     <td><b>Title</b></td>
 *     <td>JSP Amos2 base class</td>
 *   </tr>
 *   <tr>
 *     <td><b>Description</b></td>
 *     <td>Loads Amos2 as a client an connects to the server, creates a connection</td>
 *   </tr>
 *   <tr>
 *     <td><b>Copyright</b></td>
 *     <td>Copyright (c) 2001</td>
 *   </tr>
 *   <tr>
 *     <td><b>Company</b></td>
 *     <td>University of Uppsala</td>
 *   </tr>
 *   <tr>
 *     <td><b>author</b></td>
 *     <td>Dominik Businger</td>
 *   </tr>
 *   <tr>
 *     <td><b>version</b></td>
 *     <td>1.0</td>
 *   </tr>
 * </table>
 * <br>
 *  <ul>
 *  <b>!!!!!IMPORTANT!!!!!</b> <br>
 *  This Class can only be instanciated once per Application, <br>
 *  therefore the scope in the JSP-File calling this "Bean" should use the scope="application"
 *  for this bean. <br>
 *  <b>!!!!!IMPORTANT!!!!!</b> <br>
 *  </ul>
 * <br>
 *  What does this class do/proviede : <br>
 * <br>
 * <ul>
 *   <li> either load an Amos2-Instance, make it become a client and connect to the amos2 & host which names are supplied or</li>
 *   <li> load an Amos2-Instance which will act as server & client at once </li>
 *   <li> execute the queries on the embeded Amos2-Instance </li>
 * </ul>
 *
 * @author Dominik Busigner
 * @version 1.0

 */

public class Amos {

  private Connection connection;        //the Connection to AMOS
  private boolean initialized = false;  //Variable that is set true if the database has been loaded
  private String dumpFile = "";         //Variable to store location & name of dumpFile


/**
 * startAmos(String) initializes the embedded Amos II Database <br><br>
 * To make it impossible to try to load the database
 * when it is allready loaded, I set the boolean value
 * initialized to true at the end.<br><br>
 *
 * @param dumpFile full path and name to the Amos2-DumpFile
 */
  public void startAmos(String dumpFile) {
    if (!initialized){
	System.out.println("Initializing Amos II for " + dumpFile);
      this.dumpFile = dumpFile;
      this.connection = (Connection) initAmos(dumpFile);
      initialized = true;
    } else {
      System.out.println("JSP tried to reinitialize Amos II. Ignored.");
     initialized = true;
    }
  }

/**
 * Method to initialize Amos embeded in the Servlet-Engine, and get the Connection.<br><br>
 *
 * @param dumpFile full path and name to the Amos2-DumpFile.
 * @return callin.Connection
 *
 */
  private Connection initAmos(String dumpFile) {
    try {
      callin.Connection.initializeAmos(dumpFile);
    } catch ( callin.AmosException e ) {
      System.out.print("Unable to initialize Amos. \n" + e);
    }
    try {
      connection = new Connection("");
    } catch( callin.AmosException e){
      System.out.print("Unable get Connection to Amos. \n" + e);
    }
    return connection;
  }


 /**
 * Method to grant access to the connection to amos.<br><br>
 *
 * @return callin.Connection
 */

 public Connection getConnection(){
   return this.connection;
 }


/**
 * JspExecute can be used to execute any queries on the database. <br><br>
 *
 * @param The query to be executed on Amos2, including ";" at the end.
 * @return callin.AmosScan
 */
  public synchronized Scan jspExecute(String queryString) throws callin.AmosException {
    Scan result = null;
    Utilities u = new Utilities();
    result = connection.execute(queryString);
    return result;
  }
}
