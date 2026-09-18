 userId=0;
 userName="";
 wsdli=5;
 exapp=0;
 reqA=new Array();
 reqAind=-1;
 enterA=new Array();
 enterAind=-1;
//url="http://130.238.11.96:8082/wsmos/service/AmosServlet";
//url="http://udbl2.it.uu.se/wsqs/"
url="/wsmos/service/AmosServlet"
function getUSERID() {
 alert("USERID >> P"+userId);
}

function enterUSER() {
      exapp=1;
      var valIn= document.getElementById('userName');
      userName= trimStr(valIn.value);
       if(userName == "")
       {
        alert("Need a User Name !");
        return;
        }
    
      // creating the WSRequest
    var req = new WSRequest();
   
    if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
    }
 
    // request options
    var reqOptions = { useSOAP : 1.1 };
    
    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
   
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
     
        if(req.readyState == 4) {
            if(req.error == null) {
                // here is some use of DOM to retrive values of posts
                  htmlStr = "";
	          userId = req.responseXML.firstChild.firstChild.nodeValue;
               
               
                // filling the html string
                htmlStr += "<h2>" + "UserID for  "+ userName +" "+userId+"</h2>";
                htmlStr += "<p>";
               
		var resultBox = document.getElementById('resultBox');
                resultBox.innerHTML = htmlStr;
            }
            else {
                 if ( req.responseXML!=null){
		   childNodes = req.responseXML.firstChild.childNodes;
		   alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
		 }
                 else
                  alert("WSMED service may went down ");
            }
            // clear the message
            document.getElementById('message').innerHTML = "";
            document.getElementById('WSDLURI').style.visibility='visible';
            document.getElementById('NEWWSDLURI').style.visibility='visible';
            document.getElementById('Exitapp').style.visibility='visible';
            document.getElementById('WSBench').style.visibility='visible';
            document.getElementById('user').style.visibility='hidden';
        }
    };
 
    // creating the request xml 
      var message= '<tns:INIT xmlns:tns="urn:WSAmos"/>';
 
    req.send(message);
 
    document.getElementById('message').innerHTML = "Registering the USER ..";
    
}

function importWSDL() {

       
      var resultBox = document.getElementById('resultBox');
      resultBox.innerHTML = "";
       document.getElementById('message3').innerHTML = "";
      //var dl= document.getElementById('DLU');
      //var w = dl.selectedIndex;
      var wsdlURI= trimStr(document.getElementById('newWSDL').value);
         
      // creating the WSRequest
     var req = new WSRequest();
 
     if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
      }
 
    // request options
    var reqOptions = { useSOAP : 1.1 };
  
    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
 
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
   
        if(req.readyState == 4) {
            if(req.error == null) {
	      // here is some use of DOM to retrive values of posts
	     
	      childNodes = req.responseXML.firstChild.childNodes;
               
	      var htmlStr ="<h3> Available Views : </h3>"+ "<p>"+"<h2>View:         Authentication  | Web Service</h2>"+ "<p>"+"<hr/>";
		      
	      for(j = 0; j < childNodes.length; j ++) {
		
		var post = childNodes[j].firstChild.firstChild.nodeValue.split(",");
                  
		// first the operation name, then service name
		var opname = post[0];
		var au = post[1];
		var sname = post[2];
		var existwsdl= post[3];
		if (existwsdl=='false'){
		  AddItem("DLT",opname,opname);
		  if (au=='required'){
		    reqAind=reqAind+1;
		    reqA[reqAind]=opname;
                           
		  }
		}

		// filling the html string
		htmlStr += opname+" : "+au+"   |   "+sname;
		htmlStr += "<p>";
		htmlStr += "<hr/>";
	      }
 
                 
	      resultBox = document.getElementById('resultBox');
	      resultBox.innerHTML = htmlStr;
            }
            else {
                  if ( req.responseXML!=null){
                childNodes = req.responseXML.firstChild.childNodes;
	         alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
                  }
                 else
                  alert("WSMED service may went down ");
            }
            // clear the message
             document.getElementById('message1').innerHTML = "";
	    document.getElementById('newWSDL').value="";
	     
        }
    }; 
    
    // creating the request xml 
