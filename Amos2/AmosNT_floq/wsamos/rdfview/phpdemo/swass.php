<?php
	$schemaswass_n="Give me all properties, except for http://udbl.it.uu.se/schemas/eGovern#FormID, of a life event form."; 

	$contentswass_n="Give me the creator of all life event forms about becoming a parent.";

	$hybridswass_n="Give me the values of all properties, except for http://udbl.it.uu.se/schemas/eGovern#FormID, of all life event forms about retiring from work."; 

	
	echo "<p><p>\n";
	echo "<TABLE cellspacing=\"2\" border='0'  valign=\"top\" width=\"800\">\n";
	
	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Schema query</b></i></td>\n";
	echo "<td width=\"10\"><td width=\"330\"><b><i>Hybrid query</i></b></td></tr>\n";
	echo "<tr><TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"schema\"><br></TD>\n";

	echo "<td width=\"330\"><font color=\"green\">",htmlspecialchars($schemaswass_n),"</b></TD>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"hybrid\"></TD>\n";
	echo "<TD width=\"330\">", htmlspecialchars($hybridswass_n) ,"</TD></TR>\n";

	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Content query</i></b></td>\n";
	echo"<TR><TD><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"content\"></TD>\n";
	echo "<td width=\"330\">", htmlspecialchars($contentswass_n), "</TD></TR>\n";

	echo "</TABLE>\n";
	


?>