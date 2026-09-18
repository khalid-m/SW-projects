<html>
  <head>
    <title>List of students alone in a group or not in a group</title>
        <script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">

	function listLonelyStudent() {
		var url = "http://localhost:8080/axis/services/CMWSStudent";
		var qn_op = "listLonelyStudent";
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
		var soapRes = xmlDoc.getElementsByTagName("listLonelyStudentReturn")[0].childNodes[0].nodeValue;
		document.getElementById("oDivlistLonelyStudent").innerHTML = soapRes;
	}

	function close_onclick(){
		window.close();
		}
</script>
  </head>

  <body onload="return listLonelyStudent();">
    <h2>The students alone in a group or not in a group are:</h2>
    <div id="oDivlistLonelyStudent"></div>
    <input type="button" value="close" onclick="return close_onclick();"/>
  </body>
</html>
