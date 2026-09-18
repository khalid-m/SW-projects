import callin.*;

public class SWARD {

  public static void main(String argv[]) throws AmosException
  {
    Connection.initializeAmos(argv);  // Can only be called once
    Connection theConnection = new Connection("");
    theConnection.amosTopLoop("SWARD"); // Enters the AMOSQL top-loop
  }
}
