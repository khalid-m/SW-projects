if exist %AMOS_HOME%\bin\svali.dmp del %AMOS_HOME%\bin\svali.dmp
svali %AMOS_HOME%\bin\scsq.dmp -o "loadsystem('amosQL', 'init.amosql');save '../bin/svali.dmp';quit;"