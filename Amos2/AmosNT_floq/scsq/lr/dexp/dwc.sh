#!/bin/bash

(( port = $(../../get_nsport.sh) ))
echo "Using nameserverport " $port

javascsq mysql-lr.dmp -o "nameserverport($port);" \
    -l "(trace server-eval)" -ns > DexpLog-$port&
javascsq mysql-lr.dmp -o "nameserverport($port);register('c1');sp_exename('javascsq');" $*
