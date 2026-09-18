#!/bin/bash

(( port = $(./get_nsport.sh) ))
echo "Using nameserverport " $port

../bin/scsq.exe scsq.dmp \
    -o "check_q();nameserverport($port);nameserver('s');initqc();listen();" \
    > ScsqLog-$port&
../bin/scsq.exe scsq.dmp \
    -o "check_q();nameserverport($port);register('c1');waitfordaemons();" $*
