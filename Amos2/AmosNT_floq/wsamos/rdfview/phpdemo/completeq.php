<?php

		require "demo_functions.php";
		require "form.php";
		formfront();
	if (isset($_POST["syst"]) && isset($_POST["submitq"]) )
	{
	
			if (!isset($_POST["examq"]) && empty($_POST["querycont"]) )
			{
?>	
			<SCRIPT language="JavaScript"> 
			alert("You have to choose or write own query in the area!")
			//--> 
			</SCRIPT> 
<?php			
	query_form($_POST["syst"], "completeq.php", "", "", "", "");
		formback();

			}
			else if (isset($_POST["examq"]))
			{
				$contentq=exampQ($_POST["syst"], $_POST["examq"], "sparql");
				query_form($_POST["syst"], "completeq.php", $contentq, $l1,$l2);
				rdqlAmos("RDFVIEWER",$contentq , $_POST["syst"],"sparql");
			}
			else if (!empty($_POST["querycont"]))
			{
				query_form($_POST["syst"], "completeq.php", $_POST["querycont"], $l1,$l2);
				rdqlAmos("RDFVIEWER",$_POST["querycont"], $_POST["syst"],"sparql");

			}


	}
	else if ( !isset($_POST["syst"]))
	{
		echo "<a href=\"demo.php\">Back to the front page and choose wrapper</a>";

	}
	



?>