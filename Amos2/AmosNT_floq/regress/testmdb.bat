start ..\bin\amos2 -O it1.osql -n foo
start ..\bin\amos2 -O it2.osql -s fie
pause
amos2 -O remote.osql -o "quit;"
amos2 -O mdb.osql -o "quit;"


