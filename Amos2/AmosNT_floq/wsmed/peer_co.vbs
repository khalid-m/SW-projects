
set WshShell = createObject("Wscript.shell")
WshShell.run "setup.cmd",1,false
WshShell.run "javaAmos "+Wscript.Arguments(0)+" "+"-o "+"""register('CO'); listen();""",2,false


