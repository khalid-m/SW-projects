package jspamos;

import callin.AmosException;
import callin.Connection;
import callin.Scan;
import callin.Tuple;

public class TupleScan{

	private Scan theScan;
	private Connection con;

	public TupleScan(Scan s, Connection c){

		theScan = s;
		con = c;
	}

	public Tuple current() throws AmosException{

		if(!theScan.eos()){
			return theScan.getRow();
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
