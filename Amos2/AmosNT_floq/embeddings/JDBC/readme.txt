JDBC driver for Amos II
-----------------------

The AmosJDBC system allows Amos II to be called through JDBC. It is described in 
http://user.it.uu.se/~udbl/Theses/GiedriusPovilaviciusMSc.pdf

JDBC driver installation: 

  1. Install and configure Amos II. 
  
  2. Compile test program by running 
       javac JdbcTest.java

  3. Test JDBC driver by running command procedure
     test.cmd

 If you are going to use the driver with the JDBC DriverManager, you
 would use "amosjdbc.AmosJdbcDriver" as the class that implements
 java.sql.Driver. 

 SQL requests in the JDBC driver are handled by an SQL compiler
 embedded in Amos II. It does not have full SQL functionality but
 merely implements basic facilities for accessing wrapped data sources
 through Amos II. For wrapping through SQL, relational table views are
 represented as Amos II functions beginning with the symbol '#' and
 defined only over literals (no objects). The arguments and results of
 the function are regarded as columns of the SQL view.  This is
 illustrated by the file sqlwrapper.amosql