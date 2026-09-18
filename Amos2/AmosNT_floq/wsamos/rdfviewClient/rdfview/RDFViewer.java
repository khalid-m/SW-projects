/***************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Silvia Stefanova, UDBL
 * $RCSfile: RDFViewer.java,v $
 * $Revision: 1.7 $ $Date: 2008/04/24 14:22:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: RDFViewer web service client interface
 * =========================================================================
 * $Log: RDFViewer.java,v $
 * Revision 1.7  2008/04/24 14:22:54  silvias
 * Restart SWATM on the server side
 *
 * Revision 1.6  2008/04/18 14:54:36  silvias
 * *** empty log message ***
 *
 * Revision 1.5  2008/04/09 17:24:48  silvias
 * Method to restart a peer included
 *
 * Revision 1.4  2008/03/20 09:34:33  udbl
 * Added error message printing
 *
 * Revision 1.3  2007/09/13 14:00:53  udbl
 * Demo Client files
 *
 * Revision 1.2  2007/09/11 10:22:10  torer
 * Interface closer to specification
 *
 * Revision 1.1  2007/09/11 09:54:35  torer
 * Jave code
 *
 **************************************************************************/

package rdfview;

import java.util.Vector;
public class RDFViewer {
 
    RDFScan rs;
    String query;
    RDFViewWS port;
    RDFViewWSService serv;
    Vector arg;
    Vector res;
    String ress;
    String wrapper;
    Vector qres;
    Vector tmp1;
    Vector tmp2;
    Vector tmp3;
    Vector tmp4 = new Vector();
	
    public RDFViewer(String urlstr, String w) 
    {
	try
	    {
		wrapper = w;
		serv = new RDFViewWSServiceLocator();
		java.net.URL url = new java.net.URL(urlstr);
		port = serv.getRDFViewWS(url);
	
	    }
	catch (Exception e) 
	    {
		System.out.println(e.getMessage());
	    }
    }

    /**
     * Query the UPV.
     *
     * @param  q    a query in RDQL
     * @return      a scan holding the result
     */	
    public RDFScan RDQL(String q){
	

    	try{
	    q = q.toString();
	    arg= new Vector();
	    arg.add(wrapper);
	    arg.add(q);
	    res= port.callFunction("CHARSTRING.CHARSTRING.RDQLBINDS->VECTOR"
				   ,arg);
            
	}
	catch (java.rmi.RemoteException e){
 	    System.out.println(e.getMessage());
	}
	

	qres=(Vector)res.get(0);

	for(int i = 0; i < qres.size(); i++){

	    tmp1 = (Vector)qres.get(i);
	    tmp2 = (Vector)tmp1.get(0);
	    tmp3 = (Vector)tmp2.get(0);
            tmp4.add(tmp3);

	}

	rs = new RDFScan(tmp4);

	return rs;
	
    }

    /**
     * Query the UPV.
     *
     * @param  q    a query in SQL
     * @return      a scan holding the result
     */	
    public RDFScan SQL(String q) throws Exception{
	

         	try{
	    arg= new Vector();
	    arg.add(wrapper);
	    arg.add(q);
	    res= port.callFunction("CHARSTRING.CHARSTRING.SQLBINDS->VECTOR"
				   ,arg);
            
 	}
 	catch (java.rmi.RemoteException e){
 	    System.out.println(e.getMessage());
	}
	

	qres=(Vector)res.get(0);

	for(int i = 0; i < qres.size(); i++){

	    tmp1 = (Vector)qres.get(i);
	    tmp2 = (Vector)tmp1.get(0);
	    tmp3 = (Vector)tmp2.get(0);
            tmp4.add(tmp3);

	}

	rs = new RDFScan(tmp4);

	return rs;
	
    }

    /**
     * Query the UPV.
     *
     * @param  q    a query in SQL
     * @return      a scan holding the result
     */	

    public Vector RestartPeer(String xtm){
	

    	try{
	    arg= new Vector();
	    arg.add(wrapper);
	    arg.add(xtm);
	    res= port.callFunction("CHARSTRING.CHARSTRING.RESTART_SWATM_PEER->BOOLEAN", arg);
            
	}
	catch (java.rmi.RemoteException e){
	    System.out.println(e.getMessage());
	}
	
	qres=(Vector)res.get(0);

	return qres;



    }


    public RDFScan SPARQL(String q){
	

    	try{
	    arg= new Vector();
	    arg.add(wrapper);
	    arg.add(q);
	    res= port.callFunction("CHARSTRING.CHARSTRING.SPARQLBINDS->VECTOR"
				   ,arg);
            
	}
	catch (java.rmi.RemoteException e){
	    System.out.println(e.getMessage());
	}
	
       	qres=(Vector)res.get(0);

	for(int i = 0; i < qres.size(); i++){

	    tmp1 = (Vector)qres.get(i);
	    tmp2 = (Vector)tmp1.get(0);
	    tmp3 = (Vector)tmp2.get(0);
            tmp4.add(tmp3);

	}

	rs = new RDFScan(tmp4);

	return rs;
	
    }

}

