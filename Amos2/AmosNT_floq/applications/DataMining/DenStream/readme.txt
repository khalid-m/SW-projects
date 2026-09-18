-------------------------------------------------------------------
This is an introduction from Jiaowei Tang about the file structure 
and how to run the program
-------------------------------------------------------------------


Introduction

Files in Denstream:
   compile.cmd-- compile all Java code

   mkdmp.cmd--build a database image with the schema and Amos II functions.
   DSM.cmd-- run Amos II with DenStreamMiner.
   test.cmd-- test the data and functions by querying the database

   createFun--creating queries wihout storing clusters into database
   test2.cmd--test the data and functions by querying without database

   \DenstreamMiner
      \src
        This folder contains the source code and '.class' files after compiling will be put here too.
        DenstreamMiner.java--clustering on data stream according to Denstream algorithm and it is a 
      modified version of Denstream algorithm. In DenstreamMiner, when new data point from the stream
      arrives, it is merged to nearest potential-micro-cluster first, and then nearest outlier-micro-cluster
      .This source code allows overlapping between micro-clusters. Each data point could be assigned to more 
      one micro-clusters.
        DenstreamMiner1.java-- It is similar to DenstreamMiner1.java. New data point will be merged into 
      nearest micro-cluster. Here,potential-micro-clusters don't have the higher priority to get the new coming
      data points.
      \data
        intializing.txt--data set is  used to initialize the stream.
        synthetic_data.txt--data set is used to produce the stream.
      \sql 
        with-database.osql--AmosII script of database schema and some functions.
        without-database.osql--AmosII script for online query of clustering result without store clusters into database
      \database
        Denstreamminer.dmp--the image of database
      \test
        with-database-test.osql--AmosII script to do some test on Denstream algorithm with clusters stored in database
        without-database-test.osql--AmosII script to do some test on Denstream algorithm with clusters not stored in database     

How to use the program:

   A. if clusters are stored into database, follow steps below

      1. run compile.cmd
      2. run mkdmp.cmd
      3. run test.cmd
      Remark: There is a small problem in javaamos, and after do step 2, you need to run "cd ..".

   B. if clusters are not stored into database, follow steps below 
      1. run compile.cmd
      2. run test2.cmd