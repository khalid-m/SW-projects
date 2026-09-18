<%@ page isThreadSafe="false" %>
<%@ page import="callin.*" %>

<jsp:include page="Init.jsp"/>
<jsp:include page="CheckStudent.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />

<% String sname = (String) session.getAttribute("username"); %>

<html>
  <head>
    <title>Assignment status for user: <%= sname %></title>
  </head>

  <body>
  <jsp:include page="StudentMenu.jsp"/>
  <h2>Assignment status for user: <%= sname %> </h2>

<%
try {
  String colHeader;
  Connection con = amos.getConnection();
  Scan theScan;
  Tuple arg = new Tuple(1);

  arg.setElem(0, sname);
  theScan = con.callFunction("listGroupMembers", arg);
  colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
  out.println("Your group consists of:<br><br>");
  out.println(jspamos.Utilities.resultToTable(theScan, "", colHeader));
  colHeader = "<TR><TH>Assignment</TH><TH>Status</TH><TH>Assistant</TH><TR>";
  out.println("<br><br>");
  out.println("The results registered for your assignments are:<br><br>");
  theScan = con.callFunction("studentAssignmentStatus", arg);  
  out.println(jspamos.Utilities.resultToTable(theScan, "", colHeader));
} catch (Exception e) {
  out.println(e);
  e.printStackTrace();
}
%>
<br><br>
<hr>
<b>Notice:</b><br>
When the status of an assignment is "FAILED", this means that there
are some errors in the assignment and some parts have to be coorected.<br>
Once you complete your assignment and it is acceptable, its status
will be changed to "PASSED".<br>
You pass the course when all assignments are marked as "PASSED".

  </body>
</html>
