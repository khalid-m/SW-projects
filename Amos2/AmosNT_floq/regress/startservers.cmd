start /min testnameserver
..\bin\amos2 -o "wait_for('foo'); quit;"
start /min ..\bin\amos2 -O it2.osql -s fie
