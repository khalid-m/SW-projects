#!/bin/bash
# os
# qsub -pe dmp 9 -l h_rt=02:30:00 -cwd ./qss.sh
#
# qrsh -pe dmp 9 -l h_rt=02:30:00 -cwd ./qss.sh
#
# grad
# qsub -pe dmp8 64 -l h_rt=00:30:00 -cwd ./qss.sh

./install.sh

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

scsq.exe lr.dmp -l "(setq _batch_ t)"\
    -o "check_q();nameserverport($port);nameserver('s');initqc('lr.dmp');listen();" \
    > QSSBIG.log 2>&1 &
scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" \
    -O experiment/dasfaa10_scaleup.osql -O experiment/expbig.osql
