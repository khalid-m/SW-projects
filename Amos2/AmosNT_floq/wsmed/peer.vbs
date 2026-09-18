
set WshShell = createObject("Wscript.shell")
WshShell.run "javaAmos "+Wscript.Arguments(0)+" "+"-o "+"""register('P"+Wscript.Arguments(1)+"'); listen();""",2,false


