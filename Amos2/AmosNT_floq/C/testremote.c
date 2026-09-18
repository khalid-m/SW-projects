 /*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $Revision:
 * $State:
 *
 * Description: Testing Amos II remote connections. Amos II server named 'testdb' must run.
 *
 * Requirements:
 * ===========================================================================
 * $Log:
 */

#include "callin.h"

main(int argc,char **argv)
{
  int i;
  dcl_connection(c);
  dcl_connection(c2);
  dcl_connection(c3);
  dcl_scan(s);
  dcl_oid(fno); dcl_oid(tpo); dcl_oid(tp1); dcl_oid(oo);
  dcl_tuple(argl); dcl_tuple(resl);
  int id, idno;

  printf("Connecting...\n"); fflush(stdout);
  a_connect(c,"foo",TRUE);
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_initialize("../bin/amos2.dmp",FALSE);
  a_initialize("../bin/amos2.dmp",TRUE);
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_connectto(c,"foo","ToreRischsIBM",FALSE);
  a_connectto(c2,"foo","ToreRischsIBM",FALSE);
  a_connect(c3,"",FALSE);
  a_disconnect(c3,FALSE);
  printf("Initialized and connected OK\n"); fflush(stdout);
  a_disconnect(c2,FALSE); /* Tests that two connections possible */
  if(a_gettype(c,"personx",TRUE)==nil)
  {
     a_execute(c,s,"create type personx;",FALSE);
     a_execute(c,s,"create function test(integer)->integer;",FALSE);
     a_print(c->result);
  }
  a_setf(fno,a_getfunction(c,"test",TRUE));
  if (a_errorflag) {
    printf("Funtion TEST not defined (OK)\n");
  }
  a_setf(tpo,a_gettype(c,"personx",FALSE));
  a_setf(oo,a_createobject(c,tpo,FALSE));
  a_setarity(argl,1);
  a_setintelem(argl,0,1,FALSE);
  a_newtuple(resl,1,FALSE);
  a_setintelem(resl,0,5,FALSE);
  a_addfunction(c,fno,argl,resl,FALSE);
  a_callfunction(c,s,fno,argl,FALSE);
  a_remfunction(c,fno,argl,resl,FALSE);
  a_callfunction(c,s,fno,argl,FALSE);
  a_print(c->result);
  id = a_getid(oo,FALSE);
  a_print(a_getobjectno(c,id,FALSE));
  a_print(oo);
  /* Test error management */
  a_setf(fno,a_getfunction(c,"wrong",TRUE));
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_setf(fno,a_gettype(c,"wrong",TRUE));
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_deleteobject(c,fno,FALSE);
  a_execute(c,s,"select wrong(1);",TRUE);
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  printf("(12) Investigating properties of object: "); a_print(oo);
  for(i=0;i<100;i++) /* stress test. Will send 100 requests to server */
  {
     a_setf(tp1,a_typeof(oo,FALSE));
  }
  if(tp1 == tpo)
  {
     printf("(13) The type is OK: "); a_print(tp1);
  }
  else
  {
     printf("(13) The type is NOT OK: "); a_print(tp1);
     printf("(13) Not same as: "); a_print(tpo);
  }
  idno = a_getid(oo,FALSE);
  printf("(14) The idno: %d\n", idno);
  printf("(15) Object number %d is:",idno); a_print(a_getobjectno(c,idno,FALSE));
  a_disconnect(c,FALSE);
  a_disconnect(c,TRUE); /* One too much will fail */
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_execute(c,s,"1+2;",TRUE);
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  a_connect(c,"foo",FALSE);
  a_connect(c,"foo",TRUE); /* One too much */
  if(a_errorflag)
  {
      printf("Testing Error %d: %s %s\n",a_errno, a_errstr, convert_to_string(a_errform));
  }
  printf("[100 connect/disconnect...");
  for(i=0;i<100;i++)
    {
      dcl_connection(c1);
      a_connect(c1,"foo",FALSE);
      a_disconnect(c1,FALSE);
      free_connection(c1);
    }
  printf("]\n");
  a_execute(c,s,"quit;",TRUE);
  a_disconnect(c,FALSE);
  free_connection(c);
  printf("Testing remote connection OK!\n"); fflush(stdout);
  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a') amos_toploop("Amos");
  free_oid(oo); 
  free_oid(fno);
  free_oid(tpo);
  free_oid(tp1);
  free_scan(s);
  free_tuple(argl);
  free_tuple(resl);
  return 0;
}









