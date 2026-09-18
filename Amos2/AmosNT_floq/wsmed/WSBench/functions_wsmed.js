userId=window.opener.userId;
function create_onclick(){
  var myObject = new Object();
   var regSucc = window.showModalDialog('CREATE_wsmed.html',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
                }

function deploy_onclick(){
  var myObject = new Object();
  var regSucc = window.showModalDialog('DEPLOY_wsmed.html',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
                }

        
function execute_onclick(){    
   var myObject = new Object();
   var regSucc = window.showModalDialog('EXECUTE_wsmed.html',myObject,'dialogWidth:800px; dialogHeight:600px; center:Yes; resizable: Yes; help: No;');
                }


function populateDiv(rows){
    var divResult = '<br>';
    if (rows.constructor.toString().indexOf("function Array()") > -1) { 
        //multi results
        for (var i=0; i< rows.length; i++){
            if(rows[i].toString().indexOf("()->VECTOR")>-1)
            { divResult = "The function should not have the parameter(s), try again!";}
            else if(rows[i].toString().indexOf("ERROR")>-1)
            { divResult = "The parameter(s) you inputed do not match with the function, please check the function defination and try again!";}
            else{
            divResult += rows[i] + '<br>';}}}
        else{
        divResult += rows + '<br>';
    }
    
    return divResult
}


function separate(str){
    var str2="";
    if(str==""){str2="";}
    else{
    var arr=str.split(",");
    var arr1 = new Array();
    for(i=0; i<arr.length; i++)
    { if (isNaN(parseInt(arr[i],10)))
       { arr1[i]="\""+arr[i]+"\",";}
      else
      {
       arr1[i]=parseInt(arr[i],10)+",";}
       str2+=arr1[i];   
    }
    str2=str2.substring(0, str2.length-1);}
    return str2;
}

function change(str){
    var arr3=str.split(",");
    var arr4 = new Array();
    var str3="";
    for(i=0; i<arr3.length; i++)
    { if (isNaN(parseInt(arr3[i],10)))
       { arr4[i]="\"ws"+arr3[i]+"\",";}
      else
      { }
    str3+=arr4[i]; }
    str3="{"+str3.substring(0, str3.length-1)+"}";
    return str3;
}

