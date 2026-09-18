msdev localThreads.dsw /make "localThreads - Win32 Debug"
msdev crashtest.dsw /make "crashtest - Win32 Debug"
msdev crashex.dsw /make "crashex - Win32 Debug"

@echo ------------------
@echo LocalThreads check
@echo ------------------
localThreads %AMOS_HOME%/bin/amos2.dmp "< 'defs.osql';" 1000 10 niota
localThreads %AMOS_HOME%/bin/amos2.dmp "< 'defs.osql';" 2 1000 cciota
localThreads %AMOS_HOME%/bin/amos2.dmp "< 'defs.osql';" 2 1 zbg

@echo ------------------
@echo Coroutine background check
@echo ------------------
@crashtest %AMOS_HOME%/bin/amos2.dmp "< 'crashtest.osql';" > tmpfile
@crashex "ERROR: Calling Amos II from background thread"
@del tmpfile
