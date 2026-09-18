<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="updateAssignment"
             scope="request"
             class="jspamos.course_manager.UpdateAssignment"/>
<jsp:setProperty name="updateAssignment" property="*"/>

<%
callin.Connection db = amos.getConnection();
if (updateAssignment.validate()) {
  boolean updateRes = updateAssignment.doUpdate(db);
%>
<html>
  <head>
    <title>Update assignment status - result</title>
  </head>
  <body>
  <jsp:include page="AssistantMenu.jsp"/>
<%
  if (updateRes) {
    out.println("<b>The student information was updated successfully</b>");
  } else {
    out.println("<b>There was a problem when updating the database</b>");
  }
%>
  </body>
</html>
<%
} else {
  pageContext.forward("UpdateAssignment.jsp");
  return;
}
%>
