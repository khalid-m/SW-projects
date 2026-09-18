<%@ page isThreadSafe="false" %>
<%@ page import="callin.*" %>

<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="selection"
             scope="request"
             class="jspamos.course_manager.SelectStudent"/>
<jsp:setProperty name="selection" property="*"/>

<%
Connection con = amos.getConnection();
String rowTemplate;
%>

<html>
  <head>
    <title>Update assignment status</title>
  </head>

  <body>
  <jsp:include page="AssistantMenu.jsp"/>
  Select a student by ONE of the parameters below.<br><br>

    <FORM name="SelectStudent"
	  action="SelectStudent.jsp"
	  method="post">
      Students listed by Personal Number:<br>
      <select size="1" name="pn">
	<option selected value="">None</option>
        <%
        rowTemplate = "<option value='&col_2;'>&col_3;, &col_0;, &col_1;, &col_4;</option>\n";
	try {
          Tuple arg = new Tuple(2);
          arg.setElem(0, 4);
          arg.setElem(1, "inc");
          Scan theScan = con.callFunction("INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR",
                                          arg);
          out.println(jspamos.Utilities.resultToLayout(theScan, rowTemplate));
        } catch (Exception e ) {
          out.println(e);
          e.printStackTrace();
        }
        %>
      </select>
      <br><br>

      Students listed by Full Name:<br>
      <select size="1" name="fullName">
	<option selected value="">None</option>
        <%
        rowTemplate = "<option value='&col_2;'>&col_0;, &col_1;, &col_3;, &col_4;</option>\n";
	try {
          Tuple arg = new Tuple(2);
          arg.setElem(0, 1);
          arg.setElem(1, "inc");
          Scan theScan = con.callFunction("INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR",
                                          arg);
          out.println(jspamos.Utilities.resultToLayout(theScan, rowTemplate));
        } catch (Exception e ) {
          out.println(e);
          e.printStackTrace();
        }
        %>
      </select>
      <br><br>

      Students listed by E-Mail:<br>
      <select size="1" name="email">
	<option selected value="">None</option>
        <%
        rowTemplate = "<option value='&col_2;'>&col_1;, &col_0;, &col_3;, &col_4;</option>\n";
	try {
          Tuple arg = new Tuple(2);
          arg.setElem(0, 2);
          arg.setElem(1, "inc");
          Scan theScan = con.callFunction("INTEGER.CHARSTRING.LISTSTUDENTSFULL->VECTOR",
                                          arg);
          out.println(jspamos.Utilities.resultToLayout(theScan, rowTemplate));
        } catch (Exception e ) {
          out.println(e);
          e.printStackTrace();
        }
        %>
      </select>
      <br><br>

      <INPUT type="submit" value="Select student">
      <INPUT type="reset" value="Reset">
    </FORM>
<br>
<br>

<%
String sname = selection.getSelectedStudent();
  if (sname != null) {
  try {
    Tuple arg = new Tuple(1);
    arg.setElem(0, sname);
    Scan theScan = con.callFunction("studentInfoFull", arg);
    out.println("The following student was selected for subsequent actions:<br>");
    out.println(jspamos.Utilities.resultToTable(theScan, ""));
    session.setAttribute("selectedstudent", sname);
  } catch (Exception e ) {
    out.println(e);
    e.printStackTrace();
  }
}
%>

  </body>
</html>
