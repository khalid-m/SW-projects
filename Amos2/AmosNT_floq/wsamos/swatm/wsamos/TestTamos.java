package wsamos;
import java.util.*;

public class TestTamos {

    public static void main (String[] args) throws Exception {
        WebamosService serv = new WebamosServiceLocator();
	
	System.out.println("Connecting to wsamos service...");
        java.net.URL url = new java.net.URL("http://130.238.12.248:8080/axis/services/Webamos");
        System.out.println("Connected OK");
	
        Webamos port = serv.getWebamos(url);
        System.out.println("Calling amos services ...");
	Vector arg= new Vector();


// 	try{
// 	    arg= new Vector();
// 	    System.out.println("\nTesting function Topic Map schema to RDF triples:" );
// 	    Vector res= port.callFunction("TM_RDFSCHEMA_TRIPLES->CHARSTRING.CHARSTRING.CHARSTRING",arg);
// 	    Iterator i = res.iterator();
// 	    Vector qres=(Vector)i.next();
// 	    Vector attr=(Vector)i.next();
// 	    System.out.println("Attributes:" );
// 	    for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
// 		System.out.println(ia.next());
// 		}
// 	    System.out.println("Results:" );
// 	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
// 		System.out.println(ir.next());
// 	    }}
// 	catch (Exception e){
// 	    System.out.println(e.getMessage());}
	
	try{
	    System.out.println("\nTesting function LOADXTM with string argument 'hamlet.xtm':" );
	    arg= new Vector();
	    arg.add("hamlet.xtm");
	    Vector res= port.callFunction("LOADXTM",arg);
	    Vector qres=(Vector) res.get(0);
	    Vector attr=(Vector) res.get(1);
	    // System.out.println("Attributes:" );
	    //  for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
	    //	System.out.println(ia.next());
	    //	}
	    System.out.println("Results:" );
	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
		System.out.println(ir.next());
	    }}
	catch (Exception e){
	    System.out.println(e.getMessage());}

	try{
	    arg= new Vector();
	    System.out.println("\nTesting function Topic Map data to RDF triples:" );
	    Vector res= port.callFunction("TM_RDFDATA_TRIPLES->CHARSTRING.CHARSTRING.CHARSTRING",arg);
	    Iterator i = res.iterator();
	    Vector qres=(Vector)i.next();
	    Vector attr=(Vector)i.next();
	    System.out.println("Attributes:" );
	    for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
		System.out.println(ia.next());
		}
	    System.out.println("Results:" );
	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
		System.out.println(ir.next());
	    }}
	catch (Exception e){
	    System.out.println(e.getMessage());}
	
	try{
	    System.out.println("\nTesting to query TopicMaps schema in terms of RDF by RDQL:" );
	    arg= new Vector();
	    String Rdqlschema="SELECT ?tp FROM <swatm> WHERE(?tp, <rdf:type>, <rdf:Property>) (?tp, <rdfs:domain>, <swatm:TOPIC>) (?tp, <rdfs:range>, <rdfs:Literal>) AND ?tp != <swatm:IDTOPIC>";
	    arg.add(Rdqlschema);
	    Vector res= port.callFunction("RDQL",arg);
	    Vector qres=(Vector) res.get(0);
	    Vector attr=(Vector) res.get(1);
	    // System.out.println("Attributes:" );
// 	    for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
// 		System.out.println(ia.next());
// 		}
	    System.out.println("Results:" );
	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
		System.out.println(ir.next()); }

	    System.out.println("\nTesting to query TopicMaps data in terms of RDF by RDQL:" );
	    arg= new Vector();
	    String Rdqlcontent4="SELECT ?occurrence FROM <swatm> WHERE (?tm0 , <swatm:BASENAMETOPIC>, ?tm1) (?tm1 , <swatm:BASENAMESTRING>, 'Hamlet, Prince of Denmark') (?tm0 , <swatm:OCCURRENCETOPIC>, ?tm2) (?tm2 , <swatm:REFERENCE>, ?occurrence)";
	    arg.add(Rdqlcontent4);
	    Vector res2= port.callFunction("RDQL",arg);
	    Vector qres2=(Vector) res2.get(0);
	    //	    Vector attr=(Vector) res.get(1);
	    // System.out.println("Attributes:" );
// 	    for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
// 		System.out.println(ia.next());
// 		}
	    System.out.println("Results:" );
	    for(java.util.Iterator ir=qres2.iterator();ir.hasNext();){
		System.out.println(ir.next()); }



	}
	catch (Exception e){
	    System.out.println(e.getMessage());}
	
    }
}

