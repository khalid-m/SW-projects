@echo off
pushd %AMOS_HOME%\embeddings\wsmos\WEB-INF
amos2 wsmos.dmp -o "unload('E:\Courses\course_backup.amosql'); quit;"
popd