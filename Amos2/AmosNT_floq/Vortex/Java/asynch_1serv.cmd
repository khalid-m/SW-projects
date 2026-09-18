@echo off

javac -classpath ../bin/javaamos.jar asynch_1serv.java  

start /min svali -n
start /min svali -s a

svali -o "wait_for('a'); quit;"

java -classpath ../bin/javaamos.jar;. asynch_1serv

taskkill /im svali.exe /f
