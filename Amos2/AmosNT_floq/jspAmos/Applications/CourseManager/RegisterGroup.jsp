<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>

<jsp:useBean id="registerGroup"
             scope="request"
             class="jspamos.course_manager.RegisterGroup"/>
<jsp:setProperty name="registerGroup" property="*"/>

<html>
  <head>
    <title>Student group registration</title>
  </head>

  <body>
    <h1>Student group registration</h1>

    Group registration rules:
    <ul>
      <li>Minimum 1 student in a group.
      <li>Maximum 3 students in a groups.
      <li>Everyone is member of exactly one group.
      <li>In all other cases, please contact your assistant.
      <li>The students form the groups by themselves and do not 
	ask the course leader or the assistants to form groups.
    </ul>
    
    Please enter below the user name and password of all students in your
    group.
    <br><br><br>
    <form name = "RegisterGroup" action="RegisterGroupProcess.jsp" method="POST">
      <table width="90%" border="0" cellspacing="0">
          <tr>
            <td>Student 1:</td>
            <td><input type="text" name="student1" size="15"
		       value='<%= registerGroup.getStudent1() %>'></td>
            <td><font color="red"><%= registerGroup.getError("student1") %></font></td>
            <td>Password 1:</td>
            <td><input type="password" name="password1" size="15"
		       value='<%= registerGroup.getPassword1() %>'></td>
            <td><font color="red"><%= registerGroup.getError("password1") %></font></td>
          </tr>
          <tr>
            <td>Student 2:</td>
            <td><input type="text" name="student2" size="15"
		       value='<%= registerGroup.getStudent2() %>'></td>
            <td><font color="red"><%= registerGroup.getError("student2") %></font></td>
            <td>Password 2:</td>
            <td><input type="password" name="password2" size="15"
		       value='<%= registerGroup.getPassword2() %>'></td>
            <td><font color="red"><%= registerGroup.getError("password2") %></font></td>
          </tr>
          <tr>
            <td>Student 3:</td>
            <td><input type="text" name="student3" size="15"
		       value='<%= registerGroup.getStudent3() %>'></td>
            <td><font color="red"><%= registerGroup.getError("student3") %></font></td>
            <td>Password 3:</td>
            <td><input type="password" name="password3" size="15"
		       value='<%= registerGroup.getPassword3() %>'></td>
            <td><font color="red"><%= registerGroup.getError("password3") %></font></td>
          </tr>
      </table>
      <br>
      <br>
      <font color="red"><%= registerGroup.getError("formError") %></font>
      <br>
      <br>
      <input type="submit" name="register_group" value="Register group">
      <input type="reset" name="reset" value="Reset">
    </form>
    <hr>
    Back to <a href="index.jsp">home</a>.
    <hr>
  </body>
</html>
