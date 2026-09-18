
import callin.*;
import callout.*;
import java.util.*;


public class webservicewrapper
{
    
    public  void initoperation (CallContext cxt, Tuple tpl) throws AmosException {
			
	try
	    { 
		tpl.setElem(12,(WSClient.invokeOperation(tpl)).getOidElem(0));
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	
       } 
    

 
}
