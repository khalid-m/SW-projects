/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1997 Tore Risch, EDSLAB
 * $RCSfile: amosgsl.c,v $
 * $Revision: 1.1 $ $Date: 2009/07/14 13:45:47 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 driver program
 ****************************************************************************/

#include <amos2/callin.h>
#include <amos2/alisp.h>
#include "amosgsl.h"


int
main (int argc,char **argv)
{
  bindtype env;

  int fooc = 2;

  /* TODO: sort out DUMP_FILE from configure to find
     amosgsl.dmp -- wherever it may be (for example when
     installed it will be in another location:
     $datadir/amosgsl/amosgsl.dmp or some such place) */
  char * foov[2] = {"amosgsl", "./amosgsl.dmp"};

  dcl_connection (connection);/* To hold connection to Amos */

  /* load dump file if none given */
  if (argc == 1)
    {
      init_amos (fooc,foov); /* Initialize Amos and ALisp */
    }
  else
    {
      init_amos (argc,argv); /* Initialize Amos and ALisp */
    }
  a_connect (connection, "", FALSE);
  env = topframe ();

  /* AGSL */
  agsl_vector_register_functions (connection);
  agsl_matrix_register_functions (connection);
  agsl_blas_level1_register_functions (connection);
  agsl_blas_level2_register_functions (connection);
  agsl_blas_level3_register_functions (connection);
  agsl_linalg_register_functions (connection);

  /* Amosql / ALisp GSL - this _is_ loaded into the database dump */
  /* FILE * amosgsl_fp = fopen ("amosgsl.amosql", "r"); */
  /* dcloid (amosgsl_amosfp); */
  /* a_setf (amosgsl_amosfp, new_stream (amosgsl_fp)); */
  /* load_amosqlfn (env, amosgsl_amosfp, FALSE); */
  
  amos_toploop ("agsl");
  return 0;
}









