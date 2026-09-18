<html>
<head>
<title>Update assignment status</title>
<script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">
var studentName = '';
function selectStudent_onclick(){
	var selectedName='';
	var pnName = document.getElementById("pn").value;
	var fName = document.getElementById("fullName").value;
	var emailName = document.getElementById("email").value;
    if ( pnName != "") {
    	selectedName = pnName;
    } else if (fName != "") {
    	selectedName = fName;
    } else if (emailName != "") {
	    selectedName = emailName;
    } else {
        alert("Please select a student from the list above.");
        }
    var url = "http://localhost:8080/axis/services/CMWSAdmin";
	var qn_op = "getSelectedStudent";
	var pl = new SOAPClientParameters();
	pl.add("in0",selectedName);
	pl.add("in1", "client.dmp");
	pl.add("in2", "CM");
	SOAPClient.invoke(url, qn_op, pl, true, selectStudent_callBack);
	studentName=selectedName;
}

function selectStudent_callBack(o, soapResponse)
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
	var soapRes = xmlDoc.getElementsByTagName("getSelectedStudentReturn")[0].childNodes[0].nodeValue;
	document.getElementById("oDivSelectedStudent").innerHTML = soapRes;
}

//list stuent by p-number
	function listByPNumber() {
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "listByPNumber";
		var pl = new SOAPClientParameters();
		pl.add("in0", "client.dmp");
		pl.add("in1", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, listByPNumber_callBack);
	}

	function listByPNumber_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listByPNumberReturn")[0].childNodes[0].nodeValue;
		var oDivSelection = document.getElementById("oDivPn");
		oDivSelection.innerHTML = soapRes;
	}

	//list student by full name
	function listByFullName() {
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "listByFullName";
		var pl = new SOAPClientParameters();
		pl.add("in0", "client.dmp");
		pl.add("in1", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, listByFullName_callBack);
	}

	function listByFullName_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listByFullNameReturn")[0].childNodes[0].nodeValue;
		var oDivSelection = document.getElementById("oDivFullName");
		oDivSelection.innerHTML = soapRes;
	}

	//list student by email
	function listByEmail() {
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "listByEmail";
		var pl = new SOAPClientParameters();
		pl.add("in0", "client.dmp");
		pl.add("in1", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, listByEmail_callBack);
	}

	function listByEmail_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listByEmailReturn")[0].childNodes[0].nodeValue;
		var oDivSelection = document.getElementById("oDivEmail");
		oDivSelection.innerHTML = soapRes;
	}
	
	function update_onclick(){
		if (studentName == '' || studentName == null){
			alert("Choose a student first.");
			}else {
				returnValue=studentName;
			    window.close();
				}
		}

	function btnClose_onclick(){
		returnValue = 'none';
	    window.close();
		}

	function studentOptList(){
		listByPNumber();
		listByFullName();
		listByEmail();
		}
</script>
</head>
<body onload="return studentOptList();">
Select a student by ONE of the parameters below.
<br>
<br>
Students listed by Personal Number:
<br>
<div id="oDivPn"></div>
<br>
<br>

Students listed by Full Name:
<br>
<div id="oDivFullName"></div>
<br>
<br>

Students listed by E-Mail:
<br>
<div id="oDivEmail"></div>
<br>
<INPUT type="button" value="Select student" onclick="return selectStudent_onclick();">
<INPUT type="button" value="update" onclick="return update_onclick();">
<INPUT type="button" value="close" onclick="return btnClose_onclick();">
<br>
<br>
<div id="oDivSelectedStudent"></div>
</body>
</html>
