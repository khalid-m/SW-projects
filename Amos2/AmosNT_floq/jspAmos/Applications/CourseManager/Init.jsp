<%@ page isThreadSafe="true" %>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<%
  ServletContext servlet = getServletConfig().getServletContext();
  //String         appName   = servlet.getInitParameter("appName");
  //String         amosImage = servlet.getInitParameter("amosImage");
  String         appPath   = servlet.getRealPath("");
  String         amosImage  = appPath+"/WEB-INF/"+"client.dmp";

  amos.startAmos(amosImage,
                 "cm", // Amos II server to connect to (null -> local)
		 null, // The nameserver host (null -> same node)
		 true, // autoCommit
		 true  // autoSave
                );
%>
