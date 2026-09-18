#!/bin/bash

pushd ../../../system/Unix && make
popd
pushd ../..
make scsq
pushd JavaSCSQ
make HOSTTYPE=i386
popd
popd
source mkdmp.sh
