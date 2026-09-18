<%@ page isThreadSafe="false" %>
<%
Boolean authenticated = (Boolean)session.getAttribute("authenticated");
if ((authenticated == null) || (authenticated == Boolean.FALSE)) {
  pageContext.forward("Login.jsp");
  return;
} else {
  String utp = (String) session.getAttribute("usertype");
  if (! utp.equalsIgnoreCase("STUDENT")) {
    pageContext.forward("index.jsp");
    return;
  }
}
%>
