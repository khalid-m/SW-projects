SOAPClient._paramToXml = function(method, parameters, ns, async, errorcallback){
    var xml = "";
    if (ns == "urn:WSAmos"){ //handle AmosSoapServer
        xml = SOAPClient._paramToXmlAmos(parameters, async, errorcallback);
    }else {  //handle normal web service
        xml = SOAPClient._paramToXmlNormal(method,SOAPClient._wsdl, parameters, "element",async,errorcallback);
    }
    return xml;
}

//Name: SOAPClient._paramToXml
//translate the AmosSoapServer operation parameters to soap envelope xml
//Param: _pl, parameter list as array in javascript
SOAPClient._paramToXmlAmos = function(_pl,async, errorcallback)
{
    var xml = "";
    for(var i = 0; i<_pl.length; i++){
        var soapParamType = null;
        //Array
        if (_pl[i].constructor.toString().indexOf("function Array()") > -1){
            soapParamType = "tns:VectorofanyType";
        }else{
            var paramType = typeof(_pl[i]);
            //number
            if (paramType == "number"){
                soapParamType = "xsd:int";
            }
            else {
                //other type
                soapParamType = "xsd:" + paramType;
            }
        }
        xml += "<member" + i + " xsi:type = '" + soapParamType + "'>" + SOAPClient._serializeParam(_pl[i]) + "</member" + i + ">";
    }
    return xml;
}

//Name: SOAPClientParameters._serialize
//provides XML serialization for SOAP request envelope
//Param: o, web service operation parameters
SOAPClient._serializeParam = function(o)
{
    var s = "";
    switch(typeof(o))
    {
        case "string":
            s += o.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");break;
        case "number":
        case "boolean":
            s += o.toString();break;
        case "object":
            // Date
            if(o.constructor.toString().indexOf("function Date()") > -1)
            {
                var year = o.getFullYear().toString();
                var month = (o.getMonth() + 1).toString();month = (month.length == 1) ? "0" + month : month;
                var date = o.getDate().toString();date = (date.length == 1) ? "0" + date : date;
                var hours = o.getHours().toString();hours = (hours.length == 1) ? "0" + hours : hours;
                var minutes = o.getMinutes().toString();minutes = (minutes.length == 1) ? "0" + minutes : minutes;
                var seconds = o.getSeconds().toString();seconds = (seconds.length == 1) ? "0" + seconds : seconds;
                var milliseconds = o.getMilliseconds().toString();
                var tzminutes = Math.abs(o.getTimezoneOffset());
                var tzhours = 0;
                while(tzminutes >= 60)
                {
                    tzhours++;
                    tzminutes -= 60;
                }
                tzminutes = (tzminutes.toString().length == 1) ? "0" + tzminutes.toString() : tzminutes.toString();
                tzhours = (tzhours.toString().length == 1) ? "0" + tzhours.toString() : tzhours.toString();
                var timezone = ((o.getTimezoneOffset() < 0) ? "+" : "-") + tzhours + ":" + tzminutes;
                s += year + "-" + month + "-" + date + "T" + hours + ":" + minutes + ":" + seconds + "." + milliseconds + timezone;
            }
            // Array
            else if(o.constructor.toString().indexOf("function Array()") > -1)
            {   
                
                s = SOAPClient._serializeArray(o);
                
            }
            break;
        default:
            throw new Error(500, "SOAPClientParameters: type '" + typeof(o) + "' is not supported");
    }
   
    return s;
}
//check the given value is an Integer
function is_int(value){ 
  if((parseFloat(value) == parseInt(value)) && !isNaN(value)){
      return true;
  } else { 
      return false;
  } 
}