var message='<tns:IMPORTWSDL xmlns:tns="urn:WSAmos"><USERID xsi:type="xsd:int">'+userId+'</USERID><WSDLURI xsi:type="xsd:string">'+wsdlURI+'</WSDLURI></tns:IMPORTWSDL>';

    req.send(message);
 
    document.getElementById('message1').innerHTML = "Importing the WSDL URI ..";
    
   document.getElementById('Table').style.visibility='visible';
       document.getElementById('Query').style.visibility='visible';
       document.getElementById('resultBox').style.visibility='visible';
    //findServices();
}

function availableTables() {

      var resultBox = document.getElementById('resultBox');
      resultBox.innerHTML = "";
      document.getElementById('message3').innerHTML = "";
      var dl= document.getElementById('DLT');
      var w = dl.selectedIndex;
      var tname=trimStr(dl.options[w].text);
     
     
      // creating the WSRequest
     var req = new WSRequest();
 
     if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
      }
    
 
    // request options
    var reqOptions = { useSOAP : 1.1 };
  
    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
 
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
   
        if(req.readyState == 4) {
	  if(req.error == null) {
	    // here is some use of DOM to retrive values of posts
	     
	    
 
	    var htmlStr ="<h4>View Name  :   Authentication  |  Web Service</h4>"+ "<p>"+"<hr/>";
	                
	    var post = req.responseXML.firstChild.firstChild.nodeValue.split(";");
	   
	    var au = post[0];
	    var sname = post[1];
                   
	    var tin= post[2];
	    var tout= post[3];	
		    

	    // filling the html string
	    htmlStr += "<h2>"+tname+"  :  "+au+"  |   "+sname+"</h2><p>";
	    htmlStr +="<h3>View Input >> </h3>"+"<p>";
	    htmlStr += arrangeStr(tin)+"<p>";
	    htmlStr +="<h3>View Output >> </h3>"+"<p>";
	    htmlStr +=arrangeStr(tout)+"<p>";
	    htmlStr += "<hr/>";
                   
                
 
                 
	    resultBox = document.getElementById('resultBox');
	    resultBox.innerHTML = htmlStr;
	  }
	  else {
	    if ( req.responseXML!=null){
	      childNodes = req.responseXML.firstChild.childNodes;
	      alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
	    }
	    else
	      alert("WSMED service may went down ");
	  }
	  // clear the message
	  document.getElementById('message1').innerHTML = "";
	     
        }
    }; 
 
    // creating the request xml 
var message='<tns:TABLEINFO xmlns:tns="urn:WSAmos"><USERID xsi:type="xsd:int">'+userId+'</USERID><TNAME xsi:type="xsd:string">'+tname+'</TNAME></tns:TABLEINFO>';

    req.send(message);
 
    document.getElementById('message1').innerHTML = "Finding Available Views  ..";
    
   
    //findServices();
}


