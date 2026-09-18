/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Erik Zeitler, UDBL
 *
 * Exec name:    mpiamos
 * Description:  Amos in MPI Exec Env.
 * Language:     C
 ****************************************************************************/

#include "callout.h"
#include <stdio.h>
#include <math.h>
#include <mpi.h>

extern void register_fileaccess(void);

int main(int argc,char **argv) {
  int i, size, rank;
  oidtype emitsymbol;
  dcl_scan(s);
  dcl_connection(c);
  dcl_tuple(tpl);
  init_amos(argc,argv);
  emitsymbol = mksymbol("emit");

	MPI_Init(&argc, &argv);               /* Initialize MPI               */

  MPI_Comm_size(MPI_COMM_WORLD, &size); /* Get the number of processors */
  MPI_Comm_rank(MPI_COMM_WORLD, &rank); /* Get my number                */


  register_fileaccess();
  a_connect(c,"",FALSE);

  if (rank == 0) {
      char buf[BUFSIZ];
      dcl_oid(ml);
      int sz;

      void *buffer;
      unsigned int buflen;
      oidtype form = nil, form2 = nil;

      /* print_to_buffer */ 
      a_setf(form,a_read_from_string("((1)(1.1)(a))"));
      a_print_to_buffer(form, &buffer, &buflen);
      printf("buflen of form %d\n", buflen);
      MPI_Send(buffer, buflen, MPI_BYTE, 1, 0, MPI_COMM_WORLD);
      a_setf(form2,a_read_from_buffer(buffer,buflen));
      a_print(form2);
      a_free(form);
      a_free(form2);

      a_print_to_buffer(emitsymbol, &buffer, &buflen);
      printf("buflen of emitsymbol %d\n", buflen);
      MPI_Send(buffer, buflen, MPI_BYTE, 1, 0, MPI_COMM_WORLD);

      /* Try to send a result set */
      a_execute(c,s,"select t from type t;", FALSE);
      while(!a_eos(s)) {
	  a_getrow(s,tpl,FALSE);
	  a_setf(ml, a_getobjectelem(tpl,0,FALSE));
	  strcpy(buf,a_to_string(ml));
 	  fprintf(stderr, "a_to_string: %s\n", buf);
	  MPI_Send(buf,strlen(buf)+1, MPI_CHAR, 1, 0, MPI_COMM_WORLD);
	  a_nextrow(s,FALSE);
      }
      strcpy(buf,"EOF");
      MPI_Send(buf, strlen(buf)+1, MPI_CHAR, 1, 1, MPI_COMM_WORLD);

  } else if (rank == 1) {
      char *rbuf;
      int count;
      MPI_Status status;
      dcl_tuple(t);
      void *buffer = NULL;
      unsigned int buflen;
      oidtype form = nil, form2 = nil;

      /* Read from buffer */
      MPI_Probe(0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
      MPI_Get_count(&status, MPI_BYTE, &buflen);
      printf("buflen %d\n", buflen);
      MPI_Recv(buffer, buflen, MPI_BYTE, 0, 0, MPI_COMM_WORLD, &status);
      a_setf(form2,a_read_from_buffer(buffer,buflen));
      a_print(form2);
      a_free(form2);

      MPI_Probe(0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
      MPI_Get_count(&status, MPI_BYTE, &buflen);
      printf("buflen %d\n", buflen);
      MPI_Recv(buffer, buflen, MPI_BYTE, 0, 0, MPI_COMM_WORLD, &status);
      a_setf(form2,a_read_from_buffer(buffer,buflen));
      if (form2 == mksymbol("emit")) {
	printf("Emitsymbol received!\n");
      }
      a_print(form2);
      a_free(form2);

      /* Recv result set */
      while(1) {
	  MPI_Probe(0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	  if(status.MPI_TAG == 1) {
	      fprintf(stderr,"EOF\n");
	      break;
	  }
	  MPI_Get_count(&status, MPI_CHAR, &count);
	  fprintf(stderr,"count = %d\n", count);
	  rbuf = malloc(count*sizeof(char));
	  MPI_Recv(rbuf, count, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &status);
	  fprintf(stderr,"%s\n",rbuf);
/* 	  a_setobjectelem(t, 1, a_read_from_string(rbuf), FALSE); */
      }

      
  }

/*   fprintf(stderr,"Type 'a' to enter Amos top loop >"); */
/*       if(getc(stdin)=='a') */
/*       amos_toploop("Amos");  */

  free_connection(c);

  MPI_Finalize();
  return 0;
}
