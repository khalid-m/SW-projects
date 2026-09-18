<?php
	$textq1 = "List of all countries"; 
	$textq2 = "List of the passport types";
	$textq3 = "List of the local authorities"; 
	$textq4 = "List of the employees from the local authorities";
	$textq5 = "List of the projects";

	$q1 ="SELECT DISTINCT ?bs1
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egov_demo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
		    ?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Country'.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t3.
		    ?t3 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt3.
                    ?bnt3 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'English'.}";


	$q2 = "SELECT DISTINCT ?bs1
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egov_demo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
		    ?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Passport type'.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t3.
		    ?t3 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt3.
                    ?bnt3 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'English'.}";


	$q3 = "SELECT ?bs1
      	     FROM <http://user.it.uu.se/~udbl/software/swatm/egov_demo.xtm>
      	     WHERE{ ?t1 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt1.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> ?bs1.
		    ?t1 <http://udbl2.it.uu.se/swatm#INSTANCEOFTOPIC> ?t2.
		    ?t2 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt2.
		    ?bnt2 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Local authority'.
		    ?bnt1 <http://udbl2.it.uu.se/swatm#SCOPEBASENAME> ?t3.
		    ?t3 <http://udbl2.it.uu.se/swatm#BASENAMETOPIC> ?bnt3.
                    ?bnt3 <http://udbl2.it.uu.se/swatm#BASENAMESTRING> 'Display'.}";

	$q4 = "";

	$q5 = "";

	echo "<p><p>\n";
	echo "<TABLE cellspacing=\"2\" border='0'  valign=\"top\" width=\"800\">\n";
	
	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Example query 1</b></i></td>\n";
	echo "<td width=\"10\"><td width=\"330\"><b><i>Example query 2</i></b></td>\n";
	echo "<td width=\"10\"><td width=\"330\"><b><i>Example query 3</i></b></td></tr>\n";
	echo "<tr><TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"q1\"><br></TD>\n";

	echo "<td width=\"330\">",htmlspecialchars($textq1),"</b></TD>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"q2\"></TD>\n";
	echo "<TD width=\"330\">", htmlspecialchars($textq2) ,"</TD>\n";

	echo "<TD width=\"10\"><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"q3\"></TD>\n";
	echo "<TD width=\"330\">", htmlspecialchars($textq3) ,"</TD></TR>\n";

	echo "<TR><td width=\"10\"></td><td width=\"330\"><b><i>Example query 4</i></b></td>\n";
	echo "<td width=\"10\"></td><td width=\"330\"><b><i>Example query 5</i></b></td></tr>\n";
	echo"<TR><TD><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"q4\"></TD>\n";
	echo "<td width=\"330\">", htmlspecialchars($textq4), "</TD>\n";
	echo"<TD><INPUT TYPE=\"radio\" NAME=\"examq\" value=\"q5\"></TD>\n";
	echo "<td width=\"330\">", htmlspecialchars($textq5), "</TD></TR>\n";


	echo "</TABLE>\n";
	


?>