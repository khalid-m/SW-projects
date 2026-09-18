<html>
<head>
<title>List of students</title>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">

	function listStudent() {
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "listStudent";
		var pl = new SOAPClientParameters();
		pl.add("in0", "client.dmp");
		pl.add("in1", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, listStudent_callBack);
	}

	function listStudent_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listStudentReturn")[0].childNodes[0].nodeValue;
		document.getElementById("oDivlistStudent").innerHTML = soapRes;
	}

	function close_onclick(){
		window.close();
		}
</script>
</head>

<body onload="return listStudent();">
<h2>The students currently registered for the course are:</h2>
<div id="oDivlistStudent"></div>
<input type="button" value="close" onclick="return close_onclick();" />
</body>
</html>
