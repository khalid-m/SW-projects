#!/bin/bash
# os
# qsub -pe dmp 8 -l h_rt=04:00:00 -cwd ./run_cluster.sh
#
# grad
# qsub -pe dmp8 48 -l h_rt=04:00:00 -cwd ./run_cluster.sh


if [ ! -n "$AMOS_HOME" ]; then
    echo AMOS_HOME is not set.
    exit 1
fi

# ./install.sh

for i in bin0 nbrollout.dmp
  do
  if [ -f data/$i ]
      then rm data/$i
  fi
done

for i in ret ret_out ret_out.csv
  do
  if [ -f $i ]
      then rm $i
  fi
done

(( port = $(../../get_nsport.sh) ))
echo "Using nameserverport " $port

scsq.exe lr.dmp -l "(setq _batch_ t)" \
    -o "check_q();nameserverport($port);nameserver('s');initge('lr.dmp');listen();" \
    > ScsqTestLog 2>&1 &
scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" \
    -O "lr.osql" -o "quit;"
