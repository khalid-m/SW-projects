#!/bin/bash
echo "Starting MySQL server"
pushd ../../bin/
(( port = $(./start_mysql.sh) ))
  echo $port
popd

export URLDB=jdbc:mysql://localhost:$port/regress
export DRIVERDB=com.mysql.jdbc.Driver
export USERDB=regress
export PASSWORDDB=regress

javaamos -O mysqlpopulate.osql
sward sward.dmp company.amosql -o "quit;"
sward sward.dmp company_complete.amosql -o "quit;"
sward sward.dmp egov.amosql -o "quit;"

../../bin/kill_mysql.sh