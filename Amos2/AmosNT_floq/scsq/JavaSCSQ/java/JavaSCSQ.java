import callin.*;

public class JavaSCSQ 
{
    public static void main(String argv[]) throws AmosException 
    {
	Connection.initializeAmos(argv, "JavaSCSQ"); // Loads JavaSCSQ DLL
	Connection theConnection = new Connection("");
	theConnection.amosTopLoop("JavaSCSQ"); // Enters the SCSQ top-loop
    }
}

