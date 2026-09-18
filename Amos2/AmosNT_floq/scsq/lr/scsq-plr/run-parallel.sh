(( port = $(./../../get_nsport.sh) ))
echo "Using nameserverport " $port

../../../bin/javascsq lrdexp.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &
javascsq lrdexp.dmp -o "nameserverport($port);sp_exename('javascsq');" \
  -O lrdexp.osql
