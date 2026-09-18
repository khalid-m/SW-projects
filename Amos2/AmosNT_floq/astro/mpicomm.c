/*****************************************************************************
 * AMOS
 *
 * Author: (c) 2005 Erik Zeitler and Tore Risch, UDBL
 * $RCSfile: mpicomm.c,v $
 * $Revision: 1.13 $ $Date: 2006/11/20 18:03:48 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Communication primitives for MPI.
 * sendfn uses tag 1, doesn't expect return data
 * revalfn uses tag 0, and expects return data.
 */

#include <mpi.h>
#include "amos.h"
#include "binary.h"

#define DEBUG 0 /* 0 or 1 or 2 */


oidtype a_mpi_proberecv_block(int nodenum) {
  oidtype rd = nil;
  MPI_Status commstatus;
  int incoming_count, incoming_tag;
  char* rbuf;

  MPI_Probe(nodenum, MPI_ANY_TAG, MPI_COMM_WORLD, &commstatus);
  MPI_Get_count(&commstatus, MPI_BYTE, &incoming_count);
  incoming_tag = commstatus.MPI_TAG;
  if(DEBUG>0) {
    printf("a_mpi_proberecv_block: incoming_count: %d\n", incoming_count);
    fflush(stdout);
  }
  rbuf = a_get_image_buffer(incoming_count);
  if(DEBUG>0) {
    printf("a_mpi_proberecv_block: will receive\n");
    fflush(stdout);
  }
  MPI_Recv(rbuf, incoming_count, MPI_BYTE, nodenum, incoming_tag,
	   MPI_COMM_WORLD, &commstatus);
  rd = a_read_from_image_buffer();
  return rd;
}

oidtype a_mpi_proberecv_any_block(int* nodenum, int* tag) {
  /* Probe and receive from any node, with any tag. Put
     incoming node/tag values in nodenum and tag*/
  oidtype rd = nil;
  MPI_Status commstatus;
  int incoming_count;
  char* rbuf;

  MPI_Probe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &commstatus);
  MPI_Get_count(&commstatus, MPI_BYTE, &incoming_count);
  *tag = commstatus.MPI_TAG;
  *nodenum = commstatus.MPI_SOURCE;
  if(DEBUG>0) {
    printf("a_mpi_proberecv_any_block: incoming_count %d, nodenum %d, tag %d\n",
	   incoming_count, *nodenum, *tag);
  }
  rbuf = a_get_image_buffer(incoming_count);
  if(DEBUG>0) a_message("a_mpi_proberecv_any_block: will receive\n");
  MPI_Recv(rbuf, incoming_count, MPI_BYTE, *nodenum, *tag,
	   MPI_COMM_WORLD, &commstatus);
  rd = a_read_from_image_buffer();
  return rd;
}

void a_mpi_send_block(oidtype form, int nodenum, int tag) {
  void* sbuf;
  int sbuflen=0;
  a_print_to_buffer(form, &sbuf, &sbuflen);
  if(2==DEBUG) {
    a_message("a_mpi_send_block: Form is: "); a_print(form); fflush(stdout);
  }
  MPI_Send(sbuf, sbuflen, MPI_BYTE, nodenum, tag, MPI_COMM_WORLD);
}

oidtype mpi_send_blockfn(bindtype env, oidtype form, oidtype nodenum, oidtype tag) {
	a_mpi_send_block(form, getinteger(nodenum), getinteger(tag));
	return t;
}

void a_mpi_send_noblock(oidtype form, int nodenum, int tag, MPI_Request* req) {
  void* sbuf;
  int sbuflen=0;
  a_print_to_buffer(form, &sbuf, &sbuflen);
  if(2==DEBUG) {
    a_message("a_mpi_send_noblock: Form is: "); a_print(form); fflush(stdout);
  }
  MPI_Isend(sbuf, sbuflen, MPI_BYTE, nodenum, tag, MPI_COMM_WORLD, req);
}

oidtype mpi_revalfn(bindtype env, oidtype form, oidtype nodenum) {
  /* Send expression to nodenum for evaluation and receive answer. */
  int node_number;
  oidtype rd = nil;

  IntoInteger(nodenum, node_number, env);
  a_mpi_send_block(form, node_number, 0);
  if(DEBUG>0) {a_message("mpi_revalfn: form sent.\n"); fflush(0);}
  rd = a_mpi_proberecv_block(node_number);
  if(2==DEBUG) {
    a_message("mpi_revalfn: Got result from coordinator: ");
    a_print(rd);
  }
  return rd;
}

oidtype mpi_sendfn(bindtype env, oidtype form, oidtype nodenum) {
  int receiver;
  /* Send expression to nodenum for evaluation. No answer is expected. */

  IntoInteger(nodenum, receiver, env);
  a_mpi_send_block(form, receiver, 1);
  if(DEBUG>0) {printf("mpi_sendfn: form sent to %d.", receiver); fflush(0);}
  return nil;
}

void register_mpicomm() {
  extfunction2("mpi-reval", mpi_revalfn);
  extfunction2("mpi-send-form", mpi_sendfn);
	extfunction3("mpi-send-block", mpi_send_blockfn);
}
