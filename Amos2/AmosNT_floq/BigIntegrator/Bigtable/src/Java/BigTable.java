import callin.*;

/**
  The standard JavaAMOS driver program.
  This is the typical format of all JavaAMOS drivers
  started from the command line.
  */
public class BigTable {

  public static void main(String argv[]) throws AmosException
  {
    Connection.initializeAmos(argv);  // Can only be called once
    Connection theConnection = new Connection("");
    theConnection.amosTopLoop("BigTable"); // Enters the AMOSQL top-loop
  }
}
