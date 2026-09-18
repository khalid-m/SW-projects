set pythonpath=%AMOS_HOME%\bin
amos2 -O regress/savepython.osql
amos2 foo.dmp -L "regress/testsave.lsp"
python regress/callin.py
amos2 -O regress/callout.osql -o "quit;"
