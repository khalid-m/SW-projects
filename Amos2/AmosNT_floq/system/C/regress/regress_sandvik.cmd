msdev multiScanSandvik.dsw /make "multiScanSandvik - Win32 Debug"

@echo -------------------
@echo MultiScanSandvik check
@echo -------------------
multiScanSandvik %AMOS_HOME%/bin/scsq.dmp
