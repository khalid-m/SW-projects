<html>
  <head>
  <base target=_self></base>
    <title>Student Home</title>
    <script type="text/javascript" language="javascript">
    function aAssignmentStatus_onclick(studentName){
        var studentName = "dijin"; //need session
        if (studentName == '' || studentName == null){
        	alert("you should login first.");
			document.all.aindex.click();
            }
    	if (studentName!='' || studentName != null){
    		var myObject = new Object();
            myObject.studentName = studentName;
            var regSucc;
        	regSucc = window.showModalDialog('AssignmentStatus.jsp',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        	//window.showModalDialog('AssignmentStatus.jsp',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        	//window.location.href = "StudentHome.jsp";
        	//window.location = window.location.href;
        	document.location.href = 'StudentHome.jsp';
        	/*if (regSucc==true){
      		  document.all.aStudentHome.href='StudentHome.jsp';
      		  document.all.aStudentHome.click();
	      	  }
	      	  else if (regSucc!=true){
      		  document.all.aindex.href='index.jsp';
      		  document.all.aindex.click();
          	  }*/
        	}
        }
    
    function atodo_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('todo.html',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }
    </script>
  </head>

  <body>
  <jsp:include page="StudentMenu.jsp"/>
<h2>Student Home</h2>
    <ul>
      <li><a id="aindex" href="index.jsp">Main</a><br>
      <li><a id="aStudentHome" href="StudentHome.jsp">Student Home</a><br>
      <li><a id="aAssignmentStatus" href=""
		onclick="return aAssignmentStatus_onclick('');">View the status of your assignments.</a><br>
      <li><a id="aPersonalInfo" href="" onclick="return atodo_onclick();">View your personal information stored in the database.</a>
      <li><a id="aUpdateInfo" href="" onclick="return atodo_onclick();">Update your personal information.</a>
      <li><a id="aUpdateGroup" href="" onclick="return atodo_onclick();">Update your group membership.</a>
    </ul>
  </body>
</html>
