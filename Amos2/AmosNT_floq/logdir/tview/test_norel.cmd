@echo off
set NOREL=1
call mkdmp
call javaamos tview.dmp tview_ex.osql -L regress.lsp
set NOREL=
