#!/bin/bash

if [ ! -n "$AMOS_HOME" ]; then
    echo AMOS_HOME is not set.
    exit 1
fi

./install.sh

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

../bin/scsq.exe scsq.dmp -o \
    "nameserverport($port);nameserver('s');listen();" \
    -l "(trace server-eval)" > ScsqTestLog 2>&1 &
../bin/scsq.exe ../bin/scsq.dmp -O regress/master.osql -o "quit;"
../bin/scsq.exe ../bin/scsq.dmp -o "nameserverport($port);" -O \
    regress/scsqlregress.osql -O regress/bgcoregress.osql
