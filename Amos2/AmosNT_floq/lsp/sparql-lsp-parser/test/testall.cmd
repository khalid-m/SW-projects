pushd %AMOS_HOME%\sward\regress
call testmaster
popd

rem OLD PARSER!
pushd %AMOS_HOME%\wrappers\TopicMap
call test
popd

rem OLD PARSER!
pushd %AMOS_HOME%\sard\sard_new\regress
call testmaster.cmd
popd

