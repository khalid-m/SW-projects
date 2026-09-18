<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="registerGroup"
             scope="request"
             class="jspamos.course_manager.RegisterGroup"/>
<jsp:setProperty name="registerGroup" property="*"/>

<%
callin.Connection db = amos.getConnection();
if (registerGroup.validate(db)) {
  boolean updateRes = registerGroup.doRegister(db);
  if (updateRes) {
%>


<html>
  <head>
    <title>Successful group registration</title>
  </head>

  <body>
    <h2>Your group was successfully registered as:</h1>
      <table width="100%" border="0" cellspacing="0">
	<%
         int studIdx = 0;
         for (int i = 0; i < 3; i++) {
           jspamos.course_manager.Student stud = registerGroup.getStudObjects(i);
           if (stud != null) {
             ++studIdx;
             out.println("<tr>");
             out.println("<td>");
             out.println("Student " + studIdx + ": " + stud.getFullname());
             out.println("</td>");
             out.println("</tr>");
           }
         }
        %>
     </table>
     <br>
     Your assistant is: <%= registerGroup.getAssistantFullName() %><br>
     Your group number is: <%= registerGroup.getGroup() %><br>
     <br>
     <br>
     Back to <a href="index.jsp">home</a>.
  </body>
</html>

<%
	} else {
	  pageContext.forward("error.html");
	  return;
	}
    } else {
      pageContext.forward("RegisterGroup.jsp");
      return;
    }
%>
