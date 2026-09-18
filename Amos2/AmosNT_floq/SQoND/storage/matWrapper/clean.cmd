del ..\bin\matWrapper.dll
rem del ..\bin\matWrapper.lib

msdev MVC/matWrapper.dsw /make "matWrapper - Win32 Release" /clean
msdev MVC/matWrapper.dsw /make "matWrapper - Win32 Debug" /clean
