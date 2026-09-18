=======================================================================
 How to reproduce experiment results in SWARD measuring:

 1. Optimization time
 2. Execution time
 
 of SPARQL queries to UPVs while scaling the query + UPV definition size and the 
 database size (using TPC-H), respectively. 
=======================================================================

A) Scale synthetic content query and UPV definition size and measure 
   optimization time defined as optimization in SWARD + cost based optimization in MSSQL Server
   (synopt.amosql) for END(P), DPS and DVS-P.

   Database size (nt=1, nc=8) the query (SQ2_1tbl_?) was scaled the from 0-7 joins (step 1) joins, 
   that is, the ppt was scaled from 1-8. Use script synopt1db.cmd to generate the 
   test database.

   Database size (nt=8, nc=10) the query (SQ2_8tbl_?) was scaled the from 3-31 (step 4) joins, 
   that is, the ppt was fixed to 4 but the number of relational joins was scaled from 0-7.
   Use script synopt10db.cmd to generate the database. 

   For BE use synbopt.sql. 

B) Scale database size for content query Q2 using the TPC-H benchmark (on UDBL server under /software) 
   and measure execution time defined as time to execute the query in MSSQL Server (q2exec.amosql) for
   END(P), DPS and DVS-P.

   For BE use q2bexec.sql. 

C) Scale number of mapped properties extracted from a mapped class in hybrid query Q3 measuring
   optimization time (q3opt.amosql) and execution time (q3exec.amosql). Use tpchdb.cmd to generate 
   synthetic database.

 