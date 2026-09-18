import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;


public class trazan {
    public static void main(String args[]) throws AmosException {
	Connection.initializeAmos(args[0]);
        try{Connection con = new Connection("FEL");}
        catch (AmosException e) {System.out.println("Catching connect");}
        {Connection con = new Connection("FOO");}
        System.out.println("Connecting to FOO succeded");
        int j = Integer.parseInt(args[1].trim()); 
	for(int i=0; i<j; i++ )
	    {
		Tuple argl=new Tuple(1);
		Connection con = new Connection("FOO");
		con.callFunction("OBJECT.ID->OBJECT",argl);
		con.disconnect();
	    }
    }
}
