@echo off
set NOREL=
call createdb
call mkdmp
javaamos tview.dmp tview_ex.osql tview_ex2.osql -L regress.lsp
