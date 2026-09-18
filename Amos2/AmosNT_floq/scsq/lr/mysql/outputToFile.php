#!/usr/bin/php
<?php
require_once('config.php');

mysql_connect($host,$user,$password);
mysql_select_db($database) or die( "Unable to select database\n");

echo "Writing output to files...\n";
output_table(0,'output_toll_alert', 'o-tollalert' );
output_table(1,'output_accident_alert', 'o-acc-alert' );
output_table(2,'output_account_balance', 'o-acc-balance' );
output_table(3,'output_daily_exp', 'o-daily-exp' );
echo "Done.\n";

mysql_close();

function output_table( $type, $table_name, $file_name )
{
  $file = fopen($file_name,'w') or die("Can not open file ".$file_name."\n");
  $res=mysql_query('SELECT * FROM '.$table_name.';');
  while($row = mysql_fetch_array($res,MYSQL_NUM))
  {
    if ( $type==2 )
      $row[4]=(int)$row[4];
    else if ( $type==3 )
      $row[3]=(int)$row[3];
    $output_row=$type.',';
    if ( $type==0 )
      $output_row.=$row[4].','.$row[0].','.$row[1].','.($row[2]).','.(int)$row[3];
    else
      $output_row.=implode(',',$row);
    $output_row.="\n";
//     echo $output_row;
    fwrite( $file, $output_row);
  }
  fclose($file);
}

?>