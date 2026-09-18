/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix subtypes
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 4
#define SIZE2 4
oidtype A, B;

void
lower_setup (void)
{
  TEST_AMOS_SETUP ();

  A = nil; B = nil;

  a_setf (A, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));
  a_setf (B, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));

}


void
lower_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (A);
  agsl_matrix_deallocate (B);

  free_oid (A);
  free_oid (B);

}


void
test_matrix_lower ()
{
  dcloid (L);

  size_t k = 0;

  gsl_matrix * u;

  a_setf (L, agsl_matrix_lower_copy (env, A));

  fail_unless (ISLOWER (L));

  u = matrix (L);

  /* check the diagonal of L and A equal */

  if (ISUNITARY (A) || ISDECOMPOSED (A))
    {
      double min, max;
      
      gsl_vector_view diagonalL;
      
      diagonalL = gsl_matrix_diagonal (u);

      gsl_vector_minmax (&diagonalL.vector, &min, &max);

      fail_unless (1 == min && min == max,
                   "Should have ones on main diagonal");
    }
  else
    {
      gsl_vector_view diagonalL;

      gsl_vector_view diagonalA;

      /* compare A to L's main diagonal */

      diagonalA = gsl_matrix_diagonal (matrix (A));

      diagonalL = gsl_matrix_diagonal (u);

      fail_unless (1 == gsl_vector_compare
                   (&diagonalL.vector, &diagonalA.vector),
                   "main diagonals of L and A inequal",
                   k);
      
    }
  
  /* check upper triangular part is zero, and values in
     lower triangular part equal that of the original
     matrix */

  if (!(ISUPPERTRI (A) || ISDIAGONAL (A)))
    {

      for (k = 1; k < SIZE1; k++)
        {
          gsl_vector_view diagonalL;

          gsl_vector_view diagonalA;

          /* check upper triangular elements are zero */

          diagonalL = gsl_matrix_superdiagonal (u, k);

          fail_unless (1 == gsl_vector_isnull
                       (&diagonalL.vector),
                       "%d'th superdiagonal not zero", k);

          /* compare A to L for lower triangular elements */

          /* if data was retrieved from upper triangular
             part of A, compare against that */
      
          diagonalA = (ISSYMMETRICUP (A)
                       || ISGENERALTRANS (A)
                       ||  ISUPPERTRANS (A)
                       ? gsl_matrix_superdiagonal (matrix (A), k)
                       : gsl_matrix_subdiagonal (matrix (A), k));

          diagonalL = gsl_matrix_subdiagonal (u, k);

          fail_unless (1 == gsl_vector_compare
                       (&diagonalL.vector, &diagonalA.vector),
                       (ISUPPER (A)
                        ? "%d'th sub L and super of A inequal"
                        : "%d'th sub L and A don't match"), k);
        }
    }
}

START_TEST (test_matrix_lower_from_general)
{
  test_matrix_lower ();
}
END_TEST


START_TEST (test_matrix_lower_from_general_transposed)
{
  SETTRANSPOSE (A);
  
  test_matrix_lower ();
}
END_TEST

START_TEST (test_matrix_lower_from_upper)
{
  SETUPPER (A);

  test_matrix_lower ();
}
END_TEST

START_TEST (test_matrix_lower_from_upper_transposed)
{
  SETUPPER (A); SETTRANSPOSE (A);

  test_matrix_lower ();
}
END_TEST

START_TEST (test_matrix_lower_from_symmetric_lower)
{
  SETSYMMETRIC (A); SETLOWER (A);

  test_matrix_lower ();
}
END_TEST

START_TEST (test_matrix_lower_from_symmetric_upper)
{
  SETSYMMETRIC (A); SETUPPER (A);

  test_matrix_lower ();
}
END_TEST


START_TEST (test_matrix_lower_from_diagonal)
{
  SETDIAGONAL (A);

  test_matrix_lower ();
}
END_TEST

START_TEST (test_matrix_lower_from_lower)
{
  SETLOWER (A);

  test_matrix_lower ();
}

END_TEST

START_TEST (test_matrix_lower_from_lower_transposed)
{
  /* Test A as lower-trianguler and transposed */
  SETLOWER (A); SETTRANSPOSE (A);

  test_matrix_lower ();
  
}
END_TEST

START_TEST (test_matrix_lower_from_decomposed)
{
  dcloid (TMP);

  a_setf (TMP, agsl_matrix_copy (env, A));

  a_setf (A, agsl_linalg_LU_decomp (env, TMP));

  test_matrix_lower ();
}
END_TEST



/**
 * Lower triangular conversion tests
 */
TCase *
make_lower_tcase ()
{
  TCase * tc_lower = tcase_create ("Lower");

  tcase_add_checked_fixture (tc_lower, lower_setup, lower_teardown);
  
  tcase_add_test (tc_lower, test_matrix_lower_from_general);
  tcase_add_test (tc_lower, test_matrix_lower_from_general_transposed);
  tcase_add_test (tc_lower, test_matrix_lower_from_upper);
  tcase_add_test (tc_lower, test_matrix_lower_from_upper_transposed);
  tcase_add_test (tc_lower, test_matrix_lower_from_lower);
  tcase_add_test (tc_lower, test_matrix_lower_from_lower_transposed);
  tcase_add_test (tc_lower, test_matrix_lower_from_symmetric_lower);
  tcase_add_test (tc_lower, test_matrix_lower_from_symmetric_upper);
  tcase_add_test (tc_lower, test_matrix_lower_from_diagonal);
  tcase_add_test (tc_lower, test_matrix_lower_from_decomposed);

  return tc_lower;
}


Suite *
make_lower_suite (void)
{
  Suite * s = suite_create ("Convert to Lower Triangular");

  suite_add_tcase (s, make_lower_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_lower_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
