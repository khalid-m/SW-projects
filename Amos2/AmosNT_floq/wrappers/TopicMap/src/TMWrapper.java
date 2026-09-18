/*
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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.Stack;

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
import org.tm4j.topicmap.utils.TopicMapBuilder;
import org.tm4j.topicmap.utils.TopicMapWalker;
import org.tm4j.topicmap.utils.WalkerHandler;
import org.tm4j.topicmap.utils.XTMBuilder;

import callin.AmosException;
import callin.Connection;
import callin.Oid;
import callin.Scan;
import callin.Tuple;
import callout.CallContext;

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
        String tmSrc = "http://www.techquila.com/tmsamples/xtm/punk/music-xtm.xml";
        if (args.length > 0)
        {
            tmSrc = args[0];
        }

        TMWrapper theApp = new TMWrapper();
        theApp.parseInput(tmSrc);
        theApp.run();
    }

    //  TODO
    public void load(CallContext cxt, Tuple tpl) throws Exception
    {

        //String tmSrc = "../jill.xtm";
        tmSrc = tpl.getStringElem(0);

	//        TMWrapper theApp = new TMWrapper();
        parseInput(tmSrc);
        run();
        tpl.setElem(1, "TM Loaded.");
        cxt.emit(tpl);
    }

    public void run()
    {
        try
        {
            // Get the topic map from the specified file
            TopicMap tm = addTopicMap();

            // Create a simple walker chain with the TopicMapWalker
            // connected to a PrintHandler instance
            TopicMapWalker walker = new TopicMapWalker();
            PrintHandler ph = new PrintHandler(tmSrc);
            walker.setHandler(ph);
            //System.out.println("Dumping all topic map objects:");
            //System.out.println("Walker handler is: " + walker.getHandler());
            walker.walk(tm);
        }
        catch (Exception ex)
        {
            System.out.println("Error while running example: " + ex.toString());
            ex.printStackTrace();
        }
    }

    public TopicMap addTopicMap() throws Exception
    {
        try
        {
            //Create the "base" URI of the topic map
            String baseURI = getInputURI();
            Locator baseLocator = m_provider.getLocatorFactory().createLocator("URI", baseURI);

            // Create the TopicMapSource representing the topic map to be parsed
            TopicMapBuilder builder = new MyXTMBuilder();
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
    HashMap<String, Oid> currTopics = new HashMap<String, Oid>();

    String fileTMO;
    int idnum;

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
		//		arg2.setElem(0, fileTMO);
		arg22.setElem(0, fileTMO);
		arg22.setElem(1, idnum);
		//		theConnection.addFunction("FILETMO", arg1, arg2);
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
        //print("Association: " + a.getID());
        try
        {
            Oid association = theConnection.createObject("ASSOCIATION");
	    setIdTMO(association);
            arg1.setElem(0, association);

	    //create function id(TM_ASSOCIATION) -> Charstring as stored;
            String id = a.getID();
            if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
            {
                arg2.setElem(0, id.substring(0, id.length() - 3));
                theConnection.addFunction("ASSOCIATION.IDASSOCIATION->CHARSTRING", arg1, arg2);
            }

            //create function association(TopicMap) -> Bag of TM_association as stored;
            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("TOPICMAP.ASSOCIATIONOFTOPICMAP->ASSOCIATION", arg2, arg1);

            stk.push(association);
            preElement.push(new Integer(6));
            sttmo.push(a);
            //TODO to be deleted
            //System.out.println("Push ASSOCIATION " + id);
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }

        m_indent += 2;
        return true;
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
    {
        String baseNameString = bn.getData();
        int index = baseNameString.lastIndexOf('<');
        baseNameString = baseNameString.substring(0, index);

        try
        {
            Oid baseName = theConnection.createObject("BASENAME");
	    setIdTMO(baseName);
            arg1.setElem(0, baseName);
            arg2.setElem(0, baseNameString);
            theConnection.addFunction("BASENAME.BASENAMESTRING->CHARSTRING", arg1, arg2);

            //create function id(TM_baseName) -> Charstring as stored;
            String id = bn.getID();
            if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
            {
                arg2.setElem(0, id.substring(0, id.length() - 3));
                theConnection.addFunction("BASENAME.IDBASENAME->CHARSTRING", arg1, arg2);
            }

            //create function baseName(TM_topic) -> Bag of TM_baseName as stored;
            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("TOPIC.BASENAMEOFTOPIC->BASENAME", arg2, arg1);

            stk.push(baseName);
	    sttmo.push(bn);
            preElement.push(new Integer(3));
            //System.out.println("Push BaseName (" + id + ") " + baseNameString);
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }

        m_indent += 2;
        return true;
    }

    public void endBaseName(BaseName bn)
    {
        stk.pop();
	sttmo.pop();
        preElement.pop();
        //System.out.println("pop BaseName " + bn.getData());
        m_indent -= 2;
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
            theConnection.addFunction("ASSOCIATION.MEMBEROFASSOCIATION->MEMBER", arg2, arg1);
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

    public boolean startOccurrence(Occurrence o) //<occurence><resource*>
    {
        try
        {
            Oid occurrence = theConnection.createObject("OCCURRENCE");
	    setIdTMO(occurrence);
            arg1.setElem(0, occurrence);
            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("TOPIC.OCCURRENCEOFTOPIC->OCCURRENCE", arg2, arg1);

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
			 if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
			     {
				 id= id.substring(0, id.length() - 3);
			     }
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
           
		 createTopic(id,url,l);
		 arg2.setElem(0, (Oid) stk.peek());
		 //		 theConnection.addFunction("INSTANCEOF", arg2, arg1);
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
		String s=lo.getAddress();
                //create implicit topic and place it into arg1 
		// createTopic("", s);
		arg1.setElem(0,s);
                arg2.setElem(0, (Oid) stk.peek());
                theConnection.addFunction("OCCURRENCE.REFERENCE->CHARSTRING", arg2, arg1);
                //print("External Data @: " + o.getDataLocator().getAddress());
            }

	    
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }

        m_indent += 2;
        return true;
    }

    public void endOccurrence(Occurrence o)
    {
        stk.pop();
	sttmo.pop();
        preElement.pop();
        //System.out.println("pop Occurrence ");
        m_indent -= 2;
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

    public boolean startTopic(Topic t) //<topic id=*>
    {
        try
        {
            String id = t.getID();
            String address = null;
            Locator l = null;
            if (!t.getSourceLocators().isEmpty())
                l = (Locator) t.getSourceLocators().iterator().next();
            else if (!t.getSubjectIndicators().isEmpty())
                l = (Locator) t.getSubjectIndicators().iterator().next();
            else if (t.getSubject() != null)
                l = (Locator) t.getSubject();
            address = l.getAddress();

            //TODO "((Integer) preElement.peek()).intValue() == 1)" delete?
            //TODO is there the possibility that some topics may not be processed yet?
            if ((!id.contains("\"ID") && !id.contains("\"noID") && ((Integer) preElement.peek())
                    .intValue() == 1))
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

    public boolean startTopicMap(TopicMap tm) //<topicMap> + baseLocator
    {
        try
        {
            Oid topicMap = theConnection.createObject("TOPICMAP");
	    setIdTMO(topicMap);
	    String tmid=tm.getID();
	     String tmname=tm.getName();
	    arg1.setElem(0,topicMap);
	    arg2.setElem(0,tmid);
	    theConnection.addFunction("TOPICMAP.IDTOPICMAP->CHARSTRING", arg1, arg2);
	    //  arg2.setElem(0,tmname);
// 	    theConnection.addFunction("NAME", arg1, arg2);
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
		funame="BASENAME.VARIANTOFBASENAME->VARIANT";
	    else 
		funame="VARIANT.SUBVARIANT->VARIANT";
            theConnection.addFunction(funame, arg2, arg1);

            stk.push(variant);
	    sttmo.push(v);
            preElement.push(new Integer(4));
            //System.out.println("Push VARIANT");
        }
        catch (AmosException e)
        {
            System.out.println(e);
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

    public void onParameter(Topic param) //<parameters><*>
    {
        Locator l = null;
       //  if (!param.getSubjectIndicators().isEmpty())
//             l = (Locator) param.getSubjectIndicators().iterator().next();
//         //else if (roleSpec.getSubject() != null)
//         //l = roleSpec.getSubject();
//         else
//             l = (Locator) param.getSourceLocators().iterator().next();

	if (param.getSubject() != null)
            l = param.getSubject();
        else
            l = (Locator) param.getSourceLocators().iterator().next();
	String url=l.getAddress();
	String id = param.getID();
	if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
            {
              id= id.substring(0, id.length() - 3);
             }
	 Integer pos=url.indexOf("#"); 
	 if(pos != -1)
	   {
		url=url.substring(0,pos);
	    }


	String s=l.getAddress();

        //print(l.getAddress());
        try
        {
            //create implicit topic and place it into arg1 
            createTopic(id, url,l);

            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("VARIANT.PARAMETERS->TOPIC", arg2, arg1);
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    public void onPlayer(Topic player) //<member><*=*>
    {
        Locator l = null;
	String url="", id="";
 	if (!player.getSourceLocators().isEmpty())
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
			
		if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
		    {
			id= id.substring(0, id.length() - 3);
		    }

	    }
	else if (!player.getSubjectIndicators().isEmpty())
	    {
		l = (Locator) player.getSubjectIndicators().iterator().next();
	
	    }

        try
        {
            //creaet eimplicit topic and place it into arg1 
            createTopic(id, url,l);

            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("MEMBER.TOPICOFMEMBER->TOPIC", arg2, arg1);
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    public void onRoleSpec(Topic roleSpec) //<member><roleSpec>
    {
	String url="", id="";
        Locator l = null;
	if (roleSpec.getSubject() != null)
            l = roleSpec.getSubject();
        else if (!roleSpec.getSourceLocators().isEmpty())
	    {
		l = (Locator) roleSpec.getSourceLocators().iterator().next();
		url=l.getAddress();
		id = roleSpec.getID();
		if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
		    {
			id= id.substring(0, id.length() - 3);
		    }
		Integer pos=url.indexOf("#"); 
		if(pos != -1)
		    {
			url=url.substring(0,pos);
			//			id = url.substring(pos + 1);
		    }
	    }
	else 
	    l = (Locator) roleSpec.getSubjectIndicators().iterator().next();


        //print("roleSpec: " + l.getAddress());
        try
        {
            //create implicit topic and place it into arg1 
            createTopic(id, url,l);

            arg2.setElem(0, (Oid) stk.peek());
            theConnection.addFunction("MEMBER.ROLESPEC->TOPIC", arg2, arg1);
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    public void onSubject(Locator subject) //<resourceRef>
    {
         try
         {
//             //create implicit topic and place it into arg1 
	    
// 	    // createTopic("", "", subject);
	     String sub=subject.getAddress();
	     arg1.setElem(0, sub);
             arg2.setElem(0, (Oid) stk.peek());
             if (((Integer) preElement.peek()).intValue() == 2)
                 theConnection.addFunction("TOPIC.SUBJECTADDRESS->CHARSTRING", arg2, arg1);
         }
         catch (AmosException e)
         {
             System.out.println(e);
         }
//         //print("Subject: " + subject.getAddress());
    }

    public void onSubjectIndicator(Locator subjectIndicator) //<subjectIndicatorRef?>
    {
        try
        {
            //create implicit topic and place it into arg1 
	    // createTopic("", "", subjectIndicator);

	    String sub=subjectIndicator.getAddress();

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

    public void onTheme(Topic theme) //<scope><*>
    {
        Locator l = null;
	String url="";
 	String id="";
       if (!theme.getSourceLocators().isEmpty())
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

			
		if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
		    {
			id= id.substring(0, id.length() - 3);
		    }

	    }
  	else if (!theme.getSubjectIndicators().isEmpty())
	    {
		l = (Locator) theme.getSubjectIndicators().iterator().next();
	
	    }
	else
	    l = theme.getSubject();


        try
        {
            //create implicit topic and place it into arg1 
            createTopic(id, url,l);
	    arg2.setElem(0, (Oid) stk.peek());
 
	    TopicMapObject o=sttmo.peek();
	    String funame=makename(o, "SCOPEOF");
	    theConnection.addFunction(funame, arg2, arg1);

        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    public void onType(Topic type) //<instanceOf><*>
    {
        Locator l = null;
	Locator lp = null;
	String url="", id="";
	if (!type.getSourceLocators().isEmpty())
	    {
		l = (Locator) type.getSourceLocators().iterator().next();
	        url=l.getAddress();
		id = type.getID();
		if (id.contains("\"ID"))// && !id.contains("\"noID")) //explicitly defined ID attribute
		    {
			id= id.substring(0, id.length() - 3);
		    }
		Integer pos=url.indexOf("#"); 
		if(pos != -1)
		    {
			url=url.substring(0,pos);
			//			id = url.substring(pos + 1);
		    }

	    }
	//	else if (!type.getSubject.isEmpty())
	else if (!type.getSubjectIndicators().isEmpty())
	    {
                l = (Locator) type.getSubjectIndicators().iterator().next();
	      
	        }
        else
            l = type.getSubject();
     

        try
        {
            //create implicit topic and place it into arg1 
            createTopic(id, url,l);
            arg2.setElem(0, (Oid) stk.peek());

	    TopicMapObject o=sttmo.peek();
	    String funame=makename(o, "INSTANCEOF");
	    theConnection.addFunction(funame, arg2, arg1);

            
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    public void onVariantName(VariantName vn) //<variantName><*>
    {
        try
        {
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

// 		//                arg3.setElem(0, id);
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
            }
        }
        catch (AmosException e)
        {
            System.out.println(e);
        }
    }

    //    public Oid createTopic(String id, String address, Locator l) throws AmosException
    public Oid createTopic(String id, String address, Locator l) throws AmosException									
    {
        //Extract id from address
        if (address.equals(""))
        address = l.getAddress();

        if (id.equals(""))
        {
            int index = address.indexOf('#');
            if (index != -1)
            {
                id = address.substring(index + 1);
                address = address.substring(0, index);
            }
        }
        //create implicit topic and place it into arg1
        Oid topic;
        if (!currTopics.containsKey(address + id))
        {
            //Create implicit topic for the reference
            topic = theConnection.createObject("TOPIC");
	    setIdTMO(topic);

            //create function URL(TM_topic) -> Charstring as stored;
	       arg1.setElem(0, topic);
//             arg2.setElem(0, address);
//             theConnection.addFunction("TOPIC.URL->CHARSTRING", arg1, arg2);

            //create function id(TM_topic) -> Charstring as stored;
            arg2.setElem(0, id);
            theConnection.setFunction("TOPIC.IDTOPIC->CHARSTRING", arg1, arg2);

            //create function topic(TopicMap) -> Bag of TM_topic as stored;
            arg2.setElem(0, (Oid) stk.firstElement());
            theConnection.addFunction("TOPICMAP.TOPICOFTOPICMAP->TOPIC", arg2, arg1);

            currTopics.put(address + id, topic);
        }
        else
        {
            topic = (Oid) currTopics.get(address + id);
            arg1.setElem(0, topic);
        }
        return topic;
    }

    //TODO delete?
    /*private void print(String msg) //insert white spaces
    {
        StringBuffer sb = new StringBuffer(msg.length() + m_indent);
        for (int i = 0; i < m_indent; i++)
        {
            sb.append(' ');
        }
        sb.append(msg);
        System.out.println(sb.toString());
    }*/
}

class MyXTMBuilder extends XTMBuilder
{
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

    public void resourceData(String id, String data) throws TopicMapProcessingException
    {
        super.resourceData(id, id + "<" + data);
    }
    
    public void baseNameString(String id, String value) throws TopicMapProcessingException
    {
        super.baseNameString(id, value + "<" + this.generateID());
    }

}
