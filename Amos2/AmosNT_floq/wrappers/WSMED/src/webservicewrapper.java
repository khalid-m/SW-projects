
import callin.*;
import callout.*;
import java.util.*;


public class webservicewrapper
{
    
    public  void initoperation (CallContext cxt, Tuple tpl) throws AmosException {
			
	try
	    { 
		tpl.setElem(8,(WSClient.invokeOperation(tpl)).getSeqElem(0));
		cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	
       } 
 
}
