/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix subtypes
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 40
#define SIZE2 40
oidtype A, B;

void
symmetric_setup (void)
{
  TEST_AMOS_SETUP ();

  A = nil; B = nil;

  a_setf (A, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));
  a_setf (B, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));

}


void
symmetric_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (A);
  agsl_matrix_deallocate (B);

  free_oid (A);
  free_oid (B);

}


void
test_matrix_symmetric ()
{
  dcloid (S);

  size_t k = 0;

  a_setf (S, agsl_matrix_symmetric_copy (env, A));

  /* debugging */
  if (ISGENERALTRANS (A))
    {
      printf ("A = \n");

      print_matrix (matrix (A));

      printf ("S = \n");

      print_matrix (matrix (S));
  
    }
  
  if (ISDECOMPOSED (A))
    {
      agsl_matrix_recomp_form (env, A);
    }
  
  fail_unless (ISSYMMETRIC (S));

  if (ISDIAGONAL (A))
    {
      fail_unless (ISDIAGONAL (S));
    }

  /* check the diagonal of S and A equal */

  if (ISUNITARY (A))
    {
      double min, max;
      
      gsl_vector_view diagonalS;
      
      diagonalS = gsl_matrix_diagonal (matrix (S));

      gsl_vector_minmax (&diagonalS.vector, &min, &max);

      fail_unless (1 == min && min == max,
                   "Should have ones on main diagonal");
    }
  else
    {
      gsl_vector_view diagonalS;

      gsl_vector_view diagonalA;

      /* compare A to S's main diagonal */

      diagonalA = gsl_matrix_diagonal (matrix (A));

      diagonalS = gsl_matrix_diagonal (matrix (S));

      fail_unless (1 == gsl_vector_compare
                   (&diagonalS.vector, &diagonalA.vector),
                   "main diagonals of S and A inequal",
                   k);
      
    }
  
  /* check upper triangular part equals values in lower
     triangular part and values in lower triangular part
     equals that of the original matrix */

  if (!ISDIAGONAL (A))
    {
      for (k = 1; k < SIZE1; k++)
        {
          gsl_vector_view diagonalS;

          gsl_vector_view diagonalA;


          /* if data was retrieved from upper triangular part
             of A, compare against that */
      
          diagonalA = (ISUPPER (A) || ISGENERALTRANS (A) 
                       ? gsl_matrix_superdiagonal (matrix (A), k)
                       : gsl_matrix_subdiagonal (matrix (A), k));

          /* compare A to S for lower triangular part of S */

          diagonalS = gsl_matrix_subdiagonal (matrix (S), k);

          fail_unless (1 == gsl_vector_compare
                       (&diagonalS.vector, &diagonalA.vector),
                       (ISUPPER (A) || ISGENERALTRANS (A)
                        ? "%d'th sub S and super of A inequal"
                        : "%d'th sub S and A don't match"), k);

          /* compare A to S for upper triangular part of S */

          diagonalS = gsl_matrix_superdiagonal (matrix (S), k);

          fail_unless (1 == gsl_vector_compare
                       (&diagonalS.vector, &diagonalA.vector),
                       (ISUPPER (A) || ISGENERALTRANS (A)
                        ? "%d'th super of S and super of A inequal"
                        : "%d'th super of S and A don't match"), k);
        }
    }
}

START_TEST (test_matrix_symmetric_from_general)
{
  printf ("GENERAL\n");

  test_matrix_symmetric ();
}
END_TEST


START_TEST (test_matrix_symmetric_from_general_transposed)
{
  printf ("GENERAL TRANSPOSED\n");

  SETTRANSPOSE (A);

  SETUNITARY (A);
  
  test_matrix_symmetric ();
}
END_TEST

START_TEST (test_matrix_symmetric_from_upper)
{
  printf ("UPPER TRIANGULAR\n");

  SETUPPER (A);

  test_matrix_symmetric ();
}
END_TEST

START_TEST (test_matrix_symmetric_from_upper_transposed)
{
  printf ("UPPER TRIANGULAR TRANSPOSED\n");
  
  SETUPPER (A); SETTRANSPOSE (A);

  test_matrix_symmetric ();
}
END_TEST

START_TEST (test_matrix_symmetric_from_symmetric_lower)
{
  printf ("SYMMETRICLO\n");
  
  SETSYMMETRIC (A); SETLOWER (A);

  test_matrix_symmetric ();
}
END_TEST

START_TEST (test_matrix_symmetric_from_symmetric_upper)
{
  printf ("SYMMETRICUP\n");
  
  SETSYMMETRIC (A); SETUPPER (A);

  test_matrix_symmetric ();
}
END_TEST


START_TEST (test_matrix_symmetric_from_diagonal)
{
  printf ("DIAGONAL\n");
  
  SETDIAGONAL (A);

  test_matrix_symmetric ();
}
END_TEST

START_TEST (test_matrix_symmetric_from_lower)
{
  printf ("LOWER\n");
  
  SETLOWER (A);

  test_matrix_symmetric ();
}

END_TEST

START_TEST (test_matrix_symmetric_from_lower_transposed)
{
  printf ("LOWER TRANSPOSED\n");
  /* Test A as lower-trianguler and transposed */
  SETLOWER (A); SETTRANSPOSE (A);

  test_matrix_symmetric ();
  
}
END_TEST

START_TEST (test_matrix_symmetric_from_decomposed)
{
  printf ("DECOMPOSED\n");
  
  dcloid (TMP);

  a_setf (TMP, agsl_matrix_copy (env, A));

  a_setf (A, agsl_linalg_LU_decomp (env, TMP));
  
  test_matrix_symmetric ();
}
END_TEST



/**
 * Symmetric conversion tests
 */
TCase *
make_symmetric_tcase ()
{
  TCase * tc_symmetric = tcase_create ("Symmetric");

  tcase_add_checked_fixture (tc_symmetric, symmetric_setup, symmetric_teardown);
  
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_general);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_general_transposed);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_upper);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_upper_transposed);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_lower);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_lower_transposed);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_symmetric_lower);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_symmetric_upper);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_diagonal);
  tcase_add_test (tc_symmetric, test_matrix_symmetric_from_decomposed);

  return tc_symmetric;
}


Suite *
make_symmetric_suite (void)
{
  Suite * s = suite_create ("Convert to Symmetric");

  suite_add_tcase (s, make_symmetric_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_symmetric_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
