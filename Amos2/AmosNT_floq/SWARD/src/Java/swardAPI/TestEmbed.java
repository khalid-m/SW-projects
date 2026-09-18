/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Silvia Stefanova, UDBL
 * $RCSfile: TestEmbed.java,v $
 * $Revision: 1.2 $ $Date: 2008/02/05 16:54:48 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Client demonstration program for RDFViewer
 * =========================================================================
 * $Log: TestEmbed.java,v $
 * Revision 1.2  2008/02/05 16:54:48  petrini
 * Added regression test of the three scenarios Company, eGov and eGovBus.
 * Added full support for composite keys.
 * Added regression test of combined foreign and composite keys.
 * Notice that support for compound foreign keys has yet to be implemented.
 *
 * Revision 1.1  2007/12/04 13:06:20  petrini
 * Added new interactive demo of SWARD JAVA API.
 *
 * Revision 1.3  2007/09/13 14:00:53  udbl
 * Demo Client files
 *
 * Revision 1.2  2007/09/11 10:08:10  torer
 * Interface closer to specification
 *
 **************************************************************************/
package swardAPI;

import java.util.*;
import java.io.*;
import callin.*;

public class TestEmbed {

    public void input(){

	RDFViewer s = null;
	Vector row;
	Vector arg;
	RDFScan res=null;
	String cont;
        String query;
	BufferedReader myIn;

	try{
	    myIn = new BufferedReader (new InputStreamReader(System.in));

	    System.out.print("\nChoose which SWARD database you are going to connect to: ");
	    System.out.flush();	
	    String swdb =myIn.readLine();

	    //Establish connection to SWARD database.
	    s = new RDFViewer(swdb);


            while(true){

		System.out.print("\nChoose which query language you are going to use RDQL, SQL or  SPARQL: ");
		System.out.flush();	
		String lang =myIn.readLine();

		//Execute RDQL; SQL or SPARQL query against the RDF view.
		if (lang.equals("RDQL") || lang.equals("SQL") || lang.equals("SPARQL"))
		    {
			System.out.print("\nWrite your query: ");
			System.out.flush();	
			query = myIn.readLine();
			try {
			    if (lang.equals("RDQL")) 
				res = s.RDQL(query);

			    /**
			     * Iterate over the result(RDFScan) of the query.
			     */
			    System.out.println("\nThe result:\n");
			    while(res.eof() != true){
				row = res.next();
				System.out.println(row);		
			    }
			
			}
			catch (Exception e) 
			    {
				System.out.print(e.getMessage());
				System.out.flush();	
				System.out.print("\nWould you like to continue, y or n ? ");
				System.out.flush();	
				cont =myIn.readLine();
				if(!cont.equals("y")) break;
			    }
		    } else{
			System.out.println("\nRDFViewer does not support this query language!");
			System.out.print("\nWould you like to continue, y or n ? ");
			System.out.flush();	
			cont =myIn.readLine();
			if(!cont.equals("y")) break;
		    }
	    }
	}catch(IOException io){io.getMessage();}
	
    }

    public static void main (String[] args){
    
	TestEmbed test = new TestEmbed();    
        test.input();
        System.exit(0);
    }
}


