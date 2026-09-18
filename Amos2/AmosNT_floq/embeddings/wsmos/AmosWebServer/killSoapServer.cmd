@echo off

FOR /F "tokens=2,5 delims= " %%G IN ('netstat -ano') DO (
if %%G==0.0.0.0:8082 set port=%%H)

taskkill /F /pid %port%