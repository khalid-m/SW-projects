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

import javax.xml.soap.MessageFactory;
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

public class XMLSupport
{
   	static Connection theConnection;
    private XMLSupport()throws AmosException
    {
	
	
    }
    public static Tuple webserviceResponse(SOAPMessage response, Tuple output) throws SOAPException,AmosException
    {  
	theConnection = new Connection(""); 
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl= new Tuple(1);

	SOAPBody sb=response.getSOAPBody();
	Iterator sei=sb.getChildElements();
	Tuple tpl = new Tuple((sb.getChildNodes()).getLength());
	int tplindex=0;

	while (sei.hasNext())
	    {
		SOAPBodyElement bodyElement = (SOAPBodyElement)sei.next();
			
		//System.out.println("body element "+(bodyElement.getElementName()).getLocalName());
		if (bodyElement.hasChildNodes())
		    {
			Oid m=(getSoapElement(bodyElement,output)).getOidElem(0);
			if ((m.getTypename()).equalsIgnoreCase("Record"))
			    {
				mtpl.setElem(0,m);
				if (seiind==0)
				    tpl.setElem(tplindex,(makeRecord((bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
				else
				    tpl.setElem(tplindex,(putRecord(tpl,(bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
			    }
			else
			    {
				tpl.setElem(tplindex,m);
				tplindex++;
			    }
		    }
		else
		    {
		
			
		    }
		seiind++;
	    }

	return tpl;
    }
    public static Tuple rpc_webserviceResponse(SOAPMessage response, Tuple output) throws SOAPException,AmosException
    {  
	theConnection = new Connection(""); 
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl= new Tuple(1);
	
	SOAPBody sb=response.getSOAPBody();
	Iterator sei=sb.getChildElements();
	int sb_no_of_children=(sb.getChildNodes()).getLength();
	Tuple tpl;
	int tplindex=0;
	int sbeindex=0;
	
	SOAPBodyElement bodyElement = (SOAPBodyElement)sei.next();
	String checkstr=(bodyElement.getElementName()).getLocalName();
	int no_of_children=(bodyElement.getChildNodes()).getLength();
	String outelement=findElement(sbeindex,output);
	String childstr="";
	Tuple resulttpl= new Tuple(1);	 
	int iterval=0;
		System.out.println("testing ");	
	if (checkstr.equalsIgnoreCase(outelement))
	    {
		tpl=new Tuple(1);
		tpl.setElem(0,webserviceResponse(response,output));
		
	    }
	else
	    {
		if (sb_no_of_children==1)
		    {
		
			tpl=new Tuple(1);
			tpl.setElem(0,rpc_webserviceResponse(bodyElement,output));
		    }
		else
		    {
			boolean found=false;
		
			while (sei.hasNext()&& !found)
			    {
				
				bodyElement = (SOAPBodyElement)sei.next();
				
				childstr=(bodyElement.getElementName()).getLocalName();
				//System.out.println(childstr+" <test > "+outelement+" "+findWSDLtype(outelement,output));
				sbeindex=sbeindex+2;
				if (childstr.equalsIgnoreCase(findWSDLtype(outelement,output)))
				    found=true;
				else
				    {
					//System.out.println(childstr+" test12 "+(bodyElement.getElementName()).getLocalName());
					no_of_children=(bodyElement.getChildNodes()).getLength();
					outelement=findElement(sbeindex,output);
				    }
			
			    
			    }
		    }
	//System.out.println("testing >>><<<<<"+ no_of_children);
	tpl = new Tuple(no_of_children);
	int sbindex=sbeindex;
	Oid m;
	String name;
	Tuple temptpl;
	//System.out.println("sbeindex initial "+sbeindex);
	if (no_of_children==1)
	    {
		temptpl= new Tuple(1);
		
		//System.out.println("body element0 "+(bodyElement.getElementName()).getLocalName());
		if (bodyElement.hasChildNodes())
		    {
			m=(getSoapElement(bodyElement,output)).getOidElem(0);
			
			//System.out.println(" soap element success "+ (getSoapElement(bodyElement,output)).getStringElem(0));
			if ((m.getTypename()).equalsIgnoreCase("Record"))
			    {
				mtpl.setElem(0,m);
				name=findElement(sbeindex,output);
				//System.out.println(" find element success ");
				if (seiind==0)
				    {
					while (sbeindex>=0)
					    {	
						if (sbeindex==sbindex)
						    {
							//System.out.println(name+"   "+childstr+"  "+sbeindex);
							if (name.equalsIgnoreCase(childstr))
							    temptpl.setElem(0,(makeRecord((bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
							else
							    {
								sbeindex=sbeindex-2;
								//System.out.println("test1 "+" "+findElement(sbeindex,output));
								temptpl.setElem(0,(makeRecord(findElement(sbeindex,output),mtpl,output)).getOidElem(0));
								
							    }
							
						    }
						else
						    temptpl.setElem(0,(makeRecord(findElement(sbeindex,output),temptpl,output)).getOidElem(0));
						sbeindex=sbeindex-2;
					    }
					
				    }
				else
				    {
					while (sbeindex>=0)
					    {	
						if (sbeindex==sbindex)
						    {
							if (name.equalsIgnoreCase(childstr))
							    temptpl.setElem(0,(putRecord(temptpl,(bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
							else
							    {
								sbeindex=sbeindex-2;
								temptpl.setElem(0,(putRecord(temptpl,findElement(sbeindex,output),mtpl,output)).getOidElem(0));
								
							    }
						    }
						else
						    temptpl.setElem(0,(putRecord(temptpl,findElement(sbeindex,output),temptpl,output)).getOidElem(0));
						sbeindex=sbeindex-2;	
					    }
				    }
				
			    }
			tpl.setElem(tplindex,temptpl.getOidElem(0));
			//System.out.println("temptpl123 ");
			//System.out.println("temptpl "+tpl.getStringElem(0));
			tplindex++;
		    }
	    }
	else
	    {
		
		while(sei.hasNext())
		    {
			sbeindex=sbindex;
			temptpl= new Tuple(1);
			if (iterval>0) 
			    bodyElement = (SOAPBodyElement)sei.next();
			
			//System.out.println("body element "+(bodyElement.getElementName()).getLocalName());
			if (bodyElement.hasChildNodes())
			    {
				m=(getSoapElement(bodyElement,output)).getOidElem(0);
				
				if ((m.getTypename()).equalsIgnoreCase("Record"))
				    {
					mtpl.setElem(0,m);
					name=findElement(sbeindex,output);
					
					if (seiind==0)
					    {
						while (sbeindex>=0)
						    {	
							//System.out.println(" sbeindex "+sbeindex);
							if (sbeindex==sbindex)
							    {
								if (name.equalsIgnoreCase(childstr))
								    temptpl.setElem(0,(makeRecord((bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
								else
								    {
									sbeindex=sbeindex-2;
									temptpl.setElem(0,(makeRecord(findElement(sbeindex,output),mtpl,output)).getOidElem(0));
								    }
								
							    }
							else
							    {
								//	System.out.println("else test "+name);
								temptpl.setElem(0,(makeRecord(findElement(sbeindex,output),temptpl,output)).getOidElem(0));
							    }
							sbeindex=sbeindex-2;
						    }
						
					    }
					else
					    {
						while (sbeindex>=0)
						    {	
							if (sbeindex==sbindex)
							    {
								if (name.equalsIgnoreCase(childstr))
								    temptpl.setElem(0,(putRecord(temptpl,(bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
								else
								    {
									sbeindex=sbeindex-2;
									temptpl.setElem(0,(putRecord(temptpl,findElement(sbeindex,output),mtpl,output)).getOidElem(0));
								    }
							    }
							else
							    temptpl.setElem(0,(putRecord(temptpl,findElement(sbeindex,output),temptpl,output)).getOidElem(0));
							sbeindex=sbeindex-2;	
						    }
					    }
					
				    }
				else
				    {
					
				    }
				
				tpl.setElem(tplindex,temptpl.getOidElem(0));
				tplindex++;
				iterval++;
			    }
			
			//result.setElem(0,tpl);
			
		    }
	    }
	
	
	
	return tpl;
    }
    public static Tuple rpc_webserviceResponse(SOAPBodyElement sb, Tuple output) throws SOAPException,AmosException
    {  
	theConnection = new Connection(""); 
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Tuple mtpl= new Tuple(1);
	
	//SOAPBody sb=response.getSOAPBody();
	Iterator sei=sb.getChildElements();
	Tuple tpl = new Tuple((sb.getChildNodes()).getLength());
	int tplindex=0;
	while (sei.hasNext())
	    {
		SOAPBodyElement bodyElement = (SOAPBodyElement)sei.next();
		
		//System.out.println("body element "+(bodyElement.getElementName()).getLocalName());
		if (bodyElement.hasChildNodes())
		    {
			Oid m=(getSoapElement(bodyElement,output)).getOidElem(0);
			if ((m.getTypename()).equalsIgnoreCase("Record"))
			    {
				mtpl.setElem(0,m);
				if (seiind==0)
				    tpl.setElem(tplindex,(makeRecord((bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
				else
				    tpl.setElem(tplindex,(putRecord(tpl,(bodyElement.getElementName()).getLocalName(),mtpl,output)).getOidElem(0));
			    }
			else
			    {
				tpl.setElem(tplindex,m);
				tplindex++;
			    }
		    }
		else
		    {
			
			
		    }
		seiind++;
	    }
	
	return tpl;
    }
    public static Tuple getSOAPElement(SOAPBodyElement sbe, Tuple output) throws SOAPException,AmosException
    { 
	int seiind=0;
	Scan s;
	Tuple vtpl= new Tuple(1);
	Iterator sei=sbe.getChildElements();
	
	Tuple tpl=new Tuple((sbe.getChildNodes()).getLength());
	int tplindex=0;
	Oid m;
	//System.out.println(" getSoapElement success");
	while (sei.hasNext())
	    {
		SOAPBodyElement bodyElement = (SOAPBodyElement)sei.next();
	        //System.out.println("soap element "+(bodyElement.getElementName()).getLocalName());
		if ((bodyElement.getChildNodes()).getLength()>1)
		    {
			
			Iterator csei=bodyElement.getChildElements();
			SOAPBodyElement cbodyElement = (SOAPBodyElement)csei.next();
			
			String celename=(cbodyElement.getElementName()).getLocalName();
			//System.out.println(" maxoccurs testing "+celename);
			if (maxOccurs(celename,output))
			    {
				//System.out.println(" maxoccurs testing "+celename);
		    		Tuple tplcbe= new Tuple((bodyElement.getChildNodes()).getLength());
				int tplcbeindex=0;
				csei=bodyElement.getChildElements();
				while (csei.hasNext())
				    {
					cbodyElement = (SOAPBodyElement)csei.next();
					tplcbe.setElem(tplcbeindex,(makeRecord((cbodyElement.getElementName()).getLocalName(),getSoapElement(cbodyElement,output),output)).getOidElem(0));
					tplcbeindex++;
				    }
				Tuple tplresult=new Tuple(1);
				tplresult.setElem(0,tplcbe);
				tpl.setElem(tplindex,(makeRecord((bodyElement.getElementName()).getLocalName(),tplresult,output)).getOidElem(0));
			    }
			else
			    {
				if (seiind==0)
				    {
					
					tpl.setElem(tplindex,(makeRecord((bodyElement.getElementName()).getLocalName(),getSoapElement(bodyElement,output),output)).getOidElem(0));
				    }
				else
				    {
					
					tpl.setElem(tplindex,(putRecord(tpl,(bodyElement.getElementName()).getLocalName(), getSoapElement(bodyElement,output),output)).getOidElem(0));
				    }
				seiind++;
			    }
		    }
		else
		    {
			String elename=(bodyElement.getElementName()).getLocalName();
			//Iterator csei=bodyElement.getChildNodes();
			//SOAPBodyElement cbodyElement = (SOAPBodyElement)csei.next();
			String valuecsei=((bodyElement.getChildNodes()).item(0)).getTextContent();
			//System.out.println("name "+valuecsei);
			if (seiind==0)
			    {
				
				if (valuecsei!=null)
				    vtpl.setElem(0,valuecsei);
				else
				    vtpl.setElem(tplindex,""); 
				
			        tpl.setElem(tplindex,(makeRecord(elename, vtpl,output)).getOidElem(0));
			    }
			else
			    {
				
				if (valuecsei!=null)
				    vtpl.setElem(0,valuecsei);
				else
				    vtpl.setElem(0,""); 
				
			        tpl.setElem(0,(putRecord(tpl,elename, vtpl,output)).getOidElem(0)); 
				
			    }
			seiind++;	
		    }
		tplindex++;	
	    }
	
	return tpl;
    }
    
    public static Tuple makeRecord(String name, Tuple  value, Tuple output) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s;
	
	rtpl.setElem(1,name);
	rtpl.setElem(0,output.getOidElem(0));
	
	s= theConnection.callFunction("Record.Charstring.get_element->Record",rtpl);
	
	rtpl.setElem(1,"wsmedtype");
	rtpl.setElem(0,(s.getRow()).getOidElem(0));
	s = theConnection.callFunction("record.charstring.get_ele_properties->Charstring",rtpl);
	String type= (s.getRow()).getStringElem(0);
	
	
	if (type.equalsIgnoreCase("charstring"))
	    rtpl.setElem(1,value.getStringElem(0));
	else
	    if (type.equalsIgnoreCase("integer"))
		{
		    Integer ie=Integer.parseInt(value.getStringElem(0));
		    rtpl.setElem(1,ie);
		}
	    else
		if (type.equalsIgnoreCase("real"))
		    {
			Double db=Double.parseDouble(value.getStringElem(0));
			rtpl.setElem(1,db);
		    }
		else
		    if (type.equalsIgnoreCase("boolean"))
			{
			    Boolean bo=Boolean.parseBoolean(value.getStringElem(0));
			    rtpl.setElem(1,bo);
			}
		    else
			{
			    Oid record=value.getOidElem(0);
			    rtpl.setElem(1,record);
			}
	
	
	
	rtpl.setElem(0,name);
	
	s=theConnection.callFunction("Object.Object.concat_obj->vector",rtpl);
	
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
	
	s = theConnection.callFunction("vector.make_record->Record",typetpl);
	
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
	
	return typetpl;
    }
    
    public static Tuple putRecord(Tuple tpl,String name, Tuple  value, Tuple output) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Tuple ptpl= new Tuple(3);
	Scan s;
	
	rtpl.setElem(1,name);
	rtpl.setElem(0,output.getOidElem(0));
	
	s= theConnection.callFunction("Record.Charstring.get_element->Record",rtpl);
	
	rtpl.setElem(1,"wsmedtype");
	rtpl.setElem(0,(s.getRow()).getOidElem(0));
	s = theConnection.callFunction("record.charstring.get_ele_properties->Charstring",rtpl);
	
	String type= (s.getRow()).getStringElem(0);
	
	
	if (type.equalsIgnoreCase("charstring"))
	    ptpl.setElem(2,value.getStringElem(0));
	else
	    if (type.equalsIgnoreCase("integer"))
		{
		    Integer ie=Integer.parseInt(value.getStringElem(0));
		    ptpl.setElem(2,ie);
		}
	    else
		if (type.equalsIgnoreCase("real"))
		    {
			Double db=Double.parseDouble(value.getStringElem(0));
			ptpl.setElem(2,db);
		    }
		else
		    if (type.equalsIgnoreCase("boolean"))
			{
			    Boolean bo=Boolean.parseBoolean(value.getStringElem(0));
			    ptpl.setElem(2,bo);
			}
		    else
			ptpl.setElem(2,value.getOidElem(0));
	
	ptpl.setElem(0, tpl.getOidElem(0));
	ptpl.setElem(1, name);
	
	s = theConnection.callFunction("Record.Charstring.Object.put_record->Record",ptpl);
	typetpl.setElem(0,(s.getRow()).getOidElem(0));
	return typetpl;
    }
    
    public static boolean  maxOccurs(String name, Tuple output) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s;
	boolean mo=false;
	
	rtpl.setElem(1,name);
	rtpl.setElem(0,output.getOidElem(0));
	//System.out.println(rtpl.getStringElem(0));
	s= theConnection.callFunction("Record.Charstring.get_element->Record",rtpl);
	
	rtpl.setElem(1,"maxoccurs");
	rtpl.setElem(0,(s.getRow()).getOidElem(0));
	s = theConnection.callFunction("record.charstring.get_ele_properties->Charstring",rtpl);
	String type= (s.getRow()).getStringElem(0);
	//System.out.println(name+ "  "+ type);
	if (type.equalsIgnoreCase("-1"))
	    mo=true;

	return mo;
	
    }
    public static String  findElement(int ind,Tuple output) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Scan s;

	
	rtpl.setElem(1,ind);
	rtpl.setElem(0,output.getOidElem(0));
	s= theConnection.callFunction("Record.Integer.find_element->Charstring",rtpl);
	

	return (s.getRow()).getStringElem(0);
    }
     public static String  findWSDLtype(String name, Tuple output) throws AmosException 
    {  
	Tuple rtpl = new Tuple(2);
	Tuple typetpl= new Tuple(1);
	Scan s;
       
	
	rtpl.setElem(1,name);
	rtpl.setElem(0,output.getOidElem(0));
	//System.out.println(rtpl.getStringElem(0));
	s= theConnection.callFunction("Record.Charstring.get_element->Record",rtpl);

	rtpl.setElem(1,"wsdltype");
	rtpl.setElem(0,(s.getRow()).getOidElem(0));
	s = theConnection.callFunction("record.charstring.get_ele_properties->Charstring",rtpl);
	//System.out.println("testing>> "+(s.getRow()).getStringElem(0));
	

	return 	(s.getRow()).getStringElem(0);
	
    }
   
   /**
    * Returns a string representation of the given jdom element.
    *
    * @param   elem     The jdom element to be converted into a string.
    *
    * @return  The string representation of the given jdom element.
    */
    public static String  outputString(Element elem)
    {
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
  
    public static String outputString(Schema schema) throws IOException, SAXException
   {
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
    public static Document readXML(String xml) throws JDOMException, IOException
   {
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
   public static Document readXML(Reader reader) throws JDOMException, IOException
   {
      
       SAXBuilder xmlBuilder = new SAXBuilder(false);

      Document doc = xmlBuilder.build(reader);
 
      return doc;
   }
    
   /**
    * It reads the given reader and returns the castor schema.
    *
    * @param   reader   The reader to read.
q    *
    * @return  The castor schema created from the reader.
    *
    * @throws  IOException    If the schema could not be read from the reader.
    */
   public static Schema readSchema(Reader reader) throws IOException
   {
      // create the sax input source
      InputSource inputSource = new InputSource(reader);

      // create the schema reader
      SchemaReader schemaReader = new SchemaReader(inputSource);
      schemaReader.setValidation(false);

      // read the schema from the source
      Schema schema = schemaReader.read();

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
   public static Schema convertElementToSchema(Element element) throws IOException
   {
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
    
}
