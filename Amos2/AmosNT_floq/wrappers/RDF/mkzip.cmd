@echo off
call compile
call mkdmp

zip ../RDFAmos README ..\..\bin\amos2.exe ..\..\bin\javaamos.dll ..\..\bin\amos.dll ..\..\bin\javaamos.jar checkenv.cmd ..\..\bin\rdfamos.dmp run.cmd test.cmd classes/*.class
