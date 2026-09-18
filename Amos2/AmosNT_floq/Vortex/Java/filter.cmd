@echo off

javac -classpath ../bin/javaamos.jar filter.java  

start /min svali -n
start /min svali -s a

svali -o "wait_for('a'); quit;"

java -classpath ../bin/javaamos.jar;. filter

taskkill /im svali.exe /f
