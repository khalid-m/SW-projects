
import callin.*;
import callout.*;
import java.util.*;


public class webservicewrapper
{
    
    public  void initoperation (CallContext cxt, Tuple tpl) throws AmosException {
			
	try
	    {
	      	tpl.setElem(9,WSClient.invokeOperation(tpl));
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	
       } 
 
}
