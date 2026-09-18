<?php

		require "demo_functions.php";
		require "form.php";
		formfront();
	if (isset($_POST["syst"]) && isset($_POST["submitq"]) && ( isset($_POST["examq"]) || !empty($_POST["querycont"])) )
	{
	
		if (isset($_POST["qlan"]))
		{
			switch ($_POST["qlan"])
			{
			case "rdql":
				$l1="checked"; $l2=""; $l3="";break;
			case "sparql":
				$l1=""; $l2="checked"; $l3="";break;
			case "sql":
				$l1=""; $l2=""; $l3="checked";break;

			}
						
			if (!isset($_POST["examq"]))
			{
	        		query_form($_POST["syst"], "completeq.php", $_POST["querycont"],$l1,$l2,$l3);
				$contentq=$_POST["querycont"];
			}
			else
			{
				$contentq=exampQ($_POST["syst"], $_POST["examq"], $_POST["qlan"]);
				query_form($_POST["syst"], "completeq.php", $contentq, $l1,$l2,$l3);
			}
			rdqlAmos("RDFVIEWER",$contentq , $_POST["syst"],$_POST["qlan"]);
		}
		else
		{

?>	
			<SCRIPT language="JavaScript"> 
			alert("You have to choose query language!")
			//--> 
			</SCRIPT> 
<?php			
//			$contentq=exampQ($_POST["syst"], $_POST["examq"],"");

			query_form($_POST["syst"], "completeq.php", "", "", "", "");
		
		}
		
	}
	else if ( isset($_POST["syst"]))
	{
	 ?>
		<SCRIPT language="JavaScript"> 
		alert("You have to choose or write own query and choose query language!")
		//--> 
		</SCRIPT> 
<?php	
		query_form($_POST["syst"], "completeq.php", "", "", "", "");
		formback();
		
	}
	else if ( !isset($_POST["syst"]))
	{
		echo "<a href=\"demo.php\">Back to the front page and choose wrapper</a>";

	}
	



?>