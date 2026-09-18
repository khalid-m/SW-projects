Here is an introduction about how to install the WSBENCH:

1. Make sure that the AmosNT has been installed correctly.

2. Download and install the software Wampserver
   purpose: Use Apache server of WampServer as our web service 
   Installation: download the software from http://user.it.uu.se/~udbl/software/WampServer2.0a.exe
   Then make sure that the "httpd.conf" has been created correctly. The file is under the directory %wamp_home%\bin\apache\Apache2.2.6\conf

3. Set environment variables:
   3.1 Set APACHE_HOME to the parent of the Wampserver home directory e.g. c:\WAMP
   3.2 Set WSDL_HOME to a WSDL directory in Wampserver %APACHE_home%\www\wsdl

4. Load the Berlin Benchmark dataset
   Open MySQL console input your password and then pass in the following SQL commmand under mysql>
   sql command: source C:\AmosNT\wsmed\WSBench\MySQL_Dataset\Berlin_Benchmark.sql 
   If you did not install AmosNT under C:\, then you have to find the correct directory for the file Berlin_Benchmark.sql.

5. Start the WSBENCH:
   Run WSBench.cmd
