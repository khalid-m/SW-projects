@echo off
REM Deleting the old zip file
del ..\DB2_3rdEx.zip

REM Adding common files
zip ..\DB2_3rdEx kd.jar kdtree.lsp lab3_stub.osql KDTreeIndex_Stub.java winequalitysample.csv

REM Adding readme.txt and setup.cmd
zip ..\DB2_3rdEx readme.txt
zip ..\DB2_3rdEx setup.cmd
zip ..\DB2_3rdEx assignment3.cmd
