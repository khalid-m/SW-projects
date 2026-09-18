/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test matrix lu on A_nxn, n=256 * i, i=[1..10]
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

FILE * ludatfp;

#define LU_DATA_FILENAME "lu.dat"
char ludat_filename[8] = "";

void
lu_setup (void)
{
}

void
lu_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}



double
cpu_agsl_lu ()
{
  dcloid (m); dcloid (A); 
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

      status = agsl_linalg_LU_dcmp (env, A);

      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}



/**
 * Test LU via GSL using CPU Clocks
 */
double
cpu_gsl_lu ()
{
  dcloid (m); dcloid (A);
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  int s;

  a_setf (m, mkinteger (size));

  gsl_permutation * p = gsl_permutation_alloc (size);
    
  /* test for gsl */
  i = 0;
  start = clock ();
  do
    {
      a_setf (A, agsl_matrix_rand (env, m, m));

      status = gsl_linalg_LU_decomp (matrix (A), p, &s);
      
      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test LU via AmosQL using CPU Clocks
 */
double
cpu_amosql_lu ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run lu on two random matrices */
  sprintf (query, "select lu (rand (%d));", size);

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
START_TEST (test_lu_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_ludecomp = 0;
  double amosgsl_ludecomp = 0;
  double gsl_ludecomp = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 4;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_lu ();
      double gsl = cpu_gsl_lu ();
      double amosgsl = cpu_agsl_lu ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_ludecomp += amosql;
      amosgsl_ludecomp += amosgsl;
      gsl_ludecomp += gsl;
    }
  fprintf (ludatfp, "%d\t", size);
  fprintf (ludatfp, "%E\t",
           amosql_ludecomp / k);
  fprintf (ludatfp, "%E\t",
           amosgsl_ludecomp / k);
  fprintf (ludatfp, "%E\n",
           gsl_ludecomp / k);
}
END_TEST


/**
 * Lu timing tests
 */
TCase *
make_ludecomp_tcase ()
{
  TCase * tc_lu = tcase_create ("ludecomp");

  tcase_add_checked_fixture (tc_lu, lu_setup, lu_teardown);

  tcase_add_loop_test (tc_lu, test_lu_2expi, 1, MAX);

  tcase_set_timeout (tc_lu, 245);

  return tc_lu;
}


Suite *
make_ludecomp_suite (void)
{
  Suite * s = suite_create ("ludecomp");

  suite_add_tcase (s, make_ludecomp_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_ludecomp_suite ());
  
  /* set up the temporary lu.dat file */

  strcpy (ludat_filename, LU_DATA_FILENAME);

  if ((ludatfp = fopen (ludat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", ludat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
