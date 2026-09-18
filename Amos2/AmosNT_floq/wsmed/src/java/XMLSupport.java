/**
 *  @author  Manivasakan Sabesan
 */
import java.io.IOException;
import java.io.StringWriter;
import java.io.StringReader;
import java.io.Reader;

import org.exolab.castor.xml.schema.*;
import org.exolab.castor.xml.schema.reader.SchemaReader;
import org.exolab.castor.xml.schema.writer.SchemaWriter;

import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.util.List;
import java.util.Iterator;
import java.io.File;
import java.lang.Object;
import java.util.*;


import javax.xml.soap.Name;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPConnection;
import javax.xml.soap.SOAPConnectionFactory;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPHeader;
import javax.xml.soap.SOAPHeaderElement;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPBodyElement;
import javax.xml.soap.SOAPMessage;
import javax.xml.soap.SOAPPart;
import javax.xml.soap.MimeHeaders;


 import org.jdom.Document;
 import org.jdom.Element;
 import org.jdom.JDOMException;
 import org.jdom.input.SAXBuilder;
 import org.jdom.output.XMLOutputter;
 import org.jdom.*;  
 import org.jdom.adapters.*;  
 import org.jdom.input.* ; 
 import org.jdom.output.* ; 
 import org.jdom.transform.* ;

 import callin.*;
 import callout.*;



/**
 * XML support and utilities
 */

public class XMLSupport {
    
    static String dummyele="";
    static int outputeleindex=0;
    static String faultstring_str;
    static String faultdetail_str;
    static String faultcode_str;

    private XMLSupport()throws AmosException {
    }
    public static Tuple webserviceResponse(SOAPMessage response, Tuple output, CallContext cxt) throws SOAPException,AmosException  {  
	
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl;

	SOAPBody sb=response.getSOAPBody();
	Iterator sei=sb.getChildElements();
	Tuple tpl = new Tuple((sb.getChildNodes()).getLength());
	int tplindex=0;
	int initoei;
	
	outputeleindex=0;
	while (sei.hasNext()) {
	    SOAPBodyElement bodyElement = findSOAPBodyElement(sei);
	    	
	    if (bodyElement.hasChildNodes()) {
		initoei=outputeleindex;
			
		outputeleindex=outputeleindex-2;
		Tuple restpl=getSoapElement(bodyElement,output,cxt);
		Tuple etpl= new Tuple(2);
		etpl.setElem(0,output.getOidElem(1));
		etpl.setElem(1,(bodyElement.getElementName()).getLocalName());
		
				
		s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
			
		if ((s.getRow()).getIntElem(0)>0) { 
		    if (restpl.getArity()==1) {
			mtpl=new Tuple(1);
			mtpl.setElem(0,restpl.getOidElem(0));
		    }
		    else
			mtpl=restpl;
		
		   
		    if (seiind==0)
			tpl.setElem(tplindex,(makeRecord(initoei,(bodyElement.getElementName()).getLocalName(),mtpl,output,cxt)).getOidElem(0));
		    else
			tpl.setElem(tplindex,(putRecord(tpl,initoei,(bodyElement.getElementName()).getLocalName(),mtpl,output,cxt)).getOidElem(0));
		    outputeleindex=outputeleindex+2;
		}
	        else {
		    tpl.setElem(tplindex,restpl.getOidElem(0));
		    tplindex++;
		} 
	    }
	    
	    seiind++;
		
	}

	return tpl;
    }

