(( port = $(./../../get_nsport.sh) ))
echo "Using nameserverport " $port

../../../bin/javascsq mysql-lr.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &
javascsq mysql-lr.dmp -o "nameserverport($port);sp_exename('javascsq');" \
  -O ./src/run_parallel.osql
