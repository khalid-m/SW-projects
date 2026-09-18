package udbl.amos.purejavaclient;

import java.io.*;
import java.util.Scanner;

public class TopLoop {
	public Connection cn;
	public int actionNo;
	public TopLoop() {
		actionNo=1;
	}
	//set father(p) = q from Person p, Person q where name(p)='Jacob' and name(q) = 'Sam';
	public static void main(String args[]) throws Exception {
		char c;
		String servName = null, address = null, prompt=null;
		String word = "",res;
		TopLoop tlp = new TopLoop();
		Scan sc= null;
//		System.out.print("Enter your IPaddress: ");
//		Scanner in = new Scanner(System.in);
//		address = in.nextLine();
//		System.out.print("Enter Server Name: ");
//		servName = in.nextLine();
//		System.out.print("Enter prompt Name: ");
		//prompt = in.nextLine();
		address ="localhost";
		servName= "a";
		prompt="test";
		tlp.cn = new Connection(address, servName);
		
		while (true) {
			word = "";
			int i=0;
			System.out.print(prompt+" "+tlp.actionNo+" >");
			while ((c = getChar()) != '\r') {
				word = word + c;
			}
			if (!word.equals("\r")) {
				sc=tlp.cn.execute(word);
				if(sc!=null){
					res=sc.getRow().getStringElem(0);
					//System.out.println(res);
					if (res.charAt(0)!='*')
						tlp.actionNo++;
					res="(";
					while(!sc.eos()){
						res += "("+sc.getRow().getStringElem(0) +")";
						sc.nextRow();
					}
					res+=")";
					System.out.println(res);
				}
			}
		}
	}

	static public char getChar() throws IOException {
		char ch = (char) System.in.read();
		return ch;
	}
}
