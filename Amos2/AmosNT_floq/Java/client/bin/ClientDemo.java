import java.io.IOException;
import java.util.Vector;

import udbl.amos.purejavaclient.*;

/**
  Demo program illustrating the Java <-> AMOSQL interface.
   
  @author Daniel Elin
  @version 1.0 (Last modified 981011)
  */

public class ClientDemo {

  public static void main(String argv[]) throws AmosException {
    
    Connection theConnection;	// To hold the connection to AMOS
    Scan theScan;	// To hold result streams from AMOS queries
			// and function calls
    Scan extraScan;	// Extra scan	
    Oid f1, f2, tpo, o;	    // Declares a variable to hold a reference to
			    	// to an AMOS object
    Tuple row;	    // To hold results from AMOS function calls
    Tuple arg1;	    // To hold AMOS function argument lists
    Tuple res1;	    // To hold result lists of updated AMOS functions
    int idno;	    // To hold identity number of AMOS OID

    if (argv.length != 0) {
      System.err.println("Usage: java AmosDemo <path to amos2.dmp>");
      System.exit(1);
    }

    // Create the connection
    //Connection.initializeAmos(argv[0]);
    //Connection.initializeClient();

    theConnection = new Connection("A");

    // Executing illegal AMOSQL from C with error trapping
    try {
      theConnection.execute("create type usertypeobject;");
    }
    catch (AmosException e) {
      System.out.println("(1) Error " + e);
      System.out.print("(1) theConnection.printerrform(): ");
      theConnection.printErrForm();
      System.out.flush();
    }

    // Execute query and scan the result
    // theScan is 'scan' holding the result of the query
    theScan = theConnection.execute("select name(t) from type t;");

//    Vector v = theScan.toVector();
//    AmosDemo.dumpHierarchy(v, 0);
    /*
    for(int i = 0; i < v.size(); i++) {
      String str;

      str = ((Vector)v.elementAt(i)).firstElement().toString();
      System.out.println("(2) Type " + str);
    }
    */
    while (!theScan.eos()) {	// While there are more rows in the scan
      String str;

      row = theScan.getRow();    // Get current row in the scan
      str = row.getStringElem(0);   // Get 1st arg in row as a string
      System.out.println("(2) Type " + str);
      theScan.nextRow();	    // Advance the scan forward
    }

    System.out.println("End of simple call test");
    // Calling Amos functions using the fast-path interface
    // Get a handle to the function to call
    f1 = null;
    try
    {

      f1 = theConnection.getFunction("charstring.typenamed->type");
    }
    catch (AmosException e) {
      System.out.println(e);
    }
    System.out.println("hej");
    arg1 = new Tuple();
    arg1.setArity(1);	    // There is one argument
    arg1.setElem(0, "FUNCTION");    // Bind string to first argument


    // theConnection.callFunction(f1, new Tuple("FUNCTION"));

    try {
      theScan = theConnection.callFunction(f1, arg1);	// Call the function
    }
    catch (AmosException e) {
      System.out.println(e);
    }
    System.out.print("(3) ");
    row = theScan.getRow();
    row.getOidElem(0).print();
    System.out.flush();

    // Populate new stored function salary
    theScan = theConnection.execute("create function salary (charstring name)-> <integer s, real sc>;");
    f2 = theConnection.getFunction("charstring.salary->integer.real");
    arg1 = new Tuple(1);  // Argument list holding 1 argument
    res1 = new Tuple(2);  // Result list holding 2 result values
    arg1.setElem(0, "Tore");
    res1.setElem(0, 1000);
    res1.setElem(1, 3.4);
    theConnection.addFunction(f2, arg1, res1);  // Add row to stored function

    // 2nd new row
    arg1.setElem(0, "Kalle");
    res1.setElem(0, 2000);
    res1.setElem(1, 2.3);
    theConnection.addFunction(f2, arg1, res1);

    // 3rd new row
    arg1.setElem(0, (Object)"Ulla");
    res1.setElem(0, new Integer(3000));
    res1.setElem(1, new Double(4.6));
    theConnection.addFunction(f2, arg1, res1);

    // Example of call to function with width >1
    arg1.setElem(0, "Tore");
    theScan = theConnection.callFunction(f2, arg1);
    row = theScan.getRow();
    System.out.println("(4) Name: Tore, salary: " +
		       row.getIntElem(0) + ", score: " +
		       row.getDoubleElem(1));

    // Excample of illegal function call
    arg1.setElem(0, 1);
    try {
      theConnection.callFunction(f2, arg1);
    }
    catch (AmosException e) {
      System.err.println("(5) Error: " + e);
    }
    // Create derived function that retrieves all tuples from salary function
    theScan = theConnection.execute("create function pdata()-> <charstring nm, integer s, real sc> as select nm,s,sc where salary(nm)=<s,sc>;");
    row = theScan.getRow();
    f2 = row.getOidElem(0);    // Bind f2 to single result from execute()

    // Retrieve all tuples from salary
    arg1.setArity(0);	// No arguments of pdata
    theScan = theConnection.callFunction(f2, arg1);   // Call pdata
    while (!theScan.eos()) {

      String name;

      row = theScan.getRow();
      name = row.getStringElem(0);
      System.out.println("(6) Name " + name +
			 ", Salary " + ((Integer)row.getElem(1)).intValue() +
			 ", Score " + ((Double)row.getElem(2)).doubleValue());
      theScan.nextRow();
    }

    theConnection.commit();	// Makes updates permanent in image

    // Object creation
    tpo = null;
    try {
        theConnection.execute("create type person properties (name charstring);");
      tpo = theConnection.getType("person");
    }
    catch (AmosException e) {
      System.out.println(e);
    }
    f1 = theConnection.getFunction("person.name->charstring");
    arg1.setArity(1);
    res1.setArity(1);

    // 1st object
    arg1.setElem(0, theConnection.createObject(tpo));
    res1.setElem(0, "Tore");
    theConnection.addFunction(f1, arg1, res1);
    // 2nd object
    arg1.setElem(0, theConnection.createObject(tpo));
    res1.setElem(0, "Kalle");
    theConnection.addFunction(f1, arg1, res1);
    // 3rd object
    arg1.setElem(0, theConnection.createObject(tpo));
    res1.setElem(0, "Ulla");
    theConnection.addFunction(f1, arg1, res1);

    // Delete the person named 'Tore'
    theScan = theConnection.execute("select p from person p where name(p) = 'Tore';");
    row = theScan.getRow();
    o = row.getOidElem(0);
    //theConnection.deleteObject(o);
    o.delete();

    // Print the names of all persons
    theScan = theConnection.execute("select name(p) from person p;");
    while (!theScan.eos()) {

      String str;

      row = theScan.getRow();
      str = row.getStringElem(0);
      System.out.println("(8) Person " + str);
      theScan.nextRow();
    }
    theScan.closeScan();    //?????

    // Create bag (set) valued stored function
    theScan = theConnection.execute("create function hobbies(person)-> bag of charstring;");
    row = theScan.getRow();
    f1 = row.getOidElem(0);    // Bind f1 to function 'hobbies'

    // Create inverse to function name(person)->charstring
    theScan = theConnection.execute("create function personnamed(charstring nm) -> person p as select p where name(p) = nm;");
    row = theScan.getRow();
    f2 = row.getOidElem(0);

    // Get person named 'Ulla'
    arg1.setArity(1);
    arg1.setElem(0, "Ulla");
    theScan = theConnection.callFunction(f2, arg1);
    row = theScan.getRow();
    o = row.getOidElem(0);	    // Bind o to person named 'Ulla'

    // Add some hobbies for person name 'Ulla'
    arg1.setElem(0, o);	    // Bind arg1 to person named 'Ulla'
    res1.setArity(1);
    res1.setElem(0, "Sailing");	    // Bind res1 to name of hobby
    theConnection.addFunction(f1, arg1, res1);
    res1.setElem(0, "Golfing");
    theConnection.addFunction(f1, arg1, res1);

    // Replace all hobbies with 'Painting' and 'Canoing'
    res1.setElem(0, "Painting");
    theConnection.setFunction(f1, arg1, res1);
    res1.setElem(0, "Canoing");
    theConnection.addFunction(f1, arg1, res1);

    // Delete hobby 'Painting'
    res1.setElem(0, "Painting");
    theConnection.remFunction(f1, arg1, res1);

    // The only remaining hobby should now be 'Canoing'. Let's check!
    theScan = theConnection.callFunction(f1, arg1);
    while (!theScan.eos()) {
      String hobby = "";
      row = theScan.getRow();
      try {
        hobby = row.getStringElem(0);
      }
      catch (AmosException e) {
        System.out.println(e);
      }
      System.out.println("(9) The remaining hobby is " + hobby);
      theScan.nextRow();
    }

    theConnection.rollback();	// Undoes database updates after last commit()
    try {
      theConnection.getType("person");
    }
    catch (AmosException e) {
      System.out.println("(10) Rollback worked!");
    }
    theConnection.getFunction("salary");
    System.out.println("(11) Commit worked!");

    // Demo OID property functions
    f1 = theConnection.getFunction("salary");	// Bind f1 to function OID
    System.out.println("(12) Investigating properties of object: " + f1);
    System.out.println("(13) The type: " + f1.getType());
    System.out.println("(14) The name: " + f1.getName());
    idno = f1.getID();
    System.out.println("(15) The IDno: " + idno);
    try {
      System.out.println("(16) Object number " + idno + " is: " +
		       theConnection.getObjectNumbered(idno));
    }
    catch (AmosException e) {
      System.out.println(e);
    }
    //theConnection.execute("create type person;");
    f1 = theConnection.createObject(theConnection.getType("PERSON"));
    System.out.println("(17) Creating unnamed object of type PERSON: " + f1);
    System.out.println("(18) The type: " + f1.getType());
    System.out.println("(19) The name: " + f1.getName());
    System.out.println("(20) The IDno: " + f1.getID());
    try {
      theConnection.getObjectNumbered(666);
    }
    catch (AmosException e) {
      System.out.println("(21) Error " + e.errno + ": " + e.errstr);
    }

    // Print the System type-hierarchy
    System.out.println("(24) The AMOS2 type-hierarchy:");
    theScan = theConnection.execute("get_type_structure(typenamed('OBJECT'));");
    Vector vv = (Vector)theScan.toVector().firstElement();
    ClientDemo.dfs((Vector)vv.elementAt(1), 0);
	try {
		Runtime.getRuntime().exec("taskkill /im amos2.exe /f");
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
  }

  public static void dfs(java.util.Vector v, int depth) throws AmosException {
    StringBuffer indent = new StringBuffer("");
    int i, j, s;
    Object o;

    if ((s = v.size()) > 0) {
      for(i = 0; i < s; i++) {
        o = v.elementAt(i);
        if (o instanceof java.util.Vector) {
          ClientDemo.dfs((Vector)o, depth + 1);
        }
        else {
          for(j = 0; j < depth; j++) indent.append("    ");
          System.out.println(indent.toString() + ((Oid)o).getName());
        }
      }
    }
  }

}
