package jspamos;

import java.util.*;
import java.text.*;
import javax.servlet.*;
import callin.*;

/**
 * <table>
 *   <tr>
 *     <td><b>Title</b></td>
 *     <td>Utilities</td>
 *   </tr>
 *   <tr>
 *     <td><b>Description</b></td>
 *     <td>Class that provides often used methods with Amos, HTML & JSP</td>
 *   </tr>
 *   <tr>
 *     <td><b>Copyright</b></td>
 *     <td>Copyright (c) 2001</td>
 *   </tr>
 *   <tr>
 *     <td><b>Company</b></td>
 *     <td>University of Uppsala</td>
 *   </tr>
 *   <tr>
 *     <td><b>author</b></td>
 *     <td>Dominik Businger</td>
 *   </tr>
 *   <tr>
 *     <td><b>version</b></td>
 *     <td>1.0</td>
 *   </tr>
 * </table>
 * <br>
 * <b>What does this class do/proviede :</b><br>
 * <ul>
 *   <li> makes it easier to generate html-code for tables and lists 
 *        from a amos2-scan</li>
 *   <li> handels input coming via http-requests (e.g. HTML-Form Data) </li>
 * </ul>
 *
 * @author       Dominik Businger
 * @version 1.0
 *
 */

public class Utilities {

  /**
   * resultToTable creates a html-string representing the content of a 
   * scan as a table.<br>
   * if the scan contains a vector, the vector will be layouted as a table inside a 
   * cell of the parent-table, with the same formating
   * <br><br>
   *
   * @param scan the result scan that has to be output as a html-table
   * @param boolean oneTableColumnPerVector specifies if vectors should be 
   *                layouted as one row or as one column.<br>
   *                <ul>oneTableColumnPerVector is true if not set.</ul>
   * @param String  tableProperties defines the html-tag-properties of the table-tag(s)<br>
   *                <ul>tableProperties is
   *                    "bordercolor='#000000' border='1' cellspacing='0' cellpadding='5'"
   *                    if not set.
   *                </ul>
   * @param String  tableHeaders is an optional HTML string with column headers, such as<br>
   *                '<TR> <TH>Col1</TH>  <TH>Col2</TH> <TR>'
   *
   * @return string representing the content of the scan as a html-table
   *
   */
  static public String resultToTable(Scan scan,
				     String tableProperties,
				     String tableHeaders)
    throws callin.AmosException
  {
    // apply standard-table-layout if no layout passed.
    if ((tableProperties == null) || tableProperties.equalsIgnoreCase("")) {
      tableProperties = "bordercolor='#000000' border='1' cellspacing='0' cellpadding='3'";
    }
    // open html-table & apply table-layout.
    String resultString = "\n<table "+tableProperties+">\n";
    // Optionally add columns headers
    if ( ! ((tableHeaders == null) || tableHeaders.equalsIgnoreCase("")) ) {
      resultString = resultString + tableHeaders;
    }

    // start adding rows to the table for each tuple...
    while (!scan.eos()) {
      resultString = resultString +
	             tupleToTableRow((Tuple) scan.getRow(),false,false,tableProperties, "");
      scan.nextRow();
    }// stop adding rows, because all tuples are done.
    // close table
    resultString = resultString + "</table>\n";
    if (resultString.endsWith("        </tr>\n  </tr>\n</table>\n")) {
      int firstTr = resultString.indexOf("<tr>");
      resultString = resultString.substring(0,firstTr-2) + resultString.substring(firstTr+5);
      int lastTr = resultString.lastIndexOf("</tr>");
      resultString = resultString.substring(0,lastTr-2) + resultString.substring(lastTr+6);
    }
    return resultString;
  }

  static public String resultToTable(Scan scan, String tableProperties) 
    throws callin.AmosException
  {
    return resultToTable(scan, tableProperties, null);
  }

  static public String resultToTable(Scan scan)
    throws callin.AmosException
  {
    return resultToTable(scan, null, null);
  }

