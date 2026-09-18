#!/bin/bash

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

scsq.exe lr.dmp -l "(setq _batch_ t)" -o \
"check_q();nameserverport($port);nameserver('s');initsl('lr.dmp');listen();" \
    > $1.log 2>&1 &
scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" \
    -O $1

mkdir $HOME/$SLURM_JOBID
for i in `srun -n $SLURM_NNODES -N $SLURM_NNODES hostname -s`
  do mkdir $HOME/$SLURM_JOBID/$i;
  srun -n 1 -N 1 -w $i tar -cC$TMPDIR -f - . | (cd $HOME/$SLURM_JOBID/$i; tar xvf - )
done
