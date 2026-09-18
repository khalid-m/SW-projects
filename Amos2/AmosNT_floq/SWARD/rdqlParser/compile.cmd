@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

pushd %SWARD_ROOT%\SWARD\src\Java
javac -classpath ".;%SWARD_ROOT%\bin\javaamos.jar;%CLASSPATH%" -d %SWARD_ROOT%\SWARD\classes JavaCharStream.java JJTRdql2AmosState.java Node.java ParseException.java Rdql2Amos.java Rdql2AmosConstants.java Rdql2AmosTokenManager.java Rdql2AmosTreeConstants.java SimpleNode.java Start.java Token.java TokenMgrError.java
popd

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END

