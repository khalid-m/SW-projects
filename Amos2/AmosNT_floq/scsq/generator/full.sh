#!/bin/bash

if [ ! $# -eq 1 ]; then
  echo Usage: $0 num_xways
  exit 1
fi

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe generator.dmp -o "nameserverport($port);" -l "(trace server-eval)" -ns > GenLog-$port &
../../bin/scsq.exe generator.dmp -o "nameserverport($port);" -o "writefiles('/scratch/erikz/ezgen/$1/cdp', 10000000, all($1, 100, bigxslayer($1)));q();"
