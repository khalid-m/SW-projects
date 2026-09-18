/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test matrix symm on A_nxn, n=256 * i, i=[1..10]
 *
 */

#include "test_agsl.h"
#include <gsl/gsl_math.h>
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

AMOS_SETUP_TEST_VARIABLES;

#define MAX 11

size_t size;

FILE * symmdatfp;

#define SYMM_DATA_FILENAME "symm.dat"
char symmdat_filename[8] = "";

void
symm_setup (void)
{
}

void
symm_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


double
cpu_agsl_dsymm ()
{
  dcloid (alpha);  dcloid (beta);
  dcloid (m); dcloid (A); dcloid (B); dcloid (C);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  int status;
  unsigned int i = 0;

  a_setf (m, mkinteger (size));
  a_setf (alpha, mkreal (ALPHA1));
  a_setf (beta, mkreal (BETA0));


  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      /* Set up test matrices */
      a_setf (A, agsl_matrix_rand (env, m, m));
      a_setf (B, agsl_matrix_rand (env, m, m));
      a_setf (C, agsl_matrix_new (size, size));

      status = agsl_blas_dsmm (env, alpha, A, B, beta, C);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}


/**
 * Test DSYMM via GSL using CPU Clocks
 */
double
cpu_gsl_dsymm ()
{
  dcloid (m);
  dcloid (A); dcloid (B);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;


  a_setf (m, mkinteger (size));


  /* test for gsl */
  i = 0;
  start = clock ();
  do
    {
      a_setf (A, agsl_matrix_rand (env, m, m));
      a_setf (B, agsl_matrix_rand (env, m, m));

      gsl_matrix * c = gsl_matrix_alloc (size, size);
      
      status = gsl_blas_dsymm (CblasLeft, CblasLower,
                               ALPHA1,
                               matrix (A),
                               matrix (B),
                               BETA0,
                               c);
      i++;
      end = clock ();

    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test DSYMM via AmosQL using CPU Clocks
 */
double
cpu_amosql_dsymm ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run dsymm on two random matrices */
  sprintf (query, "select dsymm (rand (%d), rand (%d));",
           size, size);

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      status = a_execute (connection, scan, query, FALSE);
      i++;
      end = clock ();

    }
  while (end < start + resolution && status == GSL_SUCCESS);
  return timediff (i, start, end);
}

/* test for i=1:_i ; n=2^i */
START_TEST (test_symm_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_dsymm = 0;
  double amosgsl_dsymm = 0;
  double gsl_dsymm = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 4;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_dsymm ();
      double gsl = cpu_gsl_dsymm ();
      double amosgsl = cpu_agsl_dsymm ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_dsymm += amosql;
      amosgsl_dsymm += amosgsl;
      gsl_dsymm += gsl;
    }
  fprintf (symmdatfp, "%d\t", size);
  fprintf (symmdatfp, "%E\t",
           amosql_dsymm / k);
  fprintf (symmdatfp, "%E\t",
           amosgsl_dsymm / k);
  fprintf (symmdatfp, "%E\n",
           gsl_dsymm / k);
}
END_TEST


/**
 * Symm timing tests
 */
TCase *
make_dsymm_tcase ()
{
  TCase * tc_symm = tcase_create ("dsymm");

  tcase_add_checked_fixture (tc_symm, symm_setup, symm_teardown);

  tcase_add_loop_test (tc_symm, test_symm_2expi, 1, MAX);

  tcase_set_timeout (tc_symm, 245);

  return tc_symm;
}


Suite *
make_dsymm_suite (void)
{
  Suite * s = suite_create ("dsymm");

  suite_add_tcase (s, make_dsymm_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_dsymm_suite ());
  
  /* set up the temporary symm.dat file */

  strcpy (symmdat_filename, SYMM_DATA_FILENAME);

  if ((symmdatfp = fopen (symmdat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", symmdat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}

