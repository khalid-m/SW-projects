#!/bin/bash

if [ "$MYSQL_HOME" == "" ]; then
  echo "*************************************************************"
  echo "* Please set environment variable MYSQL_HOME first!"
  echo "* The MySQL server for regression test could not be started"
  echo "*************************************************************"
  exit 1
fi

echo "Starting MySQL server"
pushd ../../../bin/
(( port = $(./start_mysql.sh) ))
  echo $port
popd

export PORTDB=$port


MYSQL_BIN=$MYSQL_HOME/bin
$MYSQL_BIN/mysql regress -u root -P $port --protocol=tcp < ./master.sql

# Regression test for MySQL implementation
javascsq mysql-lr.dmp -O "test-mysql.osql" -o "quit;"

#Test SCSQ-LR in single-node
javascsq mysql-lr.dmp -O "test_single_node.osql" -o "quit;";

../../../bin/kill_mysql.sh