function exitApp() {
   
     // creating the WSRequest
    var req = new WSRequest();
   exapp=2;
    if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
      }
 
    // request options
    var reqOptions = { useSOAP : 1.1 };
 
   

    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
 
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
   
        if(req.readyState == 4) {
            if(req.error == null) {
                // here is some use of DOM to retrive values of posts
	      childNodes = req.responseXML.firstChild.firstChild.nodeValue;
                
                 window.close();
           }
            else {
                  if ( req.responseXML!=null){
                       childNodes = req.responseXML.firstChild.childNodes;
	                   alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
                           }
                 else {     
                  alert("WSMED service may went down "); 
                     }   
                 window.close();
            }
            // clear the message
             document.getElementById('message1').innerHTML = "";
	     document.getElementById('WSDL').value = "";
        }
    };
 
    // creating the request xml 
     var message='<tns:EXIT_S xmlns:tns="urn:WSAmos"><USERID  xsi:type="xsd:int">'+userId+'</USERID></tns:EXIT_S>';

    req.send(message);
 
   
}

 
function executeQuery() {
     var resultBox = document.getElementById('resultBox');
     resultBox.innerHTML = "";
      document.getElementById('message3').innerHTML = "";
     var valIn= document.getElementById('sqlq');
     var sql= trimStr(valIn.value);
    var start = "";
      
     if(sql == "") {
        alert("Need a valid SQL Query!");
       return;
       }
    var initsql=sql;
    sql=sql.replace(/"/g,'\?');        //need to change to handle '?' among the text
    //sql=sql.replace(/'/g,'\\"');
    sql=sql.replace(/</g,'\^');
    
    // creating the WSRequest
    var req = new WSRequest();
 
    if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
      }
    
    // request options
    var reqOptions = { useSOAP : 1.1 };
    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
 
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
   
        if(req.readyState == 4) {
            if(req.error == null) {
               		
	      var htmlStr = "<h3>" +  initsql +"</h3>";
               
	      childNodes=req.responseXML.firstChild.childNodes;
	      for(j = 0; j < childNodes.length; j ++) {
		var result = childNodes[j].firstChild.firstChild.nodeValue;
		// filling the html string
		htmlStr += result;
		htmlStr += "<p>";
	      }  
 
	      resultBox = document.getElementById('resultBox');
	      resultBox.innerHTML = htmlStr;
	      var end = new Date();
	      var difference = (end.getTime() - start.getTime())/1000;
	      document.getElementById('message3').innerHTML = "  >> Query execution time = "+ difference+"  seconds";
            }
            else {
	         document.getElementById('message3').innerHTML = "";
                if ( req.responseXML!=null){
		 childNodes = req.responseXML.firstChild.childNodes;
	         alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
                  }
                 else
                  alert("WSMED service may went down ");

                 
                   }
            // clear the message
	      document.getElementById('sqlq').value = "";
        }
    };
 
    // creating the request xml 
     var message='<tns:QUERY xmlns:tns="urn:WSAmos"><USERID xsi:type="xsd:int">'+userId+'</USERID><SQLQ xsi:type="xsd:string">'+sql+'</SQLQ></tns:QUERY>'; 
    
    req.send(message);
    var start = new Date();
 


    document.getElementById('message3').innerHTML = "Executing the Query ..";
    
}


function authenticate() {
     
      
      var resultBox = document.getElementById('resultBox');
      resultBox.innerHTML = "";
       document.getElementById('message3').innerHTML = "";
      var dl= document.getElementById('DLT');
      var w = dl.selectedIndex;
      var opi=trimStr(dl.options[w].text);
     
      var austr=trimStr(document.getElementById('auStr').value); 
      // creating the WSRequest
     
      var req = new WSRequest();
   
    if(!req) {
        alert("Error in creating the WSRequest, Try again later");
        return;
    }
 
    // request options
    var reqOptions = { useSOAP : 1.1 };
 
    // providing the options, url, async flag, username, password for the service
    req.open(reqOptions, url, true);
   
    // the callback function to execute when the ready state is change
    req.onreadystatechange = function() {
     
        if(req.readyState == 4) {
            if(req.error == null) {
               
 
                htmlStr = "";
	        // first the userId
                var result = req.responseXML.firstChild.firstChild.nodeValue;
                if (result=='true'){
                   result='finished';}
                else {
                      result='not completed';
                      }

                // filling the html string
                htmlStr += "<h2>" + "Authentication for  "+ opi +">>>"+result+"</h2>";
                htmlStr += "<p>";
               
		var resultBox = document.getElementById('resultBox');
                resultBox.innerHTML = htmlStr;
            }
            else {
                 if ( req.responseXML!=null){
		 childNodes = req.responseXML.firstChild.childNodes;
	         alert("Fault code --> "+childNodes[0].firstChild.nodeValue+"\n"+" Fault string-->  "+childNodes[1].firstChild.nodeValue+"\n"+"Fault Detail  "+childNodes[2].firstChild.firstChild.nodeValue);
                  }
                 else
                  alert("WSMED service may went down ");
               
            }
            // clear the message
            document.getElementById('message').innerHTML = "";
        }
    };
 
    // creating the request xml 
       var message='<tns:AUTHENTICATION xmlns:tns="urn:WSAmos"><USERID xsi:type="xsd:int">'+userId+'</USERID><TNAME xsi:type="xsd:string">'+opi+'</TNAME><AUTHENTICATIONSTR xsi:type="xsd:string">'+austr+'</AUTHENTICATIONSTR></tns:AUTHENTICATION>'; 
 
    req.send(message);
 
    document.getElementById('message').innerHTML = "Authenticating View"+opi+"..";
}

