/** -*- c-basic-offset: 2; -*- 
 *
 * Test Blas Level 3 Routines
 *
 * Tests include: gemm, trmm, trsm, symm
 *
 */
#include "test_agsl.h"

#define M 5
#define N 5
#define P 5

AMOS_SETUP_TEST_VARIABLES;

/* agsl matrices */
oidtype a, b, sq_a, sq_b;

/* gsl matrix views, assumed stable */
gsl_matrix_view aa, bb;

/* Square "symmetric" sub-matrix of A and B, from (0,0) to (N,N) */
gsl_matrix_view sq_aa, sq_bb;

/* Some arrays used for testing. */
double array_a [M * N];
double array_b [N * P];

/**
 * Blas Level 3 setup for matrix-matrix operations
 */
void
blas_setup_level3 (void)
{
  size_t i, j, k = 0;
  
  /* setup amos */
  TEST_AMOS_SETUP ();

  /**
   * initalize arrays for matrices A and B
   */
  for (i = 0; i < M; i++)
    {
      for (j = 0; j < N; j++)
        {
          array_a[i * N + j] = RANDOM_DOUBLE;

          /**
           * Array for matrix B has N rows and P columns.
           * We run this only once for the outer loop.
           */
          if (i == 0)
          {
            for (k = 0; k < P; k++)
              {
                array_b[j * P + k] = RANDOM_DOUBLE; 
              }
            
          }
        }
    }
  
  a_setf (a, agsl_matrix_init_array (array_a, M, N));
  aa = gsl_matrix_view_array (array_a, M, N);

  a_setf (b, agsl_matrix_init_array (array_b, N, P));
  bb = gsl_matrix_view_array (array_b, N, P);


  /* create gsl square matrix to compare with agsl matrix */
  sq_aa = gsl_matrix_submatrix (&aa.matrix, 0, 0, N, N);
  sq_bb = gsl_matrix_submatrix (&aa.matrix, 0, 0, N, N);
  
  /* create agsl square matrix  */
  a_setf (sq_a, agsl_matrix_new (N, N));
  gsl_matrix_memcpy (matrix (sq_a), &sq_aa.matrix);  

  a_setf (sq_b, agsl_matrix_new (N, N));
  gsl_matrix_memcpy (matrix (sq_b), &sq_bb.matrix);  
    
} /* blas_setup_level3 */


/**
 * 
 */
void
blas_teardown_level3 (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  agsl_matrix_deallocate (a);
  agsl_matrix_deallocate (b);
  agsl_matrix_deallocate (sq_a);

  free_oid (a); free_oid (b); free_oid (sq_a);
}


/**
 * Test BLAS Level 3 Setup, compare AGSL matrices to their
 * GSL counterparts.
 */
START_TEST (test_setup_level3)
{
  size_t i, j, k;

  gsl_matrix_compare (matrix (a), &aa.matrix);
  gsl_matrix_compare (matrix (b), &bb.matrix);
  gsl_matrix_compare (matrix (sq_a), &sq_aa.matrix);
}
END_TEST


/**
 * BLAS Level 3
 */


/**
 * Compute the matrix-matrix product and sum C = \alpha op (A) op (B) +
 * \beta C where op (A) = A, A^T
 */
START_TEST (test_dgemm)
{
  size_t i,j;
  dcloid (agsl_result);
  dcloid (alisp_result);
  dcloid (c);

  gsl_matrix * agsl_c = gsl_matrix_alloc (M, P);

  a_setf (c, agsl_matrix_assign (agsl_c));
  
  /* holds test matrix result from GSL */

  gsl_matrix * gsl_d = gsl_matrix_alloc (M, P);
  
  fail_unless
    (GSL_SUCCESS == gsl_blas_dgemm (GETTRANSPOSE (a),
                                    GETTRANSPOSE (b),
                                    ALPHA1,
                                    &aa.matrix,
                                    &bb.matrix,
                                    BETA0,
                                    gsl_d));
  
  a_setf (agsl_result,
          agsl_blas_dgemm
          (env, mkreal (ALPHA1), a, b, mkreal (BETA0), c));
  
  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dgemm"),
                     env, 5,
                     mkreal (ALPHA1), a, b, mkreal (BETA0), c));

  print_matrix (matrix (agsl_result));
  print_matrix (matrix (alisp_result));
  print_matrix (gsl_d);
  
  fail_unless (1 == gsl_matrix_compare (matrix (agsl_result),
                                         matrix (alisp_result)));
  
  fail_unless (1 == gsl_matrix_compare (gsl_d, matrix (alisp_result)));
}
END_TEST

/**
 * Compute the matrix-matrix product and sum C = \alpha A B
 * + \beta C for Side is CblasLeft and C = \alpha B A +
 * \beta C for Side is CblasRight, where the matrix A is
 * symmetric. When Uplo is CblasUpper then the upper
 * triangle and diagonal of A are used, and when Uplo is
 * CblasLower then the lower triangle and diagonal of A are
 * used.
 */
