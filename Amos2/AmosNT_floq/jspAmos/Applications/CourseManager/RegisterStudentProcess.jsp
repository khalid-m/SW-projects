<%@ page isThreadSafe="false" %>
<jsp:include page="Init.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="registerStudent"
             scope="request"
             class="jspamos.course_manager.RegisterStudent"/>
<jsp:setProperty name="registerStudent" property="*"/>

<%
callin.Connection db = amos.getConnection();
if (registerStudent.validate(db)) {
  boolean updateRes = registerStudent.createStudent(db);
  if (updateRes) {
%>

<html>
  <head>
    <title>Successful registration</title>
  </head>
  <body>
    <h2>You were successfully registered as:</h2>
    <br>
      <table width="50%" border="0" cellspacing="0">
          <tr>
            <td>Name:</td>
	    <td><%= registerStudent.getFirstName() + " " +
                    registerStudent.getLastName() %>
            </td>
          </tr>
          <tr>
            <td>Personal number:</td>
	    <td><%= registerStudent.getPersonalNumber() %></td>
          </tr>
          <tr>
            <td>E-mail:</td>
	    <td><%= registerStudent.getEmail() %></td>
          </tr>
          <tr>
            <td>User name:</td>
	    <td><%= registerStudent.getUserName() %></td>
          </tr>
      </table>
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
      pageContext.forward("RegisterStudent.jsp");
      return;
    }
%>
