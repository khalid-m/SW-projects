(( port = $(./../../get_nsport.sh) ))
echo "Using nameserverport " $port

../../../bin/scsq.exe lrdexp.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &
../../../bin/scsq.exe lrdexp.dmp -o "nameserverport($port);" -O experiments.osql
