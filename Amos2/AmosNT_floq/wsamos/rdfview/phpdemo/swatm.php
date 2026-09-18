<?php
	$schemaswatm_n="Which is the default address data for a citizen, in english, and which are the URIs where it can be found?"; 
	$contentswatm_n="Give me the names and the resources (in english) for all topics related to \"Electronic form\"";

	$hybridswatm_n="Give me all Life events together with their descriptions"; 


	$schemasw="SELECT ?tp FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm> WHERE(?tp, <rdf:type>, <rdf:Property>) (?tp, <rdfs:domain>, <swatm:TOPIC>) (?tp, <rdfs:range>, <rdfs:Literal>) AND ?tp != <swatm:IDTOPIC>";


	$hybridsw="SELECT ?iofoc, ?tm3 FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm> WHERE (?tm0 , <swatm:BASENAMETOPIC>, ?tm1) (?tm1 , <swatm:BASENAMESTRING>, 'Hamlet, Prince of Denmark') (?tm0 , <swatm:OCCURRENCETOPIC>, ?tm2) (?tm2 , <swatm:REFERENCE>, ?occurrence) (?tm2 , <swatm:INSTANCEOFOCCURRENCE>, ?iofoc) (<swatm:INSTANCEOFOCCURRENCE>, <rdfs:range>,?tm3) AND ?occurrence  != <http://www.csclub.uwaterloo.ca/u/relander/XML/hamlet.xml>";


	$contentsw="SELECT ?occurrence FROM <http://user.it.uu.se/~udbl/software/swatm/hamlet.xtm> WHERE (?tm0 , <swatm:BASENAMETOPIC>, ?tm1) (?tm1 , <swatm:BASENAMESTRING>, 'Hamlet, Prince of Denmark') (?tm0 , <swatm:OCCURRENCETOPIC>, ?tm2) (?tm2 , <swatm:REFERENCE>, ?occurrence)";

	echo "<p><p>\n";
	echo "<TABLE cellspacing=\"2\" border='0'  valign=\"top\" width=\"800\">\n";
	
	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Example query 1</b></i></td>\n";
	echo "<td width=\"10\"><td width=\"330\"><b><i>Example query 3</i></b></td></tr>\n";
	echo "<tr><TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"schema\"><br></TD>\n";

	echo "<td width=\"330\">",htmlspecialchars($schemaswatm_n),"</b></TD>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"hybrid\"></TD>\n";
	echo "<TD width=\"330\">", htmlspecialchars($hybridswatm_n) ,"</TD></TR>\n";

	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Example query 2</i></b></td>\n";
	echo"<TR><TD><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"content\"></TD>\n";
	echo "<td width=\"330\">", htmlspecialchars($contentswatm_n), "</TD></TR>\n";

	echo "</TABLE>\n";
	


?>