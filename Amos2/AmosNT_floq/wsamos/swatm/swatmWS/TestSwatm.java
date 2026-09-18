package swatmWS;
import java.util.*;

public class TestSwatm {

    public static void main (String[] args) throws Exception {

	Vector arg= new Vector();
	Vector res;

       	RDFViewer s = new RDFViewer("http://130.238.12.248:8080/axis/services/SwatmWS");

	/**
	 * Execute query against UPV .
	 */
	String content_hamlet = "SELECT ?occurrence FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm> WHERE (?tm0 , <swatm:BASENAMETOPIC>, ?tm1) (?tm1 , <swatm:BASENAMESTRING>, 'Hamlet, Prince of Denmark') (?tm0 , <swatm:OCCURRENCETOPIC>, ?tm2) (?tm2 , <swatm:REFERENCE>, ?occurrence)";

	String content_opera="SELECT ?basenamestring FROM <http://user.it.uu.se/~udbl/software/swatm/opera.xtm> WHERE (?tmo , <swatm:BASENAMESTRING> ?basenamestring)";
	res = s.query(content_hamlet);
	Vector qres=(Vector) res.get(0);
	Vector attr=(Vector) res.get(1);
	System.out.println("Results:" );
  
	for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
	    System.out.println(ir.next()); }


    }

}

