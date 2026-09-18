@echo off
start javascsq mysql-lr.dmp -l "(trace server-eval)" -ns
javascsq mysql-lr.dmp -o "register('c1');sp_exename('javascsq');" %*