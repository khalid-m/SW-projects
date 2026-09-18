@echo off
rem Test SCSQ-LR in parallelized mode
start javascsq mysql-lr.dmp -l "(trace server-eval)" -ns
javascsq mysql-lr.dmp -O "test_parallel.osql" -o "quit;";