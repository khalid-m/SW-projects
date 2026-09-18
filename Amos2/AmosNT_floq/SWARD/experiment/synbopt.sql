 /*-*-sql-*-*******************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Johan Petrini, UDBL
 * 
 * Description: Scalability experiment increasing the synthetic content 
 * query size over a TPC-H database 0.03125 GB of data.
 * We measure optimization times for strategy Back-End.
 *
 * ID: SQ2bopt
 *
 * Parameters: We used database size (nt=1 (Customer tbl in TPC-H 0.03125), 
 * nc=8).
 * In the scenario with database size (nt=1, nc=8) the query was scaled 
 * the from 1-8 (step 1) where clauses, that is, the ppt was scaled from 1-8.
 *
 * The machine used was a PC with a 2.26 GHz Pentium 4 processor and 
 *
 * As DBMS we use MSSQL Server 2005 SP2.
 * Buffer size is 100 MB.
 *
 * All measurements against MSSQL Server are done with a cold database, 
 * that is, the MSSQL server is restarted for every new test. 
 *
 * Interbase/Firebird is stopped.
 *****************************************************************************/
/* Define pMap and cMap tbls and set property and class mappings
 */
create table PMAP(TN varchar(25), CN varchar(25), ONT varchar(25), PROPID varchar(50), 
                   primary key(TN,CN,ONT),unique(ONT,PROPID))

insert into PMAP values ('CUSTOMER','C_CUSTKEY','u','http://udbl.it.uu.se/schemas/company#CustID')
insert into PMAP values ('CUSTOMER','C_NAME','u','http://udbl.it.uu.se/schemas/company#Name')
insert into PMAP values ('CUSTOMER','C_ADDRESS','u','http://udbl.it.uu.se/schemas/company#Address')
insert into PMAP values ('CUSTOMER','C_NATIONKEY','u','http://udbl.it.uu.se/schemas/company#Nation')
insert into PMAP values ('CUSTOMER','C_PHONE','u','http://udbl.it.uu.se/schemas/company#Phone')
insert into PMAP values ('CUSTOMER','C_ACCTBAL','u','http://udbl.it.uu.se/schemas/company#Acctbal')
insert into PMAP values ('CUSTOMER','C_MKTSEGMENT','u','http://udbl.it.uu.se/schemas/company#Market')
insert into PMAP values ('CUSTOMER','C_COMMENT','u','http://udbl.it.uu.se/schemas/company#Comment')

create table CMAP(TN varchar(25), ONT varchar(25), CLASSID varchar(50),
                  primary key (TN,ONT),unique(ONT,CLASSID))

insert into CMAP values ('CUSTOMER','u','http://udbl.it.uu.se/schemas/company#Customer')

create view CUSTIDV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), KP.PROPID, cast(C.C_CUSTKEY as varchar(100)) from CUSTOMER C, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u'

create view NAMEV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_NAME as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_NAME' and P.ONT = 'u'

create view ADDRESSV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_ADDRESS as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_ADDRESS' and P.ONT = 'u'

create view NATIONIDV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_NATIONKEY as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_NATIONKEY' and P.ONT = 'u'

create view PHONEV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_PHONE as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_PHONE' and P.ONT = 'u'

create view ACCTBALV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_ACCTBAL as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_ACCTBAL' and P.ONT = 'u'

create view MKTSEGMENTV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_MKTSEGMENT as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_MKTSEGMENT' and P.ONT = 'u'

