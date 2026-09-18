#!/bin/bash

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe lr.dmp -o "nameserverport($port);" -l "(trace server-eval)" -ns > LRTestLog&
../../bin/scsq.exe lr.dmp -o "nameserverport($port);" -O "src/bintree.osql" -o "quit;"
