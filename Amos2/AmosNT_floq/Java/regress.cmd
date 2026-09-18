start /min ..\bin\testnameserver.cmd
gmake test
taskkill /im amos2.exe /f
