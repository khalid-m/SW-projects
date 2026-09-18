#!/bin/bash

if [ ! $# -eq 2 ]; then
  echo Usage: $0 experiment_number osql_file
  exit 1
fi

pushd /scratch/erikz/e

if [ ! -d $1 ]; then
    mkdir $1
    mkdir $1/times
    mkdir $1/proctime
    mkdir $1/proctime/comm
    for experiment in setup bc fo; do
	mkdir $1/proctime/$experiment
	for tree in bin exp flat twomax hyb var; do
	    	mkdir $1/proctime/$experiment/$tree
	done
    done

    for experiment in setup fo; do
	for tree in bin exp flat twomax hyb var; do
	    for exponent in 2 4 8 16 32 64 128 256 512; do
		mkdir $1/proctime/$experiment/$tree/$exponent
	    done
	done
    done

    for tree in bin exp flat twomax hyb var; do
	for bc in 0 5 10 48 50 100 500 1000; do
	    mkdir $1/proctime/bc/$tree/$bc
	done
    done
fi

popd

sleep 10

(( port = $(../get_nsport.sh) ))
echo "Using nameserverport " $port

../../bin/scsq.exe lr.dmp -o "nameserverport($port);" \
    -ns > LRCommLog&
../../bin/scsq.exe lr.dmp -o "nameserverport($port);" \
    -o "experiment($1);" -O "$2" -o "quit;"
