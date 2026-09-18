<?php
	require "form.php";
	require "demo_functions.php";
	
	formfront();
	if (!isset($_POST["system"]))
	{
		echo "<h1>Query SWARD/SWATM <br> via PHP</h1>\n";
		display_form("", "", "demo.php");

	}
	else 
	{
		query_form($_POST["system"], "completeq.php", "", "", "", "");
	}
	formback();

?>

	

