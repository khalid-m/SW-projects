#!/bin/bash

ofile='../../slscale512.sh'

rm $ofile
echo "#!/bin/bash
# This is a generated file. Do not edit." > $ofile

for ((i=1;i<=8;i++))
  do for j in 1 2 3 5
    do cp psp psp_$((64*i + 8*j)).osql
    echo "sbatch -n $((64*i + 8*j)) -p node -t 0:30:00 -A p2009046 ./sl.sh\
 experiment/psplit/psp_$((64*i + 8*j)).osql" >> $ofile
  done
done

chmod +x $ofile

for ((i=1;i<9;i++))
  do echo "parasplit(64, {$i}, {5}, 100, 8, {1,2,4});" >> \
      psp_$((64*(i)+8)).osql
  echo "q();" >> psp_$((64*(i)+8)).osql
done

for ((i=1;i<9;i++))
  do echo "parasplit(64, {$i}, {5}, 100, 8, {8});" >> \
      psp_$((64*(i)+16)).osql
  echo "q();" >> psp_$((64*(i)+16)).osql
done

for ((i=1;i<9;i++))
  do echo "parasplit(64, {$i}, {5}, 100, 8, {16});" >> \
      psp_$((64*(i)+24)).osql
  echo "q();" >> psp_$((64*(i)+24)).osql
done

for ((i=1;i<9;i++))
  do echo "parasplit(64, {$i}, {5}, 100, 8, {32});" >> \
      psp_$((64*(i)+40)).osql
  echo "q();" >> psp_$((64*(i)+40)).osql
done
