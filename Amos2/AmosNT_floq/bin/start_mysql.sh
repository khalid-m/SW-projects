#!/bin/bash
(( port = $(./get_mysqlport.sh) ))
  echo $port

if [ "$MYSQL_HOME" == "" ]; then
  echo "*******************************************************************************"
  echo "* Please set environment variable MYSQL_HOME first!"
  echo "* The MySQL server for regression test could not be started"
  echo "*******************************************************************************"
  exit 1
fi

# Important: do not echo anything more, just the port number above
MYSQL_BIN=$MYSQL_HOME/bin
MYSQL_SCRIPTS=$MYSQL_HOME/scripts/
MYSQL_DATA=$HOME/Amos-MySQL/

rm -rf $MYSQL_DATA >/dev/null 2>&1
mkdir $MYSQL_DATA >/dev/null 2>&1
mkdir $MYSQL_DATA/data >/dev/null 2>&1

pushd $MYSQL_HOME >/dev/null 2>&1

./scripts/mysql_install_db --datadir=$MYSQL_DATA/data --basedir=$MYSQL_HOME >/dev/null 2>&1
./bin/mysqld_safe --no-defaults --datadir=$MYSQL_DATA/data --pid-file=$MYSQL_DATA/pid --log-error=log.txt --port=$port >/dev/null 2>&1 &

sleep 3 >/dev/null 2>&1 #wait for mysqld to start
popd >/dev/null 2>&1
$MYSQL_BIN/mysql -u root -P $port --protocol=tcp < ./start_mysql.sql >/dev/null 2>&1