@echo off

amos2 -O %AMOS_HOME%/applications/datamining/src/a3arm_solutions.osql -O run_old_propad.osql -o "quit;"

pause

amos2 %AMOS_HOME%/applications/datamining/amosMiner/amosMiner.dmp run_new_propad.osql -o "quit;"

pause