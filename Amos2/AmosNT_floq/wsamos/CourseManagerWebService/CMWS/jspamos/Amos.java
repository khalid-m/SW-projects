package jspamos;

import callin.*;

import java.io.File;
import java.util.Vector;

public class Amos {

	// a Connection to an AMOS database
	private Connection connection = null;
	// True if the database has been loaded
	private boolean initialized = false;
	// True if transactions should be committed after each modification.
	private boolean autocommit = false;
	/** 
	 *Store location & name of the image file
	 *For different user, you need to change this file path to your client.dmp location
	 */
	//private String userPath = new File("/Program Files/Apache Software Foundation/Tomcat 6.0/webapps/axis/WEB-INF").getAbsolutePath();
	private String catalinaHome = System.getenv("CATALINA_HOME");
        private String userPath = catalinaHome + "/webapps/axis/WEB-INF/";
        //private String userPath = System.getProperty("user.dir");


	public void finalize() throws AmosException {
		connection.disconnect();
	}

	public void startAmos(String imageFileName, String serverName,
			String nameServerHost, boolean autoCommit, boolean autoSave)
			throws AmosException {
		String imageFile = userPath + imageFileName;
		System.out.println("Initializing Amos II for " + imageFile + ":"+ serverName);
		if (!initialized) {
			try {
				Connection.initializeAmos(imageFile); // Load the image
				System.out.println("Initializing successfully!");
			} catch (AmosException e) {
				// See if amos.dll was already loaded and an image was rolled-in.
				if (!(e.getMessage().indexOf("already initialized") > -1)) {
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
	 * Method to grant access to the connection to amos.<br>
	 * <br>
	 * 
	 * @return callin.Connection
	 */
	public Connection getConnection(String imageFileName, String serverName) {
		Connection conn = this.connection;
		if (conn == null){
			try {
				startAmos(imageFileName,serverName,null,true,true);
			} catch (AmosException e) {
				System.out.println("Unable to connect to database");
				e.printStackTrace();
			}
			return this.connection;
		}else {
			return this.connection;
		}
	}

	/**
	 * JspExecute can be used to execute any queries on the database. <br>
	 * <br>
	 * 
	 * @param The
	 *            query to be executed on Amos2, including ";" at the end.
	 * @return callin.AmosScan
	 */
	public synchronized Scan jspExecute(String queryString)
			throws AmosException {
		Scan result = null;
		result = connection.execute(queryString);
		if (autocommit) {
			// Do not use Connection.commit() because it doesn't autosave the
			// image
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
