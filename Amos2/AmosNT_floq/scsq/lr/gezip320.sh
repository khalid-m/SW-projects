#!/bin/bash
# os
# qsub -pe dmp 8 -l h_rt=00:30:00 -cwd ./gezip.sh
#
# grad
# qsub -pe dmp8 8 -l h_rt=00:30:00 -cwd ./gezip.sh


(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

scsq.exe lr.dmp -l "(setq _batch_ t)" -o \
"check_q();nameserverport($port);nameserver('s');initge('lr.dmp');listen();" \
    > GEZIP320.log 2>&1 &
scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" \
    -O "experiment/zip320.osql"
