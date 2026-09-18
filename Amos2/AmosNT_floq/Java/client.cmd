
javac ClientDemo.java

start /min amos2 -n
start /min amos2 -s a

amos2 -o "wait_for('a'); quit;"

java  -classpath ../bin/javaamos.jar;../wrappers/JDBC/;. ClientDemo ../bin/amos2.dmp

taskkill /im amos2.exe /f
