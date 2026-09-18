echo off
pushd "%AMOS_HOME%"\embeddings\wsmos
set /a count1=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.class) do (set /a count1+=1)
echo "number of class  files exist with wsmos  " %count1%
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.dmp) do (set /a count1+=1)
echo "number of class & dmp files exist with wsmos  " %count1%
del /S *.class
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.dmp) do (if not %%X == %AMOS_HOME%embeddings\wsmos\WEB-INF\wsqs.dmp del %%X)
popd
pushd "%AMOS_HOME%"\wsmed
set /a count1=0
for /r %AMOS_HOME%\wsmed  %%X in (*.class) do (set /a count1+=1)
for /r %AMOS_HOME%\wsmed %%X in (*.dmp) do (set /a count1+=1)
echo "number of class & dmp files exist with wsmed " %count1%
del /S *.class
del /S *.dmp
popd
set /a count1=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.class) do (set /a count1+=1)
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.dmp) do (set /a count1+=1)
echo "number of class & dmp files exist with wsmos  " %count1%

set /a count1=0
for /r %AMOS_HOME%\wsmed %%X in (*.class) do (set /a count1+=1)
for /r %AMOS_HOME%\wsmed %%X in (*.dmp) do (set /a count1+=1)
echo "number of class & dmp files exist with wsmed " %count1%
popd
   