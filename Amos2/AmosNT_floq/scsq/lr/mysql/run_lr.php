#!/usr/bin/php
<?php
require_once('config.php');

$file_name=$argv[1];
if ( !$file_name || empty($file_name) )
  die("Pass the data file as first argument!\n");

$time_start=getTime();
mysql_connect($host,$user,$password) or die("Could not connect\n");
mysql_select_db($database) or die( "Unable to select database\n");

$data_file=fopen($file_name, 'r');
if ( !$data_file )
  die("Could not open SQL file\n");

mysql_query('CALL prepare_start();');

$minute=null;
echo "Systemtid\tMinut i simulatorn\n";
while( !feof($data_file) )
{
  $query=trim(fgets($data_file, 1024));
  
  if ( empty($query) || $query[0]=="#")
    continue;
  
  list(,$new_minute)=split(",", $query, 3);
  $new_minute=int_divide($new_minute,60);
  if ( $new_minute != $minute )
  {
    echo date('H.i.s')."\t".$new_minute."\n";
    $minute=$new_minute;
  }
  
  $query='CALL lr0('.$query.');';
  $res=mysql_query($query);
  if (!$res)
  {
      $message  = 'Invalid query: ' . mysql_error() . "\n";
      $message .= 'Whole query: ' . $query;
      die($message."\n");
  }
}
fclose($data_file);

$sim_duration=number_format( getTime()-$time_start, 2);
echo "Simultation finished after ".$sim_duration." seconds\n";
echo "****** Outputs are stored in database tables ******\n";
$query='SELECT count(*) FROM output_toll_alert';
$res=mysql_fetch_row(mysql_query($query));
echo "Toll alerts:\t\t\t".$res[0]."\n";

$query='SELECT count(*) FROM output_accident_alert';
$res=mysql_fetch_row(mysql_query($query));
echo "Accident alerts:\t\t".$res[0]."\n";

$query='SELECT count(*) FROM output_account_balance';
$res=mysql_fetch_row(mysql_query($query));
echo "Account balance reports:\t".$res[0]."\n";

$query='SELECT count(*) FROM output_daily_exp';
$res=mysql_fetch_row(mysql_query($query));
echo "Daily expenditure reports:\t".$res[0]."\n";


mysql_close();

function getTime()
{
  $a = explode (' ',microtime());
  return(double) $a[0] + $a[1];
}

function int_divide($x, $y)
{
    return ($x - ($x % $y)) / $y;
}

?>