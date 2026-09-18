/** -*- c-basic-offset: 2; -*- 
 *
 * Test Linear Algebra 
 *
 * Tests include: lu_solve_mv, lu_solve_alpha_ab,
 *                cholesky_solve_mv, cholesky_solve_alpha_ab
 *
 */
#include "test_agsl.h"

#define SIZE 5

AMOS_SETUP_TEST_VARIABLES;

/* agsl matrices */
oidtype A, LUP, C;

/* Some arrays used for testing. */
double array_a[] = { 0.84019, 0.78310, 0.91165, 0.33522, 0.27777,
                     0.47740, 0.36478, 0.95223, 0.63571, 0.14160,
                     0.01630, 0.13723, 0.15668, 0.12979, 0.99892,
                     0.51293, 0.61264, 0.63755, 0.49358, 0.29252,
                     0.52674, 0.40023, 0.28331, 0.80772, 0.06976 };

double array_c[] = { 0.39438, 0.79844, 0.19755, 0.76823, 0.55397,
                     0.62887, 0.51340, 0.91620, 0.71730, 0.60697,
                     0.24289, 0.80418, 0.40094, 0.10881, 0.21826,
                     0.83911, 0.29603, 0.52429, 0.97278, 0.77136,
                     0.76991, 0.89153, 0.35246, 0.91903, 0.94933 };
  
gsl_matrix_view a;
gsl_matrix * aa;
gsl_matrix_view c;
gsl_matrix * cc;

/* decomposed matrix */
gsl_matrix * lu;
gsl_permutation * p;

/* solution of A B = C for B */
gsl_matrix * b;

gsl_matrix * b2;


/**
 * Setup linear algebra test matrices A B and C
 */
void
linalg_setup (void)
{
  int i, j = 0;
  
  /* setup amos */
  TEST_AMOS_SETUP ();

  /* matrix to solve for: B */

  b = gsl_matrix_alloc (SIZE, SIZE);
  b2 = gsl_matrix_alloc (SIZE, SIZE);

  /* views */
  
  a = gsl_matrix_view_array (array_a, SIZE, SIZE);

  c = gsl_matrix_view_array (array_c, SIZE, SIZE);
  
  /* agsl matrices  */

  aa = gsl_matrix_alloc (SIZE, SIZE);

  gsl_matrix_memcpy (aa, &a.matrix);

  a_setf (A, agsl_matrix_assign (aa));

  cc = gsl_matrix_alloc (SIZE, SIZE);

  gsl_matrix_memcpy (cc, &c.matrix);

  a_setf (C, agsl_matrix_assign (cc));
  
} /* blas_setup_level3 */


/**
 *  Free memory
 */
void
linalg_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (A);

  agsl_matrix_deallocate (C);

  free_oid (A); free_oid (C);
}

/**
 *  Set up LU decomposed matrices 
 */
void
lu_setup (void)
{
  int i, signum;
  linalg_setup ();

  /* decompose a into [l, u, p] */
  {
    p = gsl_permutation_alloc (SIZE);

    lu = gsl_matrix_alloc (SIZE, SIZE);
    
    gsl_matrix_memcpy (lu, &a.matrix);

    gsl_linalg_LU_decomp (lu, p, &signum);
  }

  /* decompose agsl_matrix A into LUP */
  
  a_setf (LUP, agsl_linalg_LU_decomp (env, A));

  {
    /* solve LU B = C for B */

    /* B <- C */

    gsl_matrix_memcpy (b, &c.matrix);
    gsl_matrix_memcpy (b2, &c.matrix);

    /* for each column vector C_i solve for B_i */
    for (i = 0; i < SIZE; i++)
      {
        gsl_vector_view bi = gsl_matrix_column (b, i);

        /* solve A b = c for `b' in-place with `b' a copy of RHS `c' */
        gsl_linalg_LU_svx (lu, p, &(bi.vector));

        /* mess with `b2' to test different impl. of solve */
        bi = gsl_matrix_column (b2, i);

        gsl_permute_vector (p, &(bi.vector));
      }

    /* b2 is solved differently */

    /* Perform forward-substitution, L D = P C -> D = inv (L) P C */

    gsl_blas_dtrsm (CblasLeft, CblasLower, CblasNoTrans, CblasUnit, ALPHA1, lu, b2);

    /* Perform back-substitution, U B = D  -> B = inv (L) D */

    gsl_blas_dtrsm (CblasLeft, CblasUpper, CblasNoTrans, CblasNonUnit, ALPHA1, lu, b2);

    
  }
}


