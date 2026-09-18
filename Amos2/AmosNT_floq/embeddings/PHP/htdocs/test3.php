<?php
 $con = amos_connect("");
  $a = $_POST['something'];
  $a = stripcslashes($a); /* POST slashifies strings */
  amos_call($con, "print", $a); /* Prints to log file */
  $tpl = amos_getrow(amos_call($con, 'id', $a));
  $b = $tpl[0];
      echo "<br>$a sent through Amos II: $b<br>
         Make sure PHPAmos log contains the same string<br>";
?>