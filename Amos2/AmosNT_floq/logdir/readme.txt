Notification of file creation events in directories.

Note: REQUIRES Java 7

To test:
cd %AMOS_HOME%\logdir
run.cmd
filestream('c:/some/dir');
move a file to c:/some/dir
observe the filename being returned
repeat above two steps until satisfied
end with CTRL+C

If using scans as in:
open :s for filestream('c:/some/dir');
next(:s);
the result will not appear until the internal scanbuffer is filled
