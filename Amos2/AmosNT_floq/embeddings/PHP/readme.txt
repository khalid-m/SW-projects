		  How to install PHPAmos under WAMP
			      Tore Risch
			      2007-01-31


1. Set up WAMP
--------------

WAMP is a combined Windows installation of Apache Web Server, PHP, and
MySQL.  PHPAmos has been tested with WAMP5 2.0. It should work also
with other WAMP versions.
 
Download the WAMP installer from: 

   http://www.wampserver.com/en/

The tested version (WAMP 2.0) is also saved in
   http://user.it.uu.se/~udbl/software/WampServer2.0a.exe

WAMP is normally installed in the 'WAMP Home Directory', denoted
%WHD%, for example:

   C:/wamp

In the rest of the text you should replace %WHD% with the full name of
the WAMP home directory! Also set the environment variable WHD.

Put your http and php files in the directory:

    %WHD%/www

Copy the .php files in the %amos_home%/embeddings/PHP/htdocs/
subdirectory to %WHD%/www/.

When WAMP is up an running you can test it by typing into your
web browser:

   http://localhost/test.php

It will show everything about the PHP version you are running.

	 You have now succeeded in installing Apache and PHP!
			     Good Start!


2. Install PHPAmos as plug-in to PHP
------------------------------------

The external module PHPAmos imlements the interface between Amos II
and the PHP engine (called Zend). PHPAmos is implemented as a DLL
located in folder %amos_home%/bin. The DLL is dynamically loaded into
the plug-in of PHP under Apache.
 
NOTICE: I am forced to tell you that the Zend Engine is freely
available at http://www.zend.com. php_amos.dll redistributes parts of
the ZendEngine binaries. These are coverend by the Zend Engine
License, version 2.00, in file
%amos_home%/embeddings/PHP/ZendLicense.txt.

2.1 Deploy PHPAmos

      Copy to the appache bin directory (e.g.
      %WHD%\bin\apache\apache2.2.6\bin) the file:
      
           %amos_home%\bin\amos2.dmp
     
      Copy to the PHP bin directory (e.g. %WHD%\bin\php\php5.2.5\ext)
      the files:

           %amos_home%\bin\php_amos.dll
           %amos_home%\bin\msvcrtd.dll

NOTICE: Stop WAMP before copying the files as old copies may be
locked.

2.2 Configure PHP

PHP is configured by directives in a file named php.ini in the Apache
home directory, e.g.:

  %WHD%\bin\apache\apache2.2.6\bin\php.ini

Edit it! 

2.2.1 Look for the line: 

;Windows Extension

Insert after it the line

   extension=php_amos.dll

2.2.2 Look for the line:

   module settings:

Insert after it the lines:

   [amos]
   ; file for Amos II initialization
   amos.image = amos2.dmp
   amos.output = %WHD%/logs/PHPAmos.log

NOTICE: Look in the log file if your web server does not start or
crashes! The function 'print' in AmosQL will print to this file too.

You may optionally define an AmosQL configuration file for the
embedded Amos II system running inside the web server by specifying:

   amos.init = <AmosQL-file>

The configuration script is run once after the an embedded Amos II
system is initialized inside the web server. All errors and other
outputs happening during the execution of the initialization script
will be printed to the log file.

2.3 Run PHPAmos under Apache

2.3.1 Restart WAMP

2.3.2 Test by loading the two documents:

      http://localhost/test.php  (basic PHP)
      http://localhost/test2.php (testing PHPAmos)

Look in %WHD%/logs/php_error.log if php_amos.dll is not loaded.

Look in %WHD%/logs/PHPAmos.log for errors during initialization when
running test2.php.

	    If this works you have PHPAmos up and running under WAMP.
			   Congratulations!


3. PHPAmos guide 
----------------

The interface between PHP and Amos II is very simple. Essentially a
PHP script may connect to some Amos II peer and then execute AmosQL
commands or call AmosQL functions there. The following PHP interface
functions are defined (signatures added for clarity):

3.1 Connecting to Amos II peer

amos_connect(peer_name)->connection

e.g.

$con = amos_connect("myserver");

amos_connect opens a connection to the specified Amos II peer managed
by an Amos II name server running on the same machine as the web
server. You have to set the Amos II peer beforehand, e.g. by executing
the OS command:

  amos2 -n myserver

See http://user.it.uu.se/~udbl/amos/doc/amos_users_guide.html#peers
for how to run several distributed Amos II peers.

You can specify a different host than the webserver's host for the
Amos II name server by adding this to the PHPAmos configuration script:

  nameserverhost("<hostname>");
  e.g.
  nameserverhost("hagrid.it.uu.se");

If the empty string is specified (amos_connect("")) the connection is
made to a local transient Amos II database running inside PHP. The
local database persists as long as the web server is up and running.

The local Amos II system lacks a some facilities available in a
regular Amos II system, e.g. possibility to call Java, C, and
JDBC. When such facilities are needed a separate Amos II peer has to
be set up and connected to, as in the above example.

The connection is automatically closed when the script exited.

You can have several connections open to different Amos II peers.

3.2 Evauating AmosQL statement

  amos_execute(connection, query) -> scan
e.g.
  $scan = amos_execute($con,"1+2+3;");

amos_execute evaluates the specified AmosQL statement as a string in the
peer specified by 'connection'.

The result of amos_execute is a 'scan', which is a list of rows where
each row is represented as a PHP array. 

  amos_eos(scan)->boolean

returns true if there are no more rows in the scan.

  amos_getrow(scan)->array

returns the current row in the scan as a PHP array. NULL is returned
if there are no rows left in the scan.

3.3 Calling AmosQL functions

  amos_call(connection,functionname,arg1,...)->scan
e.g.
  $scan = amos_callfunction($con, "plus", 1, 2);

amos_call calls the specified Amos II function with the specified
arguments. Returns a scan as amos_excute.


		     That's the entire interface!
			   Keep it simple!

3.4 Hints

Q1: How are updates specified?

Hint: Use amos_call and see section 2.5.3 in Amos II User's Manual.

Q2: What about transactions?

Each amos_execute or amos_call is transactional
(auto-committed).

Q3: What about advanced data manipulation?

Use stored procedures
(http://user.it.uu.se/~udbl/amos/doc/amos_users_guide.html#procedures)
to make advanced database updates. Install the stored procedures in
the Amos II peer where they are used.

For example, it might sometimes be a good idea to collect all updates
in a web page and send them to the Amos II server peer for processing
there by a stored procedure in a single (transactional) call.

Q3: How about persistency?

Normally persistency is provided by wrapping, e.g. a relational
database, through some Amos II peer (see
http://user.it.uu.se/~udbl/amos/doc/amos_users_guide.html#mediatorfns).

However, you can make PHPAmos save the local database state on disk
automatically by adding this line in the PHPAmos configuration script:

   autosave(true);

After this call updates are saved in the amos.image file of the PHP
configuration when the PHP script is exited.

NOTICE that it may be slow to save very large local databases in this
way.

