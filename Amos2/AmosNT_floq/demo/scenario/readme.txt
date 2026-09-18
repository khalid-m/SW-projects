/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Tore Risch, UDBL
 * $RCSfile: readme.txt,v $
 * $Revision: 1.10 $ $Date: 2005/02/13 14:40:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: OO mediation scenario description
 *
 ****************************************************************************/

This directory contains the Amos II mediation scenario from:
 
   T.Risch: Mediators for Querying Heterogeneous Data, in M.P.Singh
   (ed.): The Practical Handbook of Internet Computing, ISBN
   1584883812, Chapman & Hall/CRC, USA, June 2004.

You need to install FireBird DBMS first and set variable INTERBASEDIR
to directory where FireBird has example databases.

1. Copy FireBird example database with:

copy "%interbasedir%\employee.gdb .

2. Populate FireBird database with:

   amos2
     enablejava();
     < 'stockholm_pop.amosql';
 
3. Start Uppsala database stand-alone Amos II database server and
nameserver with:

   amos2
     < 'uppsala.amosql';

4. When Uppsala is listening, start Stockholm wrapped FireBird
database with:

   javaamos
     < 'stockholm.amosql';

5. When Stockholm is up and running, start mediator with

   amos2
     < 'mediate.amosql';

6. Test queries in mediator:

   select pnr(s) from student s;
   select name(s) from student s;
   select name(s) from student s where name(s)>"L"; 
   select pnr(s) from student s where pnr(s)>1002;  
   select subject(c) from course c where subject(c)>"B";
   name(thestudent(1002));
   select distinct score(t) from takes t;
   select distinct student(t) from takes t;
   select distinct name(student(t)) from takes t;
   select distinct subject(course(t)) from takes t;
   select distinct subject(course(t)) from takes t 
                                      where name(student(t))="Mike"; 
