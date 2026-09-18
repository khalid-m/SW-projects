#!/bin/bash
echo "Stopping MySQL server"
killall -u $USER mysqld
sleep 3

MYSQL_DATA=$HOME/Amos-MySQL/
rm -rf $MYSQL_DATA >/dev/null