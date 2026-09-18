#!/bin/bash

if [ ! -n "$AMOS_HOME" ]; then
    echo AMOS_HOME is not set.
    exit 1
fi

./install.sh

pushd JavaSCSQ
make clean
make HOSTTYPE=i386
popd

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

../bin/javascsq scsq.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &
javascsq scsq.dmp -O regress/master.osql -o "quit;"
javascsq scsq.dmp -o "nameserverport($port);sp_exename('javascsq');" \
    -O regress/scsqlregress.osql
