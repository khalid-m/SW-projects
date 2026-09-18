@echo off

javac -classpath ../bin/javaamos.jar twocq.java  

start /min svali -n
start /min svali -s a

svali -o "wait_for('a'); quit;"

java -classpath ../bin/javaamos.jar;. twocq %1 %2

taskkill /im svali.exe /f
