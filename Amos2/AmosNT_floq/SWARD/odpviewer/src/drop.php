<?php
$link = mysql_connect('localhost', 'root', '');
if (!$link) {
die('Could not connect: ' . mysql_error());
}

$sql = 'DROP DATABASE dmoz';
if (mysql_query($sql, $link)) {
echo "Database DMOZ was successfully deleted...!\n";

} else {
echo 'Error dropping database: ' . mysql_error() . "\n";
}

?>
