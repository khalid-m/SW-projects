package udbl.amos.purejavaclient;

import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import java.net.UnknownHostException;
import java.io.*;
public class ServerPortFinder {
	public int portNumber;
	/**
	 * @param args
	 * @throws AmosException 
	 * @throws IOException 
	 * @throws UnknownHostException 
	 * @throws NumberFormatException 
	 */
	public ServerPortFinder(Scan sc, String serverName) throws AmosException{
		portNumber=FindPortNumber(sc, serverName);
	}
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		//ServerPortFinder spf = new ServerPortFinder(serverAddress, servername, cn);
	}
	public int FindPortNumber(Scan s, String serverName) throws AmosException{
		String res="",server="";
		while(!s.eos()){
			res=s.getRow().getStringElem(0);
			res= res.substring(1, res.length()-1);
			server = serverName.toUpperCase();
			if(res.equals(server))
				return s.getRow().getIntElem(2);
			s.nextRow();
		}

		return -1;
	}

}
