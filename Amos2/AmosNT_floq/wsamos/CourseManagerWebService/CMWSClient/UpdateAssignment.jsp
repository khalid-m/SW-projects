<html>
  <head>
    <title>Update assignment status</title>
    <script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">
var oMyObject = window.dialogArguments;

    function updateAssignment() {
        var studentName = oMyObject.selectedName;
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "updateAssignment";
		var pl = new SOAPClientParameters();
		pl.add("in0", studentName);
		pl.add("in1", "client.dmp");
		pl.add("in2", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, updateAssignment_callBack);
	}

	function updateAssignment_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("updateAssignmentReturn")[0].childNodes[0].nodeValue;
		var oDivSelection = document.getElementById("oDivUpdate");
		oDivSelection.innerHTML = soapRes;
	}

	function assignmentList() {
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "listAssignment";
		var pl = new SOAPClientParameters();
		pl.add("in0", "client.dmp");
		pl.add("in1", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, listAssignment_callBack);
	}

	function listAssignment_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("listAssignmentReturn")[0].childNodes[0].nodeValue;
		var oDivSelection = document.getElementById("oDivAssignment");
		oDivSelection.innerHTML = soapRes;
	}

	function doUpdate(assignmentStatus,applyTo){
		//alert(assignmentStatus);
		//alert(applyTo);
		var studentName = oMyObject.selectedName;
		var assignmentNo = document.getElementById("assignmentNo").value;
		//var assignmentStatus = document.getElementById("assignmentStatus").value;
		var assistantName = "assist"; //need session
		//var applyTo = document.getElementById("applyTo").value;
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "doUpdate";
		var pl = new SOAPClientParameters();
		pl.add("in0",studentName);
		pl.add("in1",assignmentNo);
		pl.add("in2",assignmentStatus);
		pl.add("in3",assistantName);
		pl.add("in4",applyTo);
		pl.add("in5", "client.dmp");
		pl.add("in6", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, doUpdate_callBack);
		}

	function doUpdate_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("doUpdateReturn")[0].childNodes[0].nodeValue;
		if ('true' == soapRes){
			alert("assignment update successful.");
			}else{
		    alert("assignment update failed.");
				}
	}

	function btnUpdate_onclick(){
		var assignmentStatus = radioAssignmentStatue();
		var applyTo = radioApplyTo();
		if (assignmentStatus == null){
			alert("please select a assignment status.");
			}else if (applyTo == null){
			alert("please select apply to.");
			}else{
			doUpdate(assignmentStatus,applyTo);
				}
		}

	function radioAssignmentStatue(){
		var allNodes=document.frmAssignment.assignmentStatus;
		for(var i=0; i<allNodes.length; i++){
			if(allNodes[i].checked){
				return(allNodes[i].value);
				}
			}
		return null;
		}

	function radioApplyTo(){
		var allNodes=document.frmApplyTo.applyTo;
		for(var i=0; i<allNodes.length; i++){
			if(allNodes[i].checked){
				return(allNodes[i].value);
				}
			}
		return null;
		}
			

	function btnClose_onclick(){
		window.close();
		}

	function window_onload(){
		updateAssignment();
		assignmentList();
		}
	</script>
  </head>
  <body onload="return window_onload();">
The student to be updated is:
<br>
<div id="oDivUpdate"></div>
<br>
<hr>
<b>Choose an assignment:</b><br>
<div id="oDivAssignment"></div>
<br>

      <b>Choose an assignment status:</b><br>
      <form name="frmAssignment">
      <INPUT type="radio" name="assignmentStatus" value="UNKNOWN"> UNKNOWN<BR>
      <INPUT type="radio" name="assignmentStatus" value="PASSED"> PASSED<BR>
      <INPUT type="radio" name="assignmentStatus" value="FAILED"> FAILED<BR>
      </form>
      <br><br>

      <b>Update the assignment status for:</b><br>
      <form name="frmApplyTo">
      <INPUT type="radio" name="applyTo" value="student">The selected student<BR>
      <INPUT type="radio" name="applyTo" value="group" >All students in the selected group<BR>
      </form>
      <br>
      <br>
      <INPUT type="button" value="Update assignment" onclick="return btnUpdate_onclick();">
      <INPUT type="button" value="Close" onclick="return btnClose_onclick();">
 <br>
  </body>
</html>
