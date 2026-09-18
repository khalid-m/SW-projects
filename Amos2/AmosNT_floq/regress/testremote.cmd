call killall

amos2 -L remoteeval.lsp

amos2 -L remotescan.lsp

call startservers

amos2 -o "wait_for('fie');" -O remote.osql -O shutdown.osql -o "quit;"
