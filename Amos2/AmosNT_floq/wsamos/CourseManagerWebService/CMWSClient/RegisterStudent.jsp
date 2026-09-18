<html>
<head>
<title>Course registration</title>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">

	function registerStudent(firstName,lastName,personalNumber,email,userName,password1) {
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "registerStudent";
		var pl = new SOAPClientParameters();
		pl.add("in0", firstName);
		pl.add("in1", lastName);
		pl.add("in2", userName);
		pl.add("in3", email);
		pl.add("in4", password1);
		pl.add("in5", personalNumber);
		pl.add("in6", "client.dmp");
		pl.add("in7", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, registerStudent_callBack);
	}

	function registerStudent_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("registerStudentReturn")[0].childNodes[0].nodeValue;
		if (soapRes==0){
			alert("User already exist!");
			document.getElementById("userName").value="";
			}
		else if(soapRes==2){
			alert("createStudent failed");
			reset_onclick();
			}
		else {
			alert("createStudent successful!");
			returnValue=soapRes;
		    window.close();
			}
	}

	function reset_onclick(){
		document.getElementById("firstName").value="";
		document.getElementById("lastName").value="";
		document.getElementById("personalNumber").value="";
		document.getElementById("email").value="";
		document.getElementById("userName").value="";
		document.getElementById("password1").value="";
		document.getElementById("password2").value="";
		}
		
				function btnClose_onclick(){
			window.close();
			}

	function register_onclick(){
		var fName = document.getElementById("firstName").value;
		var lName = document.getElementById("lastName").value;
		var pNumber = document.getElementById("personalNumber").value;
		var email = document.getElementById("email").value;
		var usrName = document.getElementById("userName").value;
		var pwd1 = document.getElementById("password1").value;
		var pwd2 = document.getElementById("password2").value;
		registerStudent(fName,lName,pNumber,email,usrName,pwd1);
		}
</script>
</head>

<body>
<h1>Course registration for students.</h1>
<br>
<p>Please enter the information necessary to manage and report yourresults.</p>
<br>

<table width="90%" border="1" cellspacing="0">
	<tr>
		<td>First name:</td>
		<td><input type="text" id="firstName" size="30"></td>
	</tr>
	<tr>
		<td>Last name:</td>
		<td><input type="text" id="lastName" size="30"></td>
	</tr>
	<tr>
		<td>Personal number:<br>Enter <b>'none'</b> if you don't have one.</td>
		<td><input type="text" id="personalNumber" size="10"></td>
	</tr>
	<tr>
		<td>E-mail:</td>
		<td><input type="text" id="email" size="50"></td>
	</tr>
	<tr>
		<td>UNIX user name (at least three charachters):<br></td>
		<td><input type="text" id="userName" size="15"></td>
	</tr>
	<tr>
		<td>Password (at least three charachters):<br>
		</td>
		<td><input type="password" id="password1" size="15"></td>
	</tr>
	<tr>
		<td>Confirm password:</td>
		<td><input type="password" id="password2" size="15"></td>
	</tr>
</table>
<input type="button" id="register" value="Register" onclick="return register_onclick();">
<input type="button" id="reset" value="Reset form" onclick="return btnReset_onclick();">
<input type="button" id="close" value="Close" onclick="return btnClose_onclick();">
<hr>
Back to<a href="index.jsp">home</a>.
<hr>
</body>
</html>
