@echo off
start amos2 -n name_serv
start amos2 -O idadb.osql
start amos2 -O isydb.osql
@echo To load the integrator
pause

REM Uncomment one of the two lines
amos2 -O lab_solution.osql
REM amos2 -O integrator.osql
