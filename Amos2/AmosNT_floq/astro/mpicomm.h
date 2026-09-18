#include <mpi.h>
#include "amos.h"

void register_mpicomm();
oidtype a_mpi_proberecv_block(int nodenum);
void a_mpi_send_block(oidtype form, int nodenum, int tag);

void a_mpi_send_noblock(oidtype form, int nodenum, int tag, MPI_Request* req);

oidtype a_mpi_proberecv_any_block(int* nodenum, int* incoming_tag);

oidtype mpi_revalfn(bindtype env, oidtype nodenum, oidtype form);
oidtype mpi_sendfn(bindtype env, oidtype form, oidtype nodenum);
oidtype mpi_send_blockfn(bindtype env, oidtype form, oidtype nodenum, oidtype tag);

