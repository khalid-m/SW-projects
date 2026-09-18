package orwise;

import callin.*;
import callout.*;
import java.util.Vector;
import java.util.HashMap;
import java.lang.Math.*;
import java.util.Date;

class W_Swissquote extends SearchEngine{
    //Oid oidMyType; if uncommented: lets the JVM crash
    Date time;
    W4F_Swissquote sq;
    Vector currency = new Vector();
    Vector bid = new Vector();
    Vector mid = new Vector();
    Vector ask = new Vector();
    Vector change = new Vector();

    //Constructor
    W_Swissquote(){
	time = new Date();
	searchEngine = "Swissquote";
	DebugSE.tracer.msg("W_Swissquote created");
	// Defining the AMOS-Type which is used by the wrapper
	try{
	    oidMyType = theConnection.getType("CURRENCY_TABLE");
	}
	catch(AmosException e){
	    System.err.println(e);
	    return;
	}
    }

    SearchEngine callWrapper(Vector propertiesVec) throws AmosException{
    
	HashMap argsHashMap = new HashMap();
	try{
	    argsHashMap = this.getHashMap(propertiesVec, searchEngine);
	}
	catch(AmosException e){
	    throw e;
	}

	try {
	    sq = W4F_Swissquote.search();
	}
	catch(Exception e){
	    System.err.println("W4F Exception: "+e);
	    return null;
	}
	try{
	    this.translateResults(sq);
	    return this;
	}
	catch(NoResultsException e){
	    return null;
	}
    }

    void fillFunctions(Oid oidDocument, int i) throws AmosException{
	Tuple res2 = new Tuple(1);
	Tuple res3 = new Tuple(1);
	Tuple res4 = new Tuple(1);
	Tuple res5 = new Tuple(1);
	Tuple arg2 = new Tuple(1);
	Oid oidTimeType, oidTime;
	Oid fCurrency, fBid, fMid, fAsk, fChange, fTimeVal, fYear, fMonth, fDay, fHour, fMinute, fSearchEngine;

	try{
	    /* oidTimeType = theConnection.getType("TIME");
	       oidTime = theConnection.createObject(oidTimeType); */

	    fCurrency = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.CURRENCY->CHARSTRING");
	    fBid = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.BID->REAL");
	    fMid = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.MID->REAL");
	    fAsk = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.ASK->REAL");
	    fChange = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.CHANGE->REAL");
	    /*fTimeVal = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.TIME->TIME");
	      fYear = SearchEngine.theConnection.getFunction("DATE.YEAR->INTEGER");
	      fMonth = SearchEngine.theConnection.getFunction("DATE.MONTH->INTEGER");
	      fDay = SearchEngine.theConnection.getFunction("DATE.DAY->INTEGER");
	      fHour = SearchEngine.theConnection.getFunction("TIME.HOUR->INTEGER");
	      fMinute = SearchEngine.theConnection.getFunction("TIME.MINUTE->INTEGER"); */
	    fSearchEngine = SearchEngine.theConnection.getFunction("CURRENCY_TABLE.WEBSOURCE->CHARSTRING");

	    arg1.setElem(0, oidDocument);
	    /* arg2.setElem(0, oidTime);  */
	}
	catch(AmosException e){
	    System.out.println(e);
	    return;
	}
	try{
	    if (this.currency.elementAt(i) == null) {
		res1.setElem(0,"");
	    }
	    else {
		res1.setElem(0,this.currency.elementAt(i));
	    }
	    theConnection.addFunction(fCurrency,arg1,res1);

	    if (this.bid.elementAt(i) == null){
		res1.setElem(0,"");
	    }
	    else {
		res1.setElem(0,this.bid.elementAt(i));
	    }
	    theConnection.addFunction(fBid, arg1, res1);

	    if (this.mid.elementAt(i) == null){
		res1.setElem(0,"");
	    }
	    else {
		res1.setElem(0,this.mid.elementAt(i));
	    }
	    theConnection.addFunction(fMid,arg1,res1);

	    if (this.ask.elementAt(i) == null){
		res1.setElem(0,"");
	    }
	    else {
		res1.setElem(0,this.ask.elementAt(i));
	    }
	    theConnection.addFunction(fAsk,arg1,res1);

	    if (this.change.elementAt(i) == null){
		res1.setElem(0,"");
	    }
	    else {
		res1.setElem(0,this.change.elementAt(i));
	    }
	    theConnection.addFunction(fChange,arg1,res1);

	    // Instanciated Date is never null -> no check
	    res1.setElem(0,(int)(time.getYear() + 1900));
	    res2.setElem(0,(int)(time.getMonth() + 1));  // 0 = January
	    res3.setElem(0,(int)time.getDate());
	    res4.setElem(0,(int)time.getHours());
	    res5.setElem(0,(int)time.getMinutes());

	    //theConnection.addFunction(fYear,arg2,res1);
	    //theConnection.addFunction(fMonth,arg2,res2);
	    //theConnection.addFunction(fDay,arg2,res3);
	    //theConnection.addFunction(fHour,arg2,res4);
	    //theConnection.addFunction(fMinute,arg2,res5);

	    //theConnection.addFunction(TimeVal, arg1, arg2);

	    //write SearchEngine
	    if (this.searchEngine==null){
		res1.setElem(0,"");
	    }
	    else{
		res1.setElem(0,this.searchEngine);
	    }
	    theConnection.addFunction(fSearchEngine,arg1,res1);
	}
	catch(AmosException e){
	    System.out.println("AMOS Error (writing)"+e);
	    return;
	}
    }

    /*this method translates the specific W4F-Object into a general SearchEngine-Object
     */
    void translateResults(W4F_Swissquote W4FResults) throws NoResultsException{
	if (W4FResults.currency != null){
	    count = W4FResults.currency.length;
	}
	else{
	    throw new NoResultsException("No entries found");
	}

	/*time = new Date();
	  String minute;
	  String hour = W4FResults.time.substring(13,15);
	  // before noon remove ":" between hour and minutes: e.g. 9:31, not 09:31
	  if (hour.substring(1,2).equals(":")){
	  hour = hour.substring(0,1);
	  minute = W4FResults.time.substring(15,17);
	  }
	  else{
	  minute = W4FResults.time.substring(16,18);
	  }
	  time.setHours(Integer.parseInt(hour));
	  time.setMinutes(Integer.parseInt(minute));*/

	for (int i=0;i<count;i++){
	    if (W4FResults.currency != null){
		this.currency.addElement(W4FResults.currency[i]);
	    }
	    if (W4FResults.bid != null){
		this.bid.addElement(this.dTest(W4FResults.bid[i]));
	    }
	    if (W4FResults.mid != null){
		this.mid.addElement(this.dTest(W4FResults.mid[i]));
	    }
	    if (W4FResults.ask != null){
		this.ask.addElement(this.dTest(W4FResults.ask[i]));
	    }

	    double d;
	    Double DTemp;
	    // changes of swissquote are either plus or minus and in percent -> / 100

	    //if negative
	    if (W4FResults.change != null){
		if (W4FResults.change[i].substring(0,1).equals("-")){
		    DTemp = Double.valueOf(W4FResults.change[i].substring(0,5));
		}
		//if 0
		else if (W4FResults.change[i].substring(1,2).equals("&")){
		    DTemp = new Double(0);
		}
		//if positive
		else{
		    DTemp = Double.valueOf(W4FResults.change[i].substring(0,4));
		}
		d = DTemp.doubleValue();
		Double C = new Double (d/100);

		/*Double C = new Double (d);*/
		this.change.addElement(C);
	    }
	}
    }
}
