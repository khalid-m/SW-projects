<%@ page isThreadSafe="false" %>
<%@ page import="callin.*" %>

<jsp:include page="Init.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />

<html>
  <head>
    <title>List of students alone in a group or not in a group</title>
  </head>

  <body>
    <h2>The students alone in a group or not in a group are:</h2>

    <%
    try {
      Connection con = amos.getConnection();
      Tuple arg = new Tuple(2);
      arg.setElem(0, 3);
      arg.setElem(1, "inc");
      Scan theScan = con.callFunction("INTEGER.CHARSTRING.LISTLONELYSTUDENTS->VECTOR",
                                       arg);

      String colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
      out.println(jspamos.Utilities.resultToTable(theScan,
						  "",
						  colHeader));
    } catch (Exception e ) {
      out.println(e);
      e.printStackTrace();
    }
    %>

    <hr>
    Back to <a href="index.jsp">home</a>.
    <hr>
  </body>
</html>
