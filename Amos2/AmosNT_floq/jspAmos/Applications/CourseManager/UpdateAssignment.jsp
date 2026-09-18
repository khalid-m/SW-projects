<%@ page isThreadSafe="false" %>
<%@ page import="callin.*" %>

<jsp:include page="Init.jsp"/>
<jsp:include page="CheckAssistant.jsp"/>

<jsp:useBean id="amos" scope="application" class="jspamos.Amos" />
<jsp:useBean id="updateAssignment"
             scope="request"
             class="jspamos.course_manager.UpdateAssignment"/>
<jsp:setProperty name="updateAssignment" property="*"/>

<html>
  <head>
    <title>Update assignment status</title>
  </head>
  <body>
  <jsp:include page="AssistantMenu.jsp"/>

<%
Connection db = amos.getConnection();
String assistantName = (String) session.getAttribute("username");
String studentName = (String) session.getAttribute("selectedstudent");
if ((studentName == null) || (studentName.equals(""))) {
%>

You have to <a href="SelectStudent.jsp">select</a> a student before updating
an assignment status.

<%
} else {
  try {
    String colHeader = "<TR><TH>Name</TH><TH>e-mail</TH><TH>Group No.</TH><TR>";
    Tuple arg = new Tuple(1);
    Scan theScan;

    arg.setElem(0, studentName);
    // Print information about the current student
    theScan = db.callFunction("studentInfoFull", arg);
    out.println("The student to be updated is:<br><br>");
    out.println(jspamos.Utilities.resultToTable(theScan, ""));
    out.println("<br><br>");
    // Print information about the student group
    theScan = db.callFunction("listGroupMembers", arg);
    out.println("The group of this student consists of:<br><br>");
    out.println(jspamos.Utilities.resultToTable(theScan, "", colHeader));
    out.println("<br><br>");
  } catch (Exception e) {
    out.println(e);
    e.printStackTrace();
  }
%>

<hr>
    <FORM name="UpdateAssignment"
	  action="UpdateAssignmentProcess.jsp"
	  method="post">
      <input type="hidden" name="assistantName" value=<%= assistantName %>>
      <input type="hidden" name="studentName" value=<%= studentName %>>

      <b>Choose an assignment:</b><br>
      <select size="1" name="assignmentNo">
	<option selected value="-1">None</option>
        <%
        String rowTemplate = "<option value='&col_0;'>&col_0;, &col_1;</option>\n";
	try {
          Scan theScan = db.callFunction("assignmentInfo", new Tuple());
          out.println(jspamos.Utilities.resultToLayout(theScan, rowTemplate));
        } catch (Exception e) {
          out.println(e);
          e.printStackTrace();
        }
        %>
      </select>
      <br>
      <font color="red"><%= updateAssignment.getError("assignmentNo") %></font>
      <br><br>

      <b>Choose an assignment status:</b><br>
      <INPUT type="radio" name="assignmentStatus" value="UNKNOWN" checked> UNKNOWN<BR>
      <INPUT type="radio" name="assignmentStatus" value="PASSED"> PASSED<BR>
      <INPUT type="radio" name="assignmentStatus" value="FAILED"> FAILED<BR>
      <br><br>

      <b>Update the assignment status for:</b><br>
      <INPUT type="radio" name="applyTo" value="student">The selected student<BR>
      <INPUT type="radio" name="applyTo" value="group" checked>All students in the selected group<BR>
      <br>
      <br>
      <INPUT type="submit" value="Update assignment">
      <INPUT type="reset" value="Reset">
      <font color="red"><%= updateAssignment.getError("formError") %></font>
    </FORM>
 <br>
<%
}
%>
  </body>
</html>
