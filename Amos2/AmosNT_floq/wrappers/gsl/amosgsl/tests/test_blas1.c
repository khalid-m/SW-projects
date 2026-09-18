/** -*- c-basic-offset: 2; -*- 
 *
 * Test BLAS Level 1 Initialization and Creation
 *
 */
#include "test_agsl.h"
#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

#define SIZE 1000

/**
 * Test BLAS 1 routines directly.
 */

AMOS_SETUP_TEST_VARIABLES;

/* agsl vectors */
oidtype u, v;

/* gsl vector views, assumed stable and used to compare
   with agsl vector blas operations */
gsl_vector_view uu, vv;

/* Some arrays used for testing. */
double * array_u;
double * array_v;

/**
 * Setup for BLAS Level 1, which operate on vectors
 */
void
blas_setup_level1 (void)
{
  int i = 0;

  long size = SIZE;
  
  /* setup amos */
  TEST_AMOS_SETUP ();

  array_u = malloc (sizeof (double) * size);
  array_v = malloc (sizeof (double) * size);
  
  /* initialize arrays for vectors u, v and for matrix B */
  for (i = 0; i < size; ++i)
    {
      array_u[i] = RANDOM_DOUBLE;
      array_v[i] = RANDOM_DOUBLE;
    }
  
  /* setup the test vectors u & v */
  a_setf (u, agsl_vector_init_array (array_u, size));
  a_setf (v, agsl_vector_init_array (array_v, size));

  /* make gsl vectors of underlying arrays */
  uu = gsl_vector_view_array (array_u, size);
  vv = gsl_vector_view_array (array_v, size);

} /* blas_setup_level1 */

/**
 * BLAS Level 1 teardown
 */
void
blas_teardown_level1 (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_vector_deallocate (u);
  agsl_vector_deallocate (v);
  free_oid (u);
  free_oid (v);
}

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


/**
 * Test BLAS Level 1 Setup
 */
START_TEST (test_setup_level1)
{
  int i;
  double x, y = 0;
  
  for (i = 0; i < SIZE; i++)
    {
      x = getreal (agsl_vector_get (env, u, mkinteger (i)));
      y = gsl_vector_get (&uu.vector, i);
      
      fail_unless (APPROX_EQUAL (x, y));

      x = getreal (agsl_vector_get (env, v, mkinteger (i)));
      y = gsl_vector_get (&vv.vector, i);

      fail_unless (APPROX_EQUAL (x, y));      
    }
}
END_TEST


/**
 * BLAS Level 1
 */
/**
 * Test DDOT via ALisp and directly.
 */
START_TEST (test_ddot)
{
  double ddot;
  dcloid (agslddot);
  dcloid (alispddot);

  /* time it */
  clock_t start, end;
  double cpu_time_used;
  int i = 0;
  int status;

  int multiplier = 1000 * _i;
  long size = SIZE * multiplier;

  array_u = malloc (sizeof (double) * size);
  array_v = malloc (sizeof (double) * size);
  
  /* initialize arrays for vectors u, v and for matrix B */
  for (i = 0; i < size; ++i)
    {
      array_u[i] = RANDOM_DOUBLE;
      array_v[i] = RANDOM_DOUBLE;
    }
  
  /* setup the test vectors u & v */
  a_setf (u, agsl_vector_init_array (array_u, size));
  a_setf (v, agsl_vector_init_array (array_v, size));

  /* make gsl vectors of underlying arrays */
  uu = gsl_vector_view_array (array_u, size);
  vv = gsl_vector_view_array (array_v, size);

  /* AGSL */
  i = 0;
  start = clock ();
  do
    {
      a_setf (agslddot, agsl_blas_ddot (env, u, v));
      end = clock ();
      i++;
    }
  while (end < start + CLOCKS_PER_SEC);
  cpu_time_used = (end - start) / ((double) i) / ((double) CLOCKS_PER_SEC / 1000.0);
  fprintf (stdout, " (%d, %E)\n", size, cpu_time_used);

  /* GSL */
  i = 0;
  start = clock ();
  do
    {
      status = gsl_blas_ddot (&uu.vector, &vv.vector, &ddot);
      end = clock ();
      i++;
    }
  while (end < start + CLOCKS_PER_SEC && status == GSL_SUCCESS);

  if (status == GSL_SUCCESS)
    {
      cpu_time_used = (end - start) / ((double) i) / ((double) CLOCKS_PER_SEC / 1000.0);
      fprintf (stdout, "(%d, %E)\n", size, cpu_time_used);
    }

  fail_unless (status == GSL_SUCCESS);
  
  fail_unless (APPROX_EQUAL (ddot, getreal (agslddot)),
               "gsl:%E != agsl:%E", ddot, getreal (agslddot));

  /* ALisp */
  i = 0;
  start = clock ();
  do
    {
      a_setf (alispddot, call_lisp (mksymbol ("agsl-blas-ddot"),
                                    env, 2,
                                    u, v));
      end = clock ();
      i++;
    }
  while (end < start + CLOCKS_PER_SEC);
  cpu_time_used = (end - start) / ((double) i) / ((double) CLOCKS_PER_SEC / 1000.0);
  fprintf (stdout, "(%d, %E)\n", size, cpu_time_used);
    
  fail_unless (APPROX_EQUAL (ddot, getreal (alispddot)),
               "gsl:%E != alisp:%E", ddot, getreal (alispddot));
  
}
END_TEST
/**
 * Test DNRM2
 */
