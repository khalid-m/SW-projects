<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>

<jsp:useBean id="login"
             scope="request"
             class="jspamos.course_manager.Login"/>
<jsp:setProperty name="login" property="*"/>

<html>
  <head>
    <title>Log in to the Course Manager system</title>
  </head>

  <body>
    <h1>Log in to the Course Manager system</h1>

    <form name="Login" method="post" action="LoginProcess.jsp">
        <table width="100%" border="0" cellspacing="0">
          <tr>
            <td>Username:</td>
            <td><input type="text" name="userName" size="15"
		       value='<%= login.getUserName() %>'></td>
            <td><font color="red"><%= login.getError("userName") %></font></td>
          </tr>
          <tr>
            <td>Password:</td>
            <td><input type="password" name="password" size="15"
		       value='<%= login.getPassword() %>'></td>
            <td><font color="red"><%= login.getError("password") %></font></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><input type="submit" name="login" value="Log in"></td>
          </tr>
        </table>
	  <br>
	  <font color="red"><%= login.getError("formError") %></font>
      </form>
<hr>
If you do not already have an account, please
<a href="RegisterStudent.jsp">register as a new user.</a>

  </body>
</html>
