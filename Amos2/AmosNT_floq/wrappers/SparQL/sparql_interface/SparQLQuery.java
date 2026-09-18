package sparql_interface;

import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.HashMap;
import java.util.Collections;

import org.xml.sax.*;
import javax.xml.parsers.*;
import org.xml.sax.helpers.DefaultHandler;

import callin.*;
import callout.*;

class ResultHandler extends DefaultHandler {
	protected boolean grabChars = false;
	protected boolean needsTags = false;
	protected ArrayList<String> currentResult;
	protected ArrayList<ArrayList<String>> results =
		new ArrayList<ArrayList<String>>();
	
	public void startElement(String uri, String localName, String qName, Attributes attrs) {
		if(qName.equals("result"))
			currentResult = new ArrayList<String>();
		else if(qName.equals("uri"))
			grabChars = needsTags = true;
		else if(qName.equals("literal"))
			grabChars = true;
	}
	public void endElement(String uri, String localName, String qName) {
		if(qName.equals("result"))
			results.add(currentResult);
		else if(qName.equals("uri") || qName.equals("literal"))
			grabChars = needsTags = false;
	}
	public void characters(char[] chars, int start, int length) {
		if(grabChars) {
			String result = new String(chars,start,length);
			if(needsTags)
				result = "<" + result + ">";
			currentResult.add(result);
		}
	}
	
	public ArrayList<ArrayList<String>> getResults() {
		return results;
	}
}

class OptionalResultHandler extends ResultHandler {
	protected HashMap<String,Integer> variables = new HashMap<String,Integer>();
	protected int varCount = 0;
	protected String currentBinding;
	
	public void startElement(String uri, String localName, String qName, Attributes attrs) {
		if(qName.equals("variable")) {
			variables.put(attrs.getValue("name"),new Integer(varCount));
			varCount++;
		}
		else if(qName.equals("result"))
			currentResult = new ArrayList<String>(Collections.nCopies(varCount,""));
		else if(qName.equals("binding"))
			currentBinding = attrs.getValue("name");
		else if(qName.equals("uri"))
			grabChars = needsTags = true;
		else if(qName.equals("literal"))
			grabChars = true;
	}

	public void characters(char[] chars, int start, int length) {
		if(grabChars) {
			int index = variables.get(currentBinding);
			String result = new String(chars,start,length);
			if(needsTags)
				result = "<" + result + ">";
			currentResult.set(index,result);
		}
	}
}

public class SparQLQuery {
	public void sparqlQuery(CallContext context, Tuple params) throws ParserConfigurationException, AmosException {
		String queryString = params.getStringElem(0);
		String queryAddress = params.getStringElem(1);
		try {
			queryString = URLEncoder.encode(queryString,"UTF-8");
			//queryString = "http://localhost:2020/dbpedia?query=" + queryString + "&output=xml";
			queryString = queryAddress + "?query=" + queryString + "&output=xml";
			URL url = new URL(queryString);
			BufferedReader in = 
				new BufferedReader(new InputStreamReader(url.openStream()));
			SAXParser sparser = 
				SAXParserFactory.newInstance().newSAXParser();
			ResultHandler resultHandler = new OptionalResultHandler();
			sparser.parse(new InputSource(in),resultHandler);
			in.close();
			
			ArrayList<ArrayList<String>> results = resultHandler.getResults();
			Iterator<ArrayList<String>> it = results.iterator();
			while(it.hasNext()) {
				ArrayList<String> resultArray = it.next();
				//if(!allEmpty(resultArray)) {
					Tuple output = new Tuple(resultArray.size());
					for(int i=0; i<resultArray.size(); i++)
						output.setElem(i,resultArray.get(i));
					params.setElem(2,output);
					context.emit(params);
					//}
			}
		}
		catch(MalformedURLException e) {
			System.out.println("Bad URL generated from: " + queryString);
		}
		catch(UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		catch(SAXException e) {
			e.printStackTrace();
		}
		catch(IOException e) {
			e.printStackTrace();
		}
	}

	public static boolean allEmpty(ArrayList<String> array) {
		Iterator<String> it = array.iterator();
		while(it.hasNext()) {
			if(!"".equals(it.next()))
				return false;
		}
		return true;
	}
}