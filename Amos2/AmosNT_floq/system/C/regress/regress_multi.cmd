msdev multiScan.dsw /make "multiScan - Win32 Debug"

@echo -------------------
@echo MultiScan check
@echo -------------------
multiScan %AMOS_HOME%/bin/amos2.dmp