    public static Tuple rpc_webserviceResponse(SOAPMessage response, Tuple output, CallContext cxt) throws SOAPException,AmosException {  

	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl= new Tuple(1);
	
	SOAPBody sb=response.getSOAPBody();
	Iterator sei=sb.getChildElements();
        
	int sb_no_of_children=findChildren(sb.getChildElements());

	Tuple tpl;
	int tplindex=0;
	int sbeindex=0,  no_of_children=0;

       	SOAPBodyElement bodyElement=null;
	String checkstr=null;
	
	bodyElement = findSOAPBodyElement(sei);
	checkstr=(bodyElement.getElementName()).getLocalName();
	no_of_children=findChildren(bodyElement.getChildElements());
	String outelement=findElement(sbeindex,output,cxt);

	String childstr="";
	Tuple resulttpl= new Tuple(1);	 
	int iterval=0;
	boolean found=false;
	outputeleindex=0;
	int initval=outputeleindex;

	if (checkstr.equalsIgnoreCase(outelement)){
	    //System.out.println("testing1");
	    tpl=new Tuple(1);
	    tpl=webserviceResponse(response,output,cxt);
	    if (tpl!=null)
		tpl.setElem(0,tpl.getOidElem(0));
	}
	else {
	    if (sb_no_of_children==1){
		//System.out.println("testing 2");
		tpl=new Tuple(1);
		tpl=webserviceResponse1(bodyElement,output,cxt);
		if (tpl!=null)
		    tpl.setElem(0,tpl.getOidElem(0));
	    }
	    else {
		//System.out.println("testing 3");
		while (sei.hasNext()&& !found){
		    bodyElement = findSOAPBodyElement(sei);
		   			
		    childstr=(bodyElement.getElementName()).getLocalName();
		    
		    sbeindex=sbeindex+2;
			
			
		    if ((childstr.equalsIgnoreCase(findWSDLtype(outputeleindex,output,cxt)))||(outputeleindex==2))
			found=true;
		    else {
			no_of_children=findChildren(bodyElement.getChildElements());
			outelement=findElement(sbeindex,output,cxt);
		    }
		    outputeleindex=outputeleindex+2;
			    
		}
                    
			
		
		tpl = new Tuple(no_of_children);
		int sbindex=sbeindex;
		Oid m;
		String name;
		Tuple temptpl;
	
		outputeleindex=outputeleindex-2;
		if (no_of_children==1) {
		    temptpl= new Tuple(1);
		
		    if (bodyElement.hasChildNodes()) {
			Iterator csei=bodyElement.getChildElements();
			
			SOAPBodyElement cbodyElement = findSOAPBodyElement(csei);
			String celename=(cbodyElement.getElementName()).getLocalName();
				
			name=findElement(sbeindex,output,cxt);
			if (!(name.equalsIgnoreCase(childstr)))
			    dummyele=findElement(sbeindex-2,output,cxt);
			String elename;

			if (!(dummyele.equalsIgnoreCase("")))
			    elename=dummyele;
			else
			    elename=name;
			Tuple etpl=new Tuple(2);
				
			etpl.setElem(0,output.getOidElem(1));
			etpl.setElem(1,elename);
			    
				
			s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
			    
			outputeleindex=outputeleindex-2;
			if (!s.eos()) {
			    if (!((((s.getRow()).getIntElem(0))==1)&& (maxOccurs(outputeleindex+2,output,cxt))))
				mtpl.setElem(0,getSoapElement(bodyElement,output,cxt).getOidElem(0));
			    else
				mtpl.setElem(0,getSoapElement(bodyElement,output,cxt)); 
			}
					
						    
			int tempoutputeleindex=outputeleindex;
			outputeleindex = sbeindex-2;
			while (sbeindex>=0)	{	
			    if (sbeindex==sbindex) {
				if (name.equalsIgnoreCase(childstr))
				    temptpl.setElem(0,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),mtpl,output,cxt)).getOidElem(0));
				else {
				    sbeindex=sbeindex-2;
				    temptpl.setElem(0,(makeRecord(outputeleindex,findElement(sbeindex,output,cxt),mtpl,output,cxt)).getOidElem(0));
				}
							
			    }
			    else  {
				String tempele=findElement(sbeindex,output,cxt);
				if (maxOccurs(sbeindex,output,cxt))	{
				    Tuple ttpl= new Tuple(1);
				    ttpl.setElem(0,temptpl);
				    temptpl.setElem(0,(makeRecord(outputeleindex,tempele,ttpl,output,cxt)).getOidElem(0));
				}
				else
				    temptpl.setElem(0,(makeRecord(outputeleindex,tempele,temptpl,output,cxt)).getOidElem(0));
			    }
			    sbeindex=sbeindex-2;
			    outputeleindex=outputeleindex-2;
			}	
			outputeleindex=tempoutputeleindex;
			   				    
			tpl.setElem(tplindex,temptpl.getOidElem(0));
			   
			tplindex++;
		    }
		}
		else  {
		
		    int tempoutputeleindex1=outputeleindex;
		    while(sei.hasNext()) {
			sbeindex=sbindex;
			temptpl= new Tuple(1);
			if (iterval>0) {
			    bodyElement=findSOAPBodyElement(sei);
			    outputeleindex=tempoutputeleindex1;
			}
				
					
			if (bodyElement.hasChildNodes()) {	
			    Iterator csei=bodyElement.getChildElements();
			    SOAPBodyElement cbodyElement = findSOAPBodyElement(csei);   
			    String celename=(cbodyElement.getElementName()).getLocalName();
			    name=findElement(sbeindex,output,cxt);
			    if (!(name.equalsIgnoreCase(childstr)))
				dummyele=findElement(sbeindex-2,output,cxt);
						
			    String elename;
						
			    if (!(dummyele.equalsIgnoreCase("")))
				elename=dummyele;
			    else
				elename=name;
			    Tuple etpl=new Tuple(2);
						
			    etpl.setElem(0,output.getOidElem(1));
			    etpl.setElem(1,elename);
			
			    s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
			    outputeleindex=outputeleindex-2;
			    if (!s.eos())  {
				if (!((((s.getRow()).getIntElem(0))==1)&& (maxOccurs(outputeleindex+2,output,cxt))))
				    mtpl.setElem(0,getSoapElement(bodyElement,output,cxt).getOidElem(0));
				else
				    mtpl.setElem(0,getSoapElement(bodyElement,output,cxt)); 
							
			    }
				
			    int tempoutputeleindex=outputeleindex;
			    outputeleindex = sbeindex;
			    while (sbeindex>=0)  {	
				if (sbeindex==sbindex)  {
					
				    if (name.equalsIgnoreCase(childstr))
					temptpl.setElem(0,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),mtpl,output,cxt)).getOidElem(0));
				    else  {
					sbeindex=sbeindex-2;
					outputeleindex=outputeleindex-2;
					temptpl.setElem(0,(makeRecord(outputeleindex,findElement(sbeindex,output,cxt),mtpl,output,cxt)).getOidElem(0));
				    }
				}
				else {
				    String tempele=findElement(sbeindex,output,cxt);
				    if (maxOccurs(sbeindex,output,cxt)) {
					Tuple ttpl= new Tuple(1);
					ttpl.setElem(0,temptpl);
					temptpl.setElem(0,(makeRecord(outputeleindex,tempele,ttpl,output,cxt)).getOidElem(0));
				    }
				    else   {
					temptpl.setElem(0,(makeRecord(outputeleindex,tempele,temptpl,output,cxt)).getOidElem(0));
				    }
							
				}

				sbeindex=sbeindex-2;
				outputeleindex=outputeleindex-2;
			    }
					
							
			    outputeleindex=tempoutputeleindex;
			    tpl.setElem(tplindex,temptpl.getOidElem(0));
			    tplindex++;
			
