----------------------------------------------------------------------------------
A. INTRODUCTION
----------------------------------------------------------------------------------
Student Name	: Thanh Truong
Unix ID		: thtr1663
Master thesis	: Indexing nearest neighbor queries
Description	: This folder contains the implementation of X-tree based index
		structure.
				

----------------------------------------------------------------------------------
B. HOW TO USE
----------------------------------------------------------------------------------
B.0 Setting up environment
--------------------------------------------------------
In order to compile the program, the JAVA_HOME must be 
configured correctly. Run env.cmd to adjust the PATH
variable after that.

env.cmd

--------------------------------------------------------
B.1 CLEANING WORKSPACE
--------------------------------------------------------
clean.cmd

--------------------------------------------------------
B.2 Compiling the workspace
both C and Java code
--------------------------------------------------------
compile.cmd

--------------------------------------------------------
B.3 MAKING DATABASE IMAGE
--------------------------------------------------------
mkdmp.cmd

OR

mkdmp_photo.cmd 

It likes mkdmp.cmd but it does contains 
some more functions for photo application.

--------------------------------------------------------
B.4 RUNNING TEST
--------------------------------------------------------
B.4.1 PHOTO APPLICATION
--------------------------------------------------------
Run test_photo.cmd

In folder AmosXtree\test\data\pictures, there are 52
pictures currently for testing.

Example :
> q1("Caption19", 3);
gives 3 the most similar pictures to the one whose caption
is "Caption19"

> q2("Caption19", 0.65);
gives pictures which are "0.65" different from the "Caption19"
picture.
--------------------------------------------------------
B.4.2 SYSTEM TEST - INDEX INTEGRATION
--------------------------------------------------------
Run test.cmd

Regression script is Xtree\AmosXtree\regress.osql

--------------------------------------------------------
B.5 RUNNING STAND-ALONE SYSTEM
--------------------------------------------------------
AmosXtree.cmd


