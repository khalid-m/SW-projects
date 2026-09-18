#!/bin/bash

pushd ..
./install.sh
popd
./install.sh

# clean up
for i in cdp_mid15.bin cdp_lite40.bin
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

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe lr.dmp -o "nameserverport($port);" -l "(trace server-eval)" -ns > LRTestLog&
../../bin/scsq.exe lr.dmp -o "nameserverport($port);" -O "src/t4bin.osql" -o "quit;"
