<html>
  <head>
    <title>Lecturer Home</title>
    <script type="text/javascript" language="javascript">
    function aSelectStudent_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('SelectStudent.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
    	if (regSucc != 'none'){
        		aUpdateAssignment_onclick(regSucc);
        	  }
        }
    
    function aUpdateAssignment_onclick(studentName){
        if (studentName == "" || studentName == null){
        	alert("select a student first.");
			aSelectStudent_onclick()
            }
    	var regSucc;
    	if (studentName != ""){
    		var myObject = new Object();
            myObject.selectedName = studentName;
        	regSucc = window.showModalDialog('UpdateAssignment.jsp',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        	}
    	
        }

    function aListStudentsFull_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('ListStudentsFull.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }

    function atodo_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('todo.html',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }

    function aQuery_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('Query.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }
    </script>
  </head>

  <body>
    <jsp:include page="LecturerMenu.jsp"/>
    <h2>Lecturer Home</h2>

    <ul>
      	<li><a id="aindex" href="index.jsp">Main</a><br>
	<li><a id="aLecturerHome" href="LecturerHome.jsp">Lecturer Home</a><br>
	<li><a id="aSelectStudent" href=""
		onclick="return aSelectStudent_onclick();">Select student</a><br>
	<li><a id="aUpdateAssignment" href=""
		onclick="return aUpdateAssignment_onclick('');">Update the
	assignment status of students</a><br>
	<li><a id="aListStudentsFull" href=""
		onclick="return aListStudentsFull_onclick();">View the status of
	students</a><br>
	<li><a id="atodo" href="" onclick="return atodo_onclick();">Register
	a new assignment.</a><br>
	<li><a id="aQuery" href="" onclick="return aQuery_onclick();">Execute
	arbitrary AmosQL</a><br>
    </ul>
  </body>
</html>
