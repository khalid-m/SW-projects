@echo off
if not exist SparQL.dmp call mkdmp.cmd
.\exe\SparQL.exe SparQL.dmp %1