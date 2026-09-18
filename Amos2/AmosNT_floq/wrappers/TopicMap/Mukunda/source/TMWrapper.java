/*Sri
 * The TM4J Software License
 *
 *
 * Copyright (c) 2000, 2001, 2002 The TM4J Project. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 va*    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by
 *        The TM4J Project (http://sourceforge.net/projects/tm4j)
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "TM4J" and "The TM4J Project" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact kal@techquila.com.
 *
 * 5. Products derived from this software may not be called "TM4J",
 *    nor may "TM4J" appear in their name, without prior written
 *    permission of the TM4J Project.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE TM4J PROJECT OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 */
 
/*
 * Creatde on 2006-12-6
 *
 * TODO To change the template for this generated file go to
 * Window - Preferences - Java - Code Style - Code Templates
 */

/**
 * @author Qin
 *
 * TODO To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Style - Code Templates
 */
/**
 * Version 1.2. Revision 2007-02-09 Silvia
 */
/**
 * Vesrion 1.3. Revision 2007-02-16 Silvia
 */
//package tmwrapper;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.Reader;
import java.net.URL;
import java.util.HashMap;
import java.util.Stack;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.tm4j.net.Locator;
import org.tm4j.net.LocatorFactoryException;
import org.tm4j.topicmap.*;
import org.tm4j.topicmap.Association;
import org.tm4j.topicmap.BaseName;
import org.tm4j.topicmap.Member;
import org.tm4j.topicmap.Occurrence;
import org.tm4j.topicmap.Topic;
import org.tm4j.topicmap.TopicMap;
import org.tm4j.topicmap.TopicMapProcessingException;
import org.tm4j.topicmap.TopicMapProvider;
import org.tm4j.topicmap.TopicMapProviderException;
import org.tm4j.topicmap.TopicMapProviderFactory;
import org.tm4j.topicmap.Variant;
import org.tm4j.topicmap.VariantName;
import org.tm4j.topicmap.source.SerializedTopicMapSource;
import org.tm4j.topicmap.source.TopicMapSource;
import org.tm4j.topicmap.utils.BuilderPropertyInvalidException;
import org.tm4j.topicmap.utils.BuilderPropertyNotRecognizedException;
import org.tm4j.topicmap.utils.TopicMapBuilder;
import org.tm4j.topicmap.utils.TopicMapWalker;
import org.tm4j.topicmap.utils.WalkerHandler;
import org.tm4j.topicmap.utils.XTMParser;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;
import callout.CallContext;
//imports for xtmbuilder
import org.tm4j.topicmap.*;
import org.tm4j.net.*;

import java.io.InputStream;
import java.io.IOException;
import java.net.*;
import java.util.*;
import java.beans.PropertyVetoException;
import javax.xml.parsers.*;
import org.xml.sax.SAXException;
//import org.apache.log4j.Category;
import org.tm4j.topicmap.utils.TopicMapHandler;


public class TMWrapper
{
    private URL m_inputURL;

    private File m_inputFile;

    public TopicMapProvider m_provider;

    public String tmSrc;

        //TODO comment rewrite
    /**
     * Constructor for the application which validates the input parameters  
     * and creates a connection to the back-end to be used for parsing the topic map.
     */

    public TMWrapper()
    {
        initialise(org.tm4j.topicmap.memory.TopicMapProviderFactoryImpl.class);
    }

    public void initialise(Class providerFactoryClass)
    {
        try
        {
            TopicMapProviderFactory tmpf = (TopicMapProviderFactory) providerFactoryClass
                    .newInstance();
            m_provider = tmpf.newTopicMapProvider(System.getProperties());
        }
        catch (Exception ex)
        {
            throw new RuntimeException("Could not initialise topic map provider" + ex.toString());
        }
    }

    private void parseInput(String inputAddress) throws Exception
    {
        //Extract either a URL or a local File object from the input address
        // This code first attempts to parse the address as a URL and if that fails,
        // falls back on trying to open the specified location as a local file (which
        // must exist).
        try
        {
            m_inputURL = new URL(inputAddress);
        }
        catch (java.net.MalformedURLException ex)
        {
            m_inputFile = new File(inputAddress);
            if (!m_inputFile.exists())
            {
                throw new FileNotFoundException(
                        "Could not locate the specified input file. It is either an invalid URL or an invalid file name.");
            }
        }
    }
    
    //TODO to be deleted
    public static void main(String[] args) throws Exception
    {
        String tmSrc = "E:/AmosNT/wrappers/TopicMap/hamlet.xtm";
        if (args.length > 0)
        {
            tmSrc = args[0];
        }
        
        TMWrapper theApp = new TMWrapper();
        theApp.parseInput(tmSrc);
        theApp.run(tmSrc);
        System.out.println("Topicmap loaded");
    }

    //  TODO
    public void load(CallContext cxt, Tuple tpl) throws Exception
    {

        //String tmSrc = "../jill.xtm";
        tmSrc = tpl.getStringElem(0);

	//        TMWrapper theApp = new TMWrapper();
        parseInput(tmSrc);
        run(tmSrc);
        tpl.setElem(1, "TM Loaded.");
        cxt.emit(tpl);
    }

    public void run(String tmSrc)
    {
        try
        {
            // Get the topic map from the specified file
            TopicMap tm = addTopicMap(tmSrc);

            // Create a simple walker chain with the TopicMapWalker
            // connected to a PrintHandler instance
            //remove walker,printhandler as we call from builder
            //TopicMapWalker walker = new TopicMapWalker();
            //PrintHandler ph = new PrintHandler(tmSrc);
            //walker.setHandler(ph);
            //System.out.println("Dumping all topic map objects:");
            //System.out.println("Walker handler is: " + walker.getHandler());
            //walker.walk(tm);
        }
        catch (Exception ex)
        {
            System.out.println("Error while running example: " + ex.toString());
            ex.printStackTrace();
        }
    }

    public TopicMap addTopicMap(String tmSrc) throws Exception
    {
        try
        {
            //Create the "base" URI of the topic map
            String baseURI = getInputURI();
            Locator baseLocator = m_provider.getLocatorFactory().createLocator("URI", baseURI);

            // Create the TopicMapSource representing the topic map to be parsed
            TopicMapBuilder builder = new XTMBuilder(tmSrc);
            TopicMapSource src = new SerializedTopicMapSource(getInputStream(), baseLocator,
                    builder);
            return m_provider.addTopicMap(src);
        }
        catch (LocatorFactoryException ex)
        {
            if (m_inputURL != null)
                throw new RuntimeException("Could not create a valid URI locator from address "
                        + m_inputURL);
            else
                throw new RuntimeException("Could not create a valid URI locator from address "
                        + m_inputFile);
        }
        catch (TopicMapProviderException ex)
        {
            throw new RuntimeException("Could not create a new topic map: " + ex.toString());
        }

    }

    /**
     * Returns the URI address string of the input to be parsed.
     * If the input source is a URL, then the URL address is returned.
     * If the input source is a File, then the file location is converted to a URL and
     * that address string is returned.
     */
    private String getInputURI() throws Exception
    {
        if (m_inputFile != null)
        {
            return m_inputFile.toURL().toString();
        }
        else
        {
            return m_inputURL.toString();
        }
    }

    /**
     * Returns the source topic map to be parsed as a Java InputStream.
     * For a File source, this will be a FileInputStream, for URL sources,
     * this will be the input stream retrived from the URLConnection.
     */
    private InputStream getInputStream() throws Exception
    {
        if (m_inputFile != null)
        {
            return new FileInputStream(m_inputFile);
        }
        else
        {
            return m_inputURL.openStream();
        }
    }
}


class PrintHandler implements WalkerHandler
{
   int m_indent = 0;

   //To hold the connection to AMOS
   Connection theConnection = null;
   Scan theScan;

   //To hold the arguments or results of AMOS queries
   Tuple arg1, arg2;

   //TODO delete: Oid preObject = null;
   Stack<Oid> stk = new Stack<Oid>();

   //Stack where to put all the created TopicMapObjects
   Stack<TopicMapObject> sttmo = new Stack<TopicMapObject>();

   /*
    * 1: instancf
    * 2: subjectIdentity
    * 3: scope
    * 4: parameters
    * 5: roleSpec
    * 6: plays
    */
   //TODO delete: int preFunction = 0;
   /*
    * 1: topicMap
    * 2: topic
    * 3: baseName
    * 4: variant
    * 5: occurrence
    * 6: association
    * 7: member
    */
   //TODO enumeration
   Stack<Integer> preElement = new Stack<Integer>();

   //TODO
   private boolean hasPushed = false;

   //TODO
   //    HashMap<String, Oid> currTopics = new HashMap<String, Oid>();

   String fileTMO;
   int idnum;
   public Oid baseName;
   public Oid occurrence;

   public PrintHandler(String filen) throws AmosException
   //TODO exception handler at TMWrapper.run()
   {

       //Create the connection
       //TODO to be deleted when called from AMOS
       //Connection.initializeAmos("E:\\AmosNT\\wrappers\\TopicMap\\TAmos.dmp");
       theConnection = new Connection("");
       //TODO to be deleted when called from AMOS
       //theConnection.execute("goovi();");

       arg1 = new Tuple(1);
       arg2 = new Tuple(1);

       fileTMO=filen;

       //TODO close connection, scan, tuple....
   }

   //Creates the names of functions consisting of equal string base added to diff TM objects' titles
   public String makename(TopicMapObject ob, String function)
   {
       String nam;
       if (ob instanceof BaseName)
           nam= function+"basename";
       else if (ob instanceof Occurrence)
           nam= function + "occurrence";
       else if  (ob instanceof Association)
           nam= function + "association";
       else if  (ob instanceof Topic)
           nam= function + "topic";
       else nam=function;

       return nam;
   }

