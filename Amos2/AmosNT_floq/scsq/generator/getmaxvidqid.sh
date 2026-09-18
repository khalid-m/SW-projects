#!/bin/bash

if [ ! $# -eq 2 ]; then
  echo Usage: $0 min_xway max_xway
  exit 1
fi

for ((i=$1; i<=$2; i++)); do echo set maxqid\($i\) = `tail -n 1000 $i/cardatapoints.out | grep -v ^0|tail -n 1 |awk 'BEGIN {FS=","} {print $10}'`";";done

for ((i=$1; i<=$2; i++)); do echo set maxvid\($i\) = `cat $i/maxCarid.out`";";done
