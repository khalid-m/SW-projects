import callin.*;

/**
  The standard JavaAMOS driver program.
  This is the typical format of all JavaAMOS drivers
  started from the command line.
  */
public class JavaAMOS {

  public static void main(String argv[]) throws AmosException
  {
    Connection.initializeAmos(argv);  // Can only be called once
    System.out.println("Connecting");
    Connection theConnection = new Connection("");
    System.out.println("Entering top loop");
    theConnection.amosTopLoop("JavaAMOS"); // Enters the AMOSQL top-loop
  }
}
