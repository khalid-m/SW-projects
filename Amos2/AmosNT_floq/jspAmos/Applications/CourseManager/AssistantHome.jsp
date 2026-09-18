<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<html>
  <head>
    <title>Assistant Home</title>
  </head>

  <body>
    <jsp:include page="AssistantMenu.jsp"/>
    <h2>Assistant Home</h2>

    <ul>
      <li><a href="UpdateAssignment.jsp">Update the assignment status of students</a>
      <li><a href="ListStudentsFull.jsp">View the status of students</a> 
      <li><a href="todo.html">Register a new assignment.</a>
      <li><a href="Query.jsp">Execute arbitrary AmosQL</a>
    </ul>
  </body>
</html>
