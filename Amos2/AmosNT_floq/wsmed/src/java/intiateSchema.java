import callin.*;
import callout.*;

class intiateSchema{
    public void initoperation(CallContext cxt, Tuple tpl) throws AmosException
    {
	populateSchema ps= new populateSchema();
	 
	try { 
	       ps.buildComponents(tpl.getStringElem(0),cxt);
	    }
	     catch (Exception e) 
		 { 
		     e.printStackTrace(); 
		 } 
    }
}