   //Sets the property idTMO, <fileTMO, idnum> for all TMO objects
   private boolean setIdTMO(Oid ob)
   {
       try
           {
               Tuple arg22 = new Tuple(2);
               idnum=idnum +1;
               arg1.setElem(0, ob);
               //              arg2.setElem(0, fileTMO);
               arg22.setElem(0, fileTMO);
               arg22.setElem(1, idnum);
               //              theConnection.addFunction("FILETMO", arg1, arg2);
               theConnection.addFunction("TM_OBJECT.IDTMO->CHARSTRING.INTEGER", arg1, arg22);
           }
       catch (AmosException e)
       {
           System.out.println(e);
       }
       return true;
   }


   public boolean startAssociation(Association a) //<association id=*>
   {
       try
       {
           Oid association = theConnection.createObject("ASSOCIATION");
           setIdTMO(association);
           arg1.setElem(0, association);
	   //create function association(TopicMap) -> Bag of TM_association as stored;
           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("TOPICMAP.ASSOCIATIONTOPICMAP->ASSOCIATION", arg2, arg1);

          
	//this should be if id is not null
	  String id = a.getID();
	if(id != null)
	 {
	  arg2.setElem(0, id.substring(0, id.length() - 3));
                
               theConnection.addFunction("ASSOCIATION.IDASSOCIATION->CHARSTRING", arg1, arg2);
          }
	else
	{
	arg2.setElem(0, id);
                
        theConnection.addFunction("ASSOCIATION.IDASSOCIATION->CHARSTRING", arg1, arg2);
    

	}
           
           stk.push(association);
           preElement.push(new Integer(6));
           sttmo.push(a);
           //TODO to be deleted
           //System.out.println("Push ASSOCIATION " + id);
       }
       catch (AmosException e)
       {
           System.out.println (e);
       }

       m_indent += 2;
       return true;
       /*
       //print("Association: " + a.getID());
       try
       {
           Oid association = theConnection.createObject("ASSOCIATION");
           setIdTMO(association);
           arg1.setElem(0, association);
           //String newid = iid;
           //System.out.println("Association newid is "+newid);
           //create function id(TM_ASSOCIATION) -> Charstring as stored;
           String id = a.getID();
           System.out.println("Association id is "+id);
           //if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
           //{
               arg2.setElem(0, id.substring(0, id.length() - 3));
               theConnection.addFunction("ASSOCIATION.IDASSOCIATION->CHARSTRING", arg1, arg2);
          // }

           //create function association(TopicMap) -> Bag of TM_association as stored;
           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("TOPICMAP.ASSOCIATIONTOPICMAP->ASSOCIATION", arg2, arg1);

           stk.push(association);
           preElement.push(new Integer(6));
           sttmo.push(a);
           //TODO to be deleted
           //System.out.println("Push ASSOCIATION " + id);
       }
       catch (AmosException e)
       {
           System.out.println (e);
       }

       m_indent += 2;
       return true;
        */
   }

   public void endAssociation(Association a)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("pop Association " + a.getID());
       m_indent -= 2;
   }

   public boolean startBaseName(BaseName bn)
   {//create the object and keep till basenamestring is retrieved
       String b = bn.getData();
       if (b ==null)
       {
           
        try
       {
           baseName = theConnection.createObject("BASENAME");
           setIdTMO(baseName);
          arg1.setElem (0, baseName);
           
		//create function id(TM_baseName) -> Charstring as stored;
           String id = bn.getID();
           arg2.setElem (0, id.substring(0, id.length() - 3));
               theConnection.addFunction("BASENAME.IDBASENAME->CHARSTRING", arg1, arg2);
           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("TOPIC.BASENAMETOPIC->BASENAME", arg2, arg1);

           stk.push(baseName);
           sttmo.push(bn);
           preElement.push (new Integer(3));
           //System.out.println("Push BaseName (" + id + ") " + baseNameString);
           m_indent += 2;
       }
        catch (AmosException e)
       {
           System.out.println(e);
       }

       }
else
	try  {
            String baseNameString = bn.getData();
       int index = baseNameString.length();
       baseNameString = baseNameString.substring(0, index);

	  arg1.setElem (0, baseName);
          arg2.setElem(0, baseNameString);
          theConnection.addFunction("BASENAME.BASENAMESTRING->CHARSTRING", arg1, arg2);

	   
	}
        catch (AmosException e)
       {
           System.out.println(e);
       }


return true;
      
   }


 
       
       
           
       /*
       String baseNameString = bn.getData();
       int index = baseNameString.length();
       baseNameString = baseNameString.substring(0, index);

       try
       {
           Oid baseName = theConnection.createObject("BASENAME");
           setIdTMO(baseName);
           arg1.setElem (0, baseName);
           arg2.setElem(0, baseNameString);
           theConnection.addFunction("BASENAME.BASENAMESTRING->CHARSTRING", arg1, arg2);

           //create function id(TM_baseName) -> Charstring as stored;
           String id = bn.getID();
          // if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
          // {
               arg2.setElem (0, id.substring(0, id.length() - 3));
               theConnection.addFunction("BASENAME.IDBASENAME->CHARSTRING", arg1, arg2);
          // }

           //create function baseName(TM_topic) -> Bag of TM_baseName as stored;
           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("TOPIC.BASENAMETOPIC->BASENAME", arg2, arg1);

           stk.push(baseName);
           sttmo.push(bn);
           preElement.push (new Integer(3));
           //System.out.println("Push BaseName (" + id + ") " + baseNameString);
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }

       m_indent += 2;*/
        
       

   public void endBaseName(BaseName bn)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("pop BaseName " + bn.getData());
       m_indent -= 2;
       baseName = null;
   }

   public boolean startMember(Member m) //<member>
   {
       try
       {
           Oid member = theConnection.createObject("MEMBER");
           setIdTMO(member);
           arg1.setElem(0, member);

           //create function member(TM_association) -> Bag of TM_member as stored;
           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("ASSOCIATION.MEMBERASSOCIATION->MEMBER", arg2, arg1);
           stk.push(member);
           sttmo.push(m);
           preElement.push(new Integer(7));
           //System.out.println("Push MEMBER " + m.getID());
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }

       m_indent += 2;
       return true;
   }

   public void endMember(Member m)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("pop MEMBER " + m.getID());
       m_indent -= 2;
   }

   public boolean startOccurrence(Occurrence o, String iid, String resrefocc) //<occurence><resource*>
   {
       if(iid == null)
           //if iid = = null
       {
           try
       {
            occurrence = theConnection.createObject("OCCURRENCE");
           setIdTMO(occurrence);
           arg1.setElem(0, occurrence);
           arg2.setElem (0, (Oid) stk.peek());
           theConnection.addFunction("TOPIC.OCCURRENCETOPIC->OCCURRENCE", arg2, arg1);

           stk.push(occurrence);
           sttmo.push(o);
           preElement.push(new Integer(5));
           //System.out.println("Push Occurrence ");
	}
           catch (AmosException e)
       {
           System.out.println(e);
       }

       m_indent += 2;
       }

else
{
           try{
	onType(iid);//method call for instanceof
	if (o.isDataInline()) //<resourceData>
           {
               //To extract id from resourceData
               String data = o.getData();
               int index = data.indexOf('<');
               if (index != -1)
               {
                   //id = data.substring(0, index);
                   data = data.substring(index + 1);
               }
               arg1.setElem(0, occurrence);
               arg2.setElem(0, data);
               theConnection.addFunction("OCCURRENCE.DATA->CHARSTRING", arg1, arg2);
           }
           else
           //<resourceRef>
           {
               Locator lo = o.getDataLocator();
               String s= lo.getAddress();
               //create implicit topic and place it into arg1
               // createTopic("", s);
               arg1.setElem(0,resrefocc);
               arg2.setElem(0, (Oid) stk.peek());
               theConnection.addFunction("OCCURRENCE.REFERENCE->CHARSTRING", arg2, arg1);
               //print("External Data @: " + o.getDataLocator().getAddress());
           }


    }
           catch (AmosException e)
       {
           System.out.println(e);
       }

}
       //this is commented to manage the individual call to startocc from builder
       /*
       try
       {
           Oid occurrence = theConnection.createObject("OCCURRENCE");
           setIdTMO(occurrence);
           arg1.setElem(0, occurrence);
           arg2.setElem (0, (Oid) stk.peek());
           theConnection.addFunction("TOPIC.OCCURRENCETOPIC->OCCURRENCE", arg2, arg1);

           stk.push(occurrence);
           sttmo.push(o);
           preElement.push(new Integer(5));
           //System.out.println("Push Occurrence ");

           Topic td=o.getType();

            //If there is a topic-definition of that occurrence
            if (td != null)
            {
               String id="";
                 Locator l = null;
                 String url="";
                if (!td.getSourceLocators().isEmpty())
                    {
                        l = (Locator) td.getSourceLocators().iterator().next();
                        id=td.getID();
                        url=l.getAddress();
                        //if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
                           // {
                                id= id.substring(0, id.length() - 3);
                           // }
                        Integer pos=url.indexOf("#");
                        if(pos != -1)
                            {
                                url=url.substring(0,pos);
                            }

                    }
                else if (!td.getSubjectIndicators().isEmpty())
                    l = (Locator) td.getSubjectIndicators().iterator().next();
                else if (td.getSubject() != null)
                    l = (Locator) td.getSubject();
                    id = iid;
                createTopic(id,url,l);
                arg2.setElem(0, (Oid) stk.peek());
                //              theConnection.addFunction("INSTANCEOF", arg2, arg1);
            }

           if (o.isDataInline()) //<resourceData>
           {
               //To extract id from resourceData
               String data = o.getData();
               int index = data.indexOf('<');
               if (index != -1)
               {
                   //id = data.substring(0, index);
                   data = data.substring(index + 1);
               }
               arg1.setElem(0, occurrence);
               arg2.setElem(0, data);
               theConnection.addFunction("OCCURRENCE.DATA->CHARSTRING", arg1, arg2);
           }
           else
           //<resourceRef>
           {
               Locator lo = o.getDataLocator();
               String s= lo.getAddress();
               //create implicit topic and place it into arg1
               // createTopic("", s);
               arg1.setElem(0,resrefocc);
               arg2.setElem(0, (Oid) stk.peek());
               theConnection.addFunction("OCCURRENCE.REFERENCE->CHARSTRING", arg2, arg1);
               //print("External Data @: " + o.getDataLocator().getAddress());
           }


       }*/
       
       //m_indent += 2;
       return true;
   }

   public void endOccurrence(Occurrence o)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("pop Occurrence ");
       m_indent -= 2;
       occurrence = null;
   }

   public boolean startScope() //<scope>
   {
       m_indent += 2;
       return true;
   }

   public void endScope()
   {
       m_indent -= 2;
   }
   //this is replaced by direct calls from builder to the corresponding methods
  /* public void allrefoftopic(Topic t,String occiid, String subiid, String insiid)
   {
           String insid = insiid;
           String newsubid = subiid;
           String newid = occiid;
           Topic currtopic = t;
           if (insid != null)
               onType(insid);
            if (newsubid != null)
                   onSubjectIndicator(newsubid);
           
            
       
   }
*/
   public boolean startTopic(Topic t) //<topic id=*>
   {
       try
       {
           String id = t.getID();
           String address = null;
           Locator l = null;
           //Topic inst;
           if (!t.getSourceLocators().isEmpty())
               l = (Locator) t.getSourceLocators().iterator().next();
           else if (!t.getSubjectIndicators().isEmpty())
               l = (Locator) t.getSubjectIndicators().iterator().next();
           else if (t.getSubject() != null)
               l = (Locator) t.getSubject();
           address = l.getAddress();

           //TODO "((Integer) preElement.peek()).intValue() == 1)" delete?
           //TODO is there the possibility that some topics may not be processed yet?
          // if ((!id.contains("\"ID") && !id.contains("\"noID") && ((Integer) preElement.peek())
            //       .intValue() == 1))
           if ((Integer) preElement.peek().intValue() == 1)
                  
           {
               if (address != null) //??
               {
                   int index = address.indexOf('#');
                   if (index != -1)
                   {
                       id = address.substring(index + 1) + "\"ID";
                       address = address.substring(0, index);
                   }
                   else
                       id = "" + "\"ID";
               }
           }
           if (id.contains("\"ID"))// && !id.contains("\"noID")))
           {
               id = id.substring(0, id.length() - 3);
               int index = address.indexOf('#');
               if (index != -1)
                   address = address.substring(0, index);

               //create topic and place it into arg1
               Oid topic = createTopic(id, address,null);
               
               stk.push(topic);
               sttmo.push(t);
               hasPushed = true;
               preElement.push(new Integer(2));
                 //System.out.println("Push Topic " + id);
               //System.out.println("preElement: " + ((Integer) preElement.peek()).intValue());
           }
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }

       m_indent += 2;
       return true;
   }

   public void endTopic(Topic t)
   {
       if (hasPushed)
       {
           stk.pop();
           sttmo.pop();
           preElement.pop();
           //System.out.println("Pop Topic " + t.getID());
           //System.out.println("preElement: " + ((Integer) preElement.peek()).intValue());
           hasPushed = false;
       }
       m_indent -= 2;
   }

   public boolean startTopicMap(TopicMap tm, String id) //<topicMap> + baseLocator
   {
       try
       {
           Oid topicMap = theConnection.createObject("TOPICMAP");
           setIdTMO(topicMap);
           String tmid=id;
            //String tmname=tm.getName();
           arg1.setElem (0,topicMap);
           arg2.setElem(0,tmid);
           theConnection.addFunction("TOPICMAP.IDTOPICMAP->CHARSTRING", arg1, arg2);
           //  arg2.setElem(0,tmname);
//          theConnection.addFunction("NAME", arg1, arg2);
           stk.push(topicMap);
           sttmo.push(tm);
           preElement.push(new Integer(1));
           //System.out.println("Push TopicMap ");
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
       //print("TopicMap: " + tm.getBaseLocator().getAddress());
       return true;
   }

   public void endTopicMap(TopicMap tm)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("Pop TopicMap ");
   }

   public boolean startVariant(Variant v) //<variant>
   {
       try
       {
           Oid variant = theConnection.createObject("VARIANT");
           setIdTMO(variant);
           arg1.setElem(0, variant);
           arg2.setElem(0, (Oid) stk.peek());

           //creates the function variant(TM_baseName)->TM_variant or variant(TM_variant)->TM_variant
           String funame;
           VariantContainer vcc = v.getParent();
           if (vcc instanceof BaseName)
               funame="variantbasename";
           else
               funame="subvariant";
           theConnection.addFunction(funame, arg2, arg1);

           stk.push(variant);
           sttmo.push(v);
           preElement.push(new Integer(4));
           //System.out.println("Push VARIANT");
       }
       catch (AmosException e)
       {
           System.out.println (e);
       }

       m_indent += 2;
       return true;
   }

   public void endVariant(Variant v)
   {
       stk.pop();
       sttmo.pop();
       preElement.pop();
       //System.out.println("pop Variant ");
       m_indent -= 2;
   }