function AddItem(IdName,Text,Value)
    {
        // Create an Option object                
         var opt = document.createElement("option");
       
        // Add an Option object to Drop Down/List Box
        document.getElementById(IdName).options.add(opt);        
        // Assign text and value to Option object
        opt.text = Text;
        opt.value = Value;

    }


function findComma(str){
  var len=str.length;
  var i=0;
  var l=0;
  while (i < len){
    if (',' == str.substring(i,i+1)){
	l=i;
	i=len
       }
    else{
      i=i+1;}
  }
   return l;      
  }


function arrangeStr(str){
 var htmlstr="";
 var len=str.length;
 var i=0;
 var start=0;

 while (i < len){
    if (',' == str.substring(i,i+1)){
	htmlstr+=str.substring(0,i-1)+"<p>";
        str=str.substring(i+1,len);
        i=0;
        len=str.length;
        }
    else{
    i=i+1;}
  }
  
 
 htmlstr+=str+"<p>";
 return htmlstr;
 }

function trimStr(str) {
  return str.replace(/^\s+|\s+$/g,"");
}

function newWSDL() {
  document.getElementById('newWSDL').value="";
 
  var dl= document.getElementById('DLU');
  var w = dl.selectedIndex;
 
  document.getElementById('newWSDL').value=document.getElementById('DLU').options[w].text;
    
}

function enterWSDL(){

  var newwsdl=trimStr(document.getElementById('newWSDL').value);
     
      if (newwsdl==null || newwsdl=="")
       {
         alert("Enter a valid WSDL URL");
         return;
        }
   
   var k=0;
  
   while ((document.getElementById('DLU').options[k].text != newwsdl)){
      k++;
       if (k>wsdli){
         k=wsdli;
          break;
       }
     }
  
   
  
   // if (document.getElementById('DLU').options[k].text!=newwsdl){
   //  AddItem("DLU",newwsdl,newwsdl);
   //   wsdli=wsdli+1;
   //   }
  // document.getElementById('newWSDL').value="";
   document.getElementById("DLU").options[wsdli].selected=true; 
   
   //document.getElementById('NEWWSDLURI').style.visibility='hidden';
   
}

function newInfo(){
  document.getElementById('auStr').value="";
  var dl= document.getElementById('DLT');
  var w = dl.selectedIndex;
  var opi=trimStr(dl.options[w].text);
  var i=0;
 
  if (reqAind>=0){
    while (reqA[i]!=opi ){
      i++;
   
      if (i > reqAind){
	i=i-1;
	break;
      }
    }
  }
  
  var j=0;
  if (enterAind>=0){
    while (enterA[j]!=opi){
      j++;

      if (j > enterAind){
	j=j-1;
	break;
      }
    }
  }
 

  if ((reqA[i]==opi) && (enterA[j]!=opi)){
    document.getElementById('Auth').style.visibility='visible';
  }
  else{
    alert("Authentication for View "+ opi+ " is not required ");
    return;
  }
}

function enterInfo(){

  var austr=trimStr(document.getElementById('auStr').value);
     
      if (austr==null || austr=="")
       {
         alert("Enter a valid Authentication String");
         return;
        }
  var dl= document.getElementById('DLT');
  var w = dl.selectedIndex;
  enterAind++;
  enterA[enterAind]= trimStr(dl.options[w].text);
  
  
  document.getElementById('Auth').style.visibility='hidden';
  authenticate();
}



window.onbeforeunload = function() { 
  switch(exapp){
  case 0:
        window.close();
        break;
  case 1:
       exitApp();
       break;
  case 2:
       break;
  default:
      window.close();
 }
} 

