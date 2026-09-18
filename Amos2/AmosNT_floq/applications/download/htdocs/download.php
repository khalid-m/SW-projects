<?php

$con = amos_connect("");

if(isset($_GET['id']))
{
  ///    Mailed download script.
  ///    Download when unique id is set in URL AND
  ///    id is registered in the database
  $id = $_GET['id'];
  /// Check that session id in database:
    $tpl = amos_getrow(amos_call($con, "download", $id, 
				 $_SERVER['REMOTE_ADDR']));
    if($tpl==null)
      echo "Sorry, the link can no longer be used for downloading <br>";
    else {
      /// Pick up file to download in $file:
      $dir = $tpl[0];
      $file = $tpl[1];
      $extension = ".zip";
      $textfont = "Verdana,Arial";  //text font for the error msg
      $SERVER_ADMIN = "Tore.Risch@it.uu.se";

      if (file_exists("$dir$file$extension"))
	{
	  Header("Content-type: octet-stream"); 
	  Header("Content-type: application/zip"); 
	  Header("Content-Description: File Transfer");
	  Header("Content-Disposition: attachment; filename=$file$extension"); 
	  readfile("$dir$file$extension");
	  exit;
	}
      else echo "Could not find file to download.<br>";}
}
else echo "Invalid link <br>";
?>
