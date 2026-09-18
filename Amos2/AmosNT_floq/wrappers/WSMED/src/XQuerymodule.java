import net.sf.saxon.Configuration;
import net.sf.saxon.Controller;
import net.sf.saxon.instruct.UserFunction;
import net.sf.saxon.om.*;
import net.sf.saxon.query.DynamicQueryContext;
import net.sf.saxon.query.QueryResult;
import net.sf.saxon.query.StaticQueryContext;
import net.sf.saxon.query.XQueryExpression;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.IntegerValue;
import net.sf.saxon.value.Value;
import net.sf.saxon.tree.NodeImpl;
import net.sf.saxon.xpath.XPathEvaluator;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.dom.DOMSource;


import javax.xml.transform.*;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.transform.JDOMResult;

import callin.*;
import callout.*;

import java.util.*;

public class XQuerymodule
{
   
   
    public static Tuple extractResult(String str,  String  src) throws XPathException, AmosException,IOException
    {
	
	Tuple res= new Tuple(1);
	int rindex=0,tindex=0;
	final Configuration config = new Configuration();
        final StaticQueryContext sqc = new StaticQueryContext(config);
	final XQueryExpression exp = sqc.compileQuery(new FileReader(str));
        final DynamicQueryContext dynamicContext = new DynamicQueryContext(config);
        
	dynamicContext.setContextItem(sqc.buildDocument(new StreamSource(src)));
	final Properties props = new Properties();
	props.setProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
        final SequenceIterator iter = exp.iterator(dynamicContext);
	final DocumentInfo docinf = QueryResult.wrap(iter, config);
        
	JDOMResult jdomResult = new JDOMResult();
	QueryResult.serialize(docinf, jdomResult, props, config);
	
	Document doc = jdomResult.getDocument();
	Element root = doc.getRootElement();
	List  allChildren = root.getChildren();
	Iterator i = allChildren.iterator();
	
	Tuple tpl = new Tuple(allChildren.size());
	
	try
	    {
	

		while (i.hasNext()) 
		    {
			
			Element child = (Element)i.next();
			
			List tempallChildren = child.getChildren();
			Iterator tempi = tempallChildren.iterator();
			while (tempi.hasNext())
			    {
				Element nextchild = (Element)tempi.next();
				List nextallChildren = nextchild.getChildren();
				Iterator nexti = nextallChildren.iterator();  
				Tuple result = new Tuple(nextallChildren.size());
				rindex=0;
				while (nexti.hasNext())
				    {
					Element nextnextchild = (Element)nexti.next();
					result.setElem(rindex,nextnextchild.getValue());
					rindex++;	
				    }
				
				tpl.setElem(tindex,result);
				tindex++;
			    }
		    }
	    }
	catch(Throwable ex)
	{}
	res.setElem(0,tpl);
	System.gc();
	return res;
	   
    }
   
}
