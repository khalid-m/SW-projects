<%@ page isThreadSafe="false" %>
<%@ page import="callin.*" %>

<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />

<html>
  <head>
    <title>List of students</title>
  </head>

  <body>
    <jsp:include page="AssistantMenu.jsp"/>
    <h2>The students currently registered for the course are:</h2>

    <%
    try {
      Connection con = amos.getConnection();
      Tuple arg = new Tuple(2);
      arg.setElem(0, 5);
      arg.setElem(1, "inc");
      Scan theScan = con.callFunction("listStudentsFullAss", arg);

      String colHeader = "<TR>"+
                         "<TH>Name</TH><TH>e-mail</TH><TH>username</TH>"+
                         "<TH>PN</TH><TH>Group No.</TH><TH>Assignment results</TH>"+
                         "<TR>";
      out.println(jspamos.Utilities.resultToTable(theScan,
						  "",
						  colHeader));
    } catch (Exception e) {
      out.println(e);
      e.printStackTrace();
    }
    %>

  </body>
</html>
