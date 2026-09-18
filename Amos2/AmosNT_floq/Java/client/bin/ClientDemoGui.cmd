start /min amos2 -n
start /min amos2 -s a
start /min amos2 -s b

amos2 -o "wait_for('b');quit;"
java -cp ;..\java\lib\PureJavaClient.jar;..\java\lib\jchart2d-3.2.2.jar; ClientDemoGUI
pause