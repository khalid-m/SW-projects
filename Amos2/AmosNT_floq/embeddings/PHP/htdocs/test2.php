<?php echo "Connecting to the embedded Amos II database";
      $con = amos_connect("");
      echo "<br>Testing Amos II query execution:";
      $scan = amos_execute($con,"select name(t) 
                                 from type t 
                                 where name(t)>'T';");
      while(!amos_eos($scan)) 
      {
         $tpl = amos_getrow($scan);
         echo "<br>"; var_export($tpl); 
         amos_next($scan);
      }
      echo "<br>Testing call to Amos II function:";
      $tpl = amos_getrow(amos_call($con,'plus',1,1.1));
      echo "<br>Function result of 1+1.1: "; var_export($tpl); 

      print "<br>Testing tuple arguments and 
             results in Amos II functions:\n";
      $a = array(1.1,NULL,2,"2",3,True,False,"#[OID 12]",
                 array(1,2,"#[OID 13]"));
      $tpl = amos_getrow(amos_call($con, 'id', $a));
      echo "<br>Complex tuple  result: "; var_export($tpl);
      echo "<br>Testing OID, true, false, null values:";
      $tpl = amos_getrow(amos_call($con, 'id', "#[OID 1]"));
      echo "<br>Function result object: "; var_export($tpl); 
      $tpl = amos_getrow(amos_call($con, 'id', true));
      echo "<br>Function result true: "; var_export($tpl); 
      $tpl = amos_getrow(amos_call($con, 'id', false));
      echo "<br>Function result false: "; var_export($tpl); 
      $tpl = amos_getrow(amos_call($con, 'id', null));
      echo "<br>Function result null: "; var_export($tpl); 
      echo "<br>Testing error handling: ";
      error_reporting(0);
      function myErrorHandler($errno, $errmsg, $filename, $linenum, $vars)
      {
        echo "<br>--------------------------------------\n";
        echo "<br>ERROR raised!\n";
        echo "<br>errno: $errno <br> errmsg: $errmsg 
              <br>filename: $filename <br> linenum: $linenum \n"; 
      }
      set_error_handler("myErrorHandler");
      amos_call($con, 'div', 1, 0);
      echo "<br>******** THE END ***********\n";
      echo "<form action=http:test3.php method=post>\n";
      echo "<table border=0 cols=2 width=100% cellspacing=0 cellpadding=0>\n";
      echo "<tbody><br>Testing text input: \n";
      echo "<tr><td>Input somthing containing '\</td>
	  <td> <input name=something type=text size=48></td>
	</tr>\n";

?>