import callin.*;
import callout.*;

public class SparQL {
    
  public SparQL() {}
        
  public void SparQL(CallContext cxt, Tuple tpl) throws Exception {
  
	Connection myCon;
	Scan myRes;
	String parsedQuery;
	
	// Pick up the argument
	String query = tpl.getStringElem(0);
	Tuple argl = new Tuple(1);
	argl.setElem(0,query);
	
	myCon = new Connection("");	
	parsedQuery = myCon.callFunction("charstring.parse_sparql->charstring",argl).getRow().getStringElem(0); 
	
	try 
	  {
			myRes = myCon.execute(parsedQuery);
			while (!myRes.eos()) 
		  {
				int arity;
				Tuple v;
				Tuple r;

				int j = 0;

				r = myRes.getRow();
				arity = r.getArity();
				v = new Tuple(arity);

				while (j < arity)
			  {
					v.setElem(j,r.getOidElem(j));
					j++;
			  }
				tpl.setElem(1,v);
				cxt.emit(tpl);
				myRes.nextRow();
		    }
	  }
	catch(AmosException e)
	    {
		throw(e);
	    }
    }
}