<html>
  <head>
    <title>Welcome to Course Manager</title>
    <script type="text/javascript" language="javascript">
    function aLogin_onclick(){
    	var userType;
    	userType = window.showModalDialog('Login.jsp',userType,'dialogWidth:300px; dialogHeight:200px; center:Yes; resizable: Yes; help: No;');
    	  if (userType=="STUDENT"){
    		  document.all.aLogin.href='StudentHome.jsp';
    		  document.all.aLogin.click();
    	  }
    	  else if (userType!="STUDENT"){
    		  if (userType=="ASSISTANT"){
        		  document.all.aLogin.href='AssistantHome.jsp';
        		  document.all.aLogin.click();
        	  }
        	  else if (userType!="ASSISTANT"){
					if (userType=="LECTURER"){
			    		  document.all.aLogin.href='LecturerHome.jsp';
			    		  document.all.aLogin.click();
			    	  }
			    	  else if (userType!="LECTURER"){
			    			  document.all.aLogin.href='index.jsp';
			        		  document.all.aLogin.click();
				    		  				    	  }
            	  }
        	  } 
        }

    function aRegisterStudent_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('RegisterStudent.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
    	  if (regSucc=="3"){
    		  document.all.aRegisterStudent.href='StudentHome.jsp';
    		  document.all.aRegisterStudent.click();
    	  }
    	  else if (regSucc!="3"){
    		  document.all.aRegisterStudent.href='index.jsp';
    		  document.all.aRegisterStudent.click();
        	  }
        }

    function aRegisterGroup_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('RegisterGroup.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
    	if ("true" == regSucc){
    		aListStudents_onclick();
  	  	}
    	else if ("true" != regSucc){
		  document.all.aRegisterGroup.href='index.jsp';
		  document.all.aRegisterGroup.click();
    	}
        }

    function aListStudents_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('ListStudents.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }

    function aListLonelyStudents_onclick(){
    	var regSucc;
    	regSucc = window.showModalDialog('ListLonelyStudents.jsp',regSucc,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
        }
    </script>
  </head>
  <body>
    <h2>Welcome to Course Manager</h2>
<hr>
<h3>From this page you can:</h3>
    <ul>
      <li><a id="aLogin" href="" onclick="return aLogin_onclick();">Login</a> to the system. <br>
      <li><a id="aRegisterStudent" href="" onclick="return aRegisterStudent_onclick();">Register as a new student</a><br>
      <li><a id="aRegisterGroup" href="" onclick="return aRegisterGroup_onclick();">Register a group of students</a><br>
      <li><a id="aListStudents" href="" onclick="return aListStudents_onclick();">List all students in the course</a><br>
      <li><a id="aListLonelyStudents" href="" onclick="return aListLonelyStudents_onclick();">List students alone in a group or not yet in a group</a>.
          These are your potential group partners.
    </ul>

    <hr>
    Powered by <a href="http://user.it.uu.se/~udbl/amos">Amos II</a><br>
    <hr>
  </body>
</html>
