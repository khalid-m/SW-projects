del logs\*.log
del output\*.csv
call killall
call mkdmp.cmd
call debs -O src/test1.osql
