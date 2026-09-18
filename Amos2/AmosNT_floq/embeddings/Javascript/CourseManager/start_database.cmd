@echo off

echo --------------------------------------------------
echo starting  wsmos database .....
echo --------------------------------------------------
start amos2 -n

pushd "%AMOS_HOME%\"embeddings\wsmos

call startDatabase
popd