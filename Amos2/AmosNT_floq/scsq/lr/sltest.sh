#!/bin/bash


# clean up
for i in cdp_mid15.bin cdp_lite40.bin u1.bin u2.bin
  do
  if [ -f data/$i ]
      then rm data/$i
  fi
done

for (( i=0 ; i<6 ; i++ ))
  do
  if [ -f "writefiles-test$i" ]
      then rm writefiles-test$i
  fi
done

## ./install.sh

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe lr.dmp -l "(trace server-eval)" \
    -o "check_q();nameserverport($port);nameserver('s');initsl('lr.dmp');listen();" \
    > SLTestLog&
../../bin/scsq.exe lr.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" -O \
    -O "src/test_setup.osql" -O "src/test.osql" -o "q();"

mkdir $HOME/$SLURM_JOBID
for i in `srun -n $SLURM_NNODES -N $SLURM_NNODES hostname -s`
  do mkdir $HOME/$SLURM_JOBID/$i;
  srun -n 1 -N 1 -w $i tar -cC$TMPDIR -f - . | (cd $HOME/$SLURM_JOBID/$i; tar xvf - )
done
