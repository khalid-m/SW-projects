package jspamos;

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
 *     <td>Loads Amos2 as a client an connects to the server, 
 *         creates a connection</td>
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
 *  This Class can only be instanciated once per JSP Application, <br>
 *  therefore the scope in the JSP-File calling this "Bean" must use 
 *  the scope="application"
 *  for this bean. <br>
 *  <b>!!!!!IMPORTANT!!!!!</b> <br>
 *  </ul>
 * <br>
 *  What does this class do/proviede : <br>
 * <br>
 * <ul>
 *   <li> either load an Amos2-Instance, make it become a client and
 *        connect to the amos2 
 *        and host which names are supplied or</li>
 *   <li> load an Amos2-Instance which will act as server & client 
 *        at once </li>
 *   <li> execute the queries on the embeded Amos2-Instance </li>
 * </ul>
 *
 * @author Dominik Busigner
 * @version 1.0
 */

public class Amos {

  // a Connection to an AMOS database
  private Connection connection = null;
  // True if the database has been loaded
  private boolean initialized = false;
  // True if transactions should be commited
  // after each modification.
  private boolean autocommit = false;
  // Store location & name of the image file
  private String imageFile = "";

  public void finalize() throws AmosException
  {
    connection.disconnect();
  }

  /**
   * Amos(String) initializes the Amos2-Database (embeded
   * as Client)and then connects to the "Server"-Amos2 using
   * the clientName, serverName and host parameters.
   * <br><br>
   * To make it impossible to load the database when it is allready loaded,
   * 'initialized' is set to 'true' at the end.<br><br>
   * <br><br>
   * @param imageFile full path and name to the Amos2-DumpFile.
   * @param servername Name of the Amos-Server to connect to.
   * @param clientname Name for embeded Amos (Client).
   * @param host location of Amos-Server. (if local, use "").
   *
   */
  public void startAmos(String localImageFile,
			String serverName,
			String nameServerHost,
			boolean autoCommit,
			boolean autoSave)
    throws AmosException
  {
      System.out.println("Initializing Amos II for " + localImageFile+":"+
                         serverName);
    if (!initialized) {
      this.imageFile = localImageFile;

      try {
	Connection.initializeAmos(localImageFile); // Load the image
      } catch (AmosException e) {
	// See if amos.dll was already loaded and an image was rolled-in.
	if ( ! (e.getMessage().indexOf("already initialized") > -1)) {
	  throw e;
	}
      }

      if (serverName == null) {
	connection = new Connection("");
      } else if (nameServerHost == null) {
	connection = new Connection(serverName);
      } else {
	connection = new Connection(serverName, nameServerHost);
      }

      setAutoSave(autoSave);
      setAutoCommit(autoCommit);

      initialized = true;
    }
  }

  public boolean isInitialized() {
    return initialized;
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
  public synchronized Scan jspExecute(String queryString)
    throws AmosException
  {
    Scan result = null;
    result = connection.execute(queryString);
    if (autocommit) {
      // Do not use Connection.commit() because it doesn't autosave the image
      connection.execute("commit;");
    }
    return result;
  }

  public boolean getAutoCommit() {
    return autocommit;
  }

  public void setAutoCommit(boolean state) {
    autocommit = state;
  }

  public boolean getAutoSave() throws AmosException {
    Tuple arg = new Tuple();
    Scan theScan;
    boolean result;

    theScan = connection.callFunction("AUTOSAVE->BOOLEAN", arg);

    if (theScan.eos()) {
      result = false;
    } else {
      result = theScan.getRow().getBooleanElem(0);
    }

    return result;

  }

  public void setAutoSave(boolean state) throws AmosException {
    Tuple arg = new Tuple(1);
    Scan theScan;
      
    arg.setElem(0, state);

    theScan = connection.callFunction("BOOLEAN.AUTOSAVE->BOOLEAN", arg);
  }

}
