/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test matrix lusolve on A_nxn, n=256 * i, i=[1..10]
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

FILE * lusolvedatfp;

#define LUSOLVE_DATA_FILENAME "lusolve.dat"
char lusolvedat_filename[8] = "";

void
lusolve_setup (void)
{
}

void
lusolve_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}



double
cpu_agsl_lusolve ()
{
  dcloid (m); dcloid (A); dcloid (C); 
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  int status;
  unsigned int i = 0;

  a_setf (m, mkinteger (size));

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      /* Set up test matrices */
      a_setf (A, agsl_matrix_rand (env, m, m));
      a_setf (C, agsl_matrix_rand (env, m, m));

      /* decompose A */
      agsl_linalg_LU_dcmp (env, A);

      status = agsl_linalg_LU_svx_alpha_ab (env, mkreal (ALPHA1), A, C);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}



/**
 * Test LUSOLVE via GSL using CPU Clocks
 */
double
cpu_gsl_lusolve ()
{
  dcloid (m); dcloid (A); dcloid (C); 
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  int status;
  unsigned int i = 0;

  a_setf (m, mkinteger (size));

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      /* Set up test matrices */
      a_setf (A, agsl_matrix_rand (env, m, m));
      a_setf (C, agsl_matrix_rand (env, m, m));

      /* decompose A */
      agsl_linalg_LU_dcmp (env, A);

      status = agsl_linalg_LU_svx_alpha_ab (env, mkreal (ALPHA1), A, C);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test LUSOLVE via AmosQL using CPU Clocks
 */
double
cpu_amosql_lusolve ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run lusolve on two random matrices */
  sprintf (query, "select lusolve (lu (rand (%d)), rand (%d));", size, size);

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
START_TEST (test_lusolve_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_lusolve = 0;
  double amosgsl_lusolve = 0;
  double gsl_lusolve = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 4;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_lusolve ();
      double gsl = cpu_gsl_lusolve ();
      double amosgsl = cpu_agsl_lusolve ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_lusolve += amosql;
      amosgsl_lusolve += amosgsl;
      gsl_lusolve += gsl;
    }
  fprintf (lusolvedatfp, "%d\t", size);
  fprintf (lusolvedatfp, "%E\t",
           amosql_lusolve / k);
  fprintf (lusolvedatfp, "%E\t",
           amosgsl_lusolve / k);
  fprintf (lusolvedatfp, "%E\n",
           gsl_lusolve / k);
}
END_TEST


/**
 * Lusolve timing tests
 */
TCase *
make_lusolve_tcase ()
{
  TCase * tc_lusolve = tcase_create ("lusolve");

  tcase_add_checked_fixture (tc_lusolve, lusolve_setup, lusolve_teardown);

  tcase_add_loop_test (tc_lusolve, test_lusolve_2expi, 1, MAX);

  tcase_set_timeout (tc_lusolve, 245);

  return tc_lusolve;
}


Suite *
make_lusolve_suite (void)
{
  Suite * s = suite_create ("lusolve");

  suite_add_tcase (s, make_lusolve_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_lusolve_suite ());
  
  /* set up the temporary lusolve.dat file */

  strcpy (lusolvedat_filename, LUSOLVE_DATA_FILENAME);

  if ((lusolvedatfp = fopen (lusolvedat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", lusolvedat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