//replace with string to create topic for parameter value
  // public void onParameter(Topic param) //<parameters><*>
   public void onParameter(String param)
   {
       Locator l = null;
       String url = "";
      //  if (!param.getSubjectIndicators().isEmpty())
//             l = (Locator) param.getSubjectIndicators().iterator().next();
//         //else if (roleSpec.getSubject() != null)
//         //l = roleSpec.getSubject();
//         else
//             l = (Locator) param.getSourceLocators ().iterator().next();

      /* if (param.getSubject() != null)
           l = param.getSubject();
       else
           l = (Locator) param.getSourceLocators().iterator().next();
       String url=l.getAddress ();
       String id = param.getID();
      // if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
          // {
             id= id.substring (0, id.length() - 3);
          //  }
        Integer pos=url.indexOf("#");
        if(pos != -1)
          {
               url=url.substring(0,pos);
           }


       String s=l.getAddress ();

       //print(l.getAddress());*/
       try
       {
           //create implicit topic and place it into arg1
           createTopic(param, url,l);

           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction("VARIANT.PARAMETERS->TOPIC", arg2, arg1);
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
   }

   //public void onPlayer(Topic player) //<member><*=*>
   public void onPlayer(String playid)
   {
       Locator l = null;
       String url="", id=playid;
       /*if (!player.getSourceLocators().isEmpty())
           {
               l = (Locator) player.getSourceLocators().iterator().next();
               url=l.getAddress();
               id=player.getID();

               int index = url.indexOf('#');
               if (index != -1)
                  {
                      id = url.substring(index + 1);
                     url = url.substring(0, index);
                  }

              // if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
                  // {
                       id= id.substring(0, id.length() - 3);
                  // }

           }
       else if (!player.getSubjectIndicators().isEmpty())
           {
               l = (Locator) player.getSubjectIndicators().iterator().next();

           }
*/
       try
       {
           //creaet eimplicit topic and place it into arg1
           createTopic(id, url,l);

           arg2.setElem (0, (Oid) stk.peek());
           theConnection.addFunction("MEMBER.TOPICMEMBER->TOPIC", arg2, arg1);
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
   }
//test this with string id of rolespec topicref
  // public void onRoleSpec(Topic roleSpec) //<member><roleSpec>
   public void onRoleSpec(String rolerefid)
   {
       /*
       String url="", id="";
       Locator l = null;
       if (roleSpec.getSubject() != null)
           l = roleSpec.getSubject();
       else if (!roleSpec.getSourceLocators().isEmpty())
           {
               l = (Locator) roleSpec.getSourceLocators().iterator().next();
               url=l.getAddress();
               id = roleSpec.getID();
               //if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
                 //  {
                       id= id.substring (0, id.length() - 3);
                 //  }
               Integer pos=url.indexOf("#");
               if(pos != -1)
                   {
                       url=url.substring(0,pos);
                       //                      id = url.substring(pos + 1);
                   }
           }
       else
           l = (Locator) roleSpec.getSubjectIndicators().iterator().next();

*/
       //print("roleSpec: " + l.getAddress ());
       try
       {
          String url="", id=rolerefid;
       Locator l = null;
       //create implicit topic and place it into arg1
           createTopic(id, url,l);

           arg2.setElem(0, (Oid) stk.peek());
           theConnection.addFunction ("MEMBER.ROLESPEC->TOPIC", arg2, arg1);
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
   }

   public void onSubject(Locator subject) //<resourceRef>
   {
       // try
//         {
//             //create implicit topic and place it into arg1

//          // createTopic("", "", subject);
//         String sub=subject.getAddress ();
//          arg1.setElem(0, sub);
//             arg2.setElem(0, (Oid) stk.peek());
//             if (((Integer) preElement.peek()).intValue() == 2)
//                 theConnection.addFunction("SUBJECTADDRESS", arg2, arg1);
//         }
//         catch (AmosException e)
//         {
//             System.out.println(e);
//         }
//         //print("Subject: " + subject.getAddress());
   }
//test if this works without loacator
  // public void onSubjectIndicator(Locator subjectIndicator) //<subjectIndicatorRef?>
   public void onSubjectIndicator (String subid)
   {
       try
       {
           //create implicit topic and place it into arg1
           // createTopic("", "", subjectIndicator);

           //String sub=subjectIndicator.getAddress ();
           String sub = subid;
            arg1.setElem(0, sub);
           arg2.setElem(0, (Oid) stk.peek());
           if (((Integer) preElement.peek()).intValue() == 2)
               theConnection.addFunction("TOPIC.SUBJECTIDENTITY->CHARSTRING", arg2, arg1);
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
       //print("SubjectIndicator: " + subjectIndicator.toString());
       //print("SubjectIndicator: " + address);
   }

   //public void onTheme(Topic theme, String scid) //<scope><*>
   public void onTheme(String scid)
   {
       Locator l = null;
       String url="";
       String id=scid;
     /* if (!theme.getSourceLocators().isEmpty())
           {
               l = (Locator)theme.getSourceLocators().iterator().next();
               url=l.getAddress();
               id=theme.getID();

       int index = url.indexOf('#');
               if (index != -1)
                  {
                      id = url.substring(index + 1);
                     url = url.substring(0, index);
                  }


               //if (id.contains ("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
               //    {
                       id= id.substring(0, id.length() - 3);
                //   }

           }
       else if (!theme.getSubjectIndicators().isEmpty())
           {
               l = (Locator) theme.getSubjectIndicators().iterator().next();

           }
       else
           l = theme.getSubject();

*/
       try
       {
           //create implicit topic and place it into arg1
           createTopic(id, url,l);
           arg2.setElem(0, (Oid) stk.peek());

           TopicMapObject o= sttmo.peek();
           String funame=makename(o, "SCOPE");
           theConnection.addFunction(funame, arg2, arg1);

       }
       catch (AmosException e)
       {
           System.out.println (e);
       }
   }
   public void onType(String insid)
   //public void onType(Topic type) //<instanceOf><*>
   {
       /*
       //commenting this to create an implicit topic for instanceof
       Locator l = null;
       Locator lp = null;
       String url="", id="";
       if (!type.getSourceLocators().isEmpty())
           {
               l = (Locator) type.getSourceLocators().iterator().next();
               url=l.getAddress();
               id = type.getID();
             //  if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
                //   {
                       id= id.substring(0, id.length() - 3);
                 //  }
               Integer pos=url.indexOf("#");
               if(pos != -1)
                   {
                       url=url.substring(0,pos);
                       //                      id = url.substring(pos + 1);
                   }

           }
       //      else if (!type.getSubject.isEmpty())
       else if (!type.getSubjectIndicators().isEmpty())
           {
               l = (Locator) type.getSubjectIndicators().iterator().next();

               }
       else
           l = type.getSubject ();

*/
       try
       {
           String url = "";
           Locator l = null;
           //create implicit topic and place it into arg1
           String iid = insid;
           createTopic(iid, url,l);
           arg2.setElem(0, (Oid) stk.peek());
           //this comtains the id of instance
            //arg1.setElem(0, iid);
              
           TopicMapObject o= sttmo.peek();
           String funame=makename(o, "INSTANCEOF");
           theConnection.addFunction(funame, arg2, arg1);


       }
       catch (AmosException e)
       {
           System.out.println (e);
       }
   }

  // public void onVariantName(VariantName vn) //<variantName><*>
   public void onVariantName(String varvalue)
   {
       try
       {
           arg1.setElem(0, varvalue);
               arg2.setElem(0, (Oid) stk.peek());
               theConnection.addFunction("VARIANT.VARIANTNAME->CHARSTRING", arg2, arg1);
         
           /*
           if (vn.isDataInline())
           {
               Tuple arg3 = new Tuple(1);
               String data = vn.getData();
               int index = data.indexOf('<');
               String id = "";
                if (index != -1)
                {
                    data = data.substring(0, index);
//                     data = data.substring(index + 1);
                }

//              //                arg3.setElem(0, id);
               arg3.setElem(0, data);
               arg2.setElem(0, (Oid) stk.peek());

               //create function data(TM_variant) -> <Charstring,Charstring> as stored;
               theConnection.addFunction("VARIANT.VARIANTNAME->CHARSTRING", arg2, arg3);
           }
           else
           {
               Locator l = vn.getDataLocator();
               String s=l.getAddress();

               //create implicit topic and place it into arg1
               //                createTopic("", s);
               arg1.setElem(0, s);
               arg2.setElem(0, (Oid) stk.peek());
               theConnection.addFunction("VARIANT.VARIANTNAME->CHARSTRING", arg2, arg1);
           }*/
       }
       catch (AmosException e)
       {
           System.out.println(e);
       }
   }

// Creates a topic in Amos with correct idtopic and idtmo if such a topic does not already exist; adds it also to the 
    //list of the topics of the Topic Map   
    public Oid createTopic(String id, String address, Locator l) throws AmosException									
    {
        Oid topic;
	idnum=idnum+1;
	Tuple arg3= new Tuple(4);
	arg3.setElem(0,id); 
	arg3.setElem(1,fileTMO);
	arg3.setElem(2,idnum);
	arg3.setElem(3, (Oid) stk.firstElement());
	topic = theConnection.callFunction("CHARSTRING.CHARSTRING.INTEGER.TOPICMAP.THETOPIC->TOPIC",arg3).getRow().getOidElem(0);
	arg1.setElem(0, topic);
        return topic;
    }

    public boolean startTopicMap(TopicMap arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
/*
    public boolean startTopic(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
*/
    public boolean startOccurrence(Occurrence arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
/*
    public boolean startAssociation(Association arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
*/
    public void onSubjectIndicator(Locator arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onType(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onTheme(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onRoleSpec(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onPlayer(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onParameter(Topic arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void onVariantName(VariantName arg0) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
    
}
class MyXTMBuilder extends XTMBuilder
{/*
    protected String assignID(Locator loc, String id) //topic
    {
        if (id != null)
            return super.assignID(loc, id + "\"ID");
        else
        {
            String address = loc.getAddress();
            int index = address.indexOf('#');
            if (index != -1)
            {
                id = address.substring(index + 1);
                return super.assignID(loc, id + "\"ID");
            }
            else
                return (super.assignID(loc, id) + "\"noID");
        }
    }

    protected String assignID(Locator loc)
    {
        String address = loc.getAddress();
        int index = address.indexOf('#');
        if (index != -1)
        {
            String id = address.substring(index + 1);
            return super.assignID(loc, id + "\"ID");
        }
        else
            return (super.assignID(loc) + "\"noID");
    }

    protected String assignID(String elementID) //baseName
    {
        if (elementID != null)
            return super.assignID(elementID + "\"ID");
        else
            return (super.assignID(elementID) + "\"noID");
    }
*/
    public void resourceData(String id, String data) throws TopicMapProcessingException
    {
        super.resourceData(id, id + "<" + data);
    }
    
    public void baseNameString(String id, String value) throws TopicMapProcessingException
    {
        super.baseNameString(id, value + "<" + this.generateID());
    }

}

//Srixtmbuilder

class XTMBuilder implements TopicMapHandler, TopicMapBuilder
{
    public static final String DEFAULT_BASE_URL = "http://topicmap.techquila.com/default";

   // private Category m_log = Category.getInstance("org.tm4j.utils.XTMBuilder");
    TopicMap m_tm;
    TopicMapUtils m_tmutils;
    
    TopicMapFactory m_factory;
    LocatorFactory m_locatorFactory;
    Locator m_defaultBaseLocator;
    Locator m_baseLocator;
    Locator m_resourceLocator;
    
    Topic m_currTopic;
    Occurrence m_currOcc;
    Association m_currAssoc;
    Topic m_currAssocType;
    Member m_currMember;
    BaseName bn;
    //here replace Scope with Topic[] as the createscope method is no longer functional
    //Scope m_currScope;
    Topic[] m_currScope;
    VariantName m_currVariantName;
    Stack m_variants;
    Stack m_refPurpose;
    //Hashtable m_stubTopics;
    //IDGenerator m_idGenerator;
    //Hashtable m_assignedIDs;

    // Map of mergeMap URI to the scope to be applied on merging.
    //HashMap m_mergeMaps;
    Locator m_mergeMapLocator;
    //HashSet m_externalTopicRefs;

    boolean m_failOnVeto = true;
    boolean m_parseOptionValidating = false;
    PrintHandler np;
    int nextID = 1;
    static final int INSTANCEOF = 1;
    static final int SCOPE = 2;
    static final int ROLESPEC = 3;
    static final int SUBJECTIDENTITY = 4;
    static final int OCCURRENCE = 5;
    static final int PARAMETERS = 6;
    static final int MEMBER = 7;
    static final int MERGESCOPE=8;
    static final int VARIANTNAME=9;
    public String tmSr = "";
//public String tmSr = "E:/AmosNT/wrappers/TopicMap/hamlet.xtm";
public String occid = null;
public String resrefocc = null;
public String subid = null;
public String insid = null;
public String scopid = null;
public String addidforocc = null;
public String addidforas = null;
public String rolespc = null;
public String playerid = null;
public String paramid = null;
    /**
     * A convenience constant defining the property name http://www.tm4j.org/tm4j/xtmbuilder/validation
     */
    public static final String OPTION_VALIDATION = "http://www.tm4j.org/tm4j/xtmbuilder/validation";

    /**
     * A convenience constant defining the property name http://www.tm4j.org/tm4j/xtmbuilder/failonveto
     */
    public static final String OPTION_FAIL_ON_VETO = "http://www.tm4j.org/tm4j/xtmbuilder/failonveto";

    public XTMBuilder(TopicMapFactory factory, LocatorFactory locFactory, String tmSrc)
    {
        m_factory = factory;
        m_locatorFactory = locFactory;
        tmSr = tmSrc;
        init();
    }

    XTMBuilder(String tmSrc) {
        tmSr = tmSrc;
         }
/*
    XTMBuilder(String tmSrc) 
    {
        tmSr = tmSrc;
        XTMBuilder x = new XTMBuilder();
        
         }
*/
    protected void init()
    {
       // m_stubTopics = new Hashtable();
       // m_assignedIDs = new Hashtable();
        m_refPurpose = new Stack();
        //m_mergeMaps  = new HashMap();
        //m_externalTopicRefs = new HashSet();

        //m_idGenerator = new IDGeneratorFactory().newIDGenerator();
        try
        {
            String urlString = System.getProperty("org.tm4j.topicmap.baseURL",
                                                  DEFAULT_BASE_URL);
            m_defaultBaseLocator = m_locatorFactory.createLocator("URI", urlString);
            String resourceString = System.getProperty("org.tm4j.topicmap.resourceURL", DEFAULT_BASE_URL);
            m_resourceLocator = m_locatorFactory.createLocator("URI", resourceString);
             np = new PrintHandler(tmSr);
        }
        catch (AmosException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        }        catch(LocatorFactoryException ex)
        {
           throw new TopicMapRuntimeException("Cannot initialise base URL for TopicMapFactoryImpl.", ex);
        } 
    }

    public XTMBuilder(TopicMap baseTM, String tmSrc )
    {
        m_factory = baseTM.getFactory();
        m_locatorFactory = baseTM.getLocatorFactory();
        m_tm = baseTM;
        m_tmutils = m_tm.getUtils();
        tmSr = tmSrc;
        init();
        if (baseTM.getResourceLocator() != null)
            m_resourceLocator = baseTM.getResourceLocator();
    }

    public XTMBuilder(TopicMap baseTM, Locator mergeMapLocator, String tmSrc)
    {
        m_factory = baseTM.getFactory();
        m_locatorFactory = baseTM.getLocatorFactory();
        m_tm = baseTM;
        m_tmutils = m_tm.getUtils();
        tmSr = tmSrc;
        init();
        m_resourceLocator = mergeMapLocator;
    }

    /**
     * Creates an unitialised XTMBuilder for later initialisation by
     * a call to the build() method.
     */
    public XTMBuilder()
    {

    }

    public boolean isSupportedProperty(String propertyName)
    {
	if (propertyName.equals(OPTION_VALIDATION))
	{
	    return true;
	}
	else if (propertyName.equals(OPTION_FAIL_ON_VETO))
	{
	    return true;
	}
	return false;
    }

    public void setProperty(String propertyName, String value)
	throws BuilderPropertyNotRecognizedException, BuilderPropertyInvalidException
    {
	if (propertyName.equals(OPTION_VALIDATION))
	{
	    m_parseOptionValidating = Boolean.valueOf(value).booleanValue();
	}
	else if (propertyName.equals(OPTION_FAIL_ON_VETO))
	{
	    m_failOnVeto = Boolean.valueOf(value).booleanValue();
	}
	else
	{
	    throw new BuilderPropertyNotRecognizedException("Property " + propertyName + " is not recognised by builder class " + getClass().getName());
	}
    }


    public void build(InputStream src, Locator baseLocator, TopicMap tm, TopicMapProvider provider)
	throws IOException, LocatorFactoryException, 
	TopicMapProcessingException, PropertyVetoException, 
	TopicMapProviderException
    {
	m_factory = tm.getFactory();
	m_locatorFactory = tm.getLocatorFactory();
        m_baseLocator = baseLocator;
	m_tm = tm;
	m_tmutils = tm.getUtils();
        
        
	init();
	if (m_tm.getResourceLocator() != null)
	{
	    m_resourceLocator = m_tm.getResourceLocator();
	}

	try
	{
	    SAXParserFactory spf = SAXParserFactory.newInstance();
	    spf.setNamespaceAware(true);
	    spf.setValidating(m_parseOptionValidating);
	    spf.setFeature("http://xml.org/sax/features/validation", m_parseOptionValidating);
	    SAXParser sp = spf.newSAXParser();
	    XTMParser handler = new XTMParser(this);
	    sp.parse(src, handler);
	}
	catch(ParserConfigurationException ex)
	{
	    throw new TopicMapProviderException("Could not initialise SAX parser: " + ex.toString());
	}
	catch(SAXException ex)
	{
	    throw new TopicMapProcessingException("Invalid XML document. Parser reports: " +  ex.toString());
	}
    }

    public TopicMap getTopicMap() { return m_tm; }

    public void setResourceLocator(Locator loc)
    {
        m_resourceLocator = loc;
    }
    
    /**
     * @deprecated From 0.6.0 use {@link #setResourceLocator} instead.
     */
    public void setResourceURL(URL u)
    {
        try
        {
            m_resourceLocator = m_locatorFactory.createLocator("URI", u.toString());
        }
        catch(LocatorFactoryException ex)
        {
         throw new TopicMapRuntimeException("Cannot convert resource URL : " + u.toString() + " to URILocator");
        }   
    }
    
    public void startTopicMap(String id, String xmlBase)
        throws TopicMapProcessingException
    {
        try
        {
           //System.out.println("topicmap id "+id);
            //System.out.println("XTMBuilder.startTopicMap()");
            if (xmlBase != null)
            {
               // m_baseLocator = m_locatorFactory.createLocator("URI", xmlBase);
                
            }
            if (m_tm == null)
            {
		throw new TopicMapProcessingException("XTMBuilder is not correctly initialised. No base topic map defined.");
		/*
                m_tm = m_factory.createTopicMap(m_resourceLocator);
                m_tmutils = m_tm.getUtils();
                String assignedID = assignID(id);
                m_tm.setResourceLocator(m_resourceLocator.resolveRelative("#" + id));
		*/
            }
            //m_factory.setBaseLocator(m_baseLocator);
            if(id == null)
                id ="noid";
            np.startTopicMap(m_tm, id);
        }
        catch(Exception ex)
        {
            throw new TopicMapProcessingException("invalid locator found in xml:base attribute: " + xmlBase + " - locator must be a valid URI");
        }
	/*
        catch(LocatorResolutionException ex)
	{
	    throw new TopicMapProcessingException("Unable to resove id " + id + " relative to URI: "+ m_resourceLocator.getAddress() + " - " + ex.toString());
	}
	*/
    }

    public void endTopicMap()
        throws TopicMapProcessingException
    {
        np.endTopicMap(m_tm);
        /*
        Enumeration stubIt = m_stubTopics.keys();
        while (stubIt.hasMoreElements())
        {
            Locator stubAddress = (Locator)stubIt.nextElement();
            Topic  stubTopic = (Topic)m_stubTopics.get(stubAddress);
            System.out.println("Stub address: " + stubAddress.getAddress());
            
            stubTopic.setResourceLocator(stubAddress);
        }
        */
    }

    public void startTopic(String id)
        throws TopicMapProcessingException
    {
         //System.out.println("topic id "+id);
          
	//m_log.debug("startTopic(" + id + ")");
        Locator resourceLocator = resourceLocatorForID(id);
	/*
        if (m_stubTopics.containsKey(resourceLocator))
        {
	    m_log.debug("Found stub topic with resourceLocator: " + resourceLocator.getAddress());
            m_currTopic = (Topic)m_stubTopics.get(resourceLocator);
        }
        else
        {
            TopicMapObject tmo = m_tm.getObjectByResourceLocator(resourceLocator);
            if ((tmo != null) && (tmo instanceof Topic))
            {
		m_log.debug("Found pre-existing topic with resourceLocator: " + resourceLocator.getAddress());
                m_currTopic = (Topic)tmo;
            }
            else
            {
                String assignedID = assignID(resourceLocator, id);
		m_log.debug("Assigned ID: " +assignedID);*/
		try
		{
		    m_currTopic = m_tm.createTopic(id);
		    m_currTopic.setResourceLocator(resourceLocator);
                    np.startTopic(m_currTopic);
		}
		catch(PropertyVetoException ex)
		{
		    throw new TopicMapProcessingException("Creation of topic was vetoed." + ex.toString());
		}
            
        
    }

    public void endTopic()
        throws TopicMapProcessingException
    {
        try {
            //createtopic called here as to put all references
            //np.startTopic(m_currTopic, occid, subid, insid);
            //np.allrefoftopic(m_currTopic, occid, subid, insid);
            np.endTopic(m_currTopic);
            //m_currTopic = null;
            
            m_currTopic.destroy();
            occid = null;
            subid = null;
            insid = null;
        } catch (IntegrityViolationException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        } catch (PropertyVetoException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    protected void pushPurpose(int purpose)
    {
        m_refPurpose.push(new Integer(purpose));
    }

    protected int peekPurpose()
    {
        if (m_refPurpose.isEmpty()) return 0;
        return ((Integer)m_refPurpose.peek()).intValue();
    }

    protected int popPurpose()
    {
        return ((Integer)m_refPurpose.pop()).intValue();
    }
        
    public void startInstanceOf(String id)
        throws TopicMapProcessingException
    {
         //System.out.println("instance of id "+id);
          
        pushPurpose(INSTANCEOF);
    }

    public void endInstanceOf()
        throws TopicMapProcessingException
    {
        //call the ontype method to create implicit topic
        np.onType(occid);
        insid = null;
        occid = null;
        popPurpose();
        
    }

    public void startSubjectIdentity(String id)
        throws TopicMapProcessingException
    {
           
        pushPurpose(SUBJECTIDENTITY);
    }

    public void endSubjectIdentity()
        throws TopicMapProcessingException
    {
        np.onSubjectIndicator(subid);
        subid = null;
        popPurpose();
    }

    public void startBaseName(String id)
        throws TopicMapProcessingException
    {
        m_variants = new Stack();
	try
	{
	     bn = m_currTopic.createName(id);
	    setResourceID(bn, id);
	    m_variants.push(bn);
            np.startBaseName(bn);
            }
	catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("property change was vetoed while adding base name. " + ex.toString());
            }
            else
            {
                // Log warning
            }
        }
    }

    public void endBaseName()
        throws TopicMapProcessingException
    {
       
	bn = (BaseName)m_variants.pop();
        np.endBaseName(bn);
	//m_currTopic.addName(bn);
    }
    
    public void startOccurrence(String id)
        throws TopicMapProcessingException
    {
	try
	{
	    m_currOcc = m_currTopic.createOccurrence(id);
	    setResourceID(m_currOcc, id);
	    pushPurpose(OCCURRENCE);
            //if (id != null)
            //{
                // System.out.println("occurrence id is "+id);
          
            np.startOccurrence(m_currOcc, occid, resrefocc);
          //  }
            //else occid = "occ";
	}
	catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Property change vetoed while adding new occurrence. " + ex.toString());
            }
            else
            {
                // Log warning
            }
        }
    }

    public void endOccurrence()
        throws TopicMapProcessingException
    {
        try {
            // {
            // {
            np.startOccurrence(m_currOcc, addidforocc, resrefocc);
            // }
            np.endOccurrence(m_currOcc);
            //m_currOcc = null;
            m_currOcc.destroy();
            
            occid = null;
            addidforocc = null;

            popPurpose();
        } catch (IntegrityViolationException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        } catch (PropertyVetoException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void startAssociation(String id)
        throws TopicMapProcessingException
    {
        try
        { 
            //try removing assignid for removing usage of hashmaps
            //m_currAssoc = m_tm.createAssociation(assignID(id));
            m_currAssoc = m_tm.createAssociation(id);
          
            setResourceID(m_currAssoc, id);
             //System.out.println("association id "+id);
          
            np.startAssociation(m_currAssoc);
        }
        catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Property change was vetoed while creating association - " + ex.toString());
            }
            else
            {
                // TODO: Log as warning
            }
        }
    }

    public void endAssociation()
        throws TopicMapProcessingException
    {
        try {
            if (m_currAssocType != null) {
                try {
                    occid = null;
                    m_currAssoc.setType(m_currAssocType);
                    np.endAssociation(m_currAssoc);
                } catch (PropertyVetoException ex) {
                    if (m_failOnVeto) {
                        throw new TopicMapProcessingException("Property change was vetoed while creating association - " + ex.toString());
                    } else {
                        // TODO: Log as warning
                    }
                }
            }
            //m_currAssoc = null;
		//m_currMember.destroy();
            m_currAssoc.destroy();
        } catch (IntegrityViolationException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        } catch (PropertyVetoException ex) {
            Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void startMember(String id)
        throws TopicMapProcessingException
    {
        try
        {
            m_currMember = m_currAssoc.createMember(id);
            setResourceID(m_currMember, id);
            pushPurpose(MEMBER);
             //System.out.println("member id "+id);
          
            np.startMember(m_currMember);
        }
        catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Property change was vetoed while processing member." + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
        }
    }

    public void endMember()
        throws TopicMapProcessingException
    {
        //try {
            np.endMember(m_currMember);

            //m_currAssoc.addMember(m_currMember);
            m_currMember = null;
            //m_currMember.destroy();
            popPurpose();
       // } catch (IntegrityViolationException ex) {
       //     Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
       // } catch (PropertyVetoException ex) {
       //     Logger.getLogger(XTMBuilder.class.getName()).log(Level.SEVERE, null, ex);
       // }
         }

    public void startRoleSpec(String id)
        throws TopicMapProcessingException
    {
        pushPurpose(ROLESPEC);
    }
    public void endRoleSpec()
        throws TopicMapProcessingException
    {
        np.onRoleSpec(rolespc);
        rolespc = null;
        popPurpose();
    }
    public void startMergeMap(String id, String mergeMapURI)
        throws TopicMapProcessingException
    {
        try
        {
            pushPurpose(MERGESCOPE);
       
        }
        catch(Exception ex)
	{
if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Property change was vetoed while processing merge map scope." + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
	}
    }
    public void endMergeMap()
        throws TopicMapProcessingException
    {
        
        //m_tm.addMergeMap(m_mergeMapLocator, m_currScope);
        popPurpose();
    }
    
        
//dont do anything for mergemap
    /*public void startMergeMap(String id, String mergeMapURI)
        throws TopicMapProcessingException
    {
        try
        {
            Locator tmp = m_locatorFactory.createLocator("URI", mergeMapURI);
            m_mergeMapLocator = expandRef(m_locatorFactory.createLocator("URI", mergeMapURI));
            //m_currScope = m_tm.createScope(generateID());
            
            pushPurpose(MERGESCOPE);
        }
        catch(LocatorFactoryException ex)
        {
            throw new TopicMapProcessingException(
                "Could not create mergeMap URI from address: " + mergeMapURI
                + ". Cause: " + ex.toString());
        }
	catch(Exception ex)
	{
if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Property change was vetoed while processing merge map scope." + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
	}
    }
    public void endMergeMap()
        throws TopicMapProcessingException
    {
        
        m_tm.addMergeMap(m_mergeMapLocator, m_currScope);
        popPurpose();
    }
*/
    //this is a test to continue from instance
     public void ref(String n, int refType,String id, String resourceLoc)
        throws TopicMapProcessingException
    {
        try
        {
            resourceLoc = m_resourceLocator.toString();
            Locator loc = m_locatorFactory.createLocator("URI", resourceLoc);
            ref(id, refType, loc);
        }
        catch(LocatorFactoryException ex)
        {
            throw new TopicMapProcessingException("Invalid reference address:" + resourceLoc);
        }
    }
    public void ref(String id, int refType, String refValue)
        throws TopicMapProcessingException
    {
        try
        {
            Locator loc = m_locatorFactory.createLocator("URI", refValue);
            ref(id, refType, loc);
        }
        catch(LocatorFactoryException ex)
        {
            throw new TopicMapProcessingException("Invalid reference address:" + refValue);
        }
    }
    
    public void ref(String id, int refType, Locator refValue)
        throws TopicMapProcessingException, LocatorFactoryException
    {
        try
        {
            Topic refTopic = null;
            Locator expandedRef = expandRef(refValue);
            int purpose = peekPurpose();
            switch (refType)
            {
                case REFTYPE_RESOURCE:
                    if ((purpose != OCCURRENCE)
                        && (purpose != VARIANTNAME)
                        && (purpose != SUBJECTIDENTITY))
                    {
                        refTopic = getTopicBySubject(expandedRef);
                    }
                    break;
                case REFTYPE_SUBJECTINDICATOR:
                    if (purpose != SUBJECTIDENTITY)
                    {
                        refTopic = getTopicBySubjectIndicator(expandedRef.getAddress());
                    }
                    break;
                case REFTYPE_TOPIC:
                    //generateid is usedto avoid duplication of ids
                    refTopic = m_tm.createTopic(generateID());
                       
                   // refTopic = getTopicByResourceLocator(expandedRef);
                    break;
            }
            switch(purpose)
            {
                case INSTANCEOF:
                    if (m_currAssoc != null)
                    {//m_currAssoc.setType(refTopic);
                        // System.out.println("instance of association id "+id);
          
                        m_currAssocType = refTopic;
                        occid = id;
                        addidforas = id;
                    }
                    else if (m_currOcc != null)
                    {
                         //System.out.println("instance of occurence id "+id);
                        occid = id;
                        addidforocc = id;
                        
                        m_currOcc.setType(refTopic);
                    }
                    else if (m_currTopic != null)
                    {
                         //System.out.println("instance of id "+id);
                         occid = id;
                         insid = id;
                         String url = "";
                        m_currTopic.addType(refTopic);
                        //along with adding the type, create a topic
                        //np.createTopic(occid, url, refValue);
                    }
                        break;
                    
                case SCOPE:
                    //Scope s = (Scope) m_currScope.toString();
                   // m_currScope.addTheme(refTopic);
                    scopid = id; 
                    break;
                    
                case ROLESPEC:
                    m_currMember.setRoleSpec(refTopic);
                    rolespc = id;
                    break;
                    
                case SUBJECTIDENTITY:
		    if (m_currTopic == null)
		    {
			throw new TopicMapProcessingException(
			    "Encountered a <subjectIdentity> element with no open <topic> element.");
		    }
                    if (refType == REFTYPE_RESOURCE)
                    {
                       // System.out.println("subject id id "+id);
                        subid = id;
                        m_currTopic.setSubject(expandedRef);
                    }
                    if (refType == REFTYPE_SUBJECTINDICATOR)
                    {
                        //System.out.println("subject id id "+id);
                        subid = id;
                        m_currTopic.addSubjectIndicator(m_locatorFactory.createLocator("URI", expandedRef.getAddress()));
                    }
                    if (refType == REFTYPE_TOPIC)
                        
                    {
                        //System.out.println("subject id id "+id);
                        subid = id;
                        m_currTopic.addMergedTopic(refTopic);
                    }
                    break;
                    
                case OCCURRENCE:
                     //System.out.println("occurence id "+id);
                     resrefocc = id;
                    m_currOcc.setDataLocator(expandedRef);
                    break;
                    
                case PARAMETERS:
                    Variant v = (Variant)m_variants.peek();
                    v.addParameter(refTopic);
                    paramid = id;
                    break;
                    
                case MEMBER:
                    m_currMember.addPlayer(refTopic);
                    playerid = id;
                    np.onPlayer(playerid);
                    break;
                    
                case VARIANTNAME:
                    m_currVariantName.setDataLocator(expandedRef);
                    break;
                    
                case MERGESCOPE:
                    //m_currScope.addTheme(refTopic);
                    break;
                    
            }
        }
              catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException(
                    "Property change was vetoed during build: " + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
        }
    }
    

    public void resourceData(String id, String data)
        throws TopicMapProcessingException
    {
	try
	{
	    if (m_currVariantName != null)
	    {
		m_currVariantName.setData(data);
	    }
	    else if (m_currOcc != null)
	    {
		m_currOcc.setData(data);
	    }
	}
	catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException(
		    "Property change was vetoed while processing ." 
		    + m_currOcc != null ? "occurrence" : "variant name" 
		    + ". " + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
        }
    }

    public void startScope(String id)
        throws TopicMapProcessingException
    {
	try
	{
            
	    //m_currScope = m_tm.createScope( assignID(id) );
	    //setResourceID(m_currScope, id);
	    pushPurpose(SCOPE);
            np.startScope();
	}
	catch(Exception ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Setting of scope was vetoed." + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
        }
    }

    public void endScope()
        throws TopicMapProcessingException
    {
        try
        {
            if ((m_variants != null) && (m_variants.size() == 1))
            {
                ((BaseName)m_variants.peek()).setScope(m_currScope);
            }
            else if (m_currAssoc != null)
            {
                m_currAssoc.setScope(m_currScope);
            }
            else if (m_currOcc != null)
            {
                m_currOcc.setScope(m_currScope);
            }
            else
            {
                throw new TopicMapProcessingException("Encountered a <scope> element in an unexpected place.");
            }
        }
        catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Setting of scope was vetoed." + ex.toString());
            }
            else
            {
                // TODO: Log warning
            }
        }
        // send id of current scope for creation of implicit topic
        np.onTheme(scopid);
        np.endScope();
        m_currScope = null;
        scopid = null;
        popPurpose();
    }

    public void baseNameString(String id, String value)
        throws TopicMapProcessingException
    {
        try
        {
            if ((BaseName)m_variants.peek() != null)
                bn.setData(value);
             //System.out.println("basename string id "+value);
          
            np.startBaseName(bn);
	
        }
        catch(PropertyVetoException ex)
        {
            if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Setting of base name string: " + value + " was vetoed: " + ex.toString());
            }
            else
            {
                // TODO: Log exception
            }
        }
    }

    public void startVariant(String id)
        throws TopicMapProcessingException
    {
	try
	{
	    Variant v = ((VariantContainer)m_variants.peek()).createVariant(id);
	    setResourceID(v, id);
	    m_variants.push(v);
             //System.out.println("variant id "+id);
          
            np.startVariant(v);
	}
	catch(PropertyVetoException ex)
	{
	    if (m_failOnVeto)
            {
                throw new TopicMapProcessingException("Addition of variant was vetoed: " + ex.toString());
            }
            else
            {
                // TODO: Log exception
            }
	}
    }

    public void endVariant()
        throws TopicMapProcessingException
    {
       Variant v = (Variant)m_variants.pop();
        np.endVariant(v);
	
    }

    public void startParameters(String id)
        throws TopicMapProcessingException
    {
        pushPurpose(PARAMETERS);
    }

    public void endParameters()
        throws TopicMapProcessingException
    {
        np.onParameter(paramid);
        popPurpose();
        paramid = null;
    }

    public void startVariantName(String id)
        throws TopicMapProcessingException
    {
	Variant v = (Variant)m_variants.peek();
        if (v == null)
	{
	    throw new TopicMapRuntimeException("Variants stack out of sync while processing end of variant name.");
	}
	try
	{
	    m_currVariantName = v.createVariantName(id);
	}
	catch(PropertyVetoException ex)
	{
	    if (m_failOnVeto)
            {
                throw new TopicMapProcessingException(
		    "Setting of variant name was vetoed. " + ex.toString());
            }
            else
            {
                // TODO: Log exception
            }
	}
        setResourceID(m_currVariantName, id);
        pushPurpose(VARIANTNAME);
    }

    public void endVariantName()
	throws TopicMapProcessingException
    {
	/*
        Variant v = (Variant)m_variants.peek();
        if (v == null || m_currVariantName == null) 
	{
	    throw new TopicMapRuntimeException("Variants stack out of sync while processing end of variant name.");
	}

        try
	{
	    v.setVariantName(m_currVariantName);
	}
	catch(PropertyVetoException ex)
	{
	    if (m_failOnVeto)
            {
                throw new TopicMapProcessingException(
		    "Setting of variant name was vetoed. " + ex.toString());
            }
            else
            {
                // TODO: Log exception
            }
	}
	*/
	m_currVariantName = null;
	popPurpose();

    }
    
    public void variantName(String id, String value)
        throws TopicMapProcessingException
    {
	try
	{
	    if (m_currVariantName != null)
	    {
		m_currVariantName.setData(value);
                np.onVariantName(value);
	    }
	}
	catch(PropertyVetoException ex)
	{
	    if (m_failOnVeto)
	    {
		throw new TopicMapProcessingException(
		    "Setting of variant name string was vetoed. "
		    + ex.toString());
	    }
	    else
	    {
		// TODO: Log the exception
	    }
	}
    }

   /* protected String assignID(Locator loc, String id)
    {
        String assignedID = ((id == null) 
			     || (m_assignedIDs.contains(id)) 
			     || (m_tm.getObjectByID(id) != null)) ? 
                              generateID() : id;
        if (loc != null)
        {
            m_assignedIDs.put(loc, assignedID);
        }
        return assignedID;
    }

    protected String assignID(Locator loc)
    {
	String assignedID = null;

	if (loc instanceof URILocator)
	{
	    String frag = ((URILocator)loc).getFragment();
	    if (frag != null)
	    {
		m_log.debug("Attempt to assign ID from URI fragment: "+ frag);
		assignedID = assignID(frag);
		m_log.debug("Assigned ID: " + assignedID);
	    }
	}

	if (assignedID == null) assignedID = generateID();

        if (loc != null)
        {
            m_assignedIDs.put(loc, assignedID);
        }
        return assignedID;
    }

    
    protected String assignID(String elementID)
    {
        String assignedID = generateID();
        if (elementID != null)
        {
            String expandedID = expandID(elementID);
	    if ( (! m_assignedIDs.containsKey(expandedID))
		 && (m_tm.getObjectByID(elementID) == null)) assignedID = elementID;
            m_assignedIDs.put(expandedID, assignedID);
        }
        return assignedID;
    }*/

    protected void setResourceID(TopicMapObject tmo, String id)
	throws DuplicateResourceLocatorException
    {
        if (id != null)
        {
            tmo.setResourceLocator(resourceLocatorForID(id));
        }
    }

    protected Locator resourceLocatorForID(String id)
    {
        try
        {
	    String rel = "#" + id;
            //Locator rel = m_locatorFactory.createLocator("URI", "#" + id);
            Locator loc = m_resourceLocator.resolveRelative(rel);
            return loc;
        }
        catch (Exception ex)
        {
            throw new TopicMapRuntimeException("resourceLocatorForID(): Could not expand: " + id +" - " + ex.toString());
        }
    }
    
    protected String expandResourceID(String id)
    {
        Locator loc = resourceLocatorForID(id);
        return loc.getAddress();
    }
    
    protected String expandID(String id)
    {
        // No longer required. URL normalisation is performed by
        // the TopicMapFactory if needed.
        Locator baseLocator = (m_baseLocator != null) ? m_baseLocator : m_defaultBaseLocator;
            
        try
        {
            if (!id.startsWith("#")) id = "#" + id;
            Locator rel = m_locatorFactory.createLocator("URI", id);
            Locator loc = baseLocator.resolveRelative(rel);
            return loc.getAddress();
        }
        catch(LocatorFactoryException ex)
        {
            throw new TopicMapRuntimeException("TopicMapFactoryImpl: Could not normalise ID: " + id, ex);
        }
        catch(LocatorResolutionException ex)
        {
            throw new TopicMapRuntimeException("Could not resolve ID '" + id + "' relative to topic map.");
        }
    }

    
    protected String expandRef(String ref)
        throws TopicMapProcessingException
    {
        try
        {
            Locator loc = m_locatorFactory.createLocator("URI", ref);
            Locator expanded = expandRef(loc);
            return loc.getAddress();
        }
        catch(LocatorFactoryException ex)
        {
            throw new TopicMapProcessingException("Could not expand reference address: " + ref +" - " + ex.toString());
        }
        
    }
    
    protected Locator expandRef(Locator loc)
        throws TopicMapProcessingException
    {
        Locator ret = loc;
        try
        {
            Locator baseLocator = m_resourceLocator;
            if (loc instanceof URILocator)
            {
                URILocator uloc = (URILocator)loc;
                if ((uloc.getPath() != null)  && (!uloc.getPath().isEmpty()))
                {
                    // Resolution should be relative to xml:base (if specified)
                    // or else topic map resource
                    if (m_baseLocator != null)
                        baseLocator = m_baseLocator;
                    else
                        baseLocator = m_resourceLocator;
                }
            }
            
            if (baseLocator != null)
            {
                ret = baseLocator.resolveRelative(loc);
            }
        }
        catch(LocatorResolutionException ex)
        {
            throw new TopicMapProcessingException("Could not resolve reference '" + loc.getAddress() + "' relative to topic map base locator.");
        }
        return ret;
    }

    public Topic getTopicByResourceLocator(Locator resourceLocator)
        throws TopicMapProcessingException
    {
        Topic ret = (Topic)m_tm.getObjectBySourceLocator(resourceLocator);
        /*
        if (ret == null)
        {
         * 
            if (m_stubTopics.containsKey(resourceLocator))
            {
                ret = (Topic)m_stubTopics.get(resourceLocator);
            }
            else
            {
                // Create a placeholder for this topic ID
                // It is not added to the topic map until the topic with this ID is encountered
                // in the input stream.
		m_log.debug("Create stub topic for resource locator: "+ resourceLocator.getAddress());
                String assignedID = assignID(resourceLocator);
		m_log.debug("Assigned ID: " + assignedID + " to stub topic.");
		try
		{
		    Topic stub = m_tm.createTopic(assignedID);
		    stub.setResourceLocator(resourceLocator);
		    m_stubTopics.put(resourceLocator, stub);
		    if (!sameDocument(resourceLocator, m_resourceLocator))
		    {
			m_tm.addExternalRef(resourceLocator);
		    }
		    ret = stub;
		}
		catch(PropertyVetoException ex)
		{
		    throw new TopicMapProcessingException("Creation of topic was vetoed." + ex.toString());
		} 
            }
        }*/
        return ret;
    }

    public Topic getTopicBySubject(Locator resource)
        throws TopicMapProcessingException
    {
        Topic ret = m_tm.getTopicBySubject(resource);
        if (ret == null)
        { 
	    try
	    {
		ret = m_tm.createTopic(generateID());
	    }
	    catch(PropertyVetoException ex)
	    {
		throw new TopicMapProcessingException("Creation of topic was vetoed." + ex.toString());
	    }

            try
            {
                ret.setSubject(resource);
            }
            catch(PropertyVetoException ex)
            {
                if (m_failOnVeto)
                {
                    throw new TopicMapProcessingException("Property change vetoed while setting topic subject. " + ex.toString());
                }
                else
                {
                    // Log warning
                }
            }
        }
        return ret;
    }

    public Topic getTopicBySubjectIndicator(String indicator)
        throws TopicMapProcessingException, LocatorFactoryException
    {
	Locator loc = m_locatorFactory.createLocator("URI", indicator);
        Topic ret = m_tm.getTopicBySubjectIndicator(loc);
        if (ret == null)
        {
            // Try retrieving this topic by ID
            ret = m_tm.getTopicByID(indicator);
            if (ret == null)
            {
                // Generate a topic to represent the subject
                try
                {
                    ret = m_tm.createTopic(generateID());
                    ret.addSubjectIndicator(loc);
                }
                catch(PropertyVetoException ex)
                {
                    if (m_failOnVeto)
                    {
                        throw new TopicMapProcessingException(
                            "Property change vetoed while setting topic subject indicator. " + ex.toString());
                    }
                    else
                    {
                        // Log warning
                    }
                }
            }
        }
        return ret;
    }

    public void reportWarning(String msg)
    {
        System.out.println(msg);
    }

    public String generateID()
    {
        return m_tmutils.generateId();
    }

    private boolean sameDocument(Locator loc1, Locator loc2)
    {
        boolean ret = false;
        if ((loc1 instanceof URILocator) && (loc2 instanceof URILocator))
        {
            URILocator uloc1 = (URILocator)loc1;
            URILocator uloc2 = (URILocator)loc2;
            
            ret =  (safeStringCompare(uloc1.getScheme(), uloc2.getScheme(), true)
                    && safeStringCompare(uloc1.getAuthority(), uloc2.getAuthority(), true)
                    && safeStringCompare(uloc1.getPathString(), uloc2.getPathString(), false));
        }
        // Cannot compare locators which are not URIs
        return ret;
    }

    private boolean safeStringCompare(String str1, String str2, boolean ignoreCase)
    {
        if (str1 == null)
        {
            return (str2 == null);
        }

        if (str2 == null) return false;

        if (ignoreCase)
        {
            return str1.equalsIgnoreCase(str2);
        }
        else
        {
            return str1.equals(str2);
        }
    }

    public void setProperty(String arg0, Object arg1) throws BuilderPropertyNotRecognizedException, BuilderPropertyInvalidException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

   /* public void build(InputStream arg0, Locator arg1, TopicMap arg2, TopicMapProvider arg3) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }
*/
    public void build(Reader arg0, Locator arg1, TopicMap arg2, TopicMapProvider arg3) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(InputStream arg0, Locator arg1, TopicMap arg2) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(InputStream arg0, Locator arg1, TopicMap arg2, Topic[] arg3) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(InputStream arg0, Locator arg1, TopicMap arg2, TopicMapProvider arg3, Topic[] arg4) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(Reader arg0, Locator arg1, TopicMap arg2) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(Reader arg0, Locator arg1, TopicMap arg2, Topic[] arg3) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void build(Reader arg0, Locator arg1, TopicMap arg2, TopicMapProvider arg3, Topic[] arg4) throws IOException, LocatorFactoryException, TopicMapProcessingException, PropertyVetoException, TopicMapProviderException {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void startMergeMap(String arg0, String arg1, String arg2) throws TopicMapProcessingException {
           throw new UnsupportedOperationException("Not supported yet.");
    }
/*
    public void ref(String arg0, int arg1, String arg2, String arg3) throws TopicMapProcessingException {
        throw new UnsupportedOperationException("Not supported yet.");
    }*/
}

/*
 * $Log: TMWrapper.java,v $
 * Revision 1.2  2008/03/13 16:47:36  mudw2335
 * *** empty log message ***
 *
 * Revision 1.38  2002/12/19 16:23:39  kal_ahmed
 * Updated test code to new interfaces.
 *
 * Revision 1.37  2002/12/19 11:04:30  kal_ahmed
 * Added createTopic, createAssociation and createScope methods to TopicMap interface.
 *
 * Revision 1.36  2002/12/12 11:55:10  kal_ahmed
 * Renamed 'strict' option to the more accurate 'validation'
 *
 * Revision 1.35  2002/12/12 11:03:05  kal_ahmed
 * Implemented property configuration methods added to TopicMapBuilder interface.
 *
 * Revision 1.34  2002/12/03 11:19:21  kal_ahmed
 * Fixed creation of Scope objects to use assignID().
 *
 * Revision 1.33  2002/11/20 20:43:41  kal_ahmed
 * setVariants() and addVariant() methods in BaseName and Variant interfaces modified to throw PropertyVetoException.
 *
 * Revision 1.32  2002/11/20 20:01:17  kal_ahmed
 * Update to assignID() fix.
 *
 * Revision 1.31  2002/11/20 19:54:58  kal_ahmed
 * Fixed assignID to work correctly when the parsed ID is null.
 *
 * Revision 1.30  2002/11/11 09:53:15  kal_ahmed
 * Fixed generation of relative URIs to avoid creation of an intermediate
 * Locator object for the relative address.
 *
 * Revision 1.29  2002/11/04 16:46:59  kal_ahmed
 * Fixed stub topic generation to attempt to use id attribute as id property of generated topic.
 *
 * Revision 1.28  2002/10/10 12:50:51  kal_ahmed
 * Implemented support for new DuplicateResourceLocatorException.
 *
 * Revision 1.27  2002/09/27 15:24:35  kal_ahmed
 * Removed methods deprecated in version 0.6.0 and earlier.
 *
 * Revision 1.26  2002/09/27 10:39:05  kal_ahmed
 * Added TopicMapProvider parameter to TopicMapBuilder interface to allow merged topic maps to be retrieved/added.
 *
 * Revision 1.25  2002/09/27 09:42:54  kal_ahmed
 * Added implementation of the TopicMapBuilder interface.
 *
 * Revision 1.24  2002/07/23 21:12:00  kal_ahmed
 * Fixed variant name processing to use assignID() to get an object ID.
 *
 * Revision 1.23  2002/06/23 16:23:04  kal_ahmed
 * Added handling of newly added PropertyVetoExceptions on Occurrence and VariantName.
 *
 * Revision 1.22  2002/05/27 17:07:37  kal_ahmed
 * Update to XTMBuilder from Sebastian Lutz.
 *
 * Revision 1.21  2002/04/29 22:07:10  kal_ahmed
 * Removed unecessary call to addAssociation() - associations are now added when they are constructed.
 *
 * Revision 1.20  2002/04/21 20:26:34  kal_ahmed
 * Set association type after adding members to avoid XTMTypeInstanceValidator rejecting changes
 *
 * Revision 1.19  2002/04/09 19:57:00  kal_ahmed
 * Updated to support vetoable change notifications.
 *
 * Revision 1.18  2002/04/02 19:38:50  kal_ahmed
 * Modified to use the IDGenerator provide by TopicMapUtils instead of
 * its own internal IDGenerator. Prevents duplicate IDs being generated
 * by the two different generators.
 *
 * Revision 1.17  2002/04/02 16:17:53  kal_ahmed
 * Added handling of PropertyVetoExceptions during build process
 *
 * Revision 1.16  2002/04/02 08:21:45  kal_ahmed
 * Created new vetoable change event notification infrastructure. Added vetoable change notification to Association properties.
 *
 * Revision 1.15  2002/03/14 21:52:34  kal_ahmed
 * Removed debug output
 *
 * Revision 1.14  2002/02/24 16:55:18  kal_ahmed
 * Fixed class cast exception in endVariant()
 *
 * Revision 1.13  2002/02/23 17:06:42  kal_ahmed
 * Moved external topic references to TopicMap.
 * Bullet-proofed sameDocument test to handle URIs with missing (null) parts.
 *
 * Revision 1.12  2002/02/15 17:30:49  kal_ahmed
 * Added mergeMap and external topic ref support.
 *
 * Revision 1.11  2002/02/09 19:38:23  kal_ahmed
 * Updated license text
 *
 * Revision 1.10  2002/01/26 19:42:35  kal_ahmed
 * Scope objects and stub topics now get their resourceLocator set correctly.
 *
 * Revision 1.9  2002/01/18 21:14:03  kal_ahmed
 * Improved reporting of errors during parsing to include line number.
 *
 * Revision 1.8  2002/01/10 11:41:36  kal_ahmed
 * Updated license text
 *
 * Revision 1.7  2002/01/08 11:16:20  kal_ahmed
 * Removed import of com.techquila.utils
 *
 * Revision 1.6  2001/12/26 20:22:13  kal_ahmed
 * Updates to match new interfaces.
 *
 * Revision 1.5  2001/11/04 18:22:48  kal_ahmed
 * Changed subject and subjectIndicator properties of Topic to Locator. Added LocatorDataObject infrastructure for persisting Locators.
 *
 * Revision 1.4  2001/10/26 16:49:20  kal_ahmed
 * Got rid of some print statements
 *
 * Revision 1.3  2001/10/25 19:58:33  kal_ahmed
 * Major interface changes.
 *
 * Revision 1.2  2001/09/28 21:29:36  kal_ahmed
 * Changed package declarations, imports and other occurrences of com.techquila.topicmap to org.tm4j.topicmap
 *
 * Revision 1.1  2001/09/28 20:54:06  kal_ahmed
 * Moved com/techquila/topicmap/* to org/tm4j/topicmap/*
 *
 * Revision 1.9  2001/09/26 19:30:46  kal_ahmed
 * Fixed to correctly assign an object ID and a resourceID to the TopicMap object. Made processing less talkative (removed some print statements).
 *
 * Revision 1.8  2001/09/08 19:29:10  kal_ahmed
 * Updated handling of the expansion of ID values in the parsed XTM file. This code no longer expands IDs relative to the URL specified by the xml:base attribute, but instead relative to the externally supplied URL of the file itself.
 *
 * Revision 1.7  2001/07/26 17:11:52  kal_ahmed
 * Updated license text
 *
 * Revision 1.6  2001/06/28 13:50:08  kal_ahmed
 * Fix to prevent creation of dummy topics when encountering a subjectIndicatorRef used for topics subjectIdentity.
 *
 * Revision 1.5  2001/06/18 06:31:44  kal_ahmed
 * Fixed expansion of topic references when loading multiple topicmaps with the same XTMBuilder object.
 *
 * Revision 1.4  2001/06/11 21:55:31  kal_ahmed
 * Fix to ensure that the URI of the resource which causes the creation of a TopicMapObject is correctly recorded in the resourceID property.
 *
 * Revision 1.3  2001/06/10 17:29:28  kal_ahmed
 * Fixed to ensure that a resourceID is assigned to stub topics which cannot be resolved during a build.
 *
 */
