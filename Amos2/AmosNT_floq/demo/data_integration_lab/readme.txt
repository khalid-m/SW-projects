/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2003 Timour Kachaunov, UDBL
 * $RCSfile: readme.txt,v $
 * $Revision: 1.1 $ $Date: 2003/02/28 09:50:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: A minimal tutorial on how to integrate two distributed data
 * sources one of which is an Access database and the other is an Amos 
 * database.
 * To load all scripts execute 'runall.bat'. Don't forget to press a key
 * in the first window to load the mediator client (this is done to wait
 * for the mediator servers to start.
 ****************************************************************************/


In a university in Northen Europe there was once upon a time two
departments called ISY and IDA. They both designed independently
employee databases containing employees from their departments
including guest employees from other departments. However, different
schemas and different DBMSs were used for the implementation of the
two databases. ISY used Amos II and IDA used Access. At some point
they needed to define an integrated database containing employee data
from both departments. They decided to use OO mediator technology for
this.


The structures of the databases were as follows:

ISY database (Amos II):
------------------------
 create type isyemp properties(
      id charstring key, /* SSN as an integer */
      name charstring, 
      pay integer,
      wplace integer); /* 1 for ISY, all other values for guests */

This database is in isydb.osql


IDA database (Microsoft Access):
-----------------------
One relation:
    IDAEMP(SSN, NAME, SALARY, HOBBY, AGE, DEPT)
where:
    NAME   string holding name of employee
    SALARY integer
    SSN    integer
    HOBBY  string
    AGE    integer
    DEPT   string   /* "IDA" or "Other" */

This database is in idadb.mdb. We are interested only in the persons that
have "IDA" for a value for the 'DEPT' attribute.


Tasks:
-------
a) Make a translator of the ida.mdb database.
   - Configure an ODBC data source for the ida.mdb Access database
   - Import the IDAEMP relation as a new type in the translator from
     the Access database using an ODBC connection. For this two operations
     are needed:
         1. Declare the file ida.mdb as an ODBC source for the operating
            system using the My Computer->Control Pannel->ODBC tab.
         2. Declare that this ODBC source will be wrapped by an AMOS using
            the following AMOSII function calls (assuming that the ODBC 
            source was named IDADS):

       import_odbc_source("IDADS");
       import_odbc_type("IDAEMP", "IDADS");


     Note: ODBC data source names are case sensitive.

   - Retrieve the names and the IDs of the all the emplyees in the IDAEMP 
     relation that are eployeed by the IDA department (i.e. DEPT is "IDA").

   - Create a derived type representing the persons whose names were retrieved
     in the previous query. Name the type idadeptemp

   - Save the definitions by issuing the command:
             save "idadb.dmp";
     This will save the image into the file idadb.dmp to be used later in this
     exercise 

   - State the query from above using the newly created derived type


b) Start a mediator client named M that accesses a stand-alone Amos II 
   server named ISYDB using the isy.dmp., and an IDA translator
   server named IDADB using the image ida.dmp created in the previous step.

   - Import types ida_dept and isyemp to M. 
     Now they can be reffered to as isyemp@ISYDB and ida_dept@IDADB. 
   - Import function id_to_ssn from ISYDB to M. 
   - Define a derived type isyemp1 representing the instances of  isyemp@ISYDB
     that have the wplace = 1. This type should be used in the remaining of the
     exercise to represent the employees of interest working at ISY

   Hints:
   - designate one of the two servers to act as a nameserver
   - alternatively you can start a separate AMOS II acting as a nameserver

c)
   - Make a multi-database query that retrieves the names and SSNs of
     all persons that work in both IDA and ISY databases.
     The persons are identified using their ssn and id respectively.
     The function id_to_ssn defined in the ISY wrapper can be used to translate
     the IDs to a SSN format. 

d) 
   -Based on the query from c), define a derived type named both_dept_person 
    representing the persons working in both departments at the same  time. 
  - List the names and the SSNs of the employees working in both departments
    at the same time using the type both_dept_person. Note that a name function
    is defined in both supertypes of  both_dept_person, therefore a fully
    resolved function name must be used. Due to current implementation
    constraints, currently in AMOSII, when an imported type is used in a
    resolved function signature, the '@' sign should be substituted by an '_'
    sign (i.e to denote the function name defined for idadeptemp@idadb, the
    user needs to use the name idadeptemp_idadb.name->charstring).
 


e) Write queries to retrieve the 
    1. the names and the salaries  of the employees working ONLY in ISY
    2. the names  and the salaries of the employees working ONLY in IDA.
    3. the names and the salaries of the employees working at both ISY and IDA
   Take in account that the salary
   of the employees should be the salary in the repective department, if a
   person is employed by only one of the departments, and a sum of the both
   salaries otherwise.
   Use the 'notany' aggregate function in these queries. The subquery
   nested in this operator should check if the other database there is
   a matching person by, e.g retrieving the his name. 

   -Write a query that will retrieve the names of all the employees of
    the new department such that each name is listed only once. Use
    the 3 queries from above as building blocks of the new query.

   Hints: -if more than one type is used in the from clause, the system will
           do a cross product first and then apply the conditions.
          -to avoid this use the 'in' aggregate function with nested subqueries
           
	 


f)
   -List the names of all the employees, such that each employee is listed only
    once. In this query use the 'distinct' keyword and nested subqueries over
    the isyemp1 and idadeptemp@idadb types.



g) 

  -Make an integration type ALLemps denoting all the employees in both
   departments along with their name, ssn, and salary. The functions of
   the new type should be named real_name, real_salary and real_ssn. Here, also
   the salary
   of the employees should be the salary in the repective department, if a
   person is employed by only one of the departments, and a sum of the both
   salaries otherwise. The name can be choosen from either of the databases.
   Make a decision to enhance the performance. The real_ssn should be in the
   same format as the ssn in IDADB. A stored function 'room' returning a 
   charstring should be defined to store the location of the employee's room. 

  -Retrieve the names and the salaries of all the employees of the new
   department
