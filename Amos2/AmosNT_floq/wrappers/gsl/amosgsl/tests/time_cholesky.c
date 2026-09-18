/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test chol decomposition on $A_{nxn}, n=256 * i,
 * i=[1..10]$
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

FILE * choleskydatfp;

#define CHOLESKY_DATA_FILENAME "cholesky.dat"
char choleskydat_filename[8] = "";

void
cholesky_setup (void)
{
}

void
cholesky_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


double
cpu_agsl_cholesky ()
{
  dcloid (m); dcloid (A);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  int status;
  unsigned int i = 0;

  a_setf (m, mkinteger (size));

  a_setf (A, agsl_matrix_identity (env, m, m));

 
  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      status = agsl_linalg_cholesky_dcmp (env, A);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}



/**
 * Test cholesky via GSL using CPU Clocks
 */
double
cpu_gsl_cholesky ()
{
  dcloid (m); dcloid (A);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;

  a_setf (m, mkinteger (size));

  a_setf (A, agsl_matrix_identity (env, m, m));

  
  /* test for gsl */
  i = 0;
  start = clock ();
  do
    {
      status = gsl_linalg_cholesky_decomp (matrix (A));
      
      i++;

      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test cholesky via AmosQL using CPU Clocks
 */
double
cpu_amosql_cholesky ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run chol on two random matrices */
  sprintf (query, "select chol(eye(%d));", size);

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
START_TEST (test_cholesky_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_cholesky = 0;
  double amosgsl_cholesky = 0;
  double gsl_cholesky = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 4;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_cholesky ();
      double gsl = cpu_gsl_cholesky ();
      double amosgsl = cpu_agsl_cholesky ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_cholesky += amosql;
      amosgsl_cholesky += amosgsl;
      gsl_cholesky += gsl;
    }
  fprintf (choleskydatfp, "%d\t", size);
  fprintf (choleskydatfp, "%E\t",
           amosql_cholesky / k);
  fprintf (choleskydatfp, "%E\t",
           amosgsl_cholesky / k);
  fprintf (choleskydatfp, "%E\n",
           gsl_cholesky / k);
}
END_TEST


/**
 * Cholesky timing tests
 */
TCase *
make_cholesky_tcase ()
{
  TCase * tc_cholesky = tcase_create ("cholesky");

  tcase_add_checked_fixture (tc_cholesky, cholesky_setup, cholesky_teardown);

  tcase_add_loop_test (tc_cholesky, test_cholesky_2expi, 1, MAX);

  tcase_set_timeout (tc_cholesky, 245);

  return tc_cholesky;
}


Suite *
make_cholesky_suite (void)
{
  Suite * s = suite_create ("cholesky");

  suite_add_tcase (s, make_cholesky_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_cholesky_suite ());
  
  /* set up the temporary cholesky.dat file */

  strcpy (choleskydat_filename, CHOLESKY_DATA_FILENAME);

  if ((choleskydatfp = fopen (choleskydat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", choleskydat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
