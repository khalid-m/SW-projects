#!/bin/bash

./install.sh

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe generator.dmp -o "nameserverport($port);" \
    -l "(trace server-eval)" -ns > GenTestLog&
sleep 2
../../bin/scsq.exe generator.dmp -o "nameserverport($port);" \
    -O "src/test.osql" -o "quit;"
