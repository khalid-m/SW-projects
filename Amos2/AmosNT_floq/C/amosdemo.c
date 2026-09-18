/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: amosdemo.c,v $
 * $Revision: 1.10 $ $Date: 2012/10/25 18:07:50 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Demo program illustrating the C <-> AMOSQL interface
 ****************************************************************************/
  
#include "callin.h"
#include <math.h>

main(int argc,char **argv)
{
  dcl_connection(c); /* To hold connection to Amos */
  dcl_scan(s);  /* To hold result streams from Amos queries and function calls */
  dcl_oid(f1); /* dcl_oid(x) declares a C variable to hold reference to Amos object */
  dcl_oid(f2);
  dcl_oid(tpo);
  dcl_oid(o);
  dcl_tuple(row);  /* To hold results from Amos function calls */
  dcl_tuple(argl); /* To hold Amos function argument lists */
  dcl_tuple(resl); /* To hold result lists of updated Amos functions*/
  int idno;        /* To hold identity number of Amos OID */

  a_initialize("../bin/amos2.dmp", FALSE);  /* Initialize embedded Amos */
  fprintf(stderr,"");
  /*** Always start with connecting to Amos ***/
  a_connect(c,"",FALSE); /*** name "" indicates connect to embedded Amos ***/
  
  /*** Executing illegal AMOSQL from C with error trapping ***/
  if(a_execute(c,s,"create type usertypeobject;",TRUE)) /* The TRUE indicates error trapping */
  {
     /* The statement generates an error which causes this block to be executed */
     printf("(1) Error %d: %s ",a_errno, a_errstr); a_print(a_errform);
     /* Print he error number, message, and object; 'a_print(x)' prints any Amos
                                               object x on stdout */
  }
  /*** Execute query and scan the result ***/
  a_execute(c,s,"select name(t) from type t;",FALSE); /* FALSE => no error trapping */
  /*          s is a 'scan' holding the result of the query */
  while(!a_eos(s)) /* While there are more rows in scan */
  {
     char str[50];

     a_getrow(s,row,FALSE); /* Get current row in scan */
     a_getstringelem(row,0,str,sizeof(str),FALSE); /* Get 1st arg in row as string */
     printf("(2) Type %s\n",str);
     a_nextrow(s,FALSE); /* Advance scan forward */
  }

  /*** Calling Amos functions using fast-path interface ***/
  /* Get a handle to the function to call */
  a_assign(f1,a_getfunction(c,"charstring.typenamed->type",FALSE));
  /*                                                     no error trapping */
  /* 'a_setf(var,xpr)' assigns the result OID from 'xpr' to the object variable
     'var'. You must declare 'var' with 'dcl_oid(var)' and release it with
     'free_oid(var)'. 'a_setf(var,xpr)' is similar to 'var = xpr', but also
     handles automatic garbage collection.

     If you use 'var = xpr' to assign OIDs it normally works too, but you can
     then sometimes get illegal memory references when assigned objects have
     been deleted. */
  a_newtuple(argl,1,FALSE); /* There is one argument */
  a_setstringelem(argl,0,"FUNCTION",FALSE); /* Bind string to first argument */
  a_callfunction(c,s,f1,argl,FALSE); /* Call the function */
  /* Result if TRUE if error.
                 c is connection handle
                   s is result scan
                     f1 is function to call
                        argl is argument list
                             FALSE indicates no error trapping */
  printf("(3) ");
  a_getrow(s,row,FALSE); /* Move single scane element to row */
  a_print(a_getobjectelem(row,0,FALSE)); /* the single result is an Amos object */

  /*** Populate new stored function salary ***/
  a_execute(c,s,
     "create function salary (charstring name)-> <integer s, real sc>;",FALSE);
  a_assign(f2,a_getfunction(c,"charstring.salary->integer.real",FALSE));
  /* It would have worked with this 'generic' getfunction too:
     a_setf(f2,a_getfunction(c,"salary",FALSE));
     but it would have been radically slower! */
  a_newtuple(argl,1,FALSE); /* Arument list holding 1 argument */
  a_newtuple(resl,2,FALSE); /* Result list holding 1 result value */
  a_setstringelem(argl,0,"Tore",FALSE);
  a_setintelem(resl,0,1000,FALSE);
  a_setdoubleelem(resl,1,3.4,FALSE);
  a_addfunction(c,f2,argl,resl,FALSE);
  /* Add row to stored function.
                c is connection
                  f2 is function handle
                     argl is argument list
                          resl is result list
                               FALSE indicates no error trapping */
  /* 2nd new row */
  a_setstringelem(argl,0,"Kalle",FALSE);
  a_setintelem(resl,0,2000,FALSE);
  a_setdoubleelem(resl,1,2.3,FALSE);
  a_addfunction(c,f2,argl,resl,FALSE);
  /* 3rd new row */
  a_setstringelem(argl,0,"Ulla",FALSE);
  a_setintelem(resl,0,3000,FALSE);
  a_setdoubleelem(resl,1,4.6,FALSE);
  a_addfunction(c,f2,argl,resl,FALSE);

  /*** Example of call to function with width > 1: ***/
  a_newtuple(argl,1,FALSE);
  a_setstringelem(argl,0,"Tore",FALSE);
  a_callfunction(c,s,f2,argl,FALSE);
  a_getrow(s,row,FALSE);
  printf("(4) Name: Tore, salary: %d, score: %g\n",
         a_getintelem(row,0,FALSE),a_getdoubleelem(row,1,FALSE));

  /*** Example of illegal function call ***/
  a_newtuple(argl,1,FALSE);
  a_setintelem(argl,0,1,FALSE);
  if(a_callfunction(c,s,f2,argl,TRUE))
  {
     char *ostring = a_stringify(a_errform);
     /* The call generates an error which causes this block to be executed */
     printf("(5) Error %d: %s %s\n",a_errno, a_errstr,ostring);
     /* Print he error number, message, and object;
        a_stringify(o) prints any Amos object o into a C string */
	 a_freebytes(ostring);
  }

  /*** Create derived function that retrieves all tuples from salary function ***/
  a_execute(c,s,
      "create function pdata()-> <charstring nm, integer s, real sc> as \
       select nm,s,sc where salary(nm)=<s,sc>;",FALSE);
  a_getrow(s,row,FALSE);
  a_assign(f2,a_getobjectelem(row,0,FALSE)); /* Bind f2 to single result from a_execute */

  /*** Retieve all tuples from salary ***/
  a_newtuple(argl,0,FALSE); /* no arguments of pdata */
  a_callfunction(c,s,f2,argl,FALSE); /* call pdata */
  while(!a_eos(s))
  {
     char name[5];

     a_getrow(s,row,FALSE);
     a_getstringelem(row,0,name,sizeof(name),FALSE);
     printf("(6) Name %s, Salary %d, Score %g\n",
        name,a_getintelem(row,1,FALSE),a_getdoubleelem(row,2,FALSE));
     a_nextrow(s,FALSE);
  }

  /* The call to a_closescan is actually not needed here since the scan is
     closed when scan_free() is called below. It is, however, good to close
     scans as soon as possible to release resources.
     The scans are also automatically closed when they are re-used */

  a_commit(c,FALSE);  /* Makes updates permanent in image */

  /*** Object creation ***/
  a_execute(c,s,
    "create type person properties (name charstring);",FALSE);
  a_assign(tpo,a_gettype(c,"person",FALSE));
  a_assign(f1,a_getfunction(c,"person.name->charstring",FALSE));
  a_newtuple(argl,1,FALSE);
  a_newtuple(resl,1,FALSE);

  /* 1st object */
  a_setobjectelem(argl,0,a_createobject(c,tpo,FALSE),FALSE);
  a_setstringelem(resl,0,"Tore",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);
  /* 2nd object */
  a_setobjectelem(argl,0,a_createobject(c,tpo,FALSE),FALSE);
  a_setstringelem(resl,0,"Kalle",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);
  /* 3rd object */
  a_setobjectelem(argl,0,a_createobject(c,tpo,FALSE),FALSE);
  a_setstringelem(resl,0,"Ulla",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);

  /*** Delete the person named 'Tore' ***/
  a_execute(c,s,"select p from person p where name(p) = 'Tore';",FALSE);
  a_getrow(s,row,FALSE);
  a_setf(o,a_getobjectelem(row,0,FALSE));
  a_deleteobject(c,o,FALSE);

  /*** Print the names of all persons ***/
  a_execute(c,s,"select name(p) from person p;",FALSE);
  while(!a_eos(s))
  {
     char str[10];

     a_getrow(s,row,FALSE);
     a_getstringelem(row,0,str,sizeof(str),FALSE);
     printf("(8) Person %s\n",str);
     a_nextrow(s,FALSE);
  }
  a_closescan(s,FALSE);

  /*** Create bag (set) values stored function ***/
  a_execute(c,s,"create function hobbies(person)-> bag of charstring;",FALSE);
  a_getrow(s,row,FALSE);
  a_setf(f1,a_getobjectelem(row,0,FALSE)); /* Bind f1 to function 'hobbies' */

  /*** Create inverse to function name(person)->charstring ***/
  a_execute(c,s,"create function personnamed(charstring nm) -> person p as \
                 select p where name(p) = nm;",FALSE);
  a_getrow(s,row,FALSE);
  a_setf(f2,a_getobjectelem(row,0,FALSE)); /* Bind f2 to function 'personnamed' */

  /*** Get person named 'Ulla' ***/
  a_newtuple(argl,1,FALSE);
  a_setstringelem(argl,0,"Ulla",FALSE);
  a_callfunction(c,s,f2,argl,FALSE);
  a_getrow(s,row,FALSE);
  a_setf(o,a_getobjectelem(row,0,FALSE)); /* Bind O to person named 'Tore' */

  /*** Add some hobbies for person named 'Ulla' ***/
  a_setobjectelem(argl,0,o,FALSE); /* Bind argl to person named 'Ulla' */
  a_newtuple(resl,1,FALSE);     /* Bind resl to name of hobby */
  a_setstringelem(resl,0,"Sailing",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);
  a_setstringelem(resl,0,"Golfing",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);

  /*** Replace all hobbies with 'Painting' and 'Canoing' ***/
  a_setstringelem(resl,0,"Painting",FALSE);
  a_setfunction(c,f1,argl,resl,FALSE);
  a_setstringelem(resl,0,"Canoing",FALSE);
  a_addfunction(c,f1,argl,resl,FALSE);

  /*** Delete hobby 'Painting' ***/
  a_setstringelem(resl,0,"Painting",FALSE);
  a_remfunction(c,f1,argl,resl,FALSE);

  /*** The only remaining hobby should now be 'Canoing'. Let's check ***/
  a_callfunction(c,s,f1,argl,FALSE);
  while(!a_eos(s))
  {
     char hobby[20];

     a_getrow(s,row,FALSE);
     a_getstringelem(row,0,hobby,sizeof(hobby),FALSE);
     printf("(9) The remaining hobby is %s\n", hobby);
     a_nextrow(s,FALSE);
  }
  a_nextrow(s,TRUE);
  if(a_errorflag)
  {
	  char *ostring = a_stringify(a_errform);

      printf("(9.5) Error %d: %s %s\n", a_errno, a_errstr, ostring);
      /* convert_to_string(o) prints any Amos object into string */
	  a_freebytes(ostring);
  }
  a_rollback(c,FALSE); /* Undoes database updates after last a_commit */
  if(a_gettype(c,"person",TRUE)== nil)
    printf("(10) Rollback worked!\n");
  if(a_getfunction(c,"salary",TRUE)!=nil) /* Get the 'generic' salary */
    printf("(11) Commit worked!\n");

  /*** Demo OID property functions ***/

  a_setf(f1,a_getfunction(c,"salary",TRUE)); /* Bind f1 to function OID */
  printf("(12) Investigating properties of object: "); a_print(f1);
  printf("(13) The type: "); a_print(a_typeof(f1,FALSE));
  idno = a_getid(f1,FALSE);
  printf("(14) The idno: %d\n", idno);
  printf("(15) Object number %d is:",idno); a_print(a_getobjectno(c,idno,FALSE));
  a_getobjectno(c,666,TRUE);
  if(a_errorflag)
  {
	  char *ostring = a_stringify(a_errform);

      printf("(16) Error %d: %s %s\n", a_errno, a_errstr,
               ostring);
	  a_freebytes(ostring);
  }
  a_getfunction(c,"xxxx",TRUE);
  if(a_errorflag)
  {
	  char *ostring = a_stringify(a_errform);
      printf("(17) Error %d: %s %s\n", a_errno, a_errstr,
               ostring);
	  a_freebytes(ostring);
  }
  a_gettype(c,"xxxx",TRUE);
  {
	  char *ostring = a_stringify(a_errform);
      printf("(18) Error %d: %s %s\n", a_errno, a_errstr,
               ostring);
	  a_freebytes(ostring);
  }
  a_disconnect(c,FALSE); /* Always disconnect connection when done! */

  /*** Important! To avoid memory leaks always call free_xxx for every handle no
       longer used! ***/
  free_tuple(argl); /* Will deallocate storage used by argument list argl */
  free_tuple(resl);
  free_tuple(row);
  free_oid(f1);
  free_oid(f2);
  free_oid(tpo);
  free_oid(o);
  free_connection(c); /* Will deallocate storage used by handle c */
  free_scan(s); /* Will deallocate storage used by handle s */

  /*** Now we can call the interactive Amos top loop on the embedded database ***/
  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a'){
  amos_toploop("Amos");
  printf("Back from amos_toploop\n");} /* Will be printed if AMOSQL command 'exit,* typed */
  return 0;
}

























