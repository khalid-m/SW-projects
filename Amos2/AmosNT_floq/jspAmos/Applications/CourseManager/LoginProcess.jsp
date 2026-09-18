<%@ page isThreadSafe="false" %>
<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="login"
             scope="request"
             class="jspamos.course_manager.Login"/>
<jsp:setProperty name="login" property="*"/>

<%!
public void authenticateUser(javax.servlet.http.HttpSession session,
                             javax.servlet.jsp.PageContext pageContext,
                             jspamos.Amos amos,
                             jspamos.course_manager.Login login)
throws javax.servlet.ServletException, java.io.IOException
{
  boolean validUser = login.validate(amos.getConnection());
  if (validUser) {
    String utp = login.getUserType();
    session.setAttribute("authenticated", Boolean.TRUE);
    session.setAttribute("username", login.getUserName());
    session.setAttribute("usertype", utp);
    if (utp.equalsIgnoreCase("STUDENT")) {
      pageContext.forward("StudentHome.jsp");
      return;
    } else if (utp.equalsIgnoreCase("ASSISTANT")) {
      pageContext.forward("AssistantHome.jsp");
      return;
    } else if (utp.equalsIgnoreCase("LECTURER")) {
      pageContext.forward("LecturerHome.jsp");
      return;
    } else {
      pageContext.forward("error.html");
      return;
    }
  } else {
    session.setAttribute("authenticated", Boolean.FALSE);
    pageContext.forward("Login.jsp");
    return;
  }
}
%>

<%
Boolean authenticated = (Boolean)session.getAttribute("authenticated");

// login for the first time
if (authenticated == null) {
    authenticated = Boolean.FALSE;
}

// first time or previously incorrect user/pass
if (authenticated == Boolean.FALSE) {
  authenticateUser(session, pageContext, amos, login);
} else { // Already logged in
  String curr_user = (String)session.getAttribute("username");
  // If logging as another user from same browser
  if ((curr_user != null) && !curr_user.equalsIgnoreCase(login.getUserName())) {
    //session.invalidate();
    //pageContext.forward("Login.jsp");
    session.setAttribute("authenticated", Boolean.FALSE);
    session.removeAttribute("username");
    session.removeAttribute("usertype");
    authenticateUser(session, pageContext, amos, login);
    return;
  } else {
    // Already logged in as the same user
    String utp = (String) session.getAttribute("usertype");
    if (utp.equalsIgnoreCase("STUDENT")) {
      pageContext.forward("StudentHome.jsp");
      return;
    } else if (utp.equalsIgnoreCase("ASSISTANT")) {
      pageContext.forward("AssistantHome.jsp");
      return;
    } else {
      pageContext.forward("error.html");
    }
  }
}
%>
