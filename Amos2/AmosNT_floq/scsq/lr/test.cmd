if exist o-0 del o-0
if exist o-2 del o-2
if exist o-3 del o-3
if exist o-lrtest15 del o-lrtest15
if exist o-lrtest15d del o-lrtest15d
if exist history-0.dmp del history-0.dmp
if exist history-1.dmp del history-1.dmp
if exist history-2.dmp del history-2.dmp
if exist history-3.dmp del history-3.dmp
if exist data\u1.bin del data\u1.bin
if exist data\u2.bin del data\u2.bin

call install

start /min cmd.exe /c lr -ns

call lr -O "src/test_setup.osql" -O "src/test.osql" -o "quit;"

if exist o-0 del o-0
if exist o-2 del o-2
if exist o-3 del o-3
if exist o-lrtest15 del o-lrtest15
if exist o-lrtest15d del o-lrtest15d
if exist history-0.dmp del history-0.dmp
if exist history-1.dmp del history-1.dmp
if exist history-2.dmp del history-2.dmp
if exist history-3.dmp del history-3.dmp
if exist data\u1.bin del data\u1.bin
if exist data\u2.bin del data\u2.bin

