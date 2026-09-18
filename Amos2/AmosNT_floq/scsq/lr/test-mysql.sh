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

#./install.sh

#(( port = $(../get_nsport.sh) ))
#echo "Using nameserverport " $port

#javascsq lr.dmp -o "nameserverport($port);" \
#    -l "(trace server-eval)" -ns > LRTestLog&
    
javascsq lr.dmp \
     src/lr-mysql.osql -O "src/test_setup.osql" -O "src/test-mysql.osql" -o "quit;"
