pushd ..\system\MVC
call compile
popd
set no_source=1
pushd ..\validate
call install
popd

copy /Y ..\bin\amos2.dll bin
copy /Y ..\bin\JavaAmos.dll bin
copy /Y ..\bin\amos2.exe bin
copy /Y ..\bin\amos2.lib bin
copy /Y ..\bin\amos2.DMP bin
copy /Y ..\bin\javaamos.jar bin
copy /Y ..\bin\xt.dll bin
copy /Y ..\bin\bt.dll bin
copy /Y ..\bin\JavaSCSQ.dll bin

copy /Y ..\bin\svali.exe bin
copy /Y ..\bin\svali.dmp bin
copy /Y ..\bin\svali.dll bin
copy /Y ..\bin\svali.lib bin

copy /Y ..\C\storage.h C
copy /Y ..\C\callin.h C
copy /Y ..\C\callout.h C
copy /Y ..\C\alisp.h C
copy /Y ..\C\a_time.h C
copy /Y ..\C\complex.h C
copy /Y ..\C\environ.h C
copy /Y ..\system\include\numarr.h C

svali -o "loadsystem('Sandvik','nov2012export.osql');"

copy /Y ..\Java\Foreign.java Java
copy /Y ..\Java\LenTest.java Java
copy /Y ..\Java\EvalTest.java Java
copy /Y ..\Java\javademo.osql Java