create view COMMENTV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.C_CUSTKEY as varchar(25)), P.PROPID, cast(C.C_COMMENT as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'C_CUSTKEY' and KP.ONT = 'u' and P.TN= 'CUSTOMER' and P.CN = 'C_COMMENT' and P.ONT = 'u'

/* Create materialized Schema view S 
 */
create table S(S varchar(75),P varchar(75),V varchar(75),
			primary key (S,P,V))

insert into S values ('http://upv.com/schemas/company#Customer','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/2000/01/rdf-schema#Class')
insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')  
insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Name','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Name','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Name','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Address','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Address','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Address','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Nation','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Nation','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Nation','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Phone','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Phone','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Phone','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Acctbal','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Acctbal','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Acctbal','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Comment','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Comment','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Comment','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')


/* Creating the UPV
 */
create view U(S,P,V)
  as (select * from CUSTIDV)     union all
     (select * from NAMEV)       union all
     (select * from ADDRESSV)    union all
     (select * from NATIONIDV)   union all
     (select * from PHONEV)      union all
     (select * from ACCTBALV)    union all
     (select * from MKTSEGMENTV) union all
     (select * from COMMENTV)    union all
     (select * from S)


/* Measure compilation (optimization) and execution time in MSSQL Server
 */
SET STATISTICS TIME ON

/* Definition of synthetic content queries
 */
 select C1.V,C2.V,C3.V,C4.V,C5.V,C6.V,C7.V,C8.V
 from U C1,
      U C2,
      U C3,
      U C4,
      U C5,
      U C6,
      U C7,
      U C8

 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and       
       C4.P = 'http://udbl.it.uu.se/schemas/company#Nation' and
       C5.P = 'http://udbl.it.uu.se/schemas/company#Phone' and
       C6.P = 'http://udbl.it.uu.se/schemas/company#Acctbal' and  
       C7.P = 'http://udbl.it.uu.se/schemas/company#Market' and
       C8.P = 'http://udbl.it.uu.se/schemas/company#Comment' and
       C1.S = C2.S and
       C2.S = C3.S and
       C3.S = C4.S and
       C4.S = C5.S and
       C5.S = C6.S and
       C6.S = C7.S and
       C7.S = C8.S

 select C1.V,C2.V,C3.V,C4.V,C5.V,C6.V,C7.V
 from U C1,
      U C2,
      U C3,
      U C4,
      U C5,
      U C6,
      U C7

 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and       
       C4.P = 'http://udbl.it.uu.se/schemas/company#Nation' and
       C5.P = 'http://udbl.it.uu.se/schemas/company#Phone' and
       C6.P = 'http://udbl.it.uu.se/schemas/company#Acctbal' and  
       C7.P = 'http://udbl.it.uu.se/schemas/company#Market' and
       C1.S = C2.S and
       C2.S = C3.S and
       C3.S = C4.S and
       C4.S = C5.S and
       C5.S = C6.S and
       C6.S = C7.S

 select C1.V,C2.V,C3.V,C4.V,C5.V,C6.V
 from U C1,
      U C2,
      U C3,
      U C4,
      U C5,
      U C6

 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and       
       C4.P = 'http://udbl.it.uu.se/schemas/company#Nation' and
       C5.P = 'http://udbl.it.uu.se/schemas/company#Phone' and
       C6.P = 'http://udbl.it.uu.se/schemas/company#Acctbal' and  
       C1.S = C2.S and
       C2.S = C3.S and
       C3.S = C4.S and
       C4.S = C5.S and
       C5.S = C6.S

 select C1.V,C2.V,C3.V,C4.V,C5.V
 from U C1,
      U C2,
      U C3,
      U C4,
      U C5
 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and       
       C4.P = 'http://udbl.it.uu.se/schemas/company#Nation' and
       C5.P = 'http://udbl.it.uu.se/schemas/company#Phone' and       
       C1.S = C2.S and
       C2.S = C3.S and
       C3.S = C4.S and
       C4.S = C5.S

 select C1.V,C2.V,C3.V,C4.V
 from U C1,
      U C2,
      U C3,
      U C4
 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and       
       C4.P = 'http://udbl.it.uu.se/schemas/company#Nation' and
       C1.S = C2.S and
       C2.S = C3.S and
       C3.S = C4.S 

 select C1.V,C2.V,C3.V
 from U C1,
      U C2,
      U C3

 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and
       C3.P = 'http://udbl.it.uu.se/schemas/company#Address' and              
       C1.S = C2.S and
       C2.S = C3.S 

 select C1.V,C2.V
 from U C1,
      U C2
 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID' and
       C2.P = 'http://udbl.it.uu.se/schemas/company#Name' and       
       C1.S = C2.S

 select C1.V
 from U C1
 where C1.P = 'http://udbl.it.uu.se/schemas/company#CustID'

SET STATISTICS TIME OFF