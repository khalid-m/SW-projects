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
    
    private XMLSupport()
    {
    }
    public static Element findResultelement(Element root,String resele) throws AmosException 
    {  

	Element finalele=null;
	String checkval="";
	
	List  allChildren = root.getChildren();

	Iterator i = allChildren.iterator();
	
	while (i.hasNext())
	    {
		Element ch_i = (Element)i.next();
		checkval=ch_i.getName();
		if ((ch_i.getName()).equalsIgnoreCase(resele))
		    finalele=ch_i;
		else
		    finalele=findResultelement(ch_i,resele);
			
		break;
	    }
	
	return finalele;
    }
   /**
    * Returns a Tuple representation of the given jdom document.
    *
    * @param   doc   The jdom document to be converted into a string.
    *
    * @return  The Tuple representation of the given jdom document.
    */
    public static Tuple outputString(Document doc,boolean isRPC) throws AmosException 
    {  
        
	Element root = doc.getRootElement();
	List  allChildren = root.getChildren();
	Element firstchild = (Element) allChildren.get(0);   
	allChildren =  firstchild.getChildren(); 
	firstchild =  (Element)allChildren.get(0);
	
	
	Tuple childvec= new Tuple(2);
	Tuple res= new Tuple(1);
	Tuple childvec1 = new Tuple(1);
	Scan s,s1;
	System.out.println("testing   "+firstchild.getName());
	childvec.setElem(0,firstchild.getName());
        if (isRPC)
	    {
		allChildren =  firstchild.getChildren(); 
		firstchild =  (Element)allChildren.get(0);
	    }

	try
	    {
		if (((firstchild.getChildren()).size())>0)
		    childvec.setElem(1,(child_iterate(firstchild)).getOidElem(0));
		else
		    childvec.setElem(1,"");
		
		Connection theConnection = new Connection("");
		s1=theConnection.callFunction("Object.Object.concat_obj->vector",childvec);
		childvec1.setElem(0,(s1.getRow()).getOidElem(0));
		s = theConnection.callFunction("vector.make_record->Record",childvec1);
		res=s.getRow();
	    }
	catch(Throwable ex)
	    {}

	
	return res;
      
   }
    public static Tuple child_iterate(Element child) 
    {
	
	List allChildren = child.getChildren();
	Iterator i = allChildren.iterator();
	//int cvindex=0;
	//Tuple childvec= new Tuple(allChildren.size());
	Tuple childvec2= new Tuple(1);
	Tuple childvec= new Tuple(2);
	Tuple addrec= new Tuple(3);
	Tuple res= new Tuple(1);
	int childcount=allChildren.size();
	Tuple vec = new Tuple(childcount);
	//System.out.println(childcount);
	Tuple childvec1 = new Tuple(1);
	Scan s,s1,s2,s3;
	int cvindex=0;
	int vecindex=0;
	String checkval="";
	String type="",tval="";
	
	try
	    {
		Connection theConnection = new Connection("");
		while(i.hasNext())
		    {
		
			Element  tempchild = (Element)i.next();
			List tempallChildren = tempchild.getChildren();
			Iterator tempi = tempallChildren.iterator();
			//System.out.println("vecindex "+vecindex+ " child count "+ childcount);
			//System.out.println(">>>>testing>>>>>");
			//s2=theConnection.execute("select maxoccurs(e) from Element e where name(e)='"+tempchild.getName()+"';");
			//childvec2.setElem(0,tempchild.getName()); 
			//s2=theConnection.callFunction("charstring.maxoccurs->Integer",childvec2);
			//System.out.println(">>>>testing "+(s2.getRow()).getIntElem(0));
			childvec2.setElem(0,tempchild.getName()); 
			s2=theConnection.callFunction("charstring.maxoccurs->Integer",childvec2);
			int chkval=(s2.getRow()).getIntElem(0);
			if (tempi.hasNext())
			    {
				//childvec.setElem(cvindex,child_iterate(tempchild));
				if (cvindex==0)
				    {   
					
				
					//if ((s2.getRow()).getIntElem(0)==1)
					if (chkval==1)
					    {
						//System.out.println("test 10 "+tempchild.getName());
						childvec.setElem(0,tempchild.getName());
						//checkval=tempchild.getName();
						childvec.setElem(1,(child_iterate(tempchild)).getOidElem(0));
						//System.out.println(">>>test<<<<<");
						//s = theConnection.execute("concat({'"+tempchild.getName()+"'},{"+(child_iterate(tempchild)).getOidElem(0)+"});");
						s1=theConnection.callFunction("Object.Object.concat_obj->vector",childvec);
						//childvec1=s1.getRow();
						childvec1.setElem(0,(s1.getRow()).getOidElem(0));
						s = theConnection.callFunction("vector.make_record->Record",childvec1);
						//s = theConnection.callFunction("vector.make_record->Record",s.getRow(),1);
						res=s.getRow();
					    }
					else
					    {
						//System.out.println("10 >>>>testing>>>>>");
						vec.setElem(vecindex,(child_iterate(tempchild)).getOidElem(0));
						vecindex+=1;
						res.setElem(0,vec);
					    }
				    }
				else
				    {
					//System.out.println("test 1111 "+tempchild.getName());
					addrec.setElem(0,res.getOidElem(0));
					//if (checkval==tempchild.getName())
					//if ((s2.getRow()).getIntElem(0)==1)
					if (chkval==1)
					    {
						//addrec.setElem(1,tempchild.getName()+cvindex);
						addrec.setElem(1,tempchild.getName());
						checkval=tempchild.getName();
						addrec.setElem(2,(child_iterate(tempchild)).getOidElem(0));
						s = theConnection.callFunction("Record.Charstring.Object.put_record->Record",addrec);
						res=s.getRow();
					    }
					else
					    {
						//System.out.println("11 >>>>testing>>>>>" );
					
						vec.setElem(vecindex,(child_iterate(tempchild)).getOidElem(0));
						vecindex+=1;
						res.setElem(0,vec);
					    }
					
					
					//childvec.setElem(cvindex,child_iterate(child));
				    }
			    }
			else
			    {
				//childvec.setElem(cvindex,tempchild.getValue());
				if (cvindex==0)
				    {
					//if ((s2.getRow()).getIntElem(0)==1)
					if (chkval==1)
					    {
						
						//checkval=tempchild.getName();
						childvec.setElem(0,tempchild.getName());
						//checkval=child.getName();
						s3=theConnection.callFunction("charstring.wsmedtype->charstring",tempchild.getName());
						tval=(s3.getRow()).getStringElem(0);
						
						if (tval.equalsIgnoreCase("charstring"))
						    {	
							//System.out.println(" test11 "+tempchild.getValue());
						    childvec.setElem(1, tempchild.getValue());
						    }
						else
						    if (tval.equalsIgnoreCase("integer"))
							{
							    Integer ie=Integer.parseInt(tempchild.getValue());
							    childvec.setElem(1,ie);
							}
						    else
							if (tval.equalsIgnoreCase("real"))
							    {
								Double db=Double.parseDouble(tempchild.getValue());
								childvec.setElem(1,db);
							    }
							else
							    if (tval.equalsIgnoreCase("boolean"))
							    {
								//	System.out.println(" test "+child.getValue());
								Boolean bo=Boolean.parseBoolean(tempchild.getValue());
								childvec.setElem(1,bo);
							    }
							
						
						//s = theConnection.execute("concat({'"+tempchild.getName()+"'},{'"+tempchild.getValue()+"'});");
						//childvec.setElem(0,(s.getRow()).getOidElem(0));
						s1=theConnection.callFunction("Object.Object.concat_obj->vector",childvec);
						//childvec1=s1.getRow();
						childvec1.setElem(0,(s1.getRow()).getOidElem(0));
						s = theConnection.callFunction("vector.make_record->Record",childvec1);
						//s = theConnection.callFunction("vector.make_record->Record",s.getRow(),1);
						//System.out.println("test 12 "+tempchild.getName()+ " "+ tempchild.getValue());
						res=s.getRow();
					    }
					else
					    {
						//System.out.println("12 >>>>testing>>>>>");
						s3=theConnection.callFunction("charstring.wsmedtype->charstring",tempchild.getName());
						tval=(s3.getRow()).getStringElem(0);
						if (tval.equalsIgnoreCase("charstring"))
						    {
							//System.out.println(" test12 "+tempchild.getValue());
							vec.setElem(vecindex, tempchild.getValue());
						    }
						else
						    if (tval.equalsIgnoreCase("integer"))
							{
							    Integer ie=Integer.parseInt(tempchild.getValue());
							    vec.setElem(vecindex,ie);
							}
						    else
							if (tval.equalsIgnoreCase("real"))
							    {
								Double db=Double.parseDouble(tempchild.getValue());
								vec.setElem(vecindex,db);
								//System.out.println(" test "+tempchild.getValue());
							    }
							else
							    if (tval.equalsIgnoreCase("boolean"))
							    {
								//	System.out.println(" test "+child.getValue());
								Boolean bo=Boolean.parseBoolean(tempchild.getValue());
								vec.setElem(1,bo);
								
							    }
							
						
						
						vecindex+=1;
						res.setElem(0,vec);
					    }
				    }
				else
				    {
					//System.out.println("test 13 "+tempchild.getName());
					
					//if (checkval==tempchild.getName())
					//addrec.setElem(1,tempchild.getName()+cvindex);
					//if ((s2.getRow()).getIntElem(0)==1)
					if (chkval==1)
					    {
						//System.out.println("test 13 "+tempchild.getName()+" "+ tempchild.getValue());
						addrec.setElem(0,res.getOidElem(0));
						addrec.setElem(1,tempchild.getName());
						//checkval=tempchild.getName();
						s3=theConnection.callFunction("charstring.wsmedtype->charstring",tempchild.getName());
						tval=(s3.getRow()).getStringElem(0);
						if (tval.equalsIgnoreCase("charstring"))
						    {
							//System.out.println(" test13 "+tempchild.getValue());
						    addrec.setElem(2, tempchild.getValue());
						    }
						else
						    if (tval.equalsIgnoreCase("integer"))
							{
							    Integer ie=Integer.parseInt(tempchild.getValue());
							    addrec.setElem(2,ie);
							}
						    else
							if (tval.equalsIgnoreCase("real"))
							    {
									
								Double db=Double.parseDouble(tempchild.getValue());
								addrec.setElem(2,db);
							
							    }
							else
							    if (tval.equalsIgnoreCase("boolean"))
							    {
								//	System.out.println(" test "+child.getValue());
								Boolean bo=Boolean.parseBoolean(tempchild.getValue());
								addrec.setElem(1,bo);
								
							    }
						
						s = theConnection.callFunction("Record.Charstring.Object.put_record->Record",addrec);
						res=s.getRow();
					    }
					else
					    {
						//System.out.println("13 >>>>testing>>>>>");
						s3=theConnection.callFunction("charstring.wsmedtype->charstring",tempchild.getName());
						tval=(s3.getRow()).getStringElem(0);
						if (tval.equalsIgnoreCase("charstring"))
						    {
							//System.out.println(" test14 "+tempchild.getValue());
							vec.setElem(vecindex, tempchild.getValue());
						    }
						else
						    if (tval.equalsIgnoreCase("integer"))
							{
							    Integer ie=Integer.parseInt(tempchild.getValue());
							    vec.setElem(vecindex,ie);
							}
						    else
							if (tval.equalsIgnoreCase("real"))
							    {
								Double db=Double.parseDouble(tempchild.getValue());
								vec.setElem(vecindex,db);
							    }
							else
							    if (tval.equalsIgnoreCase("boolean"))
							    {
								//	System.out.println(" test "+child.getValue());
								Boolean bo=Boolean.parseBoolean(tempchild.getValue());
								vec.setElem(1,bo);
								
							    }
						
						vec.setElem(vecindex,tempchild.getValue());
						vecindex+=1;
						res.setElem(0,vec);
					    }
				
						
				    }
				
			    }
	       
			cvindex++;		 
		    }
	// cxt.emit(tpl);
	    }
	catch(Throwable ex)
	    {}
	return res;
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
    * @return  The jdom document created from the xml.
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
    *
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
