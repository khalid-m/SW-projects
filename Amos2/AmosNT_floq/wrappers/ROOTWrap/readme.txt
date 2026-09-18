======================================
Main files of the project:
======================================
C/amain.cpp and helpfunction.h - C++ code of the wrapper
wrapper3.amosql - AmosQL code of the wrapper
ROOTWrap.dsw and ROOTWrap.dsp - project files for VC++
C/Makefile - make file for gcc under Linux
compile.cmd - cmd script for compiling and linking ROOT wrapper by using make file for Windows
mkdmp.cmd - cmd script for creating the image file in Windows
mkdmp.sh - bash script for creating the image file in Linux
regress.cmd - cmd script runnning regression test
regress/ - source code for regression test
testmaster.cmd - compiles ROOT wrapper and execute regression test for it for Windows

ROOT wrapper can run on Windows and Linux machines. First, instructions for Windows 2000 is presented, then for Linux.

Test file for ROOT wrapper can be downloaded http://user.it.uu.se/~udbl/root/t.root to this directory. For example of usage of ROOT wrapper you can look to ALEH project %AMOSHOME%/aleh
The test file is needed for the regression test. To run the regression test the file should be copied to this directory.

=========================================
Windows 2000/XP, installation
=========================================

0. Assumes that AMOS II was checkout together with wrappers/ROOTWrap
1. Download ROOT library: ftp://root.cern.ch/root/root_v5.10.00.win32gdk.tar.gz
2. Unzip it in some permanent directory. Set new environment variable ROOTSYS to the home directory, where ROOT was unziped.
Include in path %ROOTSYS%\bin
If you get problem with compiling ROOT wrapper, because of ROOT library, then see root.install.html for more information.

3. If you don't have fresh version of amoslib.lib in %AMOSHOME%\bin then compile AMOS for Windows with VC++:
Go to %AMOS_HOME%\System\MVC\
Open the project amoslib.dsw in VC++
Build All or Export Makefile (check dependeces file) and run compile.cmd
(Note: %AMOSHOME%\bin\install.bat tries to install amoslib.lib)

4. Compiling ROOT wrapper: could be done in 2 ways
Go to %AMOS_HOME%\wrappers\ROOTWrap
4.1 Open the project ROOTWrap.dsw
Build All
4.2 Open the project ROOTWrap.dsw and create make files with dependencies
Compile and link by using compile script from command line

5. Create dump:
Run mkdmp script to generate the image file rootwrap.dmp

6. Run ROOT wrapper: ROOTWrap.exe rootwrap.dmp
You can access test file t.root, which you can download from http://user.it.uu.se/~udbl/root/t.root
You can also run regression test: regress.cmd. Note: t.root should be in this directory (%AMOS_HOME%\wrappers\ROOTWrap)

7. Regular regression test (ALL TOGETHER):
It requires that amoslib.lib is created, ROOTWrap.mak and ROOTWrap.dep are generated.
and t.root is downloaded from http://user.it.uu.se/~udbl/root/t.root into this directory (%AMOS_HOME%\wrappers\ROOTWrap)
To run the test simple run testmaster script in this directory.

=========================================
Linux, installation

0. Assumes that AMOS II was checkout together with wrappers/ROOTWrap

1. Download ROOT

2. Unzip ROOT, Set new environment variable ROOTSYS to the home directory, where ROOT was unziped.
Include in path %ROOTSYS%/bin

3. Compile AMOS for Linux
Go to %AMOS_HOME%/System/Linux/
See instructions there in readme.txt
(set environment varible before make)

4. Compiling ROOT wrapper
Go to %AMOS_HOME%/wrappers/ROOTWrap/C
make
Go to %AMOS_HOME%/wrappers/ROOTWrap
run script mkdmp.sh to create the image file rootwrap.dmp

5. Run ROOT wrapper
Go to %AMOS_HOME%/bin/
rootwrap.exe rootwrap.dmp

6. Download t.root and run regression test regress.sh
