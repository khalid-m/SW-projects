package jspamos;

import callin.*;

public class StringScan{

	private Scan theScan;
	private Connection con;

	public StringScan(Scan s, Connection c){

		theScan = s;
		con = c;
	}

	public String current() throws AmosException{

		if(!theScan.eos()){
			return theScan.getRow().getStringElem(0);
		}
		return null;
	}

	public void nextRow() throws AmosException{

		theScan.nextRow();
	}

	public boolean eos(){

		if(theScan.eos()){
			return true;
		}
		return false;
	}

}

