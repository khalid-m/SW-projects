@echo off

javac -classpath ../../bin/javaamos.jar test_validate.java

start /min svali -n
start /min svali -s a

start svali -o "wait_for('a'); quit;"

java test_validate

taskkill /im svali.exe /f