START_TEST (test_dsymm)
{
  dcloid (agsl_result); /* The agsl_resulting matrix */
  dcloid (alisp_result); /* The alisp_resulting matrix */
  dcloid (c);
  size_t i, j;

  gsl_matrix * agsl_c = gsl_matrix_alloc (N, P);

  a_setf (c, agsl_matrix_assign (agsl_c));

  /* holds matrix agsl_result from AGSL */
  gsl_matrix * agsl_d = gsl_matrix_alloc (N, P);
  /* holds test matrix result from GSL */
  gsl_matrix * gsl_d = gsl_matrix_alloc (N, P);
  /* holds test matrix result from ALisp */
  gsl_matrix * alisp_d = gsl_matrix_alloc (N, P);

  a_setf (agsl_result,
          agsl_blas_dsymm (env,
                           mkreal (ALPHA1),
                           sq_a,
                           b,
                           mkreal (BETA0),
                           c));
  
  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dsymm"),
                     env, 5,
                     mkreal (ALPHA1),
                     sq_a,
                     b,
                     mkreal (BETA0),
                     c));

  agsl_d = matrix (agsl_result);
  alisp_d = matrix (alisp_result);

  print_matrix (agsl_d);
  print_matrix (alisp_d);
  print_matrix (gsl_d);

  
  fail_unless
    (GSL_SUCCESS == gsl_blas_dsymm (CblasLeft,
                                   CblasLower,
                                   ALPHA1,
                                   &sq_aa.matrix,
                                   &bb.matrix,
                                   BETA0,
                                   gsl_d));

  gsl_matrix_compare (gsl_d, agsl_d);
  gsl_matrix_compare (gsl_d, alisp_d);
}
END_TEST

/**
 * Compute the matrix-matrix product B = \alpha op (A) B for
 * Side is CblasLeft and B = \alpha B op (A) for Side is
 * CblasRight. The matrix A is triangular and op (A) = A,
 * A^T
 */
START_TEST (test_dtrmm)
{
  size_t i,j;
  dcloid (agsl_result);
  dcloid (alisp_result); /* The alisp_resulting matrix */

  /* holds matrix agsl_result from AGSL */
  gsl_matrix * agsl_d = gsl_matrix_calloc (N, N);
  /* holds test matrix result from GSL */
  gsl_matrix * gsl_d = gsl_matrix_calloc (N, N);
  /* holds test matrix result from ALisp */
  gsl_matrix * alisp_d = gsl_matrix_alloc (N, N);

  a_setf (agsl_result,
          agsl_blas_dtrmm (env,
                           mkreal (ALPHA1),
                           sq_a,
                           sq_b));
  
  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dtrmm"),
                     env, 3,
                     mkreal (ALPHA1),
                     sq_a,
                     sq_b));

  agsl_d = matrix (agsl_result);
  alisp_d = matrix (alisp_result);

  
  gsl_matrix_memcpy (gsl_d, &sq_bb.matrix);

  print_matrix (agsl_d);
  print_matrix (alisp_d);


  fail_unless
    (GSL_SUCCESS == gsl_blas_dtrmm (CblasLeft,
                                    CblasLower,
                                    CblasNoTrans,
                                    CblasNonUnit,
                                    ALPHA1,
                                    &sq_aa.matrix,
                                    gsl_d));

  print_matrix (gsl_d);

  fail_unless (1 == gsl_matrix_compare (gsl_d, agsl_d));
  fail_unless (1 == gsl_matrix_compare (gsl_d, alisp_d));

}
END_TEST

  
/**
 * Compute the inverse-matrix matrix product B = \alpha op
 * (inv (A))B for Side is CblasLeft and B = \alpha B op (inv
 * (A)) for Side is CblasRight. The matrix A is triangular
 * and op (A) = A, A^T, A^H for TransA = CblasNoTrans,
 * CblasTrans, CblasConjTrans. When Uplo is CblasUpper then
 * the upper triangle of A is used, and when Uplo is
 * CblasLower then the lower triangle of A is used. If Diag
 * is CblasNonUnit then the diagonal of A is used, but if
 * Diag is CblasUnit then the diagonal elements of the
 * matrix A are taken as unity and are not referenced.
 */
START_TEST (test_dtrsm)
{
  size_t i,j;
  dcloid (agsl_result);
  dcloid (alisp_result);

  /* holds matrix agsl_result from AGSL */
  gsl_matrix * agsl_d = gsl_matrix_alloc (N, N);
  /* holds test matrix result from GSL */
  gsl_matrix * gsl_d = gsl_matrix_alloc (N, N);
  /* holds test matrix result from ALisp */
  gsl_matrix * alisp_d = gsl_matrix_alloc (N, N);

  a_setf (agsl_result,
          agsl_blas_dtrsm (env,
                           mkreal (ALPHA1),
                           sq_a,
                           sq_b));
  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dtrsm"),
                     env, 3,
                     mkreal (ALPHA1),
                     sq_a,
                     sq_b));

  agsl_d = matrix (agsl_result);
  alisp_d = matrix (alisp_result);

  gsl_matrix_memcpy (gsl_d, &sq_bb.matrix);

  print_matrix (agsl_d);

  print_matrix (alisp_d);
  
  fail_unless
    (GSL_SUCCESS == gsl_blas_dtrsm (CblasLeft,
                                   CblasLower,
                                   CblasNoTrans,
                                   CblasNonUnit,
                                   ALPHA1,
                                   &sq_aa.matrix,
                                   gsl_d));

  print_matrix (gsl_d);

  fail_unless (1 == gsl_matrix_compare (agsl_d, gsl_d));
  fail_unless (1 == gsl_matrix_compare (alisp_d, gsl_d));

}
END_TEST


/**
 * BLAS Level 3
 */
TCase *
make_blas_tcase_level3 ()
{
  TCase * tc_level3 = tcase_create ("BLAS Level 3");

  tcase_add_checked_fixture
    (tc_level3, blas_setup_level3, blas_teardown_level3);

  tcase_add_test (tc_level3, test_setup_level3);
  tcase_add_test (tc_level3, test_dgemm);
  tcase_add_test (tc_level3, test_dsymm);
  tcase_add_test (tc_level3, test_dtrmm);
  tcase_add_test (tc_level3, test_dtrsm);

  return tc_level3;
}

Suite *
make_blas3_suite (void)
{
  Suite * s = suite_create ("BLAS Level 3");
  suite_add_tcase (s, make_blas_tcase_level3 ());
  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_blas3_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
