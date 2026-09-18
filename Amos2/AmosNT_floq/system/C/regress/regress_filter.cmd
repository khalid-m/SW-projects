msdev filter.dsw /make "filter - Win32 Debug"

@echo -------------------
@echo Filter check
@echo -------------------
filter %AMOS_HOME%/bin/amos2.dmp
