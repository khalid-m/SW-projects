/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test matrix trmm on A_nxn, n=256 * i, i=[1..10]
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

FILE * trmmdatfp;

#define TRMM_DATA_FILENAME "trmm.dat"
char trmmdat_filename[8] = "";

void
trmm_setup (void)
{
}

void
trmm_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


double
cpu_agsl_dtrmm ()
{
  dcloid (alpha); dcloid (m); dcloid (A); dcloid (B);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  int status;
  unsigned int i = 0;

  a_setf (m, mkinteger (size));
  a_setf (alpha, mkreal (ALPHA1));

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      /* Set up test matrices */
      a_setf (A, agsl_matrix_rand (env, m, m));
      a_setf (B, agsl_matrix_rand (env, m, m));

      status = agsl_blas_dtmm (env, alpha, A, B);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test DTRMM via GSL using CPU Clocks
 */
double
cpu_gsl_dtrmm ()
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

      status = gsl_blas_dtrmm (CblasLeft, CblasLower,
                               CblasNoTrans,
                               CblasNonUnit,
                               ALPHA1,
                               matrix (A),
                               matrix (B));
      i++;
      end = clock ();

    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test DTRMM via AmosQL using CPU Clocks
 */
double
cpu_amosql_dtrmm ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run dtrmm on two random matrices */
  sprintf (query, "select dtrmm (rand (%d), rand (%d));",
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
START_TEST (test_trmm_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_dtrmm = 0;
  double amosgsl_dtrmm = 0;
  double gsl_dtrmm = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 4;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_dtrmm ();
      double gsl = cpu_gsl_dtrmm ();
      double amosgsl = cpu_agsl_dtrmm ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_dtrmm += amosql;
      amosgsl_dtrmm += amosgsl;
      gsl_dtrmm += gsl;
    }
  fprintf (trmmdatfp, "%d\t", size);
  fprintf (trmmdatfp, "%E\t",
           amosql_dtrmm / k);
  fprintf (trmmdatfp, "%E\t",
           amosgsl_dtrmm / k);
  fprintf (trmmdatfp, "%E\n",
           gsl_dtrmm / k);
}
END_TEST


/**
 * Trmm timing tests
 */
TCase *
make_dtrmm_tcase ()
{
  TCase * tc_trmm = tcase_create ("dtrmm");

  tcase_add_checked_fixture (tc_trmm, trmm_setup, trmm_teardown);

  tcase_add_loop_test (tc_trmm, test_trmm_2expi, 1, MAX);

  tcase_set_timeout (tc_trmm, 245);

  return tc_trmm;
}


Suite *
make_dtrmm_suite (void)
{
  Suite * s = suite_create ("dtrmm");

  suite_add_tcase (s, make_dtrmm_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_dtrmm_suite ());
  
  /* set up the temporary trmm.dat file */

  strcpy (trmmdat_filename, TRMM_DATA_FILENAME);

  if ((trmmdatfp = fopen (trmmdat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", trmmdat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
