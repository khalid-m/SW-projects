#!/bin/bash
export PORTDB="3036"



(( port = $(../../get_nsport.sh) ))
echo "Using nameserverport " $port


../../../bin/javascsq mysql-lr.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &

javascsq mysql-lr.dmp -o "nameserverport($port);sp_exename('javascsq');Connect_jdbc();" \
    -O src/test_Regress.osql
