Build instructions:

First build logdir (Java 7 needed):
cd %amos_home%\logdir
compile
mkdmp

Then build svali:
cd %amos_home%\validate
compile
mkdmp
mkdll

Now build+start the wrapper:
cd %amos_home%\logdir\hlund
mkdmp
run
