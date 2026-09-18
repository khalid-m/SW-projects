#!/bin/bash
#
# sbatch -n 136 -p node -t 1:20:00 -A p2010008 ./slzip128.sh

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

scsq.exe lr.dmp -l "(setq _batch_ t)" -o \
"check_q();nameserverport($port);nameserver('s');initsl('lr.dmp');listen();" \
    > SLZIP128.log 2>&1 &
scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" \
    -O experiment/zip128.osql

mkdir $HOME/$SLURM_JOBID
for i in `srun -n $SLURM_NNODES -N $SLURM_NNODES hostname -s`
  do mkdir $HOME/$SLURM_JOBID/$i;
  srun -n 1 -N 1 -w $i tar -cC$TMPDIR -f - . | (cd $HOME/$SLURM_JOBID/$i; tar xvf - )
done
