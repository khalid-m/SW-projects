@echo off

echo Starting nameserver TORE...
start ..\..\bin\amos2.exe ..\..\bin\amos2.dmp tore.amosql

echo Starting server FOO...
start ..\..\bin\amos2.exe ..\..\bin\amos2.dmp foo.amosql

echo Starting server WC...
start ..\..\bin\amos2.exe ..\..\bin\amos2.dmp wc.amosql
