package wsamos;
import java.util.*;

public class TestNewSward {

    public static void main (String[] args) throws Exception {

	Vector arg= new Vector();
	Vector res;
	String upv=args[0];
	String username=args[1];
	String password=args[2];

       	Sward s = new Sward("http://130.238.12.248:8080/axis/services/Webamos");

	/**
	 * Connect to UPV with name 'eGov', username  and password .
	 */
	s.connect(upv,username,password);

	/**
	 * Execute query against UPV .
	 */
	String hybrid = "SELECT ?s,?p,?val2 FROM <http://udbl.it.uu.se/upv/eGov/> WHERE (?s,<http://www.egov_project.org/GovMLSchema#Subject>,?val1), (?p,<http://www.w3.org/2000/01/rdf-schema#domain>, <http://udbl.it.uu.se/schemas/eGovern#LifeEvent>),(?s,?p,?val2) AND ?p != <http://www.egov_project.org/GovMLSchema#Subject> AND ?val1 =~ '%married%'";

	res = s.query(hybrid);
	Vector qres=(Vector) res.get(0);
	Vector attr=(Vector) res.get(1);
	System.out.println("Results:" );
	for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
	    System.out.println(ir.next()); }

	/**
	 * Disconnect from UPV.
	 */
	s.disconnect("eGov");


    }

}

