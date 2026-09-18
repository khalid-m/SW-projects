<?php
/*Functions needed for the demo RDQL Query SSWARD/SWATM*/

/*Function that displays the initial form where the user can choose between SWARD and SWATM*/
	function display_form($swatmcheck, $swardcheck, $trfile)
	{
		echo "<form name=\"query\" method=\"post\" action=$trfile>"; 
		echo "<h2>Please choose between:</h2>";
  		echo "<input type=\"radio\" name=\"system\" value=\"SWARD\"",$swardcheck,">SWARD<br> (Semantic Web Abridged Relational Databases)\n";
		echo "<br><br><input type=\"radio\" name=\"system\" value=\"SWATM\"",$swatmcheck,">SWATM <br> (Semantic Web Abridged Topic Maps)\n";
		echo "<p><input name=\"submit\" type=\"submit\" value=\"Go\"></p>";

		echo "</form>";		
	}

/*Function that displays the query form where the user cna query SWARD or SWATM*/
	function query_form($servername, $filef, $qcont, $l1, $l2, $l3)
	{

		switch ($servername)
		{
		case "SWARD":
			$filein="sward.php";
			$introd="Query SWARD";
			break;
		case "SWATM":
			$filein="swatm.php";
			$introd="Query SWATM";
			break;
		case "SWASS":
			$filein="swass.php";
			$introd="Query SWASS";
			break;
		}
		echo "<a href=\"demo.php\">Back to the front page</a>";
		echo "<h1>".$introd."</h1>\n";
		echo "<h3>Choose one of the provided example queries or write your own in the field below!</h3>\n";
		echo "<form name=\"query\" method=\"post\" action=$filef>\n"; 
		include $filein;
		echo "<br><b>Choose query language among: </b>\n";
		echo "<INPUT TYPE=\"radio\" NAME=\"qlan\" value=\"rdql\" $l1>RDQL&nbsp;&nbsp;";
		echo "<INPUT TYPE=\"radio\" NAME=\"qlan\" value=\"sparql\" $l2>SPARQL";
		ECHO "<p><b>Your query</b><br>";
		echo "<textarea name=\"querycont\" cols=\"110\" rows=\"14\" color=\"yellow\">",$qcont,"</textarea></p>\n";
		echo "<p><input name=\"submitq\" type=\"submit\" value=\"Submit Query\"></p>\n";
		echo "<input type=\"hidden\" name=\"syst\" value=$servername>\n";
		echo "</form>\n";
	}


/*Function that shows a messae about an error*/	
 	function myErrorHandler($errno, $errmsg, $filename, $linenum, $vars)
      {
        echo "<br>--------------------------------------\n";
        echo "<br>ERROR raised!\n";
        echo "<br>errno: $errno <br> errmsg: $errmsg\n"; 
	exit;
//              <br>filename: $filename <br> linenum: $linenum \n"; 
      }


