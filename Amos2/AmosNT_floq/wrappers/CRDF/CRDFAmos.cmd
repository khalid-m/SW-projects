@echo off
if not exist CRDFAmos.dmp call mkdmp.cmd
.\exe\CRDFAmos.exe CRDFAmos.dmp %1