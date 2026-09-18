#!/bin/bash

echo "Starting MySQL server"
pushd ../../../bin/
(( port = $(./start_mysql.sh) ))
  echo $port
popd

export PORTDB=$port

javaamos -O mysqltest.osql

../../../bin/kill_mysql.sh