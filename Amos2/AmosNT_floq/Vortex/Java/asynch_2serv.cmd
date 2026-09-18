@echo off

javac -classpath ../bin/javaamos.jar asynch_2serv.java  

start /min svali -n
start /min svali -s a
start /min svali -s b

svali -o "wait_for({'a','b'}); quit;"

java -classpath ../bin/javaamos.jar;. asynch_2serv

taskkill /im svali.exe /f
