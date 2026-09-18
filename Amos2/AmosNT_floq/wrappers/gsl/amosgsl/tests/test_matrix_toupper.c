/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix conversions to upper triangular
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 5
#define SIZE2 5

oidtype A, B;

void
upper_setup (void)
{
  TEST_AMOS_SETUP ();

  A = nil; B = nil;

  a_setf (A, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));
  a_setf (B, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));

}


void
upper_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (A);
  agsl_matrix_deallocate (B);

  free_oid (A);
  free_oid (B);

}


void
test_matrix_upper ()
{
  dcloid (U);

  size_t k = 0;

  gsl_matrix * u;

  a_setf (U, agsl_matrix_upper_copy (env, A));

  fail_unless (ISUPPER (U));

  u = matrix (U);

  fprintf (stdout, "U = \n");
  print_matrix (u);
  
  /* check the diagonal of U and A equal */
  if (ISUNITARY (A))
    {
      double min, max;
      
      gsl_vector_view diagonalU;
      
      diagonalU = gsl_matrix_diagonal (u);

      gsl_vector_minmax (&diagonalU.vector, &min, &max);

      fail_unless (1 == min && min == max,
                   "Should have ones on main diagonal");
    }
  else
    {
      gsl_vector_view diagonalU;

      gsl_vector_view diagonalA;

      /* compare A to U's main diagonal */

      diagonalA = gsl_matrix_diagonal (matrix (A));

      diagonalU = gsl_matrix_diagonal (u);

      fail_unless (1 == gsl_vector_compare
                   (&diagonalU.vector, &diagonalA.vector),
                   "main diagonals of U and A inequal",
                   k);
      
    }
  
  /* check lower triangular part of U is zero, and values in
     upper triangular part equal that of the original
     matrix. If A is symmetric we must check where data is
     stored (as it could be in upper or lower part of A  */
  if (! (ISLOWERTRI (A) || ISDIAGONAL (A)))
    {
      for (k = 1; k < SIZE1; k++)
        {
          gsl_vector_view diagonalU;

          gsl_vector_view diagonalA;

          /* check lower triangular elements are zero */

          diagonalU = gsl_matrix_subdiagonal (u, k);

          fail_unless (1 == gsl_vector_isnull
                       (&diagonalU.vector),
                       "%d'th sub diagonal not zero", k);

          /* compare A to U's upper triangular elements, if
             A is symmetriclo or generaltrans data is stored
             in lower triangular part */

          diagonalA = (ISSYMMETRICLO (A)
                       || ISGENERALTRANS (A)
                       || ISLOWERTRANS (A)
                       ? gsl_matrix_subdiagonal (matrix (A), k)
                       : gsl_matrix_superdiagonal (matrix (A), k));

          diagonalU = gsl_matrix_superdiagonal (u, k);

          fail_unless (1 == gsl_vector_compare
                       (&diagonalU.vector, &diagonalA.vector),
                       (ISLOWER (A)
                        ? "%d'th super of U and sub of A inequal"
                        : "%d'th super of U and A don't match"),
                       k);
        }
    }
}

START_TEST (test_matrix_upper_from_general)
{
  fprintf (stdout, "GENERAL: \n");
  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_general_transposed)
{
  fprintf (stdout, "GENERAL TRANSPOSED: \n");

  SETTRANSPOSE (A);
    
  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_upper)
{
  fprintf (stdout, "UPPER: \n");
  SETUPPER (A);

  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_upper_transposed)
{
  SETUPPER (A); SETTRANSPOSE (A);
  fprintf (stdout, "UPPER TRANSPOSED: \n");

  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_symmetric_upper)
{
  SETSYMMETRIC (A); SETUPPER (A);
  fprintf (stdout, "SYMMETRIC UPPER: \n");

  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_symmetric_lower)
{
  SETSYMMETRIC (A); SETLOWER (A);
  fprintf (stdout, "SYMMETRIC LOWER: \n");

  test_matrix_upper ();
}
END_TEST
                        
START_TEST (test_matrix_upper_from_diagonal)
{
  SETDIAGONAL (A);
  fprintf (stdout, "UPPER DIAGONAL: \n");

  test_matrix_upper ();
}
END_TEST

START_TEST (test_matrix_upper_from_lower)
{
  SETLOWER (A);
  fprintf (stdout, "LOWER: \n");

  test_matrix_upper ();
}

END_TEST

START_TEST (test_matrix_upper_from_lower_transposed)
{
  fprintf (stdout, "LOWER TRANSPOSED: \n");
    /* Test A as upper-trianguler and transposed */
  SETLOWER (A); SETTRANSPOSE (A);

  test_matrix_upper ();  
}
END_TEST

START_TEST (test_matrix_upper_from_decomposed)
{
  fprintf (stdout, "DECOMPOSED: \n");
  dcloid (TMP);

  a_setf (TMP, agsl_matrix_copy (env, A));

  a_setf (A, agsl_linalg_LU_decomp (env, TMP));

  test_matrix_upper ();
}
END_TEST




/**
 * Upper triangular conversion tests
 */
TCase *
make_upper_tcase ()
{
  TCase * tc_upper = tcase_create ("Upper");

  tcase_add_checked_fixture (tc_upper, upper_setup, upper_teardown);
  
  tcase_add_test (tc_upper, test_matrix_upper_from_general);
  tcase_add_test (tc_upper, test_matrix_upper_from_general_transposed);
  tcase_add_test (tc_upper, test_matrix_upper_from_lower);
  tcase_add_test (tc_upper, test_matrix_upper_from_lower_transposed);
  tcase_add_test (tc_upper, test_matrix_upper_from_upper);
  tcase_add_test (tc_upper, test_matrix_upper_from_upper_transposed);
  tcase_add_test (tc_upper, test_matrix_upper_from_symmetric_lower);
  tcase_add_test (tc_upper, test_matrix_upper_from_symmetric_upper);
  tcase_add_test (tc_upper, test_matrix_upper_from_diagonal);
  tcase_add_test (tc_upper, test_matrix_upper_from_decomposed);

  tcase_set_timeout (tc_upper, 45);
  
  return tc_upper;
}


Suite *
make_upper_suite (void)
{
  Suite * s = suite_create ("Convert to Upper Triangular");

  suite_add_tcase (s, make_upper_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_upper_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
