		     How to install and run ABKW


ABKW is a wrapper of the BerkeleyDB storage manager. It is described in
http://user.it.uu.se/~udbl/Theses/MaryamLadjvardiMSc.pdf

Before running ABKW you must download BerkeleyDB, compile ABKW, and 
link it to Amos II through its C/C++ interfaces. The following needs
to be done:

1. Download BerkeleyDB zip file 
   
   1.1 Download from http://www.sleepycat.com/download/db/index.shtml
   Extract to 'BDB home directory', e.g. C:\db-4.2.52.NC. The wrapper
   is tested for version 4.2.52.NC.

   1.2 Set environment variable BDB_HOME to the BDB home directory.

2. Compile BerkeleyDB

   2.1 You need to install MiscroSoft Visual Studio 6 to compile
   BerkeleyDB and the ABKW wrapper. 

   2.2 Go to subfolder 'build_win32' in BDB directory, open project
   'Berkeley_DB.dsw' and do 'Rebuild All'.

   If there are no compilation errors you have successfully compiled
   BerkelyDB!

   2.3 A new subfolder build_win32/Debug (can also be
   build_win32/Release) has been created in the BDB directory. There
   is a DLL there, e.g. libdb41d.dll; copy it to the Amos II home
   directory.

3. Compile ABKW

   Go to the subfolder wrappers/ABKW under Amos II home directory
   pointed to by enviroment variable %AMOS_HOME%.
   
   3.1 You should be able to install amos2 and ABKW by simply typing
       install.cmd

   3.2 To just compile the C-code, execute command:
         compile.cmd
       Ít does:
         nmake -f bkAmos.mak

   3.2 Alternatively you can compile interactively by opening project
   'bkAmos.dsw' and there do 'Rebuild All'.

       In case BerkekelyDB was built under build_win32/Release (rather
       than build_win32\Debug\, see 2.3) you have to change the
       'Objects/Library' module $(BDB_HOME)\build_win32\Debug\*.lib to
       $(BDB_HOME)\build_win32\Release\*.lib

   If there are no errors you have successfully compiled the ABKW
   wrapper and generated an executable in %amos_home%/bin/bkAmos.exe.

4. Generate ABKW database image

   3.1 Set environment variable BK_HOME to directory where BerkeleyDB
   database files should reside.

   3.2 Run mkdmp.cmd It will create a database image containing
   both Amos II and ABKW in %AMOS_HOME%/bin/abkw.dmp.

5. Test ABKW

   You now have an Amos II system with loaded ABKW wrapper in the two
   files bkamos.exe and abkw.dmp in %AMOS_HOME%/bin.

   5.1 Run ABKW with:
       ABKW.cmd
       It executes the command:
       bkamos %AMOS_HOME%/bin/abkw.dmp

   5.2 Populate the BerkeleyDB database:
        ABKW
        < 'populate.amosql';
        quit;

   5.3 Eaxmples of queries to wrapped BerkeleyDB database:
        ABKW
        < 'search.amosql';

  
If everything works you now have a running AmosII system with ABKW
wrapper!
