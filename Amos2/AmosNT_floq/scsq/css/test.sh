#!/bin/bash

./install.sh

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe css.dmp -o "nameserverport($port);" \
    -l "(trace server-eval)" -ns > TestLog&
./css.sh -o "nameserverport($port);" -O "src/test.osql" -o "quit;"
