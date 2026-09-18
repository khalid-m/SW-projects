import callin.*;

public class WSMED {

  public static void main(String argv[]) throws AmosException
  {
     Scan theScan; 
    Connection.initializeAmos(argv);  // Can only be called once
    
    Connection theConnection = new Connection("");
    Tuple arg = new Tuple(1);
    if (argv.length>2)
     arg.setElem(0,argv[2]);
    else
     arg.setElem(0,"me");	
    theScan = theConnection.callFunction(theConnection.getFunction("charstring.register->charstring"),arg );
    Tuple arg1 = new Tuple(0);
    if (argv.length>2)
     theScan = theConnection.callFunction(theConnection.getFunction("listen"),arg1);
    theConnection.amosTopLoop("wsmed"); // Enters the AMOSQL top-loop
    
      
      
    
  }
}
