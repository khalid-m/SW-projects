	     Examples using the API between Java and SVALI
	     =============================================

This directory contains demos of the API between Java clients and
SVALI running as FDSMS servers. There are also some examples of how to
define foreign SVALI functions in Java.

NOTICE1: In order to run the Java API you must first download a 
32 bits version (!) of the Java JVM from

     http://www.oracle.com/technetwork/java/index.html

NOTICE2: You must set PATH to include ../bin

----------------------------------------------------------
A. Demonstration of Java client API to FDSMS servers

The following scripts demostrate how Java clients can call one or
several SVALI servers:

---------------
A1: Dynamic continuous query running on a FDSMS server

script: filter.cmd:
 
The script automatically starts a SVALI server and runs the Java
program 'filter.java' as a SVALI client. The server is stopped when the
program has ended.

The program 'filter.java' demonstrates the following

1. How a Java client can open several connections to a SVALI server in
different threads.

2. How a Java client dynamically installs a query function on a SVALI
server.

3. How a Java client runs a continuous query on a SVALI server.

4. How to display the result of the continuous query on the standard
   output

5. How to update the local SVALI database asynchrounously while the
continuous query is running. This simulates a user interaction with
the FDSMS according to slide 2 in
https://lists.smartvortex.eu/Meetings/20120605%20-%20Rome/Rom-12-Uppsala-06V2.pptx.

6. How to terminate a continuous query.

---------------
A2: Real-time display of two continuous queries from one FDSMS server

script: asynch_1serv.cmd

The script automatically starts a SVALI server and runs the Java
program 'asynch_1serv.java' as a SVALI client. The server is terminated
when the program has ended.

The program 'asynch_1serv.java' demonstrates how to asynchronously
process the result tuples from two different continuous queries
running on the same SVALI server, as required in slide 2 in
https://lists.smartvortex.eu/Meetings/20120605%20-%20Rome/Rom-12-Uppsala-06V2.pptx.

---------------
A3: Real-time display of two continuous queries from two FDSMS servers

script: asynch_2serv.cmd

The script automatically starts two SVALI servers and runs the Java
program 'asynch_2serv.java' as a SVALI client. The server is terminated
when the program has ended.

The program 'asynch_1serv.java' demonstrates how to asynchronously
process the result tuples from two different continuous queries
running on two different SVALI servers.

----------------------------------------------------------
B. Examples of foreign functions in Java

The following three Java source code files demonstrate how Amos II and
SVALI foreign functions can be defined in Java:

EvalTest.java
Foreign.java
LenTest.java

To dynamically load and define the foreign functions in the above
files do:

B1: You first need to download the Java virtual machine from
    http://www.oracle.com/technetwork/java/index.html

B2: Set PATH to include the directory 'bin' under the JDK

B3: javac -classpath ../bin/javaamos.jar LenTest.java EvalTest.java Foreign.java

B4: javaamos.cmd

B5: < 'javademo.osql';

The script javademo.osql dynamically loads the above Java programs
into Amos II. To test them, see instructions in javademo.osql.

