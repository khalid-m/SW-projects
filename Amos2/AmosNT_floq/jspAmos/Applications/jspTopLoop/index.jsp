<%@ page import="jspAmos.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="amos" scope="application" class="jspAmos.Amos" />
<jsp:useBean id="amosUtil" scope="request" class="jspAmos.Utilities" />

<%
String values[] = {"query"};
Hashtable v = (Hashtable) amosUtil.getRequestValues(request, values);
String query = (String) v.get("query");

// start amos & load database image
amos.startAmos(application.getRealPath("")+"/WEB-INF/amos2.dmp");

%>
<html>
<head>
  <title>
    JSP-Amos - by Dominik Businger
  </title>
</head>
<body>
<link rel="stylesheet" href="amos_style.css" type="text/css">
<table align="center" width="80%"><tr><td>
  <h1>Query Amos II via JSP</h1>
  <h3>Enter you query below:</h3>
  <form name="query" method="post" action="index.jsp">
    <p>
    <textarea name="query" cols="80" rows="5"></textarea>
    </p>
    <p>
    <input name="submit" type="submit" value="Submit query" >
    <input name="resteQuery" value="Place last query into textfield" type="button"
       onclick="document.query.query.value='<% out.print(amosUtil.replace(amosUtil.nl2Br(query),"<br>"," ")); %>'" >
    </p>
  </form>
  <b><span class="normal">Your query was : </span></b> <span class="normal">
  <% out.println(query);%>
  <br>
  <br>
  <b>The result of your query is :</b></span><b> </b><br>
  <br><div align="center">
<%
if (query.length()>0){
  try{
    out.println(amosUtil.resultToTable(amos.jspExecute(query),"")) ;
  } catch (Exception e ){
    out.println("On Executing <b>'"+query+"'</b> the following Error occured : \n<br>");
    out.println("<div align='center'><b>\n"+e.toString().substring(21)+"\n</b></div><br><br>");
  }
}
%>
  </div>
</td></tr></table>
</body>
</html>
