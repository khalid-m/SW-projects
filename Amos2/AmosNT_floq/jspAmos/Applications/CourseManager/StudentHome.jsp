<jsp:include page="Init.jsp"/>
<jsp:include page="CheckStudent.jsp"/>

<html>
  <head>
    <title>Student Home</title>
  </head>

  <body>
  <jsp:include page="StudentMenu.jsp"/>
    <h2>Student Home</h2>
    <ul>
      <li><a href="AssignmentStatus.jsp">View the status of your assignments.</a>
      <li><a href="todo.html">View your personal information stored in the database.</a>
      <li><a href="todo.html">Update your personal information.</a>
      <li><a href="todo.html">Update your group membership.</a>
    </ul>
  </body>
</html>
