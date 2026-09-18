<?php 
                 echo ".......................................................................................................";
fwrite(STDOUT, "\nThe following links below are all the RDF dump files available on ODP web site(http://rdf.dmoz.org/rdf)
and they are sorted out according to the extensions and categories.\n");
echo ".......................................................................................................";
fwrite(STDOUT, "\n\nPlease Pick a site link to download RDF from ODP (enter the number and press Enter)\n\n");
// An array of choice to sites 
$sites = array ( 
   'a'=> array("a", "txt1", "--> The categories dumps with txt extension and total file size: 56M"),
   'b'=> array("b", "txt2", "--> Short examples of structure.txt and content.txt with total file size: 60k "),
   'c'=> array("c", "kids", "--> The Kids & Teens dumps with gz extension, total size: 5M"),
   'd'=> array("d", "nets", "--> Netscape structure and content dumps with gz extension, total size: 3M"),
   'e'=> array("e", "bigg", "--> Category hierarchy information & links within each category dumps,total size: 400M "),
   'f'=> array("f", "ktrs", "--> kt-rss.rdf.u8.gz"),
   'g'=> array("g", "term", "--> kt-terms.rdf.u8.gz "),
   'h'=> array("h", "samp", "--> sample.rdf.u8.gz"),
   'i'=> array("i", "redi", "--> redirect.rdf.u8.gz"),
   'j'=> array("j", "aoli",  "--> rss-aol.rdf"),

);

echo "Enter 'q' to quit\n";

// Display the choices 
foreach ( $sites as $choice ) {
   echo "\t{$choice[0]}: {$choice[1]} - {$choice[2]}\n";
}
// Loop until they enter 'q' for Quit
do {
   // A character from STDIN, ignoring whitespace characters
   do {
       $selection = fgetc(STDIN);
   } while (trim($selection) == '' );

   if ($selection == "q") {
      echo "Exiting................\n";
      exit(0);
   }

   if (array_key_exists($selection,$sites)) {
      echo "You picked {$sites[$selection][1]}\n";
      echo "Please wait...downloading in progress for {$sites[$selection][1]}\n";
      include($sites[$selection][1] . "load.cmd");
   } else {
       $stderr = fopen('php://stderr', 'w');
       fwrite($stderr,"There was an Error\n");
       fwrite($stderr,"Please try again and pick the right number...\n");
       fclose($stderr);
   }

} while ($selection != 'q');

  exit(0);

?>
