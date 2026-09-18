start /min amos2 -n
start /min amos2 -s a

amos2 -o "wait_for('a'); quit;"
java -cp ;..\jarFiles\PureJavaClient.jar; ClientDemo