SOAPClient._serializeArray = function(o){
    var ss="";
 
    for(var p in o)
                { 
                    if(!isNaN(p)) // linear array
                    {    
                        (/function\s+(\w*)\s*\(/i).exec(o[p].constructor.toString());
			
			alert(p);
                        var type = RegExp.$1;

                        switch(type)
                        {
                            case "":
                                type = typeof(o[p]);
                            case "String":
                                type = "string";break;
                            case "Number":
			          type = "int";break;
                            case "Boolean":
                                type = "bool";break;
                            case "Date":
                                type = "DateTime";break;
                            
                        }
                        ss += "<member xsi:type=\'xsd:" + type + "'>" + SOAPClient._serializeParam(o[p]) + "</member>"
                       
                    }
                    else // associative array
                        ss += "<member xsi:type = 'tns:VectorofanyType'>" + SOAPClient._serializeParam(o[p]) + "</member>"
                }

                return ss;
}

//Name: SOAPClientParameters._paramToXmlNormal
//translate the normal operation parameters to soap envelope xml
//Param: targetName, parameters name in the tag
//wsdl: wsdl document
//parameters: parameters send from each pages
//tagName: get the parameter names from different tagName
//SOAPClient._paramToXmlNormal(paramTns[1],wsdl,parameters[j],"complexType", async, errorcallback);
SOAPClient._paramToXmlNormal = function(targetName, wsdl, parameters, tagName, async, errorcallback)
{
    var xml = "";
    var r = SOAPClient._getElementByDiffTagName(wsdl,tagName);
    var ell = r[0];
    var useNamedItem = r[1];
    for(var i = 0; i < ell.length; i++)
    {
        if(useNamedItem)
        {
            if (ell[i].attributes.getNamedItem("name") != null){
                if(ell[i].attributes.getNamedItem("name").nodeValue == targetName){ //method element
                    var s = SOAPClient._getElementByDiffTagName(ell[i], "element");
                    var subElems = s[0];
                    //var subUseNamedItem = s[1];
                    var n_subElems = subElems.length;
                    var n_params = parameters.length;
                    //alert("n_subElems" + n_subElems + " ; " + "n_params" + n_params);
                    try{
                        if (n_subElems != n_params)
                        {
                            throw new Error("Line 143: Invalid input parameters, the parameter is not correct.");
                        }
                        for(var j = 0; j< n_subElems; j++){
                            if ( subElems[j].attributes.getNamedItem("type") != null){
                                var paramNames = subElems[j].attributes.getNamedItem("name").nodeValue;
                                var paramTypes = subElems[j].attributes.getNamedItem("type").nodeValue;
                                if(paramTypes.toLowerCase().indexOf("tns") != -1){
                                    var paramTns = paramTypes.split(":");
                                    var complexParamNames = SOAPClient._paramToXmlNormal(paramTns[1],wsdl,parameters[j],"complexType", async, errorcallback);
                                    if (complexParamNames == ""){
                                        complexParamNames = SOAPClient._paramToXmlSimpleType(paramTns[1],wsdl,parameters[j],"simpleType");
                                    }
                                    if (complexParamNames == null){
                                        xml = null;
                                    }else{
                                        xml += "<" + paramNames + ">" + complexParamNames + "</" + paramNames + ">";
                                    }
                                }
                                else{
                                    xml += "<" + paramNames + ">" + SOAPClient._serializeParam(parameters[j]) + "</" + paramNames + ">";
                                }
                            }
                        }
                    }
                    catch(e){
                        if(async){
                            errorcallback(e.message, 601);
                            xml = null;
                        }
                        else
                            return errorcallback(e.message, 601);
                    //alert(e.name+" "+e.message);
                    //return;
                    }
                }
            }
        }
        else{
            if (ell[i].attributes["name"] != null){
                if(ell[i].attributes["name"].value == targetName){ //method element
                    var s = SOAPClient._getElementByDiffTagName(ell[i], "element");
                    var subElems = s[0];
                    //var subUseNamedItem = s[1];
                    var n_subElems = subElems.length;
                    var n_params = parameters.length;
                    try{
                        if (n_subElems != n_params)
                        {
                            throw new Error("Line191: Invalid input parameters, the parameter is not correct.");
                        }
                    }
                    catch(e){
                        if(async){
                            errorcallback(e.message, 601);
                            xml = null;
                        }
                        else
                            return errorcallback(e.message, 601);
                    //alert(e.name+" "+e.message);
                    //return;
                    }
                    for(var j = 0; j< n_subElems; j++){
                        if ( subElems[j].attributes["type"] != null){
                            var paramNames = subElems[j].attributes["name"].value;
                            var paramTypes = subElems[j].attributes["type"].value;
                            if(paramTypes.toLowerCase().indexOf("tns") != -1)
                            {
                                var paramTns = paramTypes.split(":");
                                var complexParamNames = SOAPClient._paramToXmlNormal(paramTns[1],wsdl,parameters[j],"complexType",async,errorcallback);
                                if (complexParamNames == ""){
                                    complexParamNames = SOAPClient._paramToXmlSimpleType(paramTns[1],wsdl,parameters[j],"simpleType");
                                }
                                xml += "<" + paramNames + ">" + complexParamNames + "</" + paramNames + ">";
                            }
                            else{
                                xml += "<" + paramNames + ">" + SOAPClient._serializeParam(parameters[j]) + "</" + paramNames + ">";
                            }
                        }
                    }
                }
            }
        }
    }
    return xml;
}

SOAPClient._paramToXmlSimpleType = function (targetName, wsdl, parameters, tagName){ //simpleType, enumeration
    var xml = "";
    var r = SOAPClient._getElementByDiffTagName(wsdl, tagName);
    var ell = r[0];
    var useNamedItem = r[1];
    for(var i = 0; i < ell.length; i++)
    {
        if(useNamedItem)
        {
            if (ell[i].attributes.getNamedItem("name") != null){
                if(ell[i].attributes.getNamedItem("name").nodeValue == targetName){ //simpleType element
                    xml = parameters;
                }
            }
        }
        else{
            if (ell[i].attributes["name"] != null){
                if(ell[i].attributes["name"].value == targetName){ //simpleType element
                    xml = parameters;
                }
            }
        }
    }
    return xml;
}

/**
 * @description Sets the timeout for this service.
 * @public
 * @param value {number} milliseconds
 */
SOAPClient.set_timeout= function(time) {
    try{
        if (time < 0)
        {
            throw new Error("Timeout value is not correct. It must be a milliseconds time.");
        }
    }
    catch(e){
        alert(e.name+" "+e.message);
        return;
    }
    SOAPClient._delay = time;
}

/**
 * @description Returns the timeout in milliseconds for this service.
 * @private
 * @return SOAPClient._timeout {number} The timeout in milliseconds for the service.
 */
SOAPClient.get_timeout= function() {
    return SOAPClient._delay;
}

/**
 * @description class function which can only contain static methods in order to allow async calls
 * @public
 */
function SOAPClient (){
    this._error = null;
    this._timeout = null;
    this._delay = null;
    this._xmlhttp = null;
    this._wsdl = null;
    this.errorcallback = null;
    if(SOAPClient.get_timeout() != null){ //no user input timeout value
        this._delay = SOAPClient.get_timeout();//setup time out by default
    }
}

/**
 * @description invoke the web service call
 * @method invoke
 * @public
 * @static
 * @param method {String} web service's operation
 * @param parameters {array} web service's operations, must be in order
 * @param async {boolean} async call, true|false
 * @param callback {function} return the xmlHttp response to the callback function
 * @param errorcallback {function} return the error response to the errorcallback function
 * @return callback {function} successed function
 * @return errorcallback {function} faild function
 */
SOAPClient.invoke = function(method, parameters, async, callback, errorcallback)
{ 
    if(SOAPClient._delay == undefined){ //no user input timeout value
        SOAPClient._delay = 500000000000;//setup time out by default
    }
    //alert("_delay = " + SOAPClient._delay);
    try{
        if (arguments.length < 5 || arguments.length > 5)
        {
            throw new Error("Invalid input argument, SOAPClient.invoke method requires 5 arguments, but " + arguments.length + (arguments.length == 1 ? " was" : " were") + " specified.");
        }
    }
    catch(e){
        alert(e.name+" "+e.message);
        return;
    }
    SOAPClient.errorcallback = errorcallback;
    var xmlDoc = SOAPClient._getURL(async,errorcallback);
    try{
        var wsdl_url = xmlDoc.getElementsByTagName("wsdl-url")[0].childNodes[0].nodeValue;
        var url = xmlDoc.getElementsByTagName("ws-url")[0].firstChild.nodeValue;
    }
    catch(e){
        if(async)
            errorcallback("Line 336" + e.name + "url in the web.xml file not specified.", 602);
        else
            return errorcallback("Line 338" + e.name + "url in the web.xml file not specified.", 602);
    }
    if(wsdl_url!=null && url!=null){
        if(async)
            SOAPClient._loadWsdl(url, method, parameters, async, callback, errorcallback, wsdl_url);
        else
            return SOAPClient._loadWsdl(url, method, parameters, async, callback, errorcallback, wsdl_url);
    }
}

SOAPClient._getURL = function (async,errorcallback){
    var xmlDoc;
    try{
        if (window.ActiveXObject){
            xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
            xmlDoc.async=false;
            //xmlDoc.load("WEB-INF/web.xml");
	    //It is hardcoded here.Need to be changed.
	xmlDoc.load("http://localhost/WSMED/WSBench/web.xml");
        }else if (window.XMLHttpRequest){
            xmlDoc = SOAPClient._getLocalXml(async,"http://localhost/WSMED/WSBench/web.xml",errorcallback).responseXML;
        }
        return xmlDoc;
    }
    catch(e){
        if(async)
            errorcallback("Line 362" + e.name + " config file not found, web.xml file does not exist.", 602);
        else
            return errorcallback("Line 364" + e.name + " config file not found, web.xml file does not exist.", 602);
    //alert(e.name+" "+e.message);
    //return;
    }
}

SOAPClient._getLocalXml = function(async,file,errorcallback){
    try{
        var xmlhttp = SOAPClient._getXmlHttp(async,errorcallback);
        if (xmlhttp!=null){
	    //alert(file);
            xmlhttp.open("GET",file,false);
            xmlhttp.send(null);
        }
    }
    catch(e){
        if(async)
            errorcallback("Line 380" + e.name + "Get Local Xml failed.", 603);
        else
            return errorcallback("Line 382" + e.name + "Get Local Xml failed.", 603);
    }
    return xmlhttp;
}

/**
 * @description load the wsdl file's content
 * @method _loadWsdl
 * @private
 * @static
 * @param url {String} web service's deployed address
 * @param method {String} web service's operation
 * @param parameters {array} web service's operations, must be in order
 * @param async {boolean} async call, true|false
 * @param callback {function} return the xmlHttp response to the callback function
 * @param errorcallback {function} return the error response to the errorcallback function
 * @param wsdl_url {String} web service's wsdl file's address
 * @return callback {function} successed function
 * @return errorcallback {function} faild function
 */
SOAPClient._loadWsdl = function(url, method, parameters, async, callback, errorcallback, wsdl_url)
{
    
    // load from cache
    SOAPClient._wsdl = wsdl_cache[wsdl_url];
    if(SOAPClient._wsdl + "" != "" && SOAPClient._wsdl + "" != "undefined"){
    // get namespace
    var ns = (SOAPClient._wsdl.documentElement.attributes["targetNamespace"] + "" == "undefined") ? SOAPClient._wsdl.documentElement.attributes.getNamedItem("targetNamespace").nodeValue : SOAPClient._wsdl.documentElement.attributes["targetNamespace"].value;
    // build SOAP request
    var paramBody = SOAPClient._paramToXml(method, parameters, ns, async, errorcallback);
    if (paramBody == null){
        return;
    }
        return SOAPClient._sendSoapRequest(url, method, paramBody, ns, async, callback, errorcallback);
    }
    else{
    // get wsdl
    var xmlHttp = SOAPClient._getXmlHttp(async,errorcallback);
    SOAPClient._xmlhttp = xmlHttp;
    xmlHttp.open("GET", wsdl_url, async);
    if (SOAPClient._timeout == null) {
        SOAPClient._timeout = window.setTimeout(SOAPClient._getTimeoutError, SOAPClient._delay,wsdl_url);
    }
    if (async) {// async call
        xmlHttp.onreadystatechange = function()
        {
            if(xmlHttp.readyState == 4){
                SOAPClient._readWsdl(url, method, parameters, async, callback, errorcallback, xmlHttp,wsdl_url);
            }
        }
        xmlHttp.send(null);
    } else if (!async){// sync call
        xmlHttp.send(null);
        return SOAPClient._readWsdl(url, method, parameters, async, callback, errorcallback, xmlHttp);
    }
    }
}

//The method searches the cache for the same WSDL in order to avoid repetitive calls:
wsdl_cache = new Array();

SOAPClient._getTimeoutError = function (){
    //alert("440 SOAPClient._getTimeoutError");
    var xmlHttp = SOAPClient._xmlhttp;
    if (xmlHttp != null) {
        xmlHttp.onreadystatechange = function() {};
        xmlHttp.abort();
    }
    window.clearTimeout(SOAPClient._timeout);
    SOAPClient._xmlhttp = null;
    SOAPClient._timeout = null;
    SOAPClient.errorcallback("LIne 452: Timeout error, the server did not response in " + (SOAPClient._delay/1000) + " second.", 604);
}

/**
 * @description get the wsdl file's content
 * @method _readWsdl
 * @private
 * @static
 * @param url {String} web service's deployed address
 * @param method {String} web service's operation
 * @param parameters {array} web service's operations, must be in order
 * @param async {boolean} async call, true|false
 * @param callback {function} return the xmlHttp response to the callback function
 * @param errorcallback {function} return the error response to the errorcallback function
 * @param req {xmlhttp} web service's wsdl file's address
 * @return callback {function} successed function
 * @return errorcallback {function} faild function
 */
SOAPClient._readWsdl = function(url, method, parameters, async, callback, errorcallback, req,wsdl_url)
{
    try {
        var httpstatus = req.status;
        var httpstatusText = req.statusText;
        if (httpstatus != null){
            window.clearTimeout(SOAPClient._timeout);
            SOAPClient._timeout = null;
            SOAPClient._xmlhttp = null;
        }
        if (httpstatus == 200 || httpstatus == 202) {
            SOAPClient._wsdl = req.responseXML;
            wsdl_cache[wsdl_url] = SOAPClient._wsdl;
            // get namespace
        var ns = (SOAPClient._wsdl.documentElement.attributes["targetNamespace"] + "" == "undefined") ? SOAPClient._wsdl.documentElement.attributes.getNamedItem("targetNamespace").nodeValue : SOAPClient._wsdl.documentElement.attributes["targetNamespace"].value;
        // build SOAP request
        var paramBody = SOAPClient._paramToXml(method, parameters, ns, async, errorcallback);
        if (paramBody == null){ 
           return;
        }
            return SOAPClient._sendSoapRequest(url, method, paramBody, ns, async, callback, errorcallback);
        }else{
            throw new Error("Line 492: HTTP " + httpstatus + " , " + httpstatusText +  "\n Server connection has failed.");
        }
    }catch (e) {
        return errorcallback(e.message,httpstatus);
    //alert(e.name+" "+e.message);
    //return;
    }
}

//Name: SOAPClient._sendSoapRequest
//Send xmlHttp request, add the soap envelope as the request content
//Param: url, web service's endpoint
//Param: method, web service's operation
//Param: parameters, web service's operations, must be in order
//Param: async, true|false
//Param: callback, return the xmlHttp response to the callback function
SOAPClient._sendSoapRequest = function(url, method, paramBody, ns, async, callback, errorcallback)
{
    var sr =
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
    "<soap:Envelope " +
    "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
    "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
    "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">" +
    "<soap:Body>" +
    "<" + method + " xmlns=\"" + ns + "\">" +
    paramBody +
    //SOAPClient._paramToXml(method, parameters, wsdl, ns, async, errorcallback) +
    "</" + method + "></soap:Body></soap:Envelope>";
    //alert(sr);
    // send request
    var xmlHttp = SOAPClient._getXmlHttp(async,errorcallback);
    SOAPClient._xmlhttp = xmlHttp;
    xmlHttp.open("POST", url, async);
    if (SOAPClient._timeout == null) {
        SOAPClient._timeout = window.setTimeout(SOAPClient._getTimeoutError, SOAPClient._delay);
    }
    var soapaction = ((ns.lastIndexOf("/") != ns.length - 1) ? ns + "/" : ns) + method;
    xmlHttp.setRequestHeader("SOAPAction", soapaction);
    xmlHttp.setRequestHeader("Content-Type", "text/xml; charset=utf-8");
    if (async) {// async call
        xmlHttp.onreadystatechange = function()
        {
            if(xmlHttp.readyState == 4){
                SOAPClient._getSoapResponse(method, async, callback, errorcallback, xmlHttp);
            }
        }
        xmlHttp.send(sr);
    } else if (!async){// sync call
        xmlHttp.send(sr);
        return SOAPClient._getSoapResponse(method, async, callback, errorcallback, xmlHttp);
    }
}

//Name:SOAPClient._getSoapResponse
//receiving the web service's response
//Param: method, web service's operation
//Param: async, true|false
//Param: callback, return the xmlHttp response to the callback function
//Param: req, xmlHttp request
SOAPClient._getSoapResponse = function(method, async, callback, errorcallback, req)
{
    var httpstatus = req.status;
    var httpstatusText = req.statusText;
    try {
        if (httpstatus != null){
            window.clearTimeout(SOAPClient._timeout);
            SOAPClient._timeout = null;
            SOAPClient._xmlhttp = null;
        }
        if (httpstatus != 200 && httpstatus != 202 && httpstatus != 500) {
            throw new Error("Line 563: HTTP " + httpstatus + " , " + httpstatusText +  "\n Server connection has failed.");
        }
    }catch (e) {
        if(async)
            errorcallback(e.message,httpstatus);
        else
            return errorcallback(e.message,httpstatus);
        //alert(e.message,httpstatus);
        return;
    }

    var o = null;
   
    //var nd = SOAPClient._getElementsByTagName(req.responseXML, "tns:results", async, errorcallback); //AmosSoapServer soap response type
      var nd = SOAPClient._getElementsByTagName(req.responseXML, req.responseXML.firstChild.firstChild.firstChild.nodeName, async, errorcallback); 
    //AmosSoapServer soap response type
    if (nd.length == 0){
        nd = SOAPClient._getElementsByTagName(req.responseXML, method + "Result", async, errorcallback); //try normal soap response type
    }
    if(nd.length == 0)
    {
        if(req.responseXML.getElementsByTagName("faultcode").length > 0){
            try{
                var faultCode = req.responseXML.getElementsByTagName("faultcode")[0].childNodes[0].nodeValue;
                var faultString = req.responseXML.getElementsByTagName("faultstring")[0].childNodes[0].nodeValue;
                if(req.responseXML.getElementsByTagName("detail")[0] != null){
                    if (req.responseXML.getElementsByTagName("detail")[0].hasChildNodes()){
                        var detail = req.responseXML.getElementsByTagName("detail")[0].childNodes[0].childNodes[0].nodeValue;
                    }
                }
                throw new Error(500, "Line 590: faultcode: " + faultCode + "\n"+ "faultstring: " + faultString+ "\n"+ "detail: " + detail);
            }
            catch (e) {
                if(async)
                    errorcallback(e.message,500);
                else
                    return errorcallback(e.message,500);
            //alert("Internal server error \n" + e.name+" "+e.message);
            }
        }
    }else{
        //var response = req.responseXML;
        //alert(response.xml);
        o = SOAPClient._soapresult2object(nd[0]);
    //alert(o.toString());
    }
    if(async)
        SOAPClient._generateCallback(o, req.responseXML, async, callback, errorcallback);
    if(!async)
        return SOAPClient._generateCallback(o, req.responseXML, async, callback, errorcallback);
}

SOAPClient._soapresult2object = function(node){
    var wsdlTypes = SOAPClient._getTypesFromWsdl(); //wsdlTypes[resultName]=resultType;
    return SOAPClient._nodeRow2object(node, wsdlTypes);
}

SOAPClient._nodeRow2object = function(node, wsdlTypes){
    if(node.childNodes[0] == null) return null;
    if (node.childNodes[0].tagName == "tns:row"){ //AmosSoapServer, return tns:row element
        var n_rowNode = node.childNodes.length;
        if (n_rowNode>1){
            var resultArray = new Array();
            for (var i = 0; i < n_rowNode; i++){
                resultArray[i] = SOAPClient._row2RESULTNAME(node.childNodes[i],wsdlTypes); //tns:row node, especially for amos multi result
            }
            return resultArray;
        }else{
            return SOAPClient._row2RESULTNAME(node.childNodes[0],wsdlTypes);//tns:row node, especially for amos single result
        }
    }else{
        return SOAPClient._row2RESULTNAME(node,wsdlTypes);
    }
}

SOAPClient._row2RESULTNAME = function(node,wsdlTypes){
    if (node.nodeName == "tns:row"){
        var n_subNode = node.childNodes.length;
        if (n_subNode>1){
            var resultArray = new Array();
            for (var i = 0; i < n_subNode; i++){
                resultArray[i] = SOAPClient._node2object(node.childNodes[i],wsdlTypes); //RESULTNAME node
            }
            return resultArray;
        }else{
            return SOAPClient._node2object(node.childNodes[0],wsdlTypes);
        }
    }else {
        return SOAPClient._node2object(node,wsdlTypes);
    }
}

SOAPClient._node2object = function(node, wsdlTypes){ //RESULTNAME node
    // null node
    if(node == null)
        return null;
    // text node
    if(node.nodeType == 3 || node.nodeType == 4)
        return SOAPClient._extractValue(node, wsdlTypes);
    //array node
    var isarray = SOAPClient._getTypeFromWsdl(node.nodeName, wsdlTypes).toLowerCase().indexOf("arrayof") != -1;
    if (isarray){
        return SOAPClient._handlArray(node, wsdlTypes);
    }
    //leaf node
    if (node.hasChildNodes()){
        if (node.childNodes[0].hasChildNodes()){ //response soap envelope including vector
            //alert(node.childNodes[0].tagName);
            return SOAPClient._handleVector(node,wsdlTypes);
        }
        else{ //response soap envelope not including vector
            return SOAPClient._node2object(node.childNodes[0], wsdlTypes);
        }
    }
    else return null;
}

//array element
SOAPClient._handlArray = function (node, wsdlTypes){
    var l = new Array();
    for(var i = 0; i < node.childNodes.length; i++)
        l[l.length] = SOAPClient._node2object(node.childNodes[i], wsdlTypes);
    return l;
}

//vector element
SOAPClient._handleVector = function (node, wsdlTypes){ //deal with vector type tns:member
    var n_elems = node.childNodes.length;
    var vectorArray = new Array();
    for (var i=0; i<n_elems; i++){
        //alert(node.childNodes[i].tagName);
        if (node.childNodes[i].hasChildNodes()){ //response soap envelope including vector
            vectorArray[i] = SOAPClient._node2object(node.childNodes[i], wsdlTypes);
        }
        else{ //response soap envelope not including vector
            var resultValue = node.childNodes[i].nodeValue;
            var resultType = node.getAttribute("xsi:type");
            vectorArray[i] = SOAPClient._extractVectorType(resultValue,resultType);
        }
    }
    return vectorArray;
}

//extract datatype from wsdl file, normal server and AmosSoapServer
SOAPClient._extractValue = function(node, wsdlTypes)
{
    var value = node.nodeValue;
    if (node.parentNode.nodeName == "tns:member"){
        var nodeType = node.parentNode.getAttribute("xsi:type");
        return SOAPClient._extractVectorType(value, nodeType);
    }
    switch(SOAPClient._getTypeFromWsdl(node.parentNode.nodeName, wsdlTypes).toLowerCase())
    {
        default:
        case "string":
            return (value != null) ? value + "" : "";
        case "boolean":
            return value + "" == "true";
        case "int":
        case "long":
            return (value != null) ? parseInt(value + "", 10) : 0;
        case "double":
            return (value != null) ? parseFloat(value + "") : 0;
        case "datetime":
            if(value == null)
                return null;
            else
            {
                value = value + "";
                value = value.substring(0, (value.lastIndexOf(".") == -1 ? value.length : value.lastIndexOf(".")));
                value = value.replace(/T/gi," ");
                value = value.replace(/-/gi,"/");
                var d = new Date();
                d.setTime(Date.parse(value));
                return d;
            }
    }
}

//extract datatype from soap response, AmosSoapServer
SOAPClient._extractVectorType = function(nodeValue, nodeType){ //RESULTNAME node
    switch(nodeType)
    {
        default:
        case "xsd:string":
            return (nodeValue != null) ? nodeValue + "" : "";
        case "xsd:boolean":
            return nodeValue + "" == "true";
        case "xsd:int":
        case "xsd:long":
            return (nodeValue != null) ? parseInt(nodeValue + "", 10) : 0;
        case "xsd:double":
            return (nodeValue != null) ? parseFloat(nodeValue + "") : 0;
        case "xsd:datetime":
            if(nodeValue == null)
                return null;
            else
            {
                nodeValue = nodeValue + "";
                nodeValue = nodeValue.substring(0, (nodeValue.lastIndexOf(".") == -1 ? nodeValue.length : nodeValue.lastIndexOf(".")));
                nodeValue = nodeValue.replace(/T/gi," ");
                nodeValue = nodeValue.replace(/-/gi,"/");
                var d = new Date();
                d.setTime(Date.parse(nodeValue));
                return d;
            }
    }
}

SOAPClient._getTypesFromWsdl = function()
{
    var wsdlTypes = new Array();
    var r = SOAPClient._getElementByDiffTagName(SOAPClient._wsdl,"element");
    var ell = r[0];
    var useNamedItem = r[1];
    for(var i = 0; i < ell.length; i++)
    {
        if(useNamedItem)
        {
            if(ell[i].attributes.getNamedItem("name") != null && ell[i].attributes.getNamedItem("type") != null){
                wsdlTypes[ell[i].attributes.getNamedItem("name").nodeValue] = ell[i].attributes.getNamedItem("type").nodeValue;
            }
        }
        else{
            if(ell[i].attributes["name"] != null && ell[i].attributes["type"] != null){
                wsdlTypes[ell[i].attributes["name"].value] = ell[i].attributes["type"].value;
            }
        }
    }
    //alert(wsdlTypes["Lon"].toString());
    return wsdlTypes;
}

SOAPClient._getElementByDiffTagName = function(wsdl, tagName){
    var ell = wsdl.getElementsByTagName("xsd:" + tagName);
    var useNamedItem = true;
    if(ell.length == 0)
    {
        ell = wsdl.getElementsByTagName("s:" + tagName);
        useNamedItem = true;
    }
    if(ell.length == 0)
    {
        ell = wsdl.getElementsByTagName("xs:" + tagName);
        useNamedItem = true;
    }
    if(ell.length == 0)
    {
        ell = wsdl.getElementsByTagName(tagName);
        useNamedItem = false;
    }
    return [ell,useNamedItem];
}

SOAPClient._getTypeFromWsdl = function(elementname, wsdlTypes)
{
    var typeOriginal = wsdlTypes[elementname] + ""; //original type name, normal cases could be s:type or xsd:type(in AmosSoapServer)
    var type = typeOriginal.split(":");
    return (typeOriginal == "undefined") ? "" : type[1];
}

//Name: SOAPClient._generateCallback
//generate the response into a xml document
//Param: o, Error object
//Param: soapResponse, xmlHttp soapResponse
//Param: async, true|false
//Param: callback fucntion
SOAPClient._generateCallback = function (o, soapResponse, async, callback, errorcallback){
    var xmlDoc = null;
    try //Internet Explorer
    {
        var soapResXML = soapResponse.xml;
        xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async="false";
        xmlDoc.loadXML(soapResXML);
    }
    catch(e)
    {
        try //Firefox, Mozilla, Opera, etc.
        {
            var soapResXML = (new XMLSerializer()).serializeToString(soapResponse);
            parser=new DOMParser();
            xmlDoc=parser.parseFromString(soapResXML,"text/xml");
        }
        catch(e)
        {
            try //Google Chrome
            {
                xmlDoc = soapResponse.documentElement;
            }
            catch (e) {
                if(async)
                    errorcallback(e.name + "Line 852: Your browser does not support DOM objects",605);
                else
                    return errorcallback(e.name + "Line 854: Your browser does not support DOM objects",605);
            //alert("Internal server error \n" + e.name+" "+e.message);
            }
        }
    }

    if(async)
        callback(o, xmlDoc);
    if(!async)
        return callback(o, xmlDoc);
}

//Name: SOAPClient._getElementsByTagName
//optimizes XPath queries according to the available XML parser
//Param: document, xmlHttp response
//Param: tagName, operations's result tagname
SOAPClient._getElementsByTagName = function(document, tagName, async, errorcallback)
{  
   
     var browser = SOAPClient._getBrowser();
    switch (browser) {
        case "ie":
        case "firefox":
            var newTagName = tagName; //tns:row
            break;
        case "chrome":
        case "opera":
        case "safari":
        case "gecko":
            var tagName2 = tagName.split(":");
            var newTagName = tagName2[1];
            break;
    }
    try
    {
        //latest versions of MSXML.XMLDocument
        return document.selectNodes(".//*[local-name()=\""+ newTagName +"\"]");
    }
    catch (e) {
    //if(async)
    //    errorcallback(e.name + "Your browser does not support XmlHttp objects",null);
    //else
    //    return errorcallback(e.name + "Your browser does not support XmlHttp objects",null);
    }
    //old XML parser support
    return document.getElementsByTagName(newTagName);
}

//Name: SOAPClient._getXmlHttp
//A factory function returns the XMLHttpRequest according to browser type
SOAPClient._getXmlHttp = function(async,errorcallback)
{
    try
    {
        if(window.XMLHttpRequest)
        {
            var req = new XMLHttpRequest();
            if(req.readyState == null)
            {
                req.readyState = 1;
                req.addEventListener("load",
                    function()
                    {
                        req.readyState = 4;
                        if(typeof req.onreadystatechange == "function")
                            req.onreadystatechange();
                    },
                    false);
            }
            return req;
        }
        if(window.ActiveXObject)
            return new ActiveXObject(SOAPClient._getXmlHttpProgID(async,errorcallback));
    }
    catch (e) {
        if(async)
            errorcallback(e.name + "Line 929: Your browser does not support XmlHttp objects",605);
        else
            return errorcallback(e.name + "Line 931: Your browser does not support XmlHttp objects",605);
    }
}

//Name: SOAPClient._getXmlHttpProgID
//give the ActiveXObject a correct ProgID
SOAPClient._getXmlHttpProgID = function(async,errorcallback)
{
    if(SOAPClient._getXmlHttpProgID.progid)
        return SOAPClient._getXmlHttpProgID.progid;
    var progids = ["Msxml2.XMLHTTP.5.0", "Msxml2.XMLHTTP.4.0", "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP", "Microsoft.XMLHTTP"];
    var o;
    for(var i = 0; i < progids.length; i++)
    {
        try
        {
            o = new ActiveXObject(progids[i]);
            return SOAPClient._getXmlHttpProgID.progid = progids[i];
        }
        catch (e) {
            if(async)
                errorcallback(e.name + "Line 952: Could not find an installed XML parser",605);
            else
                return errorcallback(e.name + "Line 954: Could not find an installed XML parser",605);
        }
    }
}

SOAPClient._getBrowser = function(){
    var ua = navigator.userAgent.toLowerCase();
    if (ua.indexOf('opera') != -1) { // Opera (check first in case of spoof)
        return 'opera';
    } else if (ua.indexOf('msie') != -1) { // IE
        return 'ie';
    } else if (ua.indexOf('chrome') != -1) { // chrome (including safari)
        return 'chrome';
    } else if (ua.indexOf('safari') != -1) { // Safari (check before Gecko because it includes "like Gecko")
        return 'safari';
    } else if (ua.indexOf('firefox') != -1) { // firefox
        return 'firefox';
    } else {
        return false;
    }
}
