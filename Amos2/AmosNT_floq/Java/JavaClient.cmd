
javac JavaClient.java

start /min scsq -n
start /min scsq -s a

scsq -o "wait_for('a'); quit;"

java  -classpath ../bin/javaamos.jar;. JavaClient

taskkill /im scsq.exe /f
