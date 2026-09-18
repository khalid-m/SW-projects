rem copy "c:\program files\firebird\examples\employee.gdb" "c:\program files\firebird\examples\leksaksdatabas.GDB"


rem * uncomment this line in order to run the test without running as part of the
rem * master regression test.
if "%1" == "-s" start /min ..\..\..\bin\amos2 ../../../bin/amos2.dmp -n foo


javaamos %amos_home%/bin/amos2.dmp amostest.osql
