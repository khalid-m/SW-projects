/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Silvia Stefanova, UDBL
 * $RCSfile: TestWS.java,v $
 * $Revision: 1.5 $ $Date: 2008/04/14 12:44:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Client demonstration program for RDFViewer
 * =========================================================================
 * $Log: TestWS.java,v $
 * Revision 1.5  2008/04/14 12:44:05  silvias
 * *** empty log message ***
 *
 * Revision 1.4  2008/03/20 09:33:20  udbl
 * Changed equals with equalsIgnoreCases
 *
 * Revision 1.3  2007/09/13 14:00:53  udbl
 * Demo Client files
 *
 * Revision 1.2  2007/09/11 10:08:10  torer
 * Interface closer to specification
 *
 **************************************************************************/

package rdfview;
import java.util.*;
import java.io.*;

public class TestWS {

    public static void main (String[] args) throws Exception {

	Vector arg= new Vector();
	RDFScan res=null;
	Vector row;
	
	BufferedReader myIn = 
                      new BufferedReader (new InputStreamReader(System.in));

	String cont="y";
	
	do {
	    //System.out.println("");
	    System.out.print("\nChoose which wrapper you are going to use, SWARD or SWATM:\n ");
	    System.out.flush();
	    String wrapper =myIn.readLine();
	    
	    if (wrapper.equalsIgnoreCase("SWARD") || wrapper.equalsIgnoreCase("SWATM"))
	    {
		System.out.println("");
		System.out.print("Choose which query language you are going to use RDQL or  SPARQL:\n ");
		String lang =myIn.readLine();
			

	/**
	 * Execute RDQL; SQL or SPARQL query against the RDF view.
	 */
		if (lang.equalsIgnoreCase("RDQL") || lang.equalsIgnoreCase("SPARQL"))
		{

		    	System.out.println("");
		    	System.out.print("Write your query and do not forget to put a \";\" charcter at its end:\n ");
			//			String query =myIn.readLine();


			String c = new String();
			char cc;
			try {
			    do 
			    {
				cc = (char)myIn.read();
				c = c + cc;
			    }
			    while ( cc != ';' );

			}
			catch (IOException io)
			    {
				System.out.println(io.getMessage());
			    }
			
			String query;
			query=c.substring(0, c.length()-1);
			System.out.println("-------------------------------");
			String tom =myIn.readLine();

		       

			// String c="";
// 			int i;
// 			char cc;
			
// 			try {
// 			    while ((i = myIn.read()) != -1 )
// 			    {
// 				cc = (char) i;
// 				c = c + cc;
// 				if (cc == ';')
// 				    {
// 					break;
// 				    }
			
// 			    }
			   //  do {

				

			try {
			    RDFViewer s = new RDFViewer("http://udbl2.it.uu.se:8080/axis/services/RDFViewWS", wrapper);
			    if (lang.equalsIgnoreCase("RDQL")) 
			   res = s.RDQL(query);
			else if (lang.equalsIgnoreCase("SPARQL"))
			    res = s.SPARQL(query);
			/**
			 * Iterate over the result(RDFScan) of the query.
			 */
			System.out.println("The result");
			while(res.eof() != true){
			    row = res.next();
			    System.out.println(row);		
			}
			
			System.out.println("");
			}
			catch (Exception e) 
			    {
				System.out.println("\nThe query could not be executed because of possible syntax error.\n");
				}
		}
		else
		    System.out.println("RDFViewer does not support this query language\n");
	
		
	  }
	   else
	   {
	       System.out.println("This wrappers is not supported");
	    }
       
	    System.out.print("Would you like to continue, y or n ?");
	    cont =myIn.readLine();
	}
	while(cont.equals("y")); 

    }

}

