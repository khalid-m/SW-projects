del ..\bin\ssdm.dll
del ..\bin\ssdm.lib

msdev MVC/ssdm.dsw /make "ssdm - Win32 Release" /clean
msdev MVC/ssdm.dsw /make "ssdm - Win32 Debug" /clean

del ..\bin\ssdm.dmp