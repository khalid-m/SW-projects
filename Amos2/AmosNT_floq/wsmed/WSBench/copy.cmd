mkdir "%APACHE_HOME%\www\WSBench"
copy %AMOS_HOME%\wsmed\WSBench\* "%APACHE_HOME%\www\WSBench"


mkdir "%APACHE_HOME%\www\WSBench\WEB-INF"
copy %AMOS_HOME%\wsmed\WSBench\WEB-INF\* "%APACHE_HOME%\www\WSBench\WEB-INF"


mkdir "%APACHE_HOME%\www\WSDL"
copy %AMOS_HOME%\wsmed\wsdl\WSBENCH.wsdl "%APACHE_HOME%\www\WSDL"


mkdir "%AMOS_HOME%\wsmed\WSBench\src\java"
copy %AMOS_HOME%\wsmed\WSBench\classes\* "%AMOS_HOME%\wsmed\WSBench\src\java"

mkdir "%APACHE_HOME%\www\information"

create_infor.bat




