<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>

<jsp:useBean id="registerStudent"
             scope="request"
             class="jspamos.course_manager.RegisterStudent"/>
<jsp:setProperty name="registerStudent" property="*"/>

<html>
  <head>
    <title>Course registration</title>
  </head>

  <body>
    <h1>Course registration for students.</h1>
    <br>
    <p>Please enter the information necessary to manage and report your results.</p>
    <br>

    <form name="RegisterStudent" method="post" action="RegisterStudentProcess.jsp">
      <table width="90%" border="0" cellspacing="0">
          <tr>
            <td>First name:</td>
	    <td><input type="text" name="firstName" size="30"
		       value='<%= registerStudent.getFirstName() %>'></td>
            <td><font color="red"><%= registerStudent.getError("firstName") %></font></td>
          </tr>
          <tr>
            <td>Last name:</td>
	    <td><input type="text" name="lastName" size="30"
		       value='<%= registerStudent.getLastName() %>'></td>
            <td><font color="red"><%= registerStudent.getError("lastName") %></font></td>
          </tr>
          <tr>
            <td>Personal number:<br>
		Enter <b>'none'</b> if you don't have one.
            </td>
	    <td><input type="text" name="personalNumber" size="10"
		       value='<%= registerStudent.getPersonalNumber() %>'></td>
            <td><font color="red"><%= registerStudent.getError("personalNumber") %></font></td>
          </tr>
          <tr>
            <td>E-mail:</td>
	    <td><input type="text" name="email" size="50"
		       value='<%= registerStudent.getEmail() %>'></td>
            <td><font color="red"><%= registerStudent.getError("email") %></font></td>
          </tr>
          <tr>
            <td>UNIX user name (at least three charachters):<br>
            </td>
	    <td><input type="text" name="userName" size="15"
		       value='<%= registerStudent.getUserName() %>'></td>
            <td><font color="red"><%= registerStudent.getError("userName") %></font></td>
          </tr>
          <tr>
            <td>Password (at least three charachters):<br>
            </td>
	    <td><input type="password" name="password1" size="15"
		       value='<%= registerStudent.getPassword1() %>'></td>
            <td><font color="red"><%= registerStudent.getError("password1") %></font></td>
          </tr>
          <tr>
            <td>Confirm password:</td>
	    <td><input type="password" name="password2" size="15"
		       value='<%= registerStudent.getPassword2() %>'></td>
            <td><font color="red"><%= registerStudent.getError("password2") %></font></td>
          </tr>
      </table>
      <br>
      <br>
      <font color="red"><%= registerStudent.getError("formError") %></font>
      <br>
      <br>
      <input type="submit" name="register" value="Register">
      <input type="reset"  name="reset" value="Reset form">
    </form>

    <hr>
    Back to <a href="index.jsp">home</a>.
    <hr>
  </body>
</html>
