
set INCLUDE_TEMP=%INCLUDE%
set LIB_TEMP=%LIB%
set INCLUDE=%INCLUDE%;C:\Program Files (x86)\National Instruments\LabVIEW 2010\cintools
set LIB=%LIB%;C:\Program Files (x86)\National Instruments\LabVIEW 2010\cintools
msdev amos.dsw /make "amos - Win32 Release"
set INCLUDE=%INCLUDE_TEMP%
set LIB=%LIB_TEMP%
