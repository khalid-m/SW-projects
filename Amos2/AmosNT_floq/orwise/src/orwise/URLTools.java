package orwise;

import callin.*;
import callout.*;
import java.io.*;
import java.net.*;

class URLTools {

    public void existsURL(CallContext cxt, Tuple tpl) throws AmosException{
	String url="";
	try{
	    url = tpl.getStringElem(0);  //method argument
	}
	catch(AmosException e){
	    System.out.println("Amos-Error (reading) in method 'existsURL': "+e);
	    return;
	}
	//not implemented yet
	System.out.println("checks if URL "+url+" exists");
	tpl.setElem(0,"true");
	cxt.emit(tpl);
    }

    // not implemented yet
    /*writes an url (Syntax: http://www.whatever.domain) in a file*/
    public void getURL(CallContext cxt, Tuple tpl) throws AmosException{
	String urlString = "";
	String fileString = "";
	try{
	    //method arguments
	    urlString = tpl.getStringElem(0);
	    fileString = tpl.getStringElem(1);
	}
	catch(AmosException e){
	    System.out.println("Amos-Error (reading) in Method 'getURL': "+e);
	    return;
	}
	InputStream in = null;
	OutputStream out = null;
	try{
	    URL url = new URL(urlString);
	    in = url.openStream();
	    out = new FileOutputStream(fileString);
	    byte[] buffer = new byte [8192];
	    int bytes_read;
	    while((bytes_read=in.read(buffer)) != -1)
		out.write(buffer,0,bytes_read);
	}
	catch (Exception e) {
	    System.err.println(e);
	    System.err.println("getURL(<URL>,<Filename>)");
	}
	finally{
	    try{in.close(); out.close();}
	    catch (Exception e){}
	}
	tpl.setElem(0,"true");
	cxt.emit(tpl);
    }
    }
