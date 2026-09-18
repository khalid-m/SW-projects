call install
start ..\..\bin\scsq.exe css.dmp -ns
call css -O "src/test.osql" -o "quit;"
