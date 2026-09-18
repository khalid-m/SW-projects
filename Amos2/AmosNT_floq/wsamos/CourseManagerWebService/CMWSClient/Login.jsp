<html>
<head>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script  type="text/javascript" language="javascript">

	function validateUser(username,password) {
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "loginValidate";
		var pl = new SOAPClientParameters();
		pl.add("in0", username);
		pl.add("in1", password);
		pl.add("in2", "client.dmp");
		pl.add("in3", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, validateUser_callBack);
	}

	function validateUser_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("loginValidateReturn")[0].childNodes[0].nodeValue;
		if ("NONE"!=soapRes){
			alert("login successfully!");
		    //returnValue=document.getElementById("txt_usr").value;
		    returnValue=soapRes;
		    window.close();
			}
		else if("NONE"==soapRes){
			alert("Invalid username/password.");
			//returnValue=soapRes;
		   // window.close();
		   document.getElementById("txt_usr").value = "";
		   document.getElementById("txt_pwd").value = "";
			}
		else {
			returnValue=null;
		    window.close();
			}
	}

	function btnLogin_onclick() {
		var username = document.getElementById("txt_usr").value;
		var password = document.getElementById("txt_pwd").value;
		validateUser(username,password);
	}

</script>
</head>
<body>
<div>
<table width="100%" border="0" cellspacing="0">
          <tr>
            <td>Username:</td>
            <td><input type="text" name="userName" size="15" id="txt_usr"></td>
          </tr>
          <tr>
            <td>Password:</td>
            <td><input type="password" name="password" size="15" id="txt_pwd"></td>
          </tr>
           <tr>
            <td>&nbsp;</td>
            <td><input type="button" value="log in" name="login" onclick="return btnLogin_onclick();"></td>
          </tr>
</table>
</div>
If you do not already have an account, please register as a new user.
</body>
</html>