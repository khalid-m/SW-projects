mkdir "%APACHE_HOME%\www\CourseManager"
copy %AMOS_HOME%\embeddings\Javascript\CourseManager\* "%APACHE_HOME%\www\CourseManager"

mkdir "%APACHE_HOME%\www\CourseManager\scripts"
copy %AMOS_HOME%\embeddings\Javascript\CourseManager\scripts\* "%APACHE_HOME%\www\CourseManager\scripts"

mkdir "%APACHE_HOME%\www\CourseManager\WEB-INF"
copy %AMOS_HOME%\embeddings\Javascript\CourseManager\WEB-INF\* "%APACHE_HOME%\www\CourseManager\WEB-INF"