START_TEST (test_dnrm2)
{
  double agslnorm = getreal (agsl_blas_dnorm (env, u));
  double norm = gsl_blas_dnrm2 (&uu.vector);

  dcloid (alispdnorm);
    
  fail_unless (APPROX_EQUAL (norm, agslnorm),
               "u: gsl:%2.1f != agsl:%2.1f",
               norm, agslnorm);

  a_setf (alispdnorm, call_lisp (mksymbol ("agsl-blas-dnorm"),
                                 env, 1, u));

  fail_unless (APPROX_EQUAL (norm, getreal (alispdnorm)),
               "gsl:%2.1f != alisp:%2.1f", norm, getreal (alispdnorm));


  /* test vector `v' */
  agslnorm = getreal (agsl_blas_dnorm (env, v));
  norm = gsl_blas_dnrm2 (&vv.vector);

  fail_unless (APPROX_EQUAL (norm, agslnorm),
               "v: gsl:%2.1f != agsl:%2.1f",
               norm, agslnorm);

  a_setf (alispdnorm, call_lisp (mksymbol ("agsl-blas-dnorm"),
                                 env, 1, v));

  fail_unless (APPROX_EQUAL (norm, getreal (alispdnorm)),
               "gsl:%2.1f != alisp:%2.1f", norm, getreal (alispdnorm));
}
END_TEST

/**
 * Test DASUM
 */
START_TEST (test_dasum)
{
  double dasum, agsldasum;

  dcloid (alispdasum);

  /* sum (abs (u)) == 7.7000 */
  dasum = gsl_blas_dasum (&uu.vector);
  agsldasum = getreal (agsl_blas_dasum (env, u));
  
  fail_unless (APPROX_EQUAL (dasum, agsldasum));
  
  a_setf (alispdasum, call_lisp (mksymbol ("agsl-blas-dasum"),
                                 env, 1, u));

  fail_unless (APPROX_EQUAL (dasum, getreal (alispdasum)),
               "gsl:%2.1f != alisp:%2.1f", dasum, getreal (alispdasum));
  
  /* test `v' */
  dasum = gsl_blas_dasum (&vv.vector);
  agsldasum = getreal (agsl_blas_dasum (env, v));
  
  fail_unless (APPROX_EQUAL (dasum, agsldasum));

  a_setf (alispdasum, call_lisp (mksymbol ("agsl-blas-dasum"),
                                 env, 1, v));

  fail_unless (APPROX_EQUAL (dasum, getreal (alispdasum)),
               "gsl:%2.1f != alisp:%2.1f", dasum, getreal (alispdasum));

  a_setf (alispdasum, call_lisp (mksymbol ("agsl-blas-dasum"),
                                 env, 1, v));
  fail_unless (APPROX_EQUAL (dasum, getreal (alispdasum)),
               "gsl:%2.1f != alisp:%2.1f", dasum, getreal (alispdasum));

  /* fail ("Not implemented"); */
}
END_TEST


/**
 * BLAS Level 1
 */
TCase * 
make_blas_tcase_level1 ()
{
  TCase * tc_level1 = tcase_create ("Level 1");

  tcase_add_checked_fixture
    (tc_level1, blas_setup_level1, blas_teardown_level1);

  tcase_add_test (tc_level1, test_setup_level1);
  tcase_add_loop_test (tc_level1, test_ddot, 1, 10);
  tcase_add_test (tc_level1, test_dnrm2);
  tcase_add_test (tc_level1, test_dasum);
  tcase_set_timeout(tc_level1, 45);
  return tc_level1;
}

Suite *
make_blas1_suite (void)
{
  Suite * s = suite_create ("Blas Level 1");
  suite_add_tcase (s, make_blas_tcase_level1 ());
  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_blas1_suite ());

  fprintf (stdout, "Execution time in ms\n");
  fprintf (stdout, "N, AGSL, GSL, ALISP\n");
  
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  
  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}