			    iterval++;
			}
					
			
					
		    }
		}
			
	    }
	}

	outputeleindex=0;


	return tpl;
    }
    public static Tuple webserviceResponse1(SOAPBodyElement sb, Tuple output, CallContext cxt) throws SOAPException,AmosException  {  

	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl= new Tuple(1);

	Iterator sei=sb.getChildElements();
	
        int no_of_children=findChildren(sb.getChildElements());
	Tuple tpl = new Tuple(no_of_children);
	int tplindex=0;


	if (!sei.hasNext()) {
	    tpl=null;
	    
	}
	else  {	    
	    while (sei.hasNext()) {
		SOAPBodyElement bodyElement=null;
		bodyElement = findSOAPBodyElement(sei);
						
		if (bodyElement!=null) {
		    if (bodyElement.hasChildNodes()) {
				
			int tempoutputeleindex=outputeleindex;
			if (maxOccurs(outputeleindex,output,cxt)) {
				   
			    mtpl.setElem(0, getSoapElement(bodyElement,output,cxt));
				    
			    tpl.setElem(tplindex,(makeRecord(tempoutputeleindex,(bodyElement.getElementName()).getLocalName(),mtpl,output,cxt)).getOidElem(0));
				    
			}
			else  {
			    outputeleindex=outputeleindex-2;
			    tpl.setElem(tplindex,(makeRecord(tempoutputeleindex,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
			}
			tplindex++;
		    }
		    else {
			Tuple tmptpl = new Tuple(1);
			tmptpl.setElem(0,1);
			tmptpl.getStringElem(0);
		    }
		    seiind++;
		    outputeleindex=outputeleindex+2;
		}
	    }
	}

	return tpl;
	
    }
    public static Tuple getSoapElement(SOAPBodyElement sbe, Tuple output, CallContext cxt) throws SOAPException,AmosException { 
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple etpl= new Tuple(2);
	Iterator sei=sbe.getChildElements();
	outputeleindex=outputeleindex+2;
	int no_of_children=findChildren(sbe.getChildElements());
        
	int tplindex=0;
	Oid m;
	Tuple tpl;

	boolean is_record=false;
	boolean subelements=false;
	boolean singleelement=false;
	String elename;
	if (dummyele.equalsIgnoreCase(""))
	    elename=(sbe.getElementName()).getLocalName();
	else
	    elename=dummyele;
	dummyele=""; 
	
	SOAPBodyElement bodyElement=null;
	etpl.setElem(0,output.getOidElem(1));
	etpl.setElem(1,elename);
		
	s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
        
	if ((s.getRow()).getIntElem(0)>0){
            bodyElement=findSOAPBodyElement(sei);
	    outputeleindex=outputeleindex+2;
	   
	}
	else {
	    bodyElement = sbe;
	    singleelement=true;
	}
		
	int iterval=0;
	  

	if (!s.eos()) {
	    if (!((((s.getRow()).getIntElem(0))==1)&& (maxOccurs(outputeleindex,output,cxt))))
		no_of_children=1;
	}
	else   {
	    no_of_children=1;
	}
        
        
	tpl= new Tuple(no_of_children);   

	if (!sei.hasNext()||singleelement) {
        
	    etpl.setElem(0,output.getOidElem(1));
	    etpl.setElem(1,(bodyElement.getElementName()).getLocalName());
	    
	    s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
	    
	    if ((s.getRow()).getIntElem(0)>0)
		subelements=true;
	    
	
	    if (subelements) {
				
		if (maxOccurs(outputeleindex+2,output,cxt)) {
		    Iterator csei=bodyElement.getChildElements();	
		    SOAPBodyElement cbodyElement;
		    
		    Tuple tplcbe= new Tuple((bodyElement.getChildNodes()).getLength());
		    int tplcbeindex=0;
		   
		    int tempoutputeleindex=outputeleindex;
		    while (csei.hasNext()) {
					
			outputeleindex=tempoutputeleindex;
			
			cbodyElement = findSOAPBodyElement(csei);
			etpl.setElem(0,output.getOidElem(1));
			etpl.setElem(1,cbodyElement.getLocalName());
			s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
				
					
			if ((s.getRow()).getIntElem(0)>0)
			    tplcbe.setElem(tplcbeindex,(makeRecord(outputeleindex+2,(cbodyElement.getElementName()).getLocalName(),getSoapElement(cbodyElement,output,cxt),output,cxt)).getOidElem(0));
			else
			    tplcbe.setElem(tplcbeindex,(getSoapElement(cbodyElement,output,cxt)).getOidElem(0));
				
			tplcbeindex++;
		    }
		    Tuple tplresult=new Tuple(1);
		    tplresult.setElem(0,tplcbe);
		    
		    outputeleindex=tempoutputeleindex;
		   
					
		    if (no_of_children==1) {
			if (seiind==0) {
			    tpl.setElem(0,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0));
			}
			else {
			    tpl.setElem(0,(putRecord(tpl,outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0));
			}
		    }
		    else {
			tpl.setElem(tplindex,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0));
			tplindex++;
		    }
		    seiind++;
				
		}
		else {
		    int tempoei=outputeleindex;
		    outputeleindex=outputeleindex-2;
		      
		    if (no_of_children==1) {
			vtpl.setElem(0,(makeRecord(tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
			tpl.setElem(0,vtpl);		
			/*if (seiind==0) 
			  tpl.setElem(0,(makeRecord(tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
			  else
			  tpl.setElem(0,(putRecord(tpl,tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));*/			    
		    }
		    else
			{  
			    tpl.setElem(tplindex,(makeRecord(tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
			    tplindex++;
			}
		    seiind++;
		}
		
	    }
	    else { 
		elename=(bodyElement.getElementName()).getLocalName();
		      	 
		String valuecsei;
               
                
		if (bodyElement.hasChildNodes())
		    valuecsei=((bodyElement.getChildNodes()).item(0)).getTextContent();
		else
		    valuecsei=null;
		
		if (no_of_children==1) {
		   	

		    if (seiind==0) {
			if (valuecsei!=null){
			    if ((findWSDLtype(outputeleindex,output,cxt)).length()>7){
				if (((findWSDLtype(outputeleindex,output,cxt)).substring(0,8)).equalsIgnoreCase("Vectorof")) {
				    Tuple vectpl= new Tuple((bodyElement.getChildNodes()).getLength());
				    int veci=0;
				    /* handling Vectorof type elements*/
				    while (veci < (bodyElement.getChildNodes()).getLength()){
					if (((bodyElement.getChildNodes()).item(veci)).hasChildNodes()) {
					    vtpl.setElem(0,getSoapElement((SOAPBodyElement)(bodyElement.getChildNodes()).item(veci),output,cxt).getOidElem(0));
					}
					else {
					    vtpl.setElem(0,((bodyElement.getChildNodes()).item(veci)).getTextContent());
					}
					vectpl.setElem(veci,(makeRecord(outputeleindex+2,((bodyElement.getChildNodes()).item(veci)).getLocalName(),vtpl,output,cxt)).getOidElem(0));
					veci++;
				    }
				    vtpl.setElem(0,vectpl);
				    tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
				}
			    }
			    else {	
				if ((bodyElement.getChildNodes()).getLength()==0) {
				    vtpl.setElem(0,valuecsei);
				    tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));	  
				}
				else {
				    if (!( (((bodyElement.getChildNodes()).item(0)) instanceof SOAPBodyElement))) {
					vtpl.setElem(0,valuecsei);
				       	tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
				    }
				    else {
					Tuple vectpl= new Tuple((bodyElement.getChildNodes()).getLength());
					int veci=0;
					while (veci < (bodyElement.getChildNodes()).getLength()){
					    vtpl.setElem(0,getSoapElement((SOAPBodyElement)(bodyElement.getChildNodes()).item(veci),output,cxt).getOidElem(0));
					    vectpl.setElem(veci,(makeRecord(outputeleindex+2,((bodyElement.getChildNodes()).item(veci)).getLocalName(),vtpl,output,cxt)).getOidElem(0));
					    veci++;				
					}

					vtpl.setElem(0,vectpl);
					tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
				    }
				}
			     
			    }
			}
			else {
			    vtpl.setElem(tplindex,""); 
			    tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
			}
				    
			
				    
		    }
		    else  {
                        
			if (valuecsei!=null)
			    vtpl.setElem(0,valuecsei);
			else
			    vtpl.setElem(0,""); 
					
			tpl.setElem(tplindex,(putRecord(tpl,outputeleindex,elename, vtpl,output,cxt)).getOidElem(0)); 
				
		    }
		}
		else  {
		    if (valuecsei!=null)
			vtpl.setElem(0,valuecsei);
		    else
			vtpl.setElem(tplindex,""); 
					
		    tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
		    tplindex++;
		}
		seiind++;
			
	    }
		
	}
    
	else {
	    int tempoei=0;
	    int tempoei1=outputeleindex;
	    String tempbe=(bodyElement.getElementName()).getLocalName();
	   
	    while (sei.hasNext()) {
			
		if (iterval>0) {
		  
		    bodyElement=findSOAPBodyElement(sei);
                              
		    //Check for valid body element
		    if (bodyElement!=null){
                              
			// To check multiple occurence of the same body element
			if (((bodyElement.getElementName()).getLocalName()).equalsIgnoreCase(tempbe)) {
			    outputeleindex=tempoei1;
			    tempoei=outputeleindex;
			}
			else {
			    outputeleindex=outputeleindex+2;
			    tempoei=outputeleindex;
			}
                                
                       	tempbe=(bodyElement.getElementName()).getLocalName();
		    }
		}
                      
		if (bodyElement!=null) {
		    etpl.setElem(0,output.getOidElem(1));
		   
		    etpl.setElem(1,findElement(outputeleindex,output,cxt));
                                     
		    s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
					
		    if ((s.getRow()).getIntElem(0)>0)
			subelements=true;
		    else
			subelements = false;
			    
		    
		    if (subelements) { 
			if (maxOccurs(outputeleindex+2,output,cxt)) {
			    Iterator csei=bodyElement.getChildElements();
			    SOAPBodyElement cbodyElement;
			
			    Tuple tplcbe= new Tuple(findChildren(bodyElement.getChildElements()));
			   		
			    int tplcbeindex=0;
			    int tempoutputeleindex=outputeleindex;
			    while (csei.hasNext()) {
				
				cbodyElement=findSOAPBodyElement(csei);
				etpl.setElem(0,output.getOidElem(1));
				etpl.setElem(1,cbodyElement.getLocalName());
				s = cxt.connection().callFunction("Operation.charstring.subelements->integer",etpl);
				outputeleindex=tempoutputeleindex;
								   
				if ((s.getRow()).getIntElem(0)>0)
				    tplcbe.setElem(tplcbeindex,(makeRecord(outputeleindex,(cbodyElement.getElementName()).getLocalName(),getSoapElement(cbodyElement,output,cxt),output,cxt)).getOidElem(0));
				else
				    tplcbe.setElem(tplcbeindex,(getSoapElement(cbodyElement,output,cxt)).getOidElem(0));
				tplcbeindex++;
						
			    }
			    Tuple tplresult=new Tuple(1);
			    tplresult.setElem(0,tplcbe);
			    outputeleindex=tempoutputeleindex;
			    
			    if (no_of_children==1) {
							
				if (seiind==0) {
				    tpl.setElem(0,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0)); 				   
				}
				else {
				    tpl.setElem(0,(putRecord(tpl,outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0));
				}
			    }
			    else {
				tpl.setElem(tplindex,(makeRecord(outputeleindex,(bodyElement.getElementName()).getLocalName(),tplresult,output,cxt)).getOidElem(0));
			
				tplindex++;
			    }
			    seiind++;
					
			}
			else {
			    outputeleindex=outputeleindex-2;
			   
			    if (no_of_children==1){
				    if (seiind==0) {
					tpl.setElem(0,(makeRecord(tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
				    }
				    else  {
					tpl.setElem(0,(putRecord(tpl,tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
				    }
				}
			    else {
				tpl.setElem(tplindex,(makeRecord(tempoei,(bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output,cxt),output,cxt)).getOidElem(0));
				tplindex++;
			    }
			    seiind++;
			}
				
		    }
		    else {
					
			elename=findElement(outputeleindex,output,cxt);
		
			String valuecsei;
			if (bodyElement.hasChildNodes())
			    valuecsei=((bodyElement.getChildNodes()).item(0)).getTextContent();
			else
			    valuecsei=null;
			
			if (no_of_children==1) {
			    if (seiind==0) {
						
				if (valuecsei!=null)
				    vtpl.setElem(0,valuecsei);
				else
				    vtpl.setElem(tplindex,""); 
						
				tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
				
			    }
			    else {
						
				if (valuecsei!=null)
				    vtpl.setElem(0,valuecsei);
				else
				    vtpl.setElem(0,""); 
									
				tpl.setElem(tplindex,(putRecord(tpl,outputeleindex,elename, vtpl,output,cxt)).getOidElem(0)); 
						
			    }
					
			}
			else {
			    if (valuecsei!=null)
				vtpl.setElem(0,valuecsei);
			    else
				vtpl.setElem(tplindex,""); 
					
			    tpl.setElem(tplindex,(makeRecord(outputeleindex,elename, vtpl,output,cxt)).getOidElem(0));
			    tplindex++;
			}
			seiind++;
		    }
		    iterval++;
		}
		
	    }
		
	}
	
	
	return tpl;
    }
      
    
    public static Tuple makeRecord(int oei, String name, Tuple  value, Tuple output,CallContext cxt) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s,r;
	rtpl.setElem(1,oei);
	rtpl.setElem(0,output.getOidElem(0));
       
        s= cxt.connection().callFunction("Record.Integer.get_element->Record",rtpl);
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
	r= cxt.connection().callFunction("Record.record_length->Integer",typetpl);
	if ((r.getRow()).getIntElem(0)==0) {
	    Oid record=value.getOidElem(0);
	    rtpl.setElem(1,record);
            
	}
        else {
	    rtpl.setElem(1,"wsmedtype");
	    rtpl.setElem(0,(s.getRow()).getOidElem(0));
	    s = cxt.connection().callFunction("record.charstring.get_ele_properties->Charstring",rtpl);
	
	    String type= (s.getRow()).getStringElem(0);
	
	    if (type.equalsIgnoreCase("charstring")) {
		rtpl.setElem(1,value.getStringElem(0));
	    }
	    else {
		if (type.equalsIgnoreCase("integer")) {
		    Integer ie=Integer.parseInt(value.getStringElem(0));
		    rtpl.setElem(1,ie);
		}
		else
		    if (type.equalsIgnoreCase("real")) {
			Double db=Double.parseDouble(value.getStringElem(0));
			rtpl.setElem(1,db);
		    }
		    else
			if (type.equalsIgnoreCase("boolean")) {
			    Boolean bo=Boolean.parseBoolean(value.getStringElem(0));
			    rtpl.setElem(1,bo);
			}
			else {
			    if (value.getArity()>1) {
				rtpl.setElem(1,value); 
			    }
			    else  {
				Oid record=value.getOidElem(0);
				rtpl.setElem(1,record);
			    }
			    
			}
	    }
	}
	
	rtpl.setElem(0,name);
	
	s=cxt.connection().callFunction("Object.Object.concat_obj->vector",rtpl);
	
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
		
	s = cxt.connection().callFunction("vector.make_record->Record",typetpl);
	
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
		
	return typetpl;
    }
    
    public static Tuple putRecord(Tuple tpl,int oei, String name, Tuple  value, Tuple output, CallContext cxt) throws AmosException {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Tuple ptpl= new Tuple(3);
	Scan s,r;

	rtpl.setElem(1,oei);
	rtpl.setElem(0,output.getOidElem(0));
	
	s= cxt.connection().callFunction("Record.Integer.get_element->Record",rtpl);
        typetpl.setElem(0,(s.getRow()).getOidElem(0));
	r= cxt.connection().callFunction("Record.record_length->Integer",typetpl);
	if ((r.getRow()).getIntElem(0)==0) {
	    
	    if (value.getArity()>1) {
		ptpl.setElem(2,value); 
	    }
	    else  {				    
		ptpl.setElem(2,value.getOidElem(0));
	    }
	}
	else {
	    rtpl.setElem(1,"wsmedtype");
	    rtpl.setElem(0,(s.getRow()).getOidElem(0));
	    s = cxt.connection().callFunction("record.charstring.get_ele_properties->Charstring",rtpl);

	    String type= (s.getRow()).getStringElem(0);
	
	    if (type.equalsIgnoreCase("charstring"))
		ptpl.setElem(2,value.getStringElem(0));
	    else
		if (type.equalsIgnoreCase("integer")) {
		    Integer ie=Integer.parseInt(value.getStringElem(0));
		    ptpl.setElem(2,ie);
		}
		else
		    if (type.equalsIgnoreCase("real")) {
			Double db=Double.parseDouble(value.getStringElem(0));
			ptpl.setElem(2,db);
		    }
		    else
			if (type.equalsIgnoreCase("boolean")) {
			    Boolean bo=Boolean.parseBoolean(value.getStringElem(0));
			    ptpl.setElem(2,bo);
			}
			else {
			    if (value.getArity()>1) {
				ptpl.setElem(2,value); 
			    }
			    else  {				    
				ptpl.setElem(2,value.getOidElem(0));
			    }
			
			}
	}
	ptpl.setElem(0, tpl.getOidElem(0));
	ptpl.setElem(1, name);
	s = cxt.connection().callFunction("Record.Charstring.Object.put_record->Record",ptpl);
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
	return typetpl;
    }
    
    public static boolean  maxOccurs(Integer oei, Tuple output, CallContext cxt) throws AmosException  {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s;
	boolean mo=false;
	   
	rtpl.setElem(1,oei);
	rtpl.setElem(0,output.getOidElem(0));
        
	s= cxt.connection().callFunction("Record.Integer.get_element->Record",rtpl);
        
	rtpl.setElem(1,"maxoccurs");
	rtpl.setElem(0,(s.getRow()).getOidElem(0));
	
	s = cxt.connection().callFunction("Record.Charstring.get_ele_properties->Charstring",rtpl);
	String type= (s.getRow()).getStringElem(0);
	    
	if (type.equalsIgnoreCase("-1"))
	    mo=true;
	
	return mo;
    }

    public static String  findElement(int ind,Tuple output, CallContext cxt) throws AmosException {  
	Tuple rtpl = new Tuple(2);
	Scan s;
	
	rtpl.setElem(1,ind/2);
	rtpl.setElem(0,output.getOidElem(1));

	s= cxt.connection().callFunction("Operation.Integer.find_output_ele_at_pos->Charstring",rtpl);
	
	return (s.getRow()).getStringElem(0);
    }
    public static String  findWSDLtype(int oei, Tuple output,CallContext cxt) throws AmosException {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s;
       	typetpl.setElem(0,output.getOidElem(0));
	s= cxt.connection().callFunction("Record.record_length->Integer",typetpl);
	if ((s.getRow()).getIntElem(0)<oei) {
	    return "string" ;
	}
	else {
	    rtpl.setElem(1,oei/2);
	    rtpl.setElem(0,output.getOidElem(1));
	
	    s= cxt.connection().callFunction("Operation.Integer.find_output_ele_wsdltype_at_pos->Charstring",rtpl);
	    return 	(s.getRow()).getStringElem(0);
	}
	
    }
   
    /**
     * Returns a string representation of the given jdom element.
     *
     * @param   elem     The jdom element to be converted into a string.
     *
     * @return  The string representation of the given jdom element.
     */
    public static String  outputString(Element elem) {
        XMLOutputter xmlWriter = new XMLOutputter();
        return xmlWriter.outputString(elem);
    }
    /**
     * Returns a string representation of the given castor schema.
     *
     * @param   schema   The castor schema to be converted into a string.
     *
     * @return  The string representation of the given castor schema.
     *
     * @throws  IOException    If the schema could not be written out.
     * @throws  SAXException   If the schema could not be written out.
     */
  
    public static String outputString(Schema schema) throws IOException, SAXException {
	// create a string writer
	StringWriter writer = new StringWriter();

	// create the schema writer
	SchemaWriter schemaWriter = new SchemaWriter(writer);

	// write the schema into the source
	schemaWriter.write(schema);

	// return the content of the writer
	return writer.toString();
    }
    /**
     * It reads the given xml returns the jdom document.
     *
     * @param   xml   The xml to read.
     *
     * @return  The jdom document created from the xml.Tuple temptpl
     *
     * @throws  JDOMException     If the parsing failed.
     */
    public static Document readXML(String xml) throws JDOMException, IOException {
	return readXML(new StringReader(xml));
    }

    /**
     * It reads the given xml reader and returns the jdom document.
     *
     * @param   reader   The xml reader to read.
     *
     * @return  The jdom document created from the xml reader.
     *
     * @throws  JDOMException     If the parsing failed.
     */
    public static Document readXML(Reader reader) throws JDOMException, IOException {
      
	SAXBuilder xmlBuilder = new SAXBuilder(false);

	Document doc = xmlBuilder.build(reader);
 
	return doc;
    }
    
    /**
     * It reads the given reader and returns the castor schema.
     *
     * @param   reader   The reader to read.
     *
     * @return  The castor schema created from the reader.
     *
     * @throws  IOException    If the schema could not be read from the reader.
     */
    public static Schema readSchema(Reader reader) throws IOException  {
	Schema schema=null;
      
	try {
	    // create the sax input source
	    InputSource inputSource = new InputSource(reader);

	    // create the schema reader
	    SchemaReader schemaReader = new SchemaReader(inputSource);
     
	    schemaReader.setValidation(false);

	    // read the schema from the source
	    schema = schemaReader.read();
      
	}
        catch(Throwable ex) {
	    ex.printStackTrace();
	  
	}
        
	return schema;
    }
   
     
    /**
     * Converts the jdom element into a castor schema.
     *
     * @param   element  The jdom element to be converted into a castor schema.
     *
     * @return  The castor schema corresponding to the element.
     *
     * @throws  IOException    If the jdom element could not be written out.
     */
    public static Schema convertElementToSchema(Element element) throws IOException {
	// get the string content of the element
	String content = outputString(element);
	
	// check for null value
	if (content != null)
	    {
		// create a schema from the string content
		return readSchema(new StringReader(content));
	    }

	// otherwise return null
	return null;
    }

    

    public static int findSize(Iterator itr) {
	int counter=0;
	while (itr.hasNext())
	    {
		itr.next();
		counter++;
	    }
	return counter;
    }

    public static boolean findSOAPFault(SOAPMessage response) throws SOAPException, AmosException {
	try {
	    SOAPBody sb=response.getSOAPBody();
	    if (sb.hasFault()){
		Iterator sei=sb.getChildElements();
		if (sei.hasNext()){
          
		    
		    SOAPElement bodyElement = findSOAPBodyElement(sei);
		    String checkstr=(bodyElement.getElementName()).getLocalName();
     
		    if (checkstr.equals("Fault")){
			sei=bodyElement.getChildElements();
		
			SOAPElement faultcode = findSOAPBodyElement(sei);
			faultcode_str=faultcode.getTextContent();
			
			SOAPElement faultstring = findSOAPBodyElement(sei);
			faultstring_str=faultstring.getTextContent();
			
			SOAPElement detail = findSOAPBodyElement(sei);
			sei=detail.getChildElements();
			if (sei.hasNext()){
			    SOAPElement faultdetail = findSOAPBodyElement(sei);
			    if (faultdetail != null)
				faultdetail_str=faultdetail.getTextContent();
			}
			return true;
		    }
		    else
			return false;
		}
		else
		    return true; 
	    }
	    else
		return false; 
	}
	catch(Throwable ex) {
	    ex.printStackTrace();
	    throw new AmosException(ex.getMessage());
	    
	}
      
    }

    public static Integer findChildren(Iterator si) throws SOAPException {
	Integer count=0;
	Object so;
	try {
	    while(si.hasNext()){
		so=si.next();
		if (so instanceof SOAPBodyElement)
		    count+=1;
	    }
	}
	catch(Throwable ex) {
	    System.out.println(ex.getMessage());
	    ex.printStackTrace();
	   
	} 
	return count;
    }
    public static SOAPBodyElement findSOAPBodyElement(Iterator si) throws SOAPException {
	Integer count=0;
	Object so;
	SOAPBodyElement be=null;
	try {
	    if (si.hasNext()){
		so=si.next();
		while(si.hasNext() && !(so instanceof SOAPBodyElement)){
		    so=si.next();
		}
	   
		if (so instanceof SOAPBodyElement){
		    be = (SOAPBodyElement)so;
		}
	    }
	}
	catch(Throwable ex) {
	    ex.printStackTrace();
	} 
	return be;
    }
    public static String getFaultcode(){
	return faultcode_str;
    }
    public static String getFaultstring(){
	return faultstring_str;
    }
    public  static String getFaultdetail(){
	return faultdetail_str;
    }
    private Object iterate(Iterator each) {
	return each.hasNext() ? each.next() : null;
    }

    
}
