
REM ****************************************************************************
REM SCSQ
REM 
REM Author: (c) UDBL
REM $RCSfile: install.bat,v $
REM $Revision: 1.2 $ $Date: 2013/05/17 14:27:52 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Installation script for Amos.
REM
REM ****************************************************************************

echo **************************************************************************
echo * Creating Pure java amos client Demo.
echo **************************************************************************

javac -cp ;%~dp0jarFiles\PureJavaClient.jar;%~dp0jarFiles\jchart.jar; %~dp0ClientDemoGUI.java
javac -cp ;%~dp0jarFiles\PureJavaClient.jar; %~dp0ClientDemo.java