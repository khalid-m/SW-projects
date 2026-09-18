Compiling the PHPAmos sources
--------------------------------

The subfolder 'amos' contains the sources of the PHPAmos plugin to
Apache/PHP as well as a MicroSoft VisualStudio 6.0 C++ project file,
amos.dsw, for generating php_amos.dll. 

The compilation requires include files from the PHP sources for
Windows and libraries from the binary PHP installation.

1. Download and install Apache and PHP

See %amos_home%/embeddings/PHP/readme.txt for instructions on how to
download and install WAMP (Apache + PHP + MySQL).

2 Download PHP development version for Windows

The PHP sources and run time libraries used to compile the current
version of php_amos.dll are stored in 
   http://user.it.uu.se/~udbl/software/PHP.zip

If you need a newer version do the following:
 
2.1 Download 'Complete Source Code' of PHP version 5 in:

http://www.php.net/downloads.php

Unpack it in the 'PHP Source Directory', e.g. 

C:\PHP\php-5.2.5

Set environment variable PHP_SOURCE to PHP Source Directory!

2.2 Download the PHP version 5 Windows runtime library to the 'Win32
Home Directory', e.g.:

C:\PHP\php-5.2.5-Win32

Set environment variable PHP_BIN to the name of the Win32 Home
Directory.

3. Compile PHPAmos

Run the command procedure:

   compile.cmd 

The compilation will generate a file php_amos.dll in AmosNT/bin. 



Finally, see %amos_home%/embeddings/PHP/readme.txt how to deploy
PHPAmos when php_amos.dll is produced.
