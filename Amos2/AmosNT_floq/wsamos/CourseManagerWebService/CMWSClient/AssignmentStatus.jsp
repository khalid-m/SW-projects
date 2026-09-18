<html>
<head>
<title>Assignment status for user</title>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">
	var oMyObject = window.dialogArguments;
	
	function assignmentStatus_onload() {
		var studentName = oMyObject.studentName;
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "listAssignmentStatus";
		var pl = new SOAPClientParameters();
		pl.add("in0",studentName);
		pl.add("in1", "client.dmp");
		pl.add("in2", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, assignmentStatus_callBack);
	}

	function assignmentStatus_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listAssignmentStatusReturn")[0].childNodes[0].nodeValue;
		document.getElementById("oDivAssignmentStatus").innerHTML = soapRes;
	}

	function btnClose_onclick(){
		//window.dialogArguments.location = "StudentHome.jsp";
		window.returnValue = true;
		//window.opener.location.reload();
		window.close();
		 //window.opener.document.location.href = "StudentHome.jsp";
		}
</script>
</head>

<body onload="return assignmentStatus_onload();">
<h2>Assignment status for user</h2>
<div id="oDivAssignmentStatus"></div>
<br>
<br>
<hr>
<b>Notice:</b>
<br>
When the status of an assignment is "FAILED", this means that there are
some errors in the assignment and some parts have to be coorected.
<br>
Once you complete your assignment and it is acceptable, its status will
be changed to "PASSED".
<br>
You pass the course when all assignments are marked as "PASSED".
<br>
<INPUT type="button" value="close" onclick="return btnClose_onclick();">
</body>
</html>
