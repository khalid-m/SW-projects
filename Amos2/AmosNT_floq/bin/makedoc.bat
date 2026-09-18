@echo off

echo Initializing evnironment...
set SAVE_CLASSPATH=%CLASSPATH%
set CLASSPATH=..

echo Compiling classes...
cd ..\Java\callin
javac Connection.java Scan.java Tuple.java Oid.java AmosException.java
cd ..\callout
javac CallContext.java

if not exist ..\doc goto notexist
echo Removing old Java-documentation...
del ..\doc\*.html
goto cont

:notexist
echo Making doc directory...
mkdir ..\doc

:cont
echo Building Java-documentation...
javadoc -private -version -author -d ..\doc callin callout

echo Cleaning up...
del CallContext.class
cd ..\callin
del Connection.class Scan.class Tuple.class Oid.class AmosException.class
set CLASSPATH=%SAVE_CLASSPATH%
set SAVE_CLASSPATH=
cd ..\..\bin

echo Done.
