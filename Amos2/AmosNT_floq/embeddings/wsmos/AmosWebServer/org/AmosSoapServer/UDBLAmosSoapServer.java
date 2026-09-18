package org.AmosSoapServer;

import org.quickserver.net.*;
import org.quickserver.net.server.*;

import callin.AmosException;
import callin.Connection;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.*;
import java.util.ArrayList;

public class UDBLAmosSoapServer {
    /**
     * A reference to other jSoapServer specific settings
     */
    public static final int STORE_JSOAPSERVER_SETTINGS = 1;
    private static String logName;
    private static boolean embedAmosLock=false; 
    private static String DBName=null;
    private static String currentUser=null;
   
    public static String getLogName(){
	return logName;
    }
    
    public static void setLogName(String newName){
	logName = newName;
    }
    /*set a lock on embedded amos*/ 
   public static void setLock(){
       	embedAmosLock=true;
    }
      /*release lock on embedded amos*/ 
   public static void releaseLock(){
       embedAmosLock=false;
    }
   /*get status of lock on embedded amos*/ 
   public static boolean getLock(){
       return embedAmosLock;
    } 
     /*set current user hold embedded amos*/ 
   public static void setUser(String user){
       //System.out.println("new user "+user);
       	currentUser=user;
    }
      /*release current user hold embedded amos*/ 
   public static void releaseUser(){
       //System.out.println("released user "+currentUser);
       currentUser=null;
    }
    
    public static void setConnectedDBName(String dbname){
	DBName=dbname;
    }
    public static String getConnectedDBName(){
	return DBName;
    }
    
   
    protected Object[] store = null;
    
    /**
     * Specifies if jSoapServer should support persistent
     * http connections
     */
    public static final String JSOAPSERVER_ENABLE_KEEP_ALIVE = "jSoapServer.keepAlive";
   
    public static void main(String s[])	{
		
	QuickServer SoapServer = new QuickServer();
		
	//setup logger to log to file
	Logger logger = null;
	FileHandler xmlLog = null;
	FileHandler txtLog = null;
	File log = new File("./log/");
	if(!log.canRead())
	    log.mkdir();
	try{
	    logger = Logger.getLogger("AmosSoapServer.log"); //get app logger
	    logger.setLevel(Level.FINEST);
	    boolean append = true;
	    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
	    String currentDate = sdf.format(new Date());

	    logName = "./log/AmosSoapServer.log."+currentDate;
	    System.out.println("logName = "+logName);
	    txtLog = new FileHandler(logName,append);
	    txtLog.setFormatter(new SimpleFormatter());
	    logger.addHandler(txtLog);
			
	    //img : Sets logger to be used for app.
	    //			SoapServer.setAppLogger(logger); 
	} catch(IOException e){
	    System.err.println("Could not create xmlLog FileHandler : "+e);
	}
		  
                    
                
	try{
	    // String amosHome = System.getenv("AMOS_HOME");
             String amosHome ="C:/udbl/AmosNT";
	    System.out.println("Initalizing embedded Amos II");
	    Connection.initializeAmos(amosHome+"/bin/amos2.dmp");
            //Connection.initializeAmos(amosHome+"/embeddings/wsmos/WEB-INF/wsqs.dmp");
		  
	    /*To create a logfile for the communication between embedded amos and the others*/
	    Connection theConnection = new Connection("");
	    //theConnection.execute("logfile('"+amosHome+"/embeddings/wsmos/AmosWebServer/log/wsmed.log','comm');");
            //theConnection.execute("logfile('','comm');");        
 
	    
		    
	}catch(AmosException e){
	    e.printStackTrace();
	    System.exit(1);
	}
		
		
	//load QuickServer from xml
	String confFile = "conf"+File.separator+"AmosSoapServer.xml";
	Object config[] = new Object[] {confFile};
	if(SoapServer.initService(config) == true) {
	    try	{
		SoapServer.startServer();
	    } catch(AppException e){
		System.out.println("Error in server : "+e);
	    } catch(Exception e){
		System.out.println("Error : "+e);
	    }
	}

    }
}
