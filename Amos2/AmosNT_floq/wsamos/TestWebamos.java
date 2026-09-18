package wsamos;
import java.util.*;

public class TestWebamos {

    public static void main (String[] args) throws Exception {
        WebamosService serv = new WebamosServiceLocator();
	
	System.out.println("Connecting to wsamos service...");
        java.net.URL url = new java.net.URL("http://130.238.12.248:8080/axis/services/Webamos");
        System.out.println("Connected OK");
	
        Webamos port = serv.getWebamos(url);

	/*	Webamos port = serv.getWebamos(); */
        System.out.println("Calling hello world...");
	String hl=port.sayHello(args[0]);
	System.out.println(hl);
        System.out.println("Callin amos service ...");
	Vector arg= new Vector();

	try{
	    System.out.println("\nFunctions published at WEB-AMOS server [Name, Arguments]:" );
	    Vector res= port.callFunction("WS_OPERATIONS_DESCR->CHARSTRING.VECTOR",new Vector());
	    Vector qres=(Vector)res.get(0);
	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
		System.out.println(ir.next());
	    }}
	catch (Exception e){
	    System.out.println(e.getMessage());}



	try{
	    arg= new Vector();
	    System.out.println("\nTesting function without arguments INFO->CHARSTRING.INTEGER:" );
	    Vector res= port.callFunction("INFO->CHARSTRING.INTEGER",arg);
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
	    System.out.println("\nTesting not published generic function INFO:" );
	    Vector res= port.callFunction("INFO",arg);}
	catch (Exception e){
	    System.out.println(e.getMessage());}

	try{
	    arg.add("select p from person p;");
	    System.out.println("\nTesting ad-hoc query 'select p from person p;' through EVAL:" );
	    Vector res= port.callFunction("EVAL",arg);
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
	    }
	    
	    System.out.println("\nTesting function INFO with oid argument(string encoding Oid of type person) read by previous query:" );
	    Vector tpl= (Vector)qres.get(0);
	    /* 1st tuple in the result*/
	    String oid = (String) tpl.get(0);
	    /* string encoding OID*/
	    arg = new Vector();
	    arg.add(oid);
	    res= port.callFunction("PERSON.INFO->CHARSTRING.INTEGER",arg);
	    qres=(Vector) res.get(0);
	    attr=(Vector) res.get(1);
	    System.out.println("Attributes:" );
	    for(java.util.Iterator ia=attr.iterator();ia.hasNext();){
		System.out.println(ia.next());
		}
	    System.out.println("Results:" );
	    for(java.util.Iterator ir=qres.iterator();ir.hasNext();){
		System.out.println(ir.next());
	    }
	   
	}
	catch (Exception e){
	    System.out.println(e.getMessage());}

	try{
	    System.out.println("\nTesting function GETAGE with string argument 'Milena':" );
	    arg= new Vector();
	    arg.add("Milena");
	    Vector res= port.callFunction("GETAGE",arg);
	    Vector qres=(Vector) res.get(0);
	    Vector attr=(Vector) res.get(1);
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
	    arg= new Vector();
	    arg.add("select name(t) from type t;");
	    System.out.println("\nTesting stopAfter=10 for query 'select t from type t;':" );
	    Vector res= port.callFunction("EVAL",arg,10);
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
    }
}

