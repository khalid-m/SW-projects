import callin.*;

/**
   Demo program illustrating an Amos II client application
   
   @author Tore Risch
   @version 1.0 (Last modified January 5, 2014)
*/

/***************************************************************************
 * NOTICE:                                                                 *
 * To run this program you have to:                                        *
 * 1. start amos2 server named 'wc' holding the 'world cup'                *
 *          database:                                                      *
 *    Windows:                                                             *
 *      start ..\bin\amos2 -O tutorial.amosql -n wc                        *
 *    Unix:                                                                *
 *      ../bin/amos2 -O tutorial.amosql -n wc&                             *
 * 2. Include path to folder with Amos binaries in system variable:        *
 *    Windows:                                                             *
 *      PATH                                                               *
 *    Linux:                                                               *
 *      LD_LIBRARY_PATH                                                    *
 *    OSX                                                                  *
 *      DYLD_LIBRARY_PATH                                                  *
 * 3. Compile the program with the command:                                *
 *      javac -cp "../bin/javaamos.jar" ClientDemo.java                    *
 * 4. Run the compiled program with the command:                           *
 *    Windows:                                                             *
 *      java -d32 -cp ".;../bin/javaamos.jar" ClientDemo                   *
 *    Unix:                                                                *
 *      java -d32 -cp ".:../bin/javaamos.jar" ClientDemo                   *
 **************************************************************************/

public class ClientDemo 
{
    public static void main(String argv[]) throws AmosException 
    {
	/*************************************/
	/*** Interface object declarations ***/
	/*************************************/
   
	Connection c; /* To hold a connection to an Amos server */
	Scan s;       /* To hold the result stream from an AmosQL query or 
			 function call */
	Tuple row;    /* To hold a row retrieved from database */
	Oid fn;	      /* To hold an object identifying a function */
	Tuple argl;   /* To hold a function argument list */

	String query;

	/****************************************/
	/*** Initialize and connect to server ***/
	/****************************************/

	/* Initialize Amos client interface: */
	Connection.initializeClient();

	/* Connect to the Amos database server named 'wc': */
	c = new Connection("wc");

	System.out.println("Connection to Amos server 'wc' OK");

	/*****************************************/
	/*** Execute query and scan the result ***/
	/*****************************************/

	query = 
	    "select name(host(t)), year(t) from Tournament t "+
	    "where year(t) < 1940;";
	System.out.println("Executing query:\n  "+query);
	s = c.execute(query);
	/* s is a 'scan' holding the result of the query */
	while (!s.eos())                /* While there are more rows in scan */
	    {	
		String host;
		int year;

		row = s.getRow();            /* Get current row in scan */
		host = row.getStringElem(0); /* Get 1st arg in row as string */
		year = row.getIntElem(1);    /* Get 2nd arg in row as integer */
		System.out.println("Host of year "+year+":"+host);
		s.nextRow();                 /* Advance scan forward */
	    }
	s.closeScan();                       /* Close the scan */
	/* The call to closeScan() is actually not needed here since the scan
	   is automatically closed by Java's garbage collector. 
	   The scans are also automatically closed when they are re-used.
	   It is, however, good to close scans as soon as possible to release 
	   resources. */

	/*****************************************/
	/*** Call function and scan the result ***/
	/*****************************************/

	System.out.println("Calling function host_name(1930):");

	/* Get the object identifying the function 'host_name': */
	fn = c.getFunction("host_name");

  
	/* The single function argument is the integer 1930: */
	argl = new Tuple();
	argl.setArity(1);   
	argl.setElem(0,1930);
        Object[] argl1= new Object[] {1930};

	s = c.callFunction(fn, argl); /* Call the function */

	/* Scan the result: */
	while(!s.eos())
	    {
		String host;

		row = s.getRow(); 
		host = row.getStringElem(0); 
		System.out.println("Host of year 1930: "+host);
		s.nextRow();    
	    }
	s.closeScan();
    }
}
 
