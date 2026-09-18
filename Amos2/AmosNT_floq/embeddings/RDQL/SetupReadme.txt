1. Changing the RDQL grammar
----------------------------

This task is needed only when you want to generate a new parser Java
program. The generated Java source code is stored in the CVS directory
so you do not need to perform this task if you are not changing the
grammar and you then don't need to download JavaCC.

1.1 Download JavaCC from
      https://javacc.dev.java.net/servlets/ProjectDocumentList.

1.2 Set the JAVACC_HOME variable to the home directory of JavaCC.

1.3 Set up system environment variables for Java compiler with
      setup.cmd

1.4 Generate the parser with
      genparser.cmd

2. Generate jar files
---------------------

   Compile the Java code of the parser and include in
   AmosNT/bin/RDFAmos.jar with 
      compile.cms


See readme.txt for how to use RDQLFront once system is set up.