  /**
   * tupleToTableRow converts any tuple into on or more html-table-row(s)<br>
   *     with sub-tables if the tuple contains a mix of vectors and non-vectors<br><br>
   *
   * @param Tuple tuple
   * @param boolean oneTableColumnPerVector
   * @param boolean startNewTable
   * @param String tableProperties
   * @param String spacer used to make the result string have a nice layout in the html-source.
   *
   * @return String html-table-row(s) for the tuple with sub-tables if the tuple contains a mix 
   * of vectors and non-vectors
   */
  static private String tupleToTableRow(Tuple tuple,
					boolean oneTableColumnPerVector,
					boolean startNewTable,
					String tableProperties,
					String spacer)
    throws callin.AmosException
  {
    String resultString = "";
    if (startNewTable) { // start a new table ...
      // start new table-cell of super table
      resultString = resultString + spacer.substring(2) +"<td>\n";
      // start new table
      resultString = resultString + spacer +"<table "+ tableProperties +" >\n";
    }
    if (!oneTableColumnPerVector ) {
      resultString = resultString + spacer +"  <tr>\n";  // open a new table-row
    }
    // create and fill all the table cells
    int column = 0;
    boolean newTable = false;
    while (column < tuple.getArity()) { // for each column in each tuple
      if (oneTableColumnPerVector) {
        resultString = resultString + spacer +"  <tr>\n";  // open a new table-row
      }
      if(tuple.isTuple(column)) { // column contains a tuple
        if (column == 0) {
          int col = 0;
          int arity = tuple.getArity();
          while ( col < arity) {
            newTable = !tuple.isTuple(col);
            col++;
          }
        }
        Tuple subTuple = tuple.getSeqElem(column);
        resultString = resultString + 
	  tupleToTableRow(subTuple, !oneTableColumnPerVector, newTable, tableProperties, spacer+"      ");
      } else {  // column contains no tuple
        newTable = true;
	// fill the new table cell
        resultString = resultString + spacer+"    <td>"+tuple.getElem(column).toString()+"</td>\n";
      } // end of else
      column++;
      if (oneTableColumnPerVector) {
        resultString = resultString + spacer +"  </tr>\n";  // close this table-row
      }
    } // end of tuple
    if (!oneTableColumnPerVector ) {
      resultString = resultString + spacer +"  </tr>\n";  // close this table-row
    }
    if (startNewTable) { // start a new table ...
      resultString = resultString + spacer +"</table>\n"; // close this table
      resultString = resultString + spacer +"</td>\n";  // close table-cell of supertable
    }
    return resultString;
  }



  /**
   * resultToLayout takes a scan and creates an html-string according to 
   * the supplied pattern for every tuple inside the scan.
   * <br><br>
   * @param Scan resultVec
   * @param String pattern    html-pattern to be used to create output 
   *                          with the scans tuples<br>
   *                          e.g.  pattern = "&lt;tr&gt;\n
   *                                           &lt;td&gt;\n
   *                                           &lt;a href='&amp;col_1;'target='_blank'&gt;\n
   *                                           Link to &amp;col_1;\n
   *                                           &lt;/a&gt;\n
   *                                           &lt;/td&gt;\n
   *                                           &lt;/tr&gt;\n";
   *
   * @return String created according to the supplied pattern for every
   *         tuple inside the scan.
   *
   */
  static public String resultToLayout(Vector resultVec, String pattern) {
    Tuple scanRow = null;
    String resultString = "";
    String msg = "";
    if (resultVec.size() == 0 ) {
      msg = "The Query you submitted, returned a NULL Scan.";
      System.out.println(msg);
    } else {
      int i = 0;
      while (i < resultVec.size()) { // for each tuple in the scan...
        try {
          int pos = 0;
          Tuple row = new Tuple();
          row.setArity(((Vector)resultVec.elementAt(i)).size());
          while (pos < row.getArity()) {
            row.setElem(pos,((Vector)resultVec.elementAt(i)).elementAt(pos));
            pos++;
          }
          resultString = resultString + tupleToLayout(row,pattern);
          i++;
        } catch ( callin.AmosException e ) {
          msg = "Exception!! : Couldn't get next Row! :\n" + e;
          System.out.println(msg);
        }
      }
    }
    if (msg != "") { resultString = msg; }
    return resultString;
  }

  static public String resultToLayout(Scan theScan, String pattern) {
    Tuple scanRow = null;
    String resultString = "";
    String msg = "";
    if (theScan == null) {
      msg = "The Query you submitted, returned an NULL Scan.";
      System.out.println(msg);
    } else {
      while (!theScan.eos()) { // for each tuple in the scan...
        try {
          resultString = resultString + tupleToLayout(theScan.getRow(),pattern);
          theScan.nextRow();
        } catch ( callin.AmosException e ) {
          msg = "Exception!! : Couldn't get next Row! :\n" + e;
          System.out.println(msg);
        }
      }
    }
    if (msg != "") {
      resultString = msg;
    }
    return resultString;
  }