/**
 *  Free memory
 */
void
lu_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (LUP);

  free_oid (LUP);
}


/**
 *  Free memory
 */
void
cholesky_setup (void)
{
}


/**
 *  Free memory
 */
void
cholesky_teardown (void)
{
}


/**
 * Test agsl_matrix's A and C are equal to a and c
 * respectively.
 */
START_TEST (test_linalg_setup)
{
  int i, j, idx;

  fail_unless (1 == gsl_matrix_compare (matrix (A), &a.matrix));

  fail_unless (1 == gsl_matrix_compare (matrix (C), &c.matrix));

}
END_TEST


/**
 * Test LU = lu and P = p
 */
START_TEST (test_LU_setup)
{
  fail_unless (1 == gsl_matrix_compare (matrix (LUP), lu));
  
  fail_unless (1 == gsl_permutation_compare (gslperm (LUP), p));
  
  fail_unless (1 == gsl_matrix_compare (b, b2));
}
END_TEST


START_TEST (test_LU_solve_mv)
{
  fail ("Test not complete");
}
END_TEST


START_TEST (test_LU_solve_alpha_ab)
{
  dcloid (B);
   
  a_setf (B, agsl_linalg_LU_solve_alpha_ab (env, mkreal (ALPHA1), LUP, C));

  fail_unless (1 == gsl_matrix_compare (b, matrix (B)));
}
END_TEST


START_TEST (test_solve)
{
  dcloid (B);
   
  a_setf (B, agsl_linalg_solve (env, mkreal (ALPHA1), LUP, mkreal (BETA0), C, C));

  print_matrix (matrix (B));
  
  fail_unless (1 == gsl_matrix_compare (b, matrix (B)));
}
END_TEST

/**
 * Test LU = lu and P = p
 */
START_TEST (test_cholesky_setup)
{
  fail_unless (1 == gsl_matrix_compare (matrix (LUP), lu));
  
  fail_unless (1 == gsl_permutation_compare (gslperm (LUP), p));
  
}
END_TEST

START_TEST (test_cholesky_solve_mv)
{
  fail ("Test not complete");
}
END_TEST


START_TEST (test_cholesky_solve_alpha_ab)
{
  fail ("Test not complete");
}
END_TEST


/**
 * General linear algebra tests
 */
TCase *
make_linalg_tcase ()
{
  TCase * tc_linalg = tcase_create ("Linear Algebra");

  tcase_add_checked_fixture
    (tc_linalg, linalg_setup, linalg_teardown);

  tcase_add_test (tc_linalg, test_linalg_setup);

  return tc_linalg;
}

/**
 * LU decomposition and solving tests
 */
TCase *
make_LU_tcase ()
{
  TCase * tc_lu = tcase_create ("LU Decompose and Solve");

  tcase_add_checked_fixture (tc_lu, lu_setup, lu_teardown);

  tcase_add_test (tc_lu, test_LU_setup);

  tcase_add_test (tc_lu, test_LU_solve_mv);

  tcase_add_test (tc_lu, test_LU_solve_alpha_ab);

  tcase_add_test (tc_lu, test_solve);

  return tc_lu;
}


/**
 * Cholesky decomposition and solving tests
 */
TCase *
make_cholesky_tcase ()
{
  TCase * tc_cholesky = tcase_create ("Cholesky");

  tcase_add_checked_fixture (tc_cholesky, cholesky_setup, cholesky_teardown);
  
  tcase_add_test (tc_cholesky, test_cholesky_setup);
  
  tcase_add_test (tc_cholesky, test_cholesky_solve_mv);

  tcase_add_test (tc_cholesky, test_cholesky_solve_alpha_ab);

  return tc_cholesky;
}


Suite *
make_linalg_suite (void)
{
  Suite * s = suite_create ("Linear Algebra");

  suite_add_tcase (s, make_linalg_tcase ());

  suite_add_tcase (s, make_LU_tcase ());

/*  suite_add_tcase (s, make_cholesky_tcase ());*/

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_linalg_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
