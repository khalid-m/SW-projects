<%@ page import="java.util.*" %>
<%@ page isThreadSafe="true" %>
<jsp:include page="Init.jsp"/>
<%
Set permittedUserTypes = new HashSet();
permittedUserTypes.add("LECTURER");
session.setAttribute("permittedUserTypes", permittedUserTypes);
%>
<jsp:include page="CheckPermissions.jsp"/>

<html>
  <head>
    <title>Lecturer Home</title>
  </head>

  <body>
    <jsp:include page="LecturerMenu.jsp"/>
    <h2>Lecturer Home</h2>

    <ul>
      <li><a href="UpdateAssignment.jsp">Update the assignment status of students</a>
      <li><a href="ListStudentsFull.jsp">View the status of students</a> 
      <li><a href="todo.html">Register a new assignment.</a>
      <li><a href="Query.jsp">Execute arbitrary AmosQL</a>
    </ul>
  </body>
</html>
