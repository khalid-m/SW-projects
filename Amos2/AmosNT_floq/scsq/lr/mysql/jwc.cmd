@echo off
start javascsq mysql-lr.dmp -l "(trace server-eval)" -ns
javascsq mysql-lr.dmp -o "sp_exename('javascsq');"