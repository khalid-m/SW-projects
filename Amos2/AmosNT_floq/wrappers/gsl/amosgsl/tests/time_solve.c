/** -*- c-basic-offset: 2; -*-
 *
 * Description: Test general decomposition on $A_{nxn}, n=256 * i,
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

FILE * solvedatfp;

#define SOLVE_DATA_FILENAME "solve.dat"
char solvedat_filename[9] = "";

void
solve_setup (void)
{
}

void
solve_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


double
cpu_agsl_solve ()
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
      a_setf (A, agsl_matrix_rand (env, m, m));
 
      a_setf (C, agsl_matrix_rand (env, m, m));

      agsl_linalg_solve_alpha_ab (env, mkreal (ALPHA1), A, C);

      status = GSL_SUCCESS;
      
      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}



/**
 * Test solve via GSL using CPU Clocks
 */
double
cpu_gsl_solve ()
{
  dcloid (m); dcloid (A); dcloid (C);
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
      a_setf (C, agsl_matrix_rand (env, m, m));

      agsl_linalg_solve_alpha_ab (env, mkreal (ALPHA1), A, C);
      status = GSL_SUCCESS;
      
      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}

/**
 * Test naive solve via GSL using CPU Clocks
 */
double
cpu_naive_gsl_solve ()
{
  dcloid (m); dcloid (A); dcloid (invA); dcloid (C);
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
      a_setf (C, agsl_matrix_rand (env, m, m));
      a_setf (invA, agsl_matrix_new (size, size));

      /* decompose A into LU */
      agsl_linalg_LU_dcmp (env, A);

      /* invert LU (not implemented in agsl) */
      
      gsl_linalg_LU_invert (matrix (A), gslperm (A), matrix (invA));

      /* multiply the inverse if A and C, that is A * B = C ->
         B = A^{-1} C */
      
      agsl_blas_dgemm_alpha_ab (env, mkreal (ALPHA1), invA, C);
      status = GSL_SUCCESS;
      
      i++;
      end = clock ();
    }
  while (end < start + resolution && status == GSL_SUCCESS);

  return timediff (i, start, end);
}


/**
 * Test solve via AmosQL using CPU Clocks
 */
double
cpu_amosql_solve ()
{
  clock_t start, end;
  int resolution = CLOCKS_PER_SEC;
  unsigned int i = 0;
  int status;
  
  char * query = malloc (100);
  
  /* run solve on two random matrices */
  sprintf (query, "select solve(rand(%d), rand(%d));", size, size);

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
START_TEST (test_solve_2expi)
{
  size_t i = 0, j = 0, k = 0;
  double amosql_solve = 0;
  double amosgsl_solve = 0;
  double gsl_solve = 0;
  double naive_gsl_solve = 0;

  size = (size_t) gsl_pow_int ((double) 2, _i);

  /* 2^1=2, 2^10=1024 */

  k = 1;

  fprintf (stdout, "Size: %d, K: %d\n", size, k);
  
  /* `k' decreases as `size' increases -- size=2, k=512
     .. size=512, k=2 */
  for (j = 0; j < k; j++)
    {
      double amosql = cpu_amosql_solve ();
      double amosgsl = cpu_agsl_solve ();
      double gsl = cpu_gsl_solve ();
      double naive_gsl = cpu_naive_gsl_solve ();

      /* sum for an average over 2^(10-i) iterations */
      amosql_solve += amosql;
      amosgsl_solve += amosgsl;
      gsl_solve += gsl;
      naive_gsl_solve += naive_gsl;
    }
  fprintf (solvedatfp, "%d\t", size);
  fprintf (solvedatfp, "%E\t",
           amosql_solve / k);
  fprintf (solvedatfp, "%E\t",
           amosgsl_solve / k);
  fprintf (solvedatfp, "%E\n",
           gsl_solve / k);
  fprintf (solvedatfp, "%E\n",
           naive_gsl_solve / k);

}
END_TEST


/**
 * Solve timing tests
 */
TCase *
make_solve_tcase ()
{
  TCase * tc_solve = tcase_create ("solve");

  tcase_add_checked_fixture (tc_solve, solve_setup, solve_teardown);

  tcase_add_loop_test (tc_solve, test_solve_2expi, 1, MAX);

  tcase_set_timeout (tc_solve, 245);

  return tc_solve;
}


Suite *
make_solve_suite (void)
{
  Suite * s = suite_create ("solve");

  suite_add_tcase (s, make_solve_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_solve_suite ());
  
  /* set up the temporary solve.dat file */

  strcpy (solvedat_filename, SOLVE_DATA_FILENAME);

  if ((solvedatfp = fopen (solvedat_filename, "w")) == NULL) {
    fprintf (stderr, "%s: %s\n", solvedat_filename, strerror (errno));
  }

  /* setup amos once */
  TEST_AMOS_SETUP ();

  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
