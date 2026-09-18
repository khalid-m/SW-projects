<%@ page isThreadSafe="false" %>
<%@ page import="java.util.*" %>

<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />

<html>
<head>
  <title>Query Amos via AmosQL</title>
</head>
<body>
<jsp:include page="AssistantMenu.jsp"/>
<h2>Query Amos2 via AmosQL</h2>
 
 <h3>Enter you query below:</h3>

  <form name="query" method="post" action="Query.jsp">
    <p>
    <textarea name="query" cols="80" rows="5"></textarea>
    </p>
    <p>
    <input name="submit" type="submit" value="Submit query" >
    </p>
  </form>

  <hr>

  <br>
  <b>The result of your query is :</b></span><b> </b>
  <br>
  <br>

<%
String query = request.getParameter("query");

if ((query != null) && (query.length() > 0)) {
  try{
    out.println(jspamos.Utilities.resultToTable(amos.jspExecute(query),""));
  } catch (Exception e ){
    out.println("When executing <b>'" +
		query +
		"'</b> the following error occured : <br>");
    out.println("<b>" + e.toString() + "</b><br>");
  }
}
%>
  </div>
</td></tr></table>
</body>
</html>