  static private String tupleToLayout(Tuple tuple, String pattern) {
    String resultString = "";
    String msg = "";
    String element = "";
    int tplBeginTag = 0;
    int tplEndTag = 0;
    boolean isTuple = false;
    int arity = 1;
    try {
      arity = tuple.getArity();
    } catch ( AmosException e) {}
    if ( arity > 0 ) {
      try {
	isTuple = tuple.isTuple(0);
      } catch ( AmosException e) {
      }
      // if the tuple contains a vector (SeqElem), use tupleToLayout to create resultString
      if ( isTuple ) {
	int nextTuple=0;
	try {
	  int size = tuple.getArity();
	  while ( size > nextTuple ) {
	    resultString = resultString + tupleToLayout(tuple.getSeqElem(nextTuple),pattern);
	    nextTuple++;
	  }
	} catch ( AmosException e) {
	}
	// if the tuple doesn't contain a vector (SeqElem) create create html-string with this tuple
      } else {
	while (pattern.substring(tplBeginTag).indexOf("&col_") > -1) {
	  tplBeginTag = pattern.indexOf("&col_",tplBeginTag);
	  tplEndTag = pattern.indexOf(";",tplBeginTag);
	  int tplToShow = -1;
	  try {
	    tplToShow = Integer.parseInt((String) pattern.substring(tplBeginTag+5, tplEndTag));
	  } catch ( Exception e ) {
	    msg = "Exception!! : The Tag '" + pattern.substring(tplBeginTag+5, tplEndTag) + 
	      "' contains an invalid number-format \n" + e;
	    System.out.println(msg);
	    break;
	  }
	  try{
	    element = tuple.getElem(tplToShow).toString();
	  } catch (callin.AmosException e) {
	    msg = "The column '" +
	          tplToShow +
	          "' does not exist in the tuple! " + e;
	    System.out.println(msg);
	  }
	  pattern = pattern.substring(0,tplBeginTag)+ element + pattern.substring(tplEndTag+1);
	} // end of while...
	resultString = resultString + pattern + "\n";
      }  // end of else ... is no tuple
    }// end of "if tuple arity > 0"
    if (msg != "") { resultString = msg; }
    return resultString;
  }

  /**
   * getRequestValues puts all parameters and their values from a request into a hashtable.<br>
   * It creates an empty String object in the hashtable for all values in the String array "values"<br><br>
   *
   * @param request the http-request containing the values
   * @param values a String array containing Strings for all the expected values in the request
   * @return Hashtable with all the values supplied in the request, but at least with String values for the Strings in the array "values"
   */
  static public Hashtable getRequestValues(ServletRequest request, String[] values) {
    Hashtable valuesHashTable = getRequestValues(request);
    int i = 0;
    while ( i < values.length) {
      if(!valuesHashTable.containsKey(values[i])) {
        valuesHashTable.put(values[i],"");
      }
      i++;
    }
    return valuesHashTable;
  }

  /**
   * getRequestValues puts all parameters and their values from a request into a hashtable.<br><br>
   *
   * @param request the http-request containing the values
   * @return Hashtable with all the values supplied in the request
   */
  static public Hashtable getRequestValues(ServletRequest _request) {
    Hashtable values = new Hashtable();
    ServletRequest request = _request;
    Enumeration parameterNames = request.getParameterNames();
    while (parameterNames.hasMoreElements()) {
      String nextParameter = (String) parameterNames.nextElement();
      String nextValueSet[] = (String[]) request.getParameterValues(nextParameter);
      String nextValue = nextValueSet[0];
      values.put(nextParameter, nextValue);
    }
    return values;
  }

