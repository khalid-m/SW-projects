<hr>
<table border="0">
    <col width="60">
    <col width="60">
    <col width="100">
    <col width="180">
    <col width="100">
    <col width="20">
    <col width="100">
    <col width="20">
    <col width="200">
    <tr><td><a href="index.jsp">Main</a></td>
        <td><a href="AssistantHome.jsp">Home</a></td>
        <td><a href="SelectStudent.jsp">Select student</a></td>
        <td><a href="UpdateAssignment.jsp">Update assignment status</a></td>
        <td><a href="Query.jsp">AmosQL</a></td>
        <td></td>
        <td><a href="Logout.jsp">Logout</a></td>
        <td></td>
        <td>You are logged as: <b><%= (String) session.getAttribute("username") %></b></td>
</table>
<hr>
