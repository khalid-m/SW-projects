
import callin.*;
import callout.*;
import java.util.*;
import javax.xml.soap.*;

public class webservicewrapper
{
      
    public void initoperation (CallContext cxt, Tuple tpl) throws AmosException, SOAPException, java.net.MalformedURLException{
	WSClient wc= new WSClient();
	try { 
	    tpl.setElem(14,(wc.invokeOperation(cxt,tpl)).getOidElem(0));
            tpl.setElem(15, wc.getTime());
	    cxt.emit(tpl);
	}
	catch(AmosException ex){
            System.err.println("Error invoking operation >>: "+ tpl.getStringElem(0));
	    System.out.println(ex.getMessage());
	    ex.printStackTrace();
            if (((ex.getMessage()).toString()).indexOf("Message Send Failed Due to Timeout of Web Service") > -1){
	      Tuple temptpl=new Tuple(1);
              temptpl.setElem(0,"Message Send Failed Due to Timeout of Web Service");
              tpl.setElem(14,temptpl);
	      tpl.setElem(15, wc.getTime());
	      cxt.emit(tpl);
              //throw new AmosException(ex.getMessage());
	    }
	    else{
		Tuple temptpl=new Tuple(0);
		tpl.setElem(14,temptpl);
		tpl.setElem(15, wc.getTime());
		cxt.emit(tpl);
	
		if ((tpl.getIntElem(13))==1)
		    throw new AmosException(ex.getMessage());
	    }
	    
	}
	
    } 
    
 
}
