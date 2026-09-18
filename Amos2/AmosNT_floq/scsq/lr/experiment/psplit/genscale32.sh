#!/bin/bash

ofile='../../slscale32.sh'
b=5
msz=8

rm $ofile
echo "#!/bin/bash
# This is a generated file. Do not edit." > $ofile

for ((i=1;i<=7;i++))
  do cp psp psp_$((8*i)).osql
  echo "sbatch -n $((8*i)) -p node -t 0:30:00 -A p2009046 ./sl.sh\
 experiment/psplit/psp_$((8*i)).osql" >> $ofile
done  

echo "parasplit(1, {2}, {$b}, 100, $msz, {1,2,4});" >> psp_8.osql
echo "parasplit(1, {4}, {$b}, 100, $msz, {1,2});" >> psp_8.osql

echo "parasplit(1, {2}, {$b}, 100, $msz, {8});" >> psp_16.osql
echo "parasplit(1, {4}, {$b}, 100, $msz, {4,8});" >> psp_16.osql
echo "parasplit(1, {8}, {$b}, 100, $msz, {1,2,4});" >> psp_16.osql

echo "parasplit(1, {16}, {$b}, 100, $msz, {1,2,4});" >> psp_24.osql
echo "parasplit(1, {8}, {$b}, 100, $msz, {8});" >> psp_24.osql
echo "parasplit(1, {2,4}, {$b}, 100, $msz, {16});" >> psp_24.osql

echo "parasplit(1, {8}, {$b}, 100, $msz, {16});" >> psp_32.osql
echo "parasplit(1, {16}, {$b}, 100, $msz, {8});" >> psp_32.osql

echo "parasplit(1, {16}, {$b}, 100, $msz, {16});" >> psp_40.osql
echo "parasplit(1, {32}, {$b}, 100, $msz, {1,2,4});" >> psp_40.osql

echo "parasplit(1, {32}, {$b}, 100, $msz, {8});" >> psp_48.osql

echo "parasplit(1, {32}, {$b}, 100, $msz, {16});" >> psp_56.osql

for ((i=1;i<=7;i++))
  do 
  echo "write_ntuples({ub_para_res()}, getenv('AMOS_HOME') + '/scsq/lr/output/psplit_nuvraa' + timestamp());" >> psp_$((8*i)).osql
  echo "q();" >> psp_$((8*i)).osql
done  

chmod +x $ofile
