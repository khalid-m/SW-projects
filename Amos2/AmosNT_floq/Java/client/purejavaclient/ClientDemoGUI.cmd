start /min amos2 -n
start /min amos2 -s a
start /min amos2 -s b

amos2 -o "wait_for('b');quit;"
java -cp ;%~dp0jarFiles\PureJavaClient.jar;%~dp0jarFiles\jchart.jar; ClientDemoGUI
