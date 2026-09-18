#!/bin/bash

(( port = $(./get_nsport.sh) ))
echo "Using nameserverport " $port

svali.exe profileUppmax.dmp -o "nameserverport($port);" -n s > SvaliLog-$port &
svali.exe profileUppmax.dmp -o "nameserverport($port);register('c1');" $*