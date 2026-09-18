<?php

$con = amos_connect("");

if(isset($_GET['what']))
{
  /// A: Fill out form section. 
  /// Always run when variable '?what=<system>' is set in URL:
  $what = $_GET['what'];
  $tpl = amos_getrow(amos_call($con, "fullname", $what));
  if($tpl==null)
    {
      echo "$what not downloadable.<br>";
      exit;
    }
  else
    {
      $fullname = $tpl[0];
      echo "Please specify name and e-mail address to receive link to download 
            $fullname.<br>";
      echo '<form method="post" action="dl.php?what=' . $what . '">';
      echo '<table border="0" cols="2" width="100%" cellspacing="0" 
            cellpadding="0"> <tbody>';
      echo '<tr><td>Name:</td><td><textarea name="name" rows="1" cols="30">';
      echo '</textarea></td></tr>';
      echo '<tr><td>Email:</td><td><textarea name="email" rows="1" cols="30">';
      echo '</textarea></td></tr>';
      echo "<tr><td></td><td><input type='submit' value='Download 
            $fullname'/></td></tr></tbody></table>";
      echo '</form>';
    }
}

if(isset($_POST['email']))
{
  /// B: Assign session handle and submit e-mail
  ///    Run when variable 'email' is posted
  $name = $_POST['name'];
  $to = $_POST['email'];
  function CheckEmail($Email = "") 
    {
      if (ereg("[[:alnum:]]+@[[:alnum:]]+\.[[:alnum:]]+", $Email)) 
	return true;
      else return false;
    }

  if (!CheckEmail($to)) echo "Illegal or unspecified e-mail address!<br>";
  else 
    {
      $id = uniqid("x");
      $dllink = "http://udbl.it.uu.se/download.php";
      $subject = "Downloading $fullname";
      $tpl = amos_getrow(amos_call($con, "responsible", $what));
      $from = $tpl[0];
      $message = '<html><a href="' . $dllink . '?id=' . $id . 
	'">Click here to download ' . $fullname . '!</a></html>';

      $headers  = 'MIME-Version: 1.0' . "\r\n";
      $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
      $headers .= 'From: ' . $from . "\r\n" . "\r\n" .
	'X-Mailer: PHP/' . phpversion();

      $scan = amos_call($con, "reserve", $id, $what, $_SERVER['REMOTE_ADDR'],
                        $name, $to);
      if(amos_eos($scan)) echo "Cannot download $fullname<br>";
      else 
	{
	  mail($to, $subject, $message, $headers);
	  echo "E-mail with link to download $fullname sent to $to!<br>";
	}
    }
}

?>
 