  /**
   * validate strings according to a supplied "pattern" and some extra constraints<br><br>
   *
   * @param _input the String that has to be checked if it matches the pattern
   * @param _pattern can be "email" "number" "digits" "phone" "url"<br>
   * <ul>
   *   <li>email : it will be checked if it could be a valid email, containing at least one "."
   *       and exactly one @ at the proper positions</li>
   *   <li>number : it will be checked if it is a valid number (=> it it could be a float) </li>
   *   <li>digits : it will be checked if there are digits only </li>
   *   <li>phone : it will be checked if there are digits, spaces, "/" and "+" only </li>
   *   <li>url : it will be checked if it can be parsed into a java.net.URL </li>
   * </ul><br>
   * @param _maxlength maximum length of _input
   * @param _notNull boolean value that sets, if an empty string is a valid string.
   * @param _minlength minimum length of _input
   *
   * @return boolean true if _input matches the supplied constraints
   */
  static public boolean validate(String _input,
				 String _pattern,
				 int _maxlength,
				 boolean _notNull,
				 int _minlength)
  {
    boolean result = true;
    boolean notNull = _notNull;
    String input = new String(_input);
    String pattern = _pattern;
    int maxlength = _maxlength;
    int minlength = _minlength;
    // checking the length & if notNull
    if ( notNull && !(input.length()>0)) { result = false; }
    if ( _maxlength < input.length() && (_maxlength != -1) ) { result = false; }
    if ( _minlength > input.length() && (_minlength != -1) ) { result = false; }

    // checking the string to match the pattern ...
    // number    0-9*.0-9*
    if ( pattern.startsWith("number"))  {
      try{
	Double test = new Double(input);
      } catch (Exception e) {
	result = false;
      }
    }
    // digits    (0-9)*
    if ( pattern.startsWith("digits"))  {
      try{
	Long test = new Long(input);
      } catch (Exception e) {
	result = false;
      }
    }

												    
    // phone    ((0-9)*(" ")*)*
    if ( pattern.startsWith("phone"))  {
      input = input.replace(" ".charAt(0),"1".charAt(0));
      input = input.replace("/".charAt(0),"1".charAt(0));
      input = input.replace("+".charAt(0),"1".charAt(0));
      try{
	Long test = new Long(input);
      } catch (Exception e) {
	result = false;
      }
    }
																	  
    // email   w*(.w*)*@w*.w*(.w*)*
    if ( pattern.startsWith("email"))  {

      // checking for unwanted characters
      int badChar = badChar = input.indexOf("§");
      badChar = badChar + input.indexOf("°");
      badChar = badChar + input.indexOf("+");
      badChar = badChar + input.indexOf("\"");
      badChar = badChar + input.indexOf("*");
      badChar = badChar + input.indexOf("ç");
      badChar = badChar + input.indexOf("%");
      badChar = badChar + input.indexOf("&");
      badChar = badChar + input.indexOf("/");
      badChar = badChar + input.indexOf("(");
      badChar = badChar + input.indexOf(")");
      badChar = badChar + input.indexOf("=");
      badChar = badChar + input.indexOf("?");
      badChar = badChar + input.indexOf("`");
      badChar = badChar + input.indexOf("^");
      badChar = badChar + input.indexOf("~");
      badChar = badChar + input.indexOf("´");
      badChar = badChar + input.indexOf("¢");
      badChar = badChar + input.indexOf("|");
      badChar = badChar + input.indexOf("¬");
      badChar = badChar + input.indexOf("#");
      badChar = badChar + input.indexOf("¦");
      badChar = badChar + input.indexOf("¨");
      badChar = badChar + input.indexOf("!");
      badChar = badChar + input.indexOf("[");
      badChar = badChar + input.indexOf("]");
      badChar = badChar + input.indexOf("$");
      badChar = badChar + input.indexOf("£");
      badChar = badChar + input.indexOf("{");
      badChar = badChar + input.indexOf("}");
      badChar = badChar + input.indexOf("<");
      badChar = badChar + input.indexOf(">");
      badChar = badChar + input.indexOf("\\");
      badChar = badChar + input.indexOf("@.");
      badChar = badChar + input.indexOf(".@");
      badChar = badChar + input.indexOf("..");
      // checking for first "@"
      int indexOfAt = input.indexOf("@");
      // checking if there is an 2nd "@"
      int ats = input.indexOf("@", indexOfAt+1);
      // checking for the last "." behind the "@"
      String behindTheAt = input.substring(indexOfAt+1);
      int lastDot = behindTheAt.lastIndexOf(".");
      // checking if all the tests were negative
      //   @ exists     // only one @ // . after @ exists
      // the last dot is max 3rd but last character
      // none of the 36 checked bad characters exists
      if ( indexOfAt < 1 | ats != -1  | !(lastDot > 1)  |
	   !(lastDot < behindTheAt.length()-2) | !(badChar==-36) )
      {
	result = false;
      }
    }																				       
    // url
    if ( pattern.startsWith("url"))  {
      try{
	java.net.URL u = new java.net.URL(input);
      } catch (Exception e) {
	result = false;
      }
    }
    return result;
  }

