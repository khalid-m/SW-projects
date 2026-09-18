<html>
<head>
  <title>Query Amos via AmosQL</title>
      <script type="text/javascript" src="scripts/SOAPClient.js"></script>
<script type="text/javascript" language="javascript">

	function btnQuery_onclick() {
		var query = document.getElementById("txtQuery").value;
		var url = "http://localhost:8080/axis/services/CMWSAdmin";
		var qn_op = "excuteQuery";
		var pl = new SOAPClientParameters();
		pl.add("in0",query);
		pl.add("in1", "client.dmp");
		pl.add("in2", "CM");
		SOAPClient.invoke(url, qn_op, pl, true, excuteQuery_callBack);
	}

	function excuteQuery_callBack(o, soapResponse)
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
		var soapRes = xmlDoc.getElementsByTagName("excuteQueryReturn")[0].childNodes[0].nodeValue;
		document.getElementById("oDivQueryResult").innerHTML = soapRes;
	}

	function btnClose_onclick(){
		returnValue='true';
	    window.close();
		}
</script>
</head>
<body>
<h2>Query Amos2 via AmosQL</h2>
 
 <h3>Enter you query below:</h3>
<p>
    <textarea id="txtQuery" cols="80" rows="5"></textarea>
    </p>
    <p>
    <input id="btnQuery" type="button" value="Submit query" onclick="return btnQuery_onclick();">
    <br>
    <input id="btnClose" type="button" value="Close" onclick="return btnClose_onclick();">
    </p>
  <hr>

  <br>
  <b>The result of your query is :</b>
  <br>
  <div id="oDivQueryResult"></div>
  <br>
</body>
</html>
