#!/bin/bash

(( port = $(../bin/get_nsport.sh) ))
echo "Using nameserverport " $port
amos2 -o "nameserverport($port);" -O nbg_ns.osql > nbg_ns.log &
sleep 0.3
amos2 -o "nameserverport($port);" -O nbg_c1.osql > nbg_c1.log &
amos2 -o "nameserverport($port);" -O nbg_c2.osql > nbg_c2.log &
amos2 -o "nameserverport($port);" -O nbg_srv.osql
