/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test agsl wrapper header
 */

#ifndef TEST_AGSL_H
#define TEST_AGSL_H

#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <check.h>
#include <math.h>
#include <amos2/callin.h>

#include "../amosgsl.h"

/* GSL stuff */
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_blas.h> 
#include <gsl/gsl_cblas.h>

/* all tests run this - not sure if they should be run and initialized
   somewhere else? e.g. prior to running tests? */
#define AMOS_SETUP_TEST_VARIABLES               \
  a_connection connection;                      \
  a_scan scan;                                  \
  a_tuple tuple;                                \
  bindtype env

#define TEST_AMOS_SETUP()                               \
  int fooc = 2;                                         \
  char * foov[2] = {"amosgsl", DUMP_FILE};              \
  connection = a_init_connection ();                    \
  scan = a_init_scan ();                                \
  tuple = a_init_tuple ();                              \
  init_amos (fooc, foov);                               \
  a_connect (connection, "", FALSE);                    \
  env = topframe ();                                    \
  agsl_vector_register_functions (connection);          \
  agsl_matrix_register_functions (connection);          \
  agsl_blas_level1_register_functions (connection);     \
  agsl_blas_level2_register_functions (connection);     \
  agsl_blas_level3_register_functions (connection);     \
  agsl_linalg_register_functions (connection)




#define TEST_AMOS_TEARDOWN() free_connection (c)

Suite * make_vector_suite (void);
Suite * make_matrix_suite (void);
Suite * make_blas1_suite (void);
Suite * make_blas2_suite (void);
Suite * make_blas3_suite (void);
Suite * make_matrix_subtypes_suite (void);


#define timediff(iterations, start, end)                                \
  (end - start) / ((double) iterations) / ((double) CLOCKS_PER_SEC)

#endif /* TEST_AGSL_H */
