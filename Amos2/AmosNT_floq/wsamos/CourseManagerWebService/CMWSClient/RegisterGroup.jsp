<html>
  <head>
    <title>Student group registration</title>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">

	function registerGroup(students,passwords) {
		alert(students+passwords);
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "registerGroup";
		var pl = new SOAPClientParameters();
		pl.add("in0", students);
		pl.add("in1", passwords);
		pl.add("in2", "client.dmp");
		pl.add("in3", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, registerGroup_callBack);
	}

	function registerGroup_callBack(o, soapResponse)
	{
		if(soapResponse.xml) {   // IE
			var soapResXML = soapResponse.xml;
			xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		    xmlDoc.async="false";
		    xmlDoc.loadXML(soapResXML);
		}
	    else{    // MOZ
		    var soapResXML = (new XMLSerializer()).serializeToString(soapResponse);
	    	parser=new DOMParser();
    		xmlDoc=parser.parseFromString(soapResXML,"text/xml");
	    }
		var soapRes = xmlDoc.getElementsByTagName("registerGroupReturn")[0].childNodes[0].nodeValue;
		alert(soapRes);
		if("true" == soapRes){
			alert("create Group successful!");
			returnValue=soapRes;
		    window.close();
			}
		else {
			alert("create group failed");
			reset_onclick();
			}
	}

	function btnReset_onclick(){
		document.getElementById("student1").value="";
		document.getElementById("password1").value="";
		document.getElementById("student2").value="";
		document.getElementById("password2").value="";
		document.getElementById("student3").value="";
		document.getElementById("password3").value="";
		}
		
		function btnClose_onclick(){
			window.close();
			}

	function registerGroup_onclick(){
		var student1 = document.getElementById("student1").value;
		var password1 = document.getElementById("password1").value;
		var student2 = document.getElementById("student2").value;
		var password2 = document.getElementById("password2").value;
		var student3 = document.getElementById("student3").value;
		var password3 = document.getElementById("password3").value;
		var students = new Array(student1,student2,student3);
		var passwords = new Array(password1,password2,password3);
		registerGroup(students,passwords);
		}
</script>
  </head>

  <body>
    <h1>Student group registration</h1>

    Group registration rules:
    <ul>
      <li>Minimum 1 student in a group.
      <li>Maximum 3 students in a groups.
      <li>Everyone is member of exactly one group.
      <li>In all other cases, please contact your assistant.
      <li>The students form the groups by themselves and do not 
	ask the course leader or the assistants to form groups.
    </ul>
    
    Please enter below the user name and password of all students in your
    group.
    <br><br><br>
      <table width="90%" border="0" cellspacing="0">
          <tr>
            <td>Student 1:</td>
            <td><input type="text" name="student1" size="15"></td>
            <td>Password 1:</td>
            <td><input type="password" name="password1" size="15"></td>
          </tr>
          <tr>
            <td>Student 2:</td>
            <td><input type="text" name="student2" size="15"></td>
            <td>Password 2:</td>
            <td><input type="password" name="password2" size="15"></td>
          </tr>
          <tr>
            <td>Student 3:</td>
            <td><input type="text" name="student3" size="15"></td>
            <td>Password 3:</td>
            <td><input type="password" name="password3" size="15"></td>
          </tr>
      </table>
      <br>
      <br>
      <input type="button" id="register_group" value="Register group" onclick="return registerGroup_onclick();">
      <input type="button" id="reset" value="Reset" onclick="return btnReset_onclick();">
      <input type="button" id="close" value="Close" onclick="return btnClose_onclick();">
    <hr>
    Back to <a href="index.jsp">home</a>.
    <hr>
  </body>
</html>
