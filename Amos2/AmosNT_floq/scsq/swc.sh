#!/bin/bash

(( port = $(./get_nsport.sh) ))
echo "Using nameserverport " $port

../bin/scsq.exe scsq.dmp -o "nameserverport($port);" -ns > ScsqLog-$port&
../bin/scsq.exe scsq.dmp -o "nameserverport($port);register('c1');" $*
