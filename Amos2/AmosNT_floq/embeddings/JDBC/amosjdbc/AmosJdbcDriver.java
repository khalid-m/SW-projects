/*
 * Created on 2004.10.01
 *
 * 
 */
package amosjdbc;

import java.sql.*;
import java.util.Properties;

/**
 * @author Giedrius Povilavicius
 *
 * 
 */
public class AmosJdbcDriver extends AmosJdbcObject implements Driver {
    
    protected boolean firsttime=true;
    protected String url=null;
    
    /**
     * Standart Driver class constructor.
     * @throws SQLException 
     */
    public AmosJdbcDriver() throws SQLException
    {
        //  Attempt to register this driver with the JDBC DriverManager.
        //  If it fails, an exception will be thrown.
        DriverManager.registerDriver(this);
        firsttime=true;
    }
    
    
    
    /**
     * Returns <code>true</code> if provided URL is acceptable for this driver
     * <p><b>Note:</b> Acceptable URL: "jdbc:amos://[hostname][:port]/dbname" 
     * @see java.sql.Driver#acceptsURL(java.lang.String)
     */
    public boolean acceptsURL(String url) throws SQLException {
        
        if (traceOn()) {
            trace("@acceptsURL (url=" + url + ")");
        }
        
        boolean rc = false;
        
        // Get the subname from the url.  If the url is not valid for
        // this driver, a null will be returned.
        if (getSubname(url) != null) {
            rc = true;
        }
        
        if (traceOn()) {
            trace(" " + rc);
        }
        return rc;
    }
    
    /**
     * Attempts to make connection to database. 
     * @param url - URL to database
     * @param info - parameters required for connection
     * @return Connection. In case of wrong <code>URL</code> returns <code>null</code>
     * @throws SQLException 
     * @see java.sql.Driver#connect(java.lang.String, java.util.Properties)
     */
    public Connection connect(String url, Properties info) throws SQLException {
        
        if (traceOn()) {
            trace("@connect (url=" + url + ")");
        }
        
        this.url=url;
        
        // Ensure that we can understand the given url
        if (!acceptsURL(url)) {
            return null;
        }
        
        if (info.getProperty("dumpfile")==null)
        {
            String subname = getSubname(url);
            if (subname.endsWith(".DMP"))
                info.setProperty("dumpfile",subname);
            else 
                info.setProperty("dumpfile",subname+".DMP");
        }
        // Create a new AmosJdbcConnection object
        AmosJdbcConnection con = new AmosJdbcConnection(this,info);
        
        return con;
    }
    
    /**
     * Returns major version number of this driver.
     * @see java.sql.Driver#getMajorVersion()
     */
    public int getMajorVersion() {
        return AmosJdbcDefine.MAJOR_VERSION;
    }
    
    /**
     * Returns minor version number of this driver.
     * @see java.sql.Driver#getMinorVersion()
     */
    public int getMinorVersion() {
        return AmosJdbcDefine.MINOR_VERSION;
    }
    
    /**
     * Returns list of required properties for connection
     * <p><b>Note:</b> This driver requires 1 property:
     * <p><code>directory</code> - Dump file directory
     * <p>Other possible properties:
     * <p><code>database</code> - Dump file 
     * <p><code>dbName</code> - Amos II nameserver
     * <p><code>nameServerHost</code> - IP of nameserver (needed only if it's not localhost )
     * @see java.sql.Driver#getPropertyInfo(java.lang.String, java.util.Properties)
     */
    public DriverPropertyInfo[] getPropertyInfo(String url, Properties info)
    throws SQLException {
        DriverPropertyInfo prop[];
        
        // Only 1 property is required for the Amos driver. The
        // directory where dump file is.  Check the property list coming in.  If the
        // directory and database is specified, return an empty list.
        
        
        // Setup the DriverPropertyInfo entry
        prop = new DriverPropertyInfo[4];
        prop[0] = new DriverPropertyInfo("directory", null);
        prop[0].description = "Dump file directory";
        prop[0].required = true;
        prop[1] = new DriverPropertyInfo("dumpfile", null);
        prop[1].description = "Dump file";
        prop[1].required = true;
        prop[2] = new DriverPropertyInfo("dbName", null);
        prop[2].description = "Amos II nameserver id";
        prop[2].required = false;
        prop[3] = new DriverPropertyInfo("nameServerHost", null);
        prop[3].description = "IP of nameserver";
        prop[3].required = true;
        
        return prop;
    }
    
    /** 
     * Returns <code>true</code> if this driver is JDBC compliant, <code>false</code> otherwise.
     * <p><b>Note:</b> In case of this driver it allways returns <code>false</code>  
     * 
     * @see java.sql.Driver#jdbcCompliant()
     */
    public boolean jdbcCompliant() {
        return false;
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    /**
     * Given a URL, returns the subname.  
     * 
     * @param url	String containing URL 
     * @return 		Subname. Returns <code>null</code> if the protocol is
     * not 'jdbc' or the subprotocol is not 'amos' 
     */
    private String getSubname(String url)
    {
        String subname = null;
        String protocol = "JDBC";
        String subProtocol = "AMOS";
        
        // Convert to upper case and trim all leading and trailing
        // blanks
        
        url = (url.toUpperCase()).trim();
        
        // Make sure the protocol is jdbc:
        if (url.startsWith(protocol)) {
            
            // Strip off the protocol
            url = url.substring (protocol.length());
            
            // Look for the colon
            if (url.startsWith(":")) {
                url = url.substring(1);
                
                // Check the subprotocol
                if (url.startsWith (subProtocol)) {
                    
                    // Strip off the subprotocol, leaving the subname
                    url = url.substring(subProtocol.length());
                    
                    // Look for the colon that separates the subname
                    // from the subprotocol (or the fact that there
                    // is no subprotocol at all)
                    if (url.startsWith(":")) {
                        subname = url.substring(1);
                        
                        //remove preceding "/" whats left should be dump file name
                        while (subname.startsWith("/")==true) 
                            subname = subname.substring(1);
                        
                    }
                    else if (url.length() == 0) {
                        subname = "";
                    }
                }
            }
        }
        return subname;
    }
}
