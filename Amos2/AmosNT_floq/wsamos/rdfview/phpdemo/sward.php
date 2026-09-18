<?php

	$schemasward_n="Give me all properties, except for http://purl.org/dc/elements/1.1/Identifier, of a life-event."; 

	$contentsward_n="Give me the names and descriptions of all life-events.";

	$hybridsward_n="Give me all life-event forms about moving and their properties."; 

	echo "<p><p>\n";
	echo "<TABLE cellspacing=\"2\" border='0'  valign=\"top\" width=\"100%\"><TR>\n";
	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Schema query</b></i></td>\n";
	echo "<td width=\"10\"><td width=\"330\"><b><i>Hybrid query</i></b></td></tr>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"schema\"><br></TD>\n";
	echo "<td width=\"330\">",htmlspecialchars($schemasward_n),"</b></TD>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"hybrid\"></TD>\n";
	echo "<TD width=\"330\"><p>", htmlspecialchars($hybridsward_n) ,"</TD></TR>\n";

	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Content query</i></b></td>\n";
	echo"<TR><TD><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"content\"></TD>\n";
	echo "<td width=\"330\">", htmlspecialchars($contentsward_n), "</TD></TR>\n";

	echo "</TABLE>\n";

	
?>
