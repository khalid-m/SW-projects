#!/bin/bash

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe generator.dmp -o "nameserverport($port);" -l "(trace server-eval)" -ns > GenTestLog&
../../bin/scsq.exe generator.dmp -o "nameserverport($port);"
