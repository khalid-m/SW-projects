(( port = $(./../../get_nsport.sh) ))
echo "Using nameserverport " $port

../../../bin/scsq.exe lrdexp.dmp -o "nameserverport($port);" -l "(trace server-eval)" \
    -ns > ScsqTestLog 2>&1 &

for i in `seq 0 $(expr $1 \- 1)`; do
       (javaamos lrdexp.dmp -O peer.osql -o "imagesize 20000000;connect_jdbc($i);" -s P$i &)
done

../../../bin/scsq.exe lrdexp.dmp -o "nameserverport($port);register('c1');" -O experiments.osql