/*Function responsible for the making connection to Amos, calling the Amos "RDQL" function and returning back the result to the web page*/
	function rdqlAmos($server, $querycont, $system, $qlan)
	{
		$con = amos_connect($server);
		$conam=amos_connect("");
		amos_call($conam, "print", $querycont); /* Prints to log file */
      		echo "<b>The result :</b>";
		set_error_handler("myErrorHandler");		
		
		/*Replaces the Return charcter chr(13) with a blank space  */
		if ($qlan=="sparql")
		{
			$querycont = str_replace(chr(13), " ", $querycont);
		}


			$scan = amos_call($con,'CALL_FUNCTION',$system,$qlan,array($querycont),10);
			$i=0;
			$partq= substr($querycont,0, strpos($querycont,"FROM"));
					
			if ($qlan<>"sql")
			{
				$count=substr_count($partq, '?')-1;
			}
			else
			{
				$count=substr_count($partq, ',');
			}
			
		
			while(!amos_eos($scan)) 
			{	  	
				echo "<br>";
				echo "<b>{ </b>";
				$tpl = amos_getrow($scan);
								
				for ($i = 0; $i <= $count; $i++) 
				{
					echo $tpl[0][0][$i];
					if($i < $count) 
						echo "<b>, </b> ";
					
				}
				echo "<b> }</b>";
					
				amos_next($scan);

			}

	}


	function exampQ($system, $typq, $ql)
	{

	//RDQL queries for SWATM
		$schemasw="SELECT ?bs1,?sa1 
	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE (?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
		    (?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bs1)
		    (?bnt1, <http://udbl2.it.uu.se/swatm#SCOPEBASENAME>, ?s1)
		    (?s1, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')
		    (?t1, <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS>, ?sa1)
	            (?t1, <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC>, ?t2)
		    (?t2, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt2)
		    (?bnt2, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>,  'Default address data')";

		$contentsw="SELECT ?bns, ?sa
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE  (?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
		    (?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Electronic form')
		    (?t1, <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?t2)
		    (?t2, <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE>, ?t3)
		    (?t3, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt3)
		    (?bnt3, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bns)
		    (?t3, <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS>, ?sa)
		    (?bnt3, <http://udbl2.it.uu.se/swatm#SCOPEBASENAME>, ?t4)
		    (?t4, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')";

		$hybridsw="SELECT ?bs2, ?dat
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE  (?t1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt1)
		    (?bnt1, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, 'Life events')
		    (?i1, <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC>, ?t1)
	            (?i1, <http://udbl2.it.uu.se/swatm#BASENAMETOPIC>, ?bnt2)
		    (?bnt2, <http://udbl2.it.uu.se/swatm#BASENAMESTRING>, ?bs2)
		    (?bnt2, <http://udbl2.it.uu.se/swatm#SCOPEBASENAME>, ?t2)
		    (?t2, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')
		    (?i1, <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC>, ?o1)
		    (?o1, <http://udbl2.it.uu.se/swatm#SCOPEOCCURRENCE>, ?t3)
		    (?t3, <http://udbl2.it.uu.se/swatm#IDTOPIC>, 'systemId2')
		    (?o1, <http://udbl2.it.uu.se/swatm#DATA>, ?dat)";

	//RDQL queries for SWARD
		$schemasward="SELECT ?lifeeventprop
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE (?lifeeventprop, <http://www.w3.org/2000/01/rdf-schema#domain>, 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent>)
 AND	?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>";

		$contentsward="SELECT ?val1, ?val2
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE (?s1,<http://purl.org/dc/elements/1.1/title>,?val1)
       (?s1,<http://purl.org/dc/elements/1.1/description>,?val2)";

		$hybridsward="SELECT ?s2, ?p, ?val3
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE (?s1,<http://purl.org/dc/elements/1.1/description>,?val1),
       (?s1,<http://purl.org/dc/elements/1.1/identifier>,?val2),
       (?s2,<http://udbl.it.uu.se/schemas/eGovern#LifeEventID>,?val2),
       (?p,<http://www.w3.org/2000/01/rdf-schema#domain>,
           <http://udbl.it.uu.se/schemas/eGovern#Form>),
       (?s2,?p,?val3)
 AND ?p != <http://udbl.it.uu.se/schemas/eGovern#FormID>
 AND ?p != <http://udbl.it.uu.se/schemas/eGovern#LifeEventID>
 AND ?val1 =~ '%move%'";

	
	//SPARQL queries for SWATM
<<<<<<< demo_functions.php
		$sparqlschemasw="SELECT ?bs1 ?sa1 
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?s1.
		    ?s1 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
		    ?t1 <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS> ?sa1.
	            ?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING>  'Default address data'.}";
=======
		$sparqlschemasw="SELECT DISTINCT ?bs1 ?sa1
	FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
	WHERE{ 	?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
    	?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
    	?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?s1.
    	?s1 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
    	?t1 <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS> ?sa1.
       	?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
    	?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
    	?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Default address data'.}";
>>>>>>> 1.4

		$sparqlcontentsw="SELECT DISTINCT ?bns ?sa
<<<<<<< demo_functions.php
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Electronic form'.
		    ?t1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> ?t3.
		    ?t3 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt3.
		    ?bnt3 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bns.
		    ?t3 <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS> ?sa.
		    ?bnt3 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t4.
		    ?t4 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.}";
=======
      	FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	WHERE{ 	?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
	 	?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Electronic form'.
		?t1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?t2.
		?t2 <http://udbl2.it.uu.se/swatm#INSTANCEOFOCCURRENCE> ?t3.
		?t3 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt3.
		?bnt3 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bns.
		?t3 <http://udbl2.it.uu.se/swatm#SUBJECTADDRESS> ?sa.
		?bnt3 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t4.
		?t4 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.}";
>>>>>>> 1.4
	
		$sparqlhybridsw="SELECT ?bs2 ?dat
<<<<<<< demo_functions.php
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Life events'.
		    ?i1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t1.
	            ?i1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
		    ?i1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?o1.
		    ?o1 <http://udbl2.it.uu.se/swatm#SCOPEOCCURRENCE> ?t3.
		    ?t3 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
		    ?o1 <http://udbl2.it.uu.se/swatm#DATA> ?dat.}";
=======
       FROM <http://user.it.uu.se/~udbl/software/swatm/egovdemo.xtm>
       WHERE{ 	?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Life events'.
		?i1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t1.
	        ?i1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs2.
		?bnt2 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t2.
		?t2 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
		?i1 <http://udbl2.it.uu.se/swatm#OCCURRENCETOPIC> ?o1.
		?o1 <http://udbl2.it.uu.se/swatm#SCOPEOCCURRENCE> ?t3.
		?t3 <http://udbl2.it.uu.se/swatm#IDTOPIC> 'systemId2'.
		?o1 <http://udbl2.it.uu.se/swatm#DATA> ?dat.}";
>>>>>>> 1.4
	
	//SPARQL queries for SWARD
		$sparqlschemasward="SELECT ?lifeeventprop
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE {?lifeeventprop <http://www.w3.org/2000/01/rdf-schema#domain> 
		<http://udbl.it.uu.se/schemas/eGovern#LifeEvent> .
 FILTER	(?lifeeventprop != <http://purl.org/dc/elements/1.1/identifier>) .}";

		$sparqlcontentsward="SELECT ?val1 ?val2
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE {?s1 <http://purl.org/dc/elements/1.1/title> ?val1 .
        ?s1 <http://purl.org/dc/elements/1.1/description> ?val2 .}";

		$sparqlhybridsward="SELECT ?s2 ?p ?val3
 FROM <http://udbl.it.uu.se/upv/eGovBus/>
 WHERE {?s1 <http://purl.org/dc/elements/1.1/description> ?val1 .
       ?s1 <http://purl.org/dc/elements/1.1/identifier> ?val2 .
       ?s2 <http://udbl.it.uu.se/schemas/eGovern#LifeEventID> ?val2 .
       ?p <http://www.w3.org/2000/01/rdf-schema#domain> 
        <http://udbl.it.uu.se/schemas/eGovern#Form> .
       ?s2 ?p ?val3 .
 FILTER (?p != <http://udbl.it.uu.se/schemas/eGovern#FormID>) .
 FILTER (?p != <http://udbl.it.uu.se/schemas/eGovern#LifeEventID>) .
 FILTER REGEX (?val1, '%move%') .}";
		


		switch ($ql) {

		case "rdql":
			if ($system=="SWATM")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$schemasw;
					break;				
				case "hybrid":
					$contentq=$hybridsw;
					break;				
				case "content":
					$contentq=$contentsw;
					break;				
				}
			}
			else if ($system=="SWARD")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$schemasward;
					break;				
				case "hybrid":
					$contentq=$hybridsward;
					break;				
				case "content":
					$contentq=$contentsward;
					break;				
				}
			}
			else if ($system=="SWASS")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$schemaswass;
					break;				
				case "hybrid":
					$contentq=$hybridswass;
					break;				
				case "content":
					$contentq=$contentswass;
					break;				
				}
			}
			break;
	
		case "sql":
			if ($system=="SWATM")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sqlschemasw;
					break;				
				case "hybrid":
					$contentq=$sqlhybridsw;
					break;				
				case "content":
					$contentq=$sqlcontentsw;
					break;				
				}
			}
			else if ($system=="SWARD")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sqlschemasward;
					break;				
				case "hybrid":
					$contentq=$sqlhybridsward;
					break;				
				case "content":
					$contentq=$sqlcontentsward;
					break;				
				}
			}
			else if ($system=="SWASS")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sqlschemaswass;
					break;				
				case "hybrid":
					$contentq=$sqlhybridswass;
					break;				
				case "content":
					$contentq=$sqlcontentswass;
					break;				
				}
			}
			break;

		case "sparql":
			if ($system=="SWATM")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sparqlschemasw;
					break;				
				case "hybrid":
					$contentq=$sparqlhybridsw;
					break;				
				case "content":
					$contentq=$sparqlcontentsw;
					break;				
				}
			}
			else if ($system=="SWARD")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sparqlschemasward;
					break;				
				case "hybrid":
					$contentq=$sparqlhybridsward;
					break;				
				case "content":
					$contentq=$sparqlcontentsward;
					break;				
				}
			}
			else if ($system=="SWASS")
			{
				switch($typq)
				{
				case "schema":
					$contentq=$sparqlschemaswass;
					break;				
				case "hybrid":
					$contentq=$sparqlhybridswass;
					break;				
				case "content":
					$contentq=$sparqlcontentswass;
					break;				
				}
			}

			break;
		}
		return $contentq;
	}

?>