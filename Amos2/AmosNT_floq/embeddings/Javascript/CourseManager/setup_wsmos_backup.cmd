@echo off

echo --------------------------------------------------
echo setup and compile  wsmos .....
echo --------------------------------------------------

pushd "%AMOS_HOME%\"embeddings\wsmos
call setup
call compile

echo --------------------------------------------------
echo mkdmp .....
echo --------------------------------------------------

IF EXIST wsmos.dmp del wsmos.dmp /q
call mkdmp

popd

echo --------------------------------------------------
echo adding courses .....
echo --------------------------------------------------

rem copy the backed up course data from  another disk
copy  "E:\Courses\course_backup.amosql" %AMOS_HOME%\embeddings\Javascript\CourseManager\osql\

rem wait some time for copying files
call  c:\UDBL\AmosNT\wsmed\wait 2

amos2 %AMOS_HOME%\embeddings\wsmos\WEB-INF\wsmos.dmp -o "load_amosql('osql/CMWS_backup.osql');load_amosql('osql/course_backup.amosql'); save '../../wsmos/WEB-INF/wsmos.dmp'; quit;"

