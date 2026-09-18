msdev remoteThreads.dsw /make "remoteThreads - Win32 Debug"

@echo -------------------
@echo RemoteThreads check
@echo -------------------
remoteThreads %AMOS_HOME%/bin/amos2.dmp 5 2
