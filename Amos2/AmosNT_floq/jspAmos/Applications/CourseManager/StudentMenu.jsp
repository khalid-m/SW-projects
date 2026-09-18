  <hr>
  <table border="0">
    <col width="50">
    <col width="50">
    <col width="150">
    <col width="20">
    <col width="100">
    <col width="20">
    <col width="200">
    <tr><td><a href="index.jsp">Main</a></td>
        <td><a href="StudentHome.jsp">Home</a></td>
        <td><a href="AssignmentStatus.jsp">Assignment status</a></td>
        <td></td>
        <td><a href="Logout.jsp">Logout</a></td>
        <td></td>
        <td>You are logged as: <b><%= (String) session.getAttribute("username") %></b></td>
  </table>
  <hr>
