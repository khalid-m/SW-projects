/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix copy
 *
 */

#include "test_agsl.h"
#include <gsl/gsl_math.h>
#include <time.h>                               
#include <sys/time.h>
#include <sys/resource.h>

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 2
#define SIZE2 2

int resultfd = -1;
FILE * resultfp;

#define TEMP_RESULT_FILENAME_TEMPLATE "copy_XXXXXX"
#define TEMP_RESULT_FILENAME_LENGTH 15

char result_filename[TEMP_RESULT_FILENAME_LENGTH] = "";

/* microseconds (usec) */
double getcputime (void)
{
  struct timeval tim;
  struct rusage ru;
  getrusage (RUSAGE_SELF, &ru);
  tim=ru.ru_utime;
  double t= (double)tim.tv_sec * 1000000.0 + (double)tim.tv_usec;
  tim=ru.ru_stime;
  t+= (double)tim.tv_sec * 1000000.0 + (double)tim.tv_usec;
  return t;
}


void
copy_setup (void)
{
  TEST_AMOS_SETUP ();

}

void
copy_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


START_TEST (test_matrix_copy_from_general)
{
  dcloid (A);
  dcloid (U);
  clock_t start, end;
  double cpu_ms_used;
  int i = 0;
  size_t k = 0;
  gsl_matrix * u;

  /* run for 6^1, 6^2, ..., 6^9 */
  long size = (long) gsl_pow_int (SIZE1, _i);

  a_setf (A, agsl_matrix_rand (env, mkinteger (size), mkinteger (size)));

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      a_setf (U, agsl_matrix_copy (env, A));
      i++;
      end = clock ();
    }
  while ((end < start + CLOCKS_PER_SEC) || i < 1000);
  cpu_ms_used = (end - start) / ((double) i);

  if (_i == 1)
    {
      fprintf (resultfp, "AGSL\n");
    }
  fprintf (resultfp, " (%d, %E)\n", size, cpu_ms_used);

}
END_TEST


START_TEST (gsl_copy_from_general)
{
  gsl_matrix * A;
  gsl_matrix * U;

  clock_t start, end;
  double cpu_ms_used;
  int i = 0;
  size_t k = 0;
  gsl_matrix * u;

  /* run for 6^1, 6^2, ..., 6^9 */
  unsigned long size = (unsigned long) gsl_pow_int (SIZE1, _i);

  A = matrix (agsl_matrix_rand (env, mkinteger (size), mkinteger (size)));
  U = gsl_matrix_alloc (size, size);
  
  /* test for gsl */
  i = 0;
  start = clock ();
  do
    {
      gsl_matrix_memcpy (U, A);
      i++;
      end = clock ();
    }
  while ((end < start + CLOCKS_PER_SEC) || i < 1000);
  cpu_ms_used = (end - start) / ((double) i);

  if (_i == 1)
    {
      fprintf (resultfp, "GSL\n");
    }
  fprintf (resultfp, " (%d, %E)\n", size, cpu_ms_used);

}
END_TEST


START_TEST (test_matrix_rusage_general)
{
  dcloid (A);
  dcloid (U);
  clock_t start, end;
  double cpu_ms_used;
  int i = 0;
  size_t k = 0;
  gsl_matrix * u;

  /* run for 6^1, 6^2, ..., 6^9 */
  long size = (long) gsl_pow_int (SIZE1, _i);

  a_setf (A, agsl_matrix_rand (env, mkinteger (size), mkinteger (size)));

  /* test for agsl */
  i = 0;
  start = clock ();
  do
    {
      a_setf (U, agsl_matrix_copy (env, A));
      i++;
      end = clock ();
    }
  while ((end < start + CLOCKS_PER_SEC) || i < 1000);
  cpu_ms_used = (end - start) / ((double) i);

  if (_i == 1)
    {
      fprintf (resultfp, "AGSL\n");
    }
  fprintf (resultfp, " (%d, %E)\n", size, cpu_ms_used);

}
END_TEST


START_TEST (gsl_rusage_general)
{
  gsl_matrix * A;
  gsl_matrix * U;

  clock_t start, end;
  double cpu_ms_used;
  int i = 0;
  size_t k = 0;
  gsl_matrix * u;

  /* run for 6^1, 6^2, ..., 6^9 */
  unsigned long size = (unsigned long) gsl_pow_int (SIZE1, _i);

  A = matrix (agsl_matrix_rand (env, mkinteger (size), mkinteger (size)));
  U = gsl_matrix_alloc (size, size);
  
  /* test for gsl */
  i = 0;
  start = clock ();
  do
    {
      gsl_matrix_memcpy (U, A);
      i++;
      end = clock ();
    }
  while ((end < start + CLOCKS_PER_SEC) || i < 1000);
  cpu_ms_used = (end - start) / ((double) i);

  if (_i == 1)
    {
      fprintf (resultfp, "GSL\n");
    }
  fprintf (resultfp, " (%d, %E)\n", size, cpu_ms_used);

}
END_TEST


/**
 * Copy timing tests
 */
TCase *
make_copy_tcase ()
{
  TCase * tc_copy = tcase_create ("Copy");

  tcase_add_checked_fixture (tc_copy, copy_setup, copy_teardown);
  
  tcase_add_loop_test (tc_copy, test_matrix_copy_from_general, 6, 12);
  tcase_add_loop_test (tc_copy, gsl_copy_from_general, 6, 12);
  tcase_add_loop_test (tc_copy, test_matrix_rusage_general, 6, 12);
  tcase_add_loop_test (tc_copy, gsl_rusage_general, 6, 12);

  tcase_set_timeout (tc_copy, 45);
  
  return tc_copy;
}


Suite *
make_copy_suite (void)
{
  Suite * s = suite_create ("Copy Matrix");

  suite_add_tcase (s, make_copy_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_copy_suite ());

  /* set up the temporary result file */
  
  strcpy (result_filename, TEMP_RESULT_FILENAME_TEMPLATE);
  
  if ((resultfd = mkstemp (result_filename)) == -1 ||
      (resultfp = fdopen (resultfd, "w")) == NULL) {
    if (resultfd != -1) {
      unlink (result_filename);
      close (resultfd);
    }
    fprintf (stderr, "%s: %s\n", result_filename, strerror (errno));
  }

  
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