  static public boolean validate(String _input, String _pattern) {
    return validate(_input, _pattern, -1,  false, -1);
  }
  static public boolean validate(String _input, String _pattern, boolean _notNull) {
    return validate(_input, _pattern,  -1,  _notNull, -1);
  }
  static public boolean validate(String _input, String _pattern, int _maxlenght, boolean _notNull) {
    return validate(_input, _pattern,  _maxlenght,  _notNull, -1);
  }
  static public boolean validate(String _input, String _pattern, int _maxlenght, int _minlength) {
    return validate(_input, _pattern,  _maxlenght,  false, _minlength);
  }
  static public boolean validate(String _input, String _pattern, int  _minlength) {
    return validate(_input, _pattern,  -1,  true, _minlength);
  }

  /**
   * notNull checks if the supplied object o is null or not. if it
   * is null, it creats a new object of the class "returnClass",
   * which can be String , String ,Integer, Integer, Date or Vector.
   * <br><br>
   *
   * The method writes a message to standardoutput
   * if object is null, or not of supported Class type.
   * <br><br>
   *
   * @param object object to check if it is null
   * @param returnClass String with the name of the expected class
   * @return object of the expected class
   */
  static public Object notNull(Object object, String returnClass) {
    Object returnObject = null;
    if ( object == null ) {
      if( returnClass.equalsIgnoreCase("Integer")) {
        Integer r = new Integer("-1");
        returnObject = r;
      } else if( returnClass.equalsIgnoreCase("Integer[]")) {
        Integer[] r = {};
        returnObject = r;
      } else if( returnClass.equalsIgnoreCase("String")) {
        String r = new String("");
        returnObject = r;
      } else if( returnClass.equalsIgnoreCase("String[]")) {
        String[] r = {};
        returnObject = r;
      } else if( returnClass.equalsIgnoreCase("Vector")) {
        Vector r = new Vector();
        returnObject = r;
      } else if( returnClass.equalsIgnoreCase("Date")) {
        Date r = new Date();
        returnObject = r;
      } else {
        System.out.println("This method doesn't support the supplied Class of Objects!");
      }
    } else if( object != null ) {
      Object r = object;
      returnObject = r;
    }
    return returnObject;
  }

  /**
   * method to convert a string into a java.util.Date object
   * <br><br>
   *
   * @param dateString String of the format "y-M-d H:m:s" (e.g. 2002-2-23 23:44:02)
   *
   * @return Date java object that matches the date enterd as a String
   *
   */
  static public Date stringToDate(String dateString) {
    Date date = null;
    SimpleDateFormat format = new SimpleDateFormat("y-M-d H:m:s");
    try{
      date = format.parse(dateString);
    } catch (java.text.ParseException e) {
      System.out.println("The supplied dateString couldn't be parsed! " + e);
    }
    return date;
  }

  /**
   * method to convert a java.util.Date into a string
   * <br><br>
   *
   * @param java.util.Date
   *
   * @return dateString of the format "y-M-d H:m:s" (e.g. 2002-2-23 23:44:02)
   */
  static public String dateToString(Date date) {
    String dateString;
    SimpleDateFormat format = new SimpleDateFormat("y-M-d H:m:s");
    dateString = format.format(date);
    return dateString;
  }

  /**
   * Method to change double quotes to single quotes
   * <br><br>
   *
   * @param String with double quotes
   * @return String with single quotes instead of double quotes
   */
  static public String toSingleQuote(String s) {
    return s.replace("\"".charAt(0),"'".charAt(0));
  }

  /**
   * Method to change normal line breaks to html-tag-line breaks
   * <br><br>
   *
   * @param String without html-line breaks
   * @return String with html-line breaks
   */
  static public String nl2Br(String s) {
    s = replace(s,"\n\r","<br>");
    s = replace(s,"\r\n","<br>");
    s = replace(s,"\n","<br>");
    s = replace(s,"\r","<br>");
    return s;
  }

  /**
   * Method to replace any occurence of a string in a string
   * <br><br>
   *
   * @param text the text that has to be searched for strings to replace
   * @param removeString the String that should be replaced by "replaceString"
   * @param replaceString the String that should replaced the "removeString"
   *
   * @return String where removeString has been replaced with replaceString
   *
   */
  static public String replace(String text, String removeString, String replaceString) {
    int idx = text.indexOf(removeString);
    while(idx != -1) {
      text = text.substring(0, idx) +
	replaceString +
	text.substring(idx + removeString.length());
      idx = text.indexOf(removeString);
    }
    return(text);
  }

}
