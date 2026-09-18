/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix conversions to form triangular
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 4
#define SIZE2 4

oidtype A;

void
form_setup (void)
{
  TEST_AMOS_SETUP ();

  A = nil; 

  a_setf (A, agsl_matrix_rand (env, mkinteger (SIZE1), mkinteger (SIZE2)));
}


void
form_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (A);

  free_oid (A);
}


void
test_matrix_form ()
{
  dcloid (B);

  size_t k = 0;

  gsl_matrix * a;

  a_setf (B, agsl_matrix_softcopy (env, A));
  
  agsl_matrix_form (env, A);

  a = matrix (A);

  fprintf (stdout, "A = \n");
  print_matrix (a);
  
  /* check the diagonal of U and A equal */
  if (ISUNITARY (B))
    {
      double min, max;
      
      gsl_vector_view diagonalA;
      
      diagonalA = gsl_matrix_diagonal (a);

      gsl_vector_minmax (&diagonalA.vector, &min, &max);

      fail_unless (1 == min && min == max,
                   "Should have ones on main diagonal");
    }
  else
    {
      gsl_vector_view diagonalA;
      gsl_vector_view diagonalB;

      /* compare A to B's main diagonal */

      diagonalA = gsl_matrix_diagonal (a);

      diagonalB = gsl_matrix_diagonal (matrix (B));

      fail_unless (1 == gsl_vector_compare
                   (&diagonalB.vector, &diagonalA.vector),
                   "main diagonals of B and A inequal");
      
    }
  
  if (!(ISDIAGONAL (B)))
    {
      /* if B is lower or upper triangular, A should have
         zeros above or below the diagonal respectively */
      for (k = 1; k < SIZE1; k++)
        {
          gsl_vector_view diagonalA;
          gsl_vector_view diagonalB;

          if (ISTRIANGULAR (B))
            {
              /* check upper / lower triangular elements are zero */
              diagonalA = (ISLOWERTRI (B)
                           ? gsl_matrix_superdiagonal (a, k)
                           : gsl_matrix_subdiagonal (a, k));
          
              fail_unless (1 == gsl_vector_isnull
                           (&diagonalA.vector),
                           "%d'th sub diagonal not zero", k);
          
              /* check upper / lower triangle equals B */
              diagonalA = (ISUPPERTRI (B)
                           ? gsl_matrix_superdiagonal (a, k)
                           : gsl_matrix_subdiagonal (a, k));
              
              /* matrix is upper / lower triangular but data in
                 B may be stored in lower / upper triangle */
              diagonalB =
                (GETUPLO (B) == CblasLower
                 ? gsl_matrix_subdiagonal (matrix (B), k)
                 : gsl_matrix_superdiagonal (matrix (B), k));
              
              fail_unless
                (1 == gsl_vector_compare
                 (&diagonalA.vector, &diagonalB.vector),
                 (GETUPLO (B) == CblasLower
                  ? "%d'th super of A and sub of B inequal"
                  : "%d'th super of A and B don't match"),
                 k);
            }
          else if (ISSYMMETRIC (B))
            {
              diagonalB =
                (GETUPLO (B) == CblasLower
                 ? gsl_matrix_subdiagonal (matrix (B), k)
                 : gsl_matrix_superdiagonal (matrix (B), k));

              diagonalA = gsl_matrix_superdiagonal (a, k);

              fail_unless
                (1 == gsl_vector_compare
                 (&diagonalA.vector, &diagonalB.vector),
                 (GETUPLO (B) == CblasLower
                  ? "%d'th super of A and sub of B inequal"
                  : "%d'th super of A and B don't match"),
                 k);
              
              diagonalA = gsl_matrix_subdiagonal (a, k);

              fail_unless
                (1 == gsl_vector_compare
                 (&diagonalA.vector, &diagonalB.vector),
                 (GETUPLO (B) == CblasLower
                  ? "%d'th sub of A and sub of B inequal"
                  : "%d'th sub of A and B don't match"),
                 k);
            }
        }
      if (ISGENERAL (B))
        {
          gsl_matrix * bb = gsl_matrix_alloc (ROWS (B), COLS (B));
          if ISTRANSPOSE (B)
            {
              gsl_matrix_transpose_memcpy (bb, matrix (B));
            }
          else
            {
              gsl_matrix_memcpy (bb, matrix (B));
            }

          gsl_matrix_compare (a, bb);
        }

    }
}

START_TEST (test_form_general)
{
  fprintf (stdout, "GENERAL: \n");
  test_matrix_form ();
}
END_TEST

START_TEST (test_form_general_transposed)
{
  fprintf (stdout, "GENERAL TRANSPOSED: \n");

  SETTRANSPOSE (A);
    
  test_matrix_form ();
}
END_TEST

START_TEST (test_form_upper)
{
  fprintf (stdout, "UPPER: \n");
  SETUPPER (A);

  test_matrix_form ();
}
END_TEST

START_TEST (test_form_upper_transposed)
{
  SETUPPER (A); SETTRANSPOSE (A);
  fprintf (stdout, "UPPER TRANSPOSED: \n");

  test_matrix_form ();
}
END_TEST

START_TEST (test_form_symmetric_upper)
{
  SETSYMMETRIC (A); SETUPPER (A);
  fprintf (stdout, "SYMMETRIC UPPER: \n");

  test_matrix_form ();
}
END_TEST

START_TEST (test_form_symmetric_lower)
{
  SETSYMMETRIC (A); SETLOWER (A);
  fprintf (stdout, "SYMMETRIC LOWER: \n");

  test_matrix_form ();
}
END_TEST
                        
START_TEST (test_form_diagonal)
{
  SETDIAGONAL (A);
  fprintf (stdout, "UPPER DIAGONAL: \n");

  test_matrix_form ();
}
END_TEST

START_TEST (test_form_lower)
{
  SETLOWER (A);
  fprintf (stdout, "LOWER: \n");

  test_matrix_form ();
}

END_TEST

START_TEST (test_form_lower_transposed)
{
  fprintf (stdout, "LOWER TRANSPOSED: \n");
  /* Test A as upper-trianguler and transposed */
  SETLOWER (A); SETTRANSPOSE (A);

  test_matrix_form ();  
}
END_TEST

START_TEST (test_form_decomposed)
{
  fprintf (stdout, "DECOMPOSED: \n");

  dcloid (TMP);

  a_setf (TMP, agsl_matrix_copy (env, A));

  a_setf (A, agsl_linalg_LU_decomp (env, TMP));

  test_matrix_form ();
}
END_TEST




/**
 * Upper triangular conversion tests
 */
TCase *
make_form_tcase ()
{
  TCase * tc_form = tcase_create ("Form");

  tcase_add_checked_fixture (tc_form, form_setup, form_teardown);
  
  tcase_add_test (tc_form, test_form_general);
  tcase_add_test (tc_form, test_form_general_transposed);
  tcase_add_test (tc_form, test_form_lower);
  tcase_add_test (tc_form, test_form_lower_transposed);
  tcase_add_test (tc_form, test_form_upper);
  tcase_add_test (tc_form, test_form_upper_transposed);
  tcase_add_test (tc_form, test_form_symmetric_lower);
  tcase_add_test (tc_form, test_form_symmetric_upper);
  tcase_add_test (tc_form, test_form_diagonal);
  tcase_add_test (tc_form, test_form_decomposed);

  return tc_form;
}


Suite *
make_form_suite (void)
{
  Suite * s = suite_create ("Form different matrices");

  suite_add_tcase (s, make_form_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_form_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
