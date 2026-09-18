import swardAPI.*;
import java.util.Vector;

public class SwardAPIDemo{

    public static void main(String argv[]){
	
	String username;
	String password;
	SwardScan res;
	int j;

	username = argv[0];
	password = argv[1];
	
	/**
	 * Declaring RDQL query.
	 */
	String hybrid = "SELECT ?s,?p,?val2 FROM <http://udbl.it.uu.se/upv/eGov/> WHERE (?s,<http://www.egov_project.org/GovMLSchema#Subject>,?val1), (?p,<http://www.w3.org/2000/01/rdf-schema#domain>, <http://udbl.it.uu.se/schemas/eGovern#LifeEvent>),(?s,?p,?val2) AND ?p != <http://www.egov_project.org/GovMLSchema#Subject> AND ?val1 =~ '%married%'";

	/**
	 * Create new Sward object.
	 */
	Sward s = new Sward();
	
	/**
	 * Connect to UPV with name 'eGov', username  and password .
	 */
	s.connect("eGov",username,password);
	
	/**
	 * Execute query against UPV .
	 */
	res = s.query(hybrid);
	
	while (!res.eof()){
	    
	    System.out.println("New result row: ");
	    System.out.println("=============== ");
			System.out.println("\n");
			
			Vector tmp = res.next();
			
	    j = 0;
	    while (j < tmp.size())
			{
				Vector pair = (Vector)tmp.get(j);				
				System.out.println("Variable " + (String)pair.elementAt(0) + " has value " + (String)pair.elementAt(1));
		    System.out.println("\n");
				j++;
	    }
	    System.out.println("\n");
	}

	/**
	 * Disconnect from UPV.
	 */
	s.disconnect("eGov");
    }
}
