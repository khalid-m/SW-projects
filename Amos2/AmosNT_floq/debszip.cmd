del Epic.zip

REM Adding binary files and libraries
zip Epic.zip bin/svali.exe bin/*.dll

REM Adding command lines
zip Epic.zip bin/killall.cmd debs2013/q1.cmd debs2013/q2.cmd debs2013/q3.cmd debs2013/q4.cmd debs2013/all.cmd debs2013/all_delays.cmd debs2013/delays.cmd debs2013/setup.cmd debs2013/debs.cmd

REM Adding database image
zip Epic.zip bin/debs.dmp

REM Adding source files
zip Epic.zip debs2013/src/schema_data.osql
zip Epic.zip debs2013/src/schema.osql
zip Epic.zip debs2013/src/q1.osql
zip Epic.zip debs2013/src/q2.osql
zip Epic.zip debs2013/src/q3new.osql
zip Epic.zip debs2013/src/q4.osql
zip Epic.zip debs2013/src/master.osql
zip Epic.zip debs2013/src/misc.lsp
zip Epic.zip debs2013/src/heatmap.lsp
zip Epic.zip debs2013/src/*.c
zip Epic.zip debs2013/wrappers/wrappers.*
zip Epic.zip debs2013/src/delays.osql

REM Adding log folders
zip Epic.zip debs2013/logs/readme.txt debs2013/output/readme.txt

REM Adding data files
zip Epic.zip debs2013/data/1stHalf.csv
zip Epic.zip debs2013/data/2ndHalf.csv

zip -D Epic.zip debs2013/index.html
