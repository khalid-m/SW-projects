@echo off

javac -classpath javaamos.jar test_block.java  

start /min cmd /k svali testBlock.dmp -n
start /min cmd /k svali testBlock.dmp -s a

svali testBlock.dmp -o "wait_for('a'); quit;"

java -classpath javaamos.jar;. test_block

taskkill /im svali.exe /f
