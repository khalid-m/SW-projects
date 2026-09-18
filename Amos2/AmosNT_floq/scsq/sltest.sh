#!/bin/bash
# os
# qsub -pe dmp 8 -l h_rt=00:30:00 -cwd ./qtest.sh
#
# grad
# qsub -pe dmp8 8 -l h_rt=00:30:00 -cwd ./qtest.sh


if [ ! -n "$AMOS_HOME" ]; then
    echo AMOS_HOME is not set.
    exit 1
fi

#./install.sh

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

(( port = $(./get_nsport.sh) ))
echo "Using nameserverport " $port

../bin/scsq.exe scsq.dmp -l "(setq _batch_ t)"\
    -o "check_q();nameserverport($port);nameserver('s');initsl('');listen();" \
    > ScsqTestLog 2>&1 &
../bin/scsq.exe ../bin/scsq.dmp -O regress/master.osql -O regress/pipe.osql
../bin/scsq.exe ../bin/scsq.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" -O \
    regress/scsqlregress.osql

mkdir $HOME/$SLURM_JOB_ID
for i in `srun -n $SLURM_NNODES -N $SLURM_NNODES hostname -s`
  do mkdir $HOME/$SLURM_JOB_ID/$i;
  srun -n 1 -N 1 -w $i tar -cC$TMPDIR -f - . | (cd $HOME/$SLURM_JOB_ID/$i; tar xvf - )
done
