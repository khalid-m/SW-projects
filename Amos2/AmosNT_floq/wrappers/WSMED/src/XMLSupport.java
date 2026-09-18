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

   /**
    * Returns a Tuple representation of the given jdom document.
    *
    * @param   doc   The jdom document to be converted into a string.
    *
    * @return  The String representation of the given jdom document.
    */
   
    public static String  outputString(Document doc)
    {
        XMLOutputter xmlWriter = new XMLOutputter();
        return xmlWriter.outputString(doc);
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
