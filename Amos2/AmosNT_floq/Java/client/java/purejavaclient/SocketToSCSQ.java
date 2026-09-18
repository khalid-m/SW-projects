package udbl.amos.purejavaclient;

import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;

public class SocketToSCSQ {
	private Socket scToSCSQ;
	private OutputStream out;
	private DataInputStream in;
	private int ServerPortNumber;
	private String ServerName;
	private String ServerAddress;
	public String recQuery;
	public SocketToSCSQ(String ipAddress, String serverName, int portNumber){
		ServerPortNumber=portNumber;
		scToSCSQ=null;
		out=null;
		in=null;
		ServerAddress=ipAddress;
		ServerName = serverName;
		recQuery="";
		connectSocketToSCSQ();
	}
	public void connectSocketToSCSQ(){
		try {
			scToSCSQ = new Socket(ServerAddress, ServerPortNumber);
			out = scToSCSQ.getOutputStream();
			in = new DataInputStream(scToSCSQ.getInputStream());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			System.out.println("Failed to connect the socket to server\":"+this.ServerName+"\"...");
		}
	}
	public void closeSocketToSCSQ(){
		try {
			scToSCSQ.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			System.out.println("Failed to close the socket to server\":"+this.ServerName+"\"...");
		}
	}
	public void WriteToSocket(String txtAddToOutputStream){
		byte[] byteArray = null;
		try {
			recQuery+=txtAddToOutputStream;
			byteArray = txtAddToOutputStream.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e1) {
			//e1.printStackTrace();
			System.out.println("Failed to change string to bytes for the socket to server\":"+this.ServerName+"\"...");
		}
		try {
			this.out.write(byteArray);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			System.out.println("Failed to write on the output stream of the socket to server\":" +
					this.ServerName+"\"...");
		}
	}
	public void SendToSocket(){
		try {
			//System.out.println("The query is sent: "+recQuery);
			recQuery="";
			if(!out.equals(null))
				this.out.flush();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			System.out.println("Failed to send over the socket to server\":"+this.ServerName+"\"...");
		}
	}
	static String rec="";
	public String ReadFromSocket() throws AmosException{
		int c;
		rec="";
		try {
			while ((c = this.in.read()) != 10) {
				rec +=(char) c;
			}
			if(rec.charAt(0)=='('){
				if(rec.charAt(1)=='*'){
					if(rec.charAt(2)=='*'){
						if(rec.charAt(3)==' '){
							if(rec.charAt(4)=='N'){
								if(rec.charAt(5)=='I'){
									if(rec.charAt(6)=='L'){
										while (rec.charAt(rec.length()-2) != ')' || rec.charAt(rec.length()-1) != ')'){
											rec+=ReadFromSocket();
										}
										errorThrower(rec);
									}
								}
							}
						}
					}
					
				}
			}
//(** NIL :ERROR (-1 "Type USERTYPEOBJECT already defined" NIL))				
		} catch (IOException e) {
			// TODO Auto-generated catch block
			//e.printStackTrace();
			System.out.println("Failed to read from the socket to server\":"+this.ServerName+"\"...");
		}
		return rec;
	}
	public void errorThrower(String rec)throws AmosException{
		String res="",errMsg="",errCode="";
		int i=0;
		res=rec.substring(16, rec.length());
		while(i<res.length() && res.charAt(i)!=' '){
			errCode+=res.charAt(i++);
		}
		while(i<res.length()){
			if(res.charAt(i)==' '){
				if(res.length()>(i+1)){
					if(res.charAt(i+1)=='N'){
						if(res.length()>(i+2)){
							if(res.charAt(i+2)=='I'){
								if(res.length()>(i+3)){
									if(res.charAt(i+3)=='L'){
										break;
									}
								}
							}
						}
					}
				}
			}
			errMsg+=res.charAt(i++);
		}
		throw new AmosException(Integer.parseInt(errCode), null, errMsg);
		//return "0";
		
	}
	public void Close(){
		try {
			this.scToSCSQ.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println("Failed to close the socket to server\":"+this.ServerName+"\"...");
			//e.printStackTrace();
		}
	}
}
