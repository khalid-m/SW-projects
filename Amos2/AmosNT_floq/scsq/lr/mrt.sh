#!/bin/bash

ts=`head -n 1 o0|sed 's/)//'|awk '{print $7}'`

export ts

echo "tstart:" $ts

cat o* |grep "#(0" |\
    awk 'BEGIN {ts = ENVIRON["ts"]} \
    {a[$3] = $7 - ts - $3} \
    END {for (i in a) {print i, a[i]}}' |sort -n > t0
echo t0 done

cat o* |grep "#(1" |\
    awk 'BEGIN {ts = ENVIRON["ts"]} \
    {a[$2] = $6 - ts - $2} \
    END {for (i in a) {print i, a[i]}}' |sort -n > t1
echo t1 done

cat o* |grep "#(2" |\
    awk 'BEGIN {ts = ENVIRON["ts"]} \
    {a[$2] = $7 - ts - $2} \
    END {for (i in a) {print i, a[i]}}' |sort -n > t2
echo t2 done

cat o* |grep "#(3" |\
    awk 'BEGIN {ts = ENVIRON["ts"]} \
    {a[$2] = $6 - ts - $2} \
    END {for (i in a) {print i, a[i]}}' |sort -n > t3
echo t3 done

for ((i=0; i<4; i++))
do
  cat t$i |\
      awk '{if (a[int($1/60)] < $2) a[int($1/60)] = $2} \
           END  {for (i in a) {print i ";" a[i]}}' |sort -n > mrt$i.csv
done
