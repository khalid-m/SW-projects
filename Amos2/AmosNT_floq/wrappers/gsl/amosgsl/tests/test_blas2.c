/** -*- c-basic-offset: 2; -*- 
 *
 * Test Blas Level 2 Routines
 *
 * Tests include: gemv, trmv, trsv, symv
 *
 */
#include "test_agsl.h"                          

#define SIZE 3
#define SIZE1 2
#define SIZE2 3

AMOS_SETUP_TEST_VARIABLES;

/* agsl matrices and vectors */
oidtype a, b;
oidtype u;

/* gsl matrix and vector views, assumed stable and used to compare
   with agsl matrices and vectors */
gsl_matrix_view aa, bb;
gsl_vector_view uu;

/* Some arrays used for testing. */
double array_a [SIZE1 * SIZE2];
double array_b [SIZE * SIZE];
double array_u [SIZE];

/**
 * BLAS Level 2 setup for vector-matrix operations
 *
 * Symmetric matrix need only store lower or upper part
 * plus the main diagonal. We will store just the lower
 * part, thus
 *
 *     ( 2  1  5 )                   ( 2  0  0 )
 * S = ( 1  3  4 ) will be stored as ( 1  3  0 )
 *     ( 5  4 -2 )                   ( 5  4 -2 )
 *  
 * So, we will use the same test matrix for symmetric and
 * triangular matrices.
 *
 */
void
blas_setup_level2 (void)
{
  int i, j = 0;

  /* setup amos */
  TEST_AMOS_SETUP ();

  /* initialize arrays for vectors u, v and for matrix B */
  for (i = 0; i < SIZE; i++)
    {
      array_u[i] = RANDOM_DOUBLE;
      
      /* matrix b is SIZE * SIZE */
      for (j = 0; j < SIZE; j++)
        array_b[i * SIZE + j] = RANDOM_DOUBLE;
    }

  /* initialize array for matrix A */
  for (i = 0; i < SIZE1; i++)
    for (j = 0; j < SIZE2; j++)
      array_a[i * SIZE1 + j] = RANDOM_DOUBLE;
  
  
  /* create agsl matrix and vector */
  a_setf (a, agsl_matrix_init_array (array_a, SIZE1, SIZE2));
  a_setf (b, agsl_matrix_init_array (array_b, SIZE, SIZE));
  a_setf (u, agsl_vector_init_array (array_u, SIZE));

  /* create gsl matrix / vector to compare with agsl matrix / vector */
  aa = gsl_matrix_view_array (array_a, SIZE1, SIZE2);
  bb = gsl_matrix_view_array (array_b, SIZE, SIZE);
  uu = gsl_vector_view_array (array_u, SIZE);
  
} /* blas_setup_level2 */


/**
 *
 */
void
blas_teardown_level2 (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  /* agsl_matrix_deallocate (a); */
  /* agsl_matrix_deallocate (b); */
  /* agsl_vector_deallocate (u); */

  /* free_oid (a); */
  /* free_oid (b); */
  /* free_oid (u); */
}

/**
 * Test BLAS Level 2 Setup
 */
START_TEST (test_setup_level2)
{
  int i, j=0;
  double x, y=0.0;

  for (i = 0; i < SIZE; i++)
    {
      x = coerce_real (env, agsl_vector_get (env,
                                            u,
                                            mkinteger (i)));
      y = gsl_vector_get (&uu.vector, i);

      fail_unless (APPROX_EQUAL (x, y), "e_%d: u=%2f, v=%2f", i, x, y);

      for (j = 0 ; j < SIZE ; j++)
        {
          x =  coerce_real (env,
                            agsl_matrix_get (env, b,
                                             mkinteger (i),
                                             mkinteger (j)));
          y = gsl_matrix_get (&bb.matrix, i, j);

          fail_unless (APPROX_EQUAL (x, y), "e_%d%d: u=%2f, v=%2f", i, j, x, y);
        }
    }

  /* test amosgsl matrix `a', compare to gsl matrix `aa' */
  for (i = 0 ; i < SIZE1 ; i++)
    {
      for (j = 0 ; j < SIZE2 ; j++)
        {
          x = coerce_real (env,
                           agsl_matrix_get (env, a,
                                            mkinteger (i),
                                            mkinteger (j)));
          y = gsl_matrix_get (&aa.matrix, i, j);

          fail_unless (APPROX_EQUAL (x,y));
        }
    }
}
END_TEST




/**
 * BLAS Level 2
 */



/**
 * Compute the matrix-vector product `y = Au'
 *
 * Use GSL functions directly to test the agsl wrapper.
 *
 * Variables
 *
 * agsl_y     result vector from AGSL from the equation above
 * gsl_y    test vector GSL from the equation above
 *
 * Global Variables
 * a     agsl matrix `A' in the equation above
 * aa    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
START_TEST (test_dgemv)
{
  int i;
  dcloid (agsl_result);
  dcloid (alisp_result);

  /* holds vector result from AGSL */
  gsl_vector * agsl_y = gsl_vector_alloc (SIZE);
  /* holds test vector result from GSL */
  gsl_vector * gsl_y = gsl_vector_alloc (SIZE);
  gsl_vector * alisp_y = gsl_vector_alloc (SIZE);;

  a_setf (agsl_result, agsl_blas_dgemv (env, b, u));

  a_setf (alisp_result, call_lisp (mksymbol ("agsl-blas-dgemv"),
                                   env, 2,
                                   b, u));

  fail_unless (AGSL_VECTOR_P (agsl_result), "result of agsl dgemv should be an agsl vector");

  fail_unless (AGSL_VECTOR_P (alisp_result), "result of agsl dgemv should be an agsl vector");
  
  agsl_y = GET_GSL_VECTOR (agsl_result);
  alisp_y = GET_GSL_VECTOR (alisp_result);

  /* gsl_y <- uu */
  gsl_vector_memcpy (gsl_y, &uu.vector);
  
  fail_unless (GSL_SUCCESS == gsl_blas_dgemv (CblasNoTrans,
                                              ALPHA1,
                                              &bb.matrix,
                                              &uu.vector,
                                              BETA0,
                                              gsl_y));

  /* ensure agsl_y = gsl_y, where both are `Bu' via AmosGSL and GSL
     respectively */
  fail_unless (1 == gsl_vector_compare (gsl_y, agsl_y));
  fail_unless (1 == gsl_vector_compare (gsl_y, alisp_y));
}
END_TEST

/**
 * Compute the matrix-vector product x = op (A) x for the triangular
 * matrix A, where op (A) = A or A^T
 *
 * Variables
 *
 * agsl_y     result vector from AGSL from the equation above
 * gsl_y    test vector GSL from the equation above
 *
 * Global Variables
 * b     agsl matrix `A' in the equation above
 * bb    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
START_TEST (test_dtrmv)
{
  int i;

  dcloid (agsl_result);
  dcloid (alisp_result);
  
  /* holds vector from AGSL */
  gsl_vector * agsl_y = gsl_vector_alloc (SIZE);
  /* holds test vector result from GSL */
  gsl_vector * gsl_y = gsl_vector_alloc (SIZE);
  /* holds vector from ALisp call */ 
  gsl_vector * alisp_y = gsl_vector_alloc (SIZE);
  
  /* compute dtrmv on agsl vector */
  a_setf (agsl_result, agsl_blas_dtrmv (env, b, u));

  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dtrmv"),
                     env, 2,
                     b, u));

  fail_unless (AGSL_VECTOR_P (agsl_result)
               && AGSL_VECTOR_P (alisp_result),
               "agsl / alisp `dgemv': result is not a vector");
  
  agsl_y = GET_GSL_VECTOR (agsl_result);
  alisp_y = GET_GSL_VECTOR (alisp_result);

  /* gsl_y <- uu */
  gsl_vector_memcpy (gsl_y, &uu.vector);
 
  /* compute dtrmv and store in test vector `gsl_y' */
  fail_unless (GSL_SUCCESS == gsl_blas_dtrmv 
               (CblasLower,
                CblasNoTrans,
                CblasNonUnit,
                &bb.matrix,
                gsl_y));

  /* ensure agsl_y = gsl_y, where both are `Bu' via AmosGSL and GSL
     respectively */
  fail_unless (1 == gsl_vector_compare (gsl_y, agsl_y));
  fail_unless (1 == gsl_vector_compare (gsl_y, alisp_y));
}
END_TEST

/**
 * DTRSV
 *
 * Compute inv (op (A)) x for x, where op (A) = A, A^T
 *
 * Variables
 *
 * agsl_y     result vector from AGSL from the equation above
 * gsl_y    test vector GSL from the equation above
 *
 * Global Variables
 * b     agsl matrix `A' in the equation above
 * bb    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
START_TEST (test_dtrsv)
{
  int i;
  
  dcloid (agsl_result);
  dcloid (alisp_result);

  /* holds vector from AGSL */
  gsl_vector * agsl_y = gsl_vector_alloc (SIZE);
  /* holds test vector result from GSL */
  gsl_vector * gsl_y = gsl_vector_alloc (SIZE);
  /* holds vector from ALisp call */ 
  gsl_vector * alisp_y = gsl_vector_alloc (SIZE);
  
  /* compute dtrsv on agsl vector */
  a_setf (agsl_result, agsl_blas_dtrsv (env, b, u));

  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dtrsv"),
                     env, 2,
                     b, u));

  fail_unless (AGSL_VECTOR_P (agsl_result)
               && AGSL_VECTOR_P (alisp_result),
               "agsl / alisp `dgemv': result is not a vector");
  
  agsl_y = GET_GSL_VECTOR (agsl_result);
  alisp_y = GET_GSL_VECTOR (alisp_result);

  /* gsl_y <- uu */
  gsl_vector_memcpy (gsl_y, &uu.vector);

  fail_unless (GSL_SUCCESS == gsl_blas_dtrsv 
               (CblasLower, CblasNoTrans, CblasNonUnit,
                &bb.matrix, gsl_y));


  /* ensure agsl_y = gsl_y, where both are `Bu' via AmosGSL and GSL
     respectively */
  fail_unless (1 == gsl_vector_compare (gsl_y, agsl_y));
  fail_unless (1 == gsl_vector_compare (gsl_y, alisp_y));
  
}
END_TEST

/**
 * Compute the matrix-vector product and sum y = \alpha A x + \beta y
 * for the symmetric matrix A
 *
 * Variables
 *
 * agsl_y     result vector from AGSL from the equation above
 * gsl_y    test vector GSL from the equation above
 *
 * Global Variables
 * b     agsl matrix `A' in the equation above
 * bb    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
START_TEST (test_dsymv)
{
  int i;

  dcloid (agsl_result);
  dcloid (alisp_result);

  double agsl_y_i, gsl_y_i, alisp_y_i;
  /* holds vector from AGSL */
  gsl_vector * agsl_y = gsl_vector_alloc (SIZE);
  /* holds test vector result from GSL */
  gsl_vector * gsl_y = gsl_vector_alloc (SIZE);
  /* holds vector from ALisp call */ 
  gsl_vector * alisp_y = gsl_vector_alloc (SIZE);
  
  /* compute dsymv on agsl vector */
  a_setf (agsl_result, agsl_blas_dsymv (env, b, u));

  a_setf (alisp_result,
          call_lisp (mksymbol ("agsl-blas-dsymv"),
                     env, 2,
                     b, u));

  fail_unless (AGSL_VECTOR_P (agsl_result)
               && AGSL_VECTOR_P (alisp_result),
               "agsl / alisp `dgemv': result is not a vector");
  
  agsl_y = GET_GSL_VECTOR (agsl_result);
  alisp_y = GET_GSL_VECTOR (alisp_result);


  /* gsl_y <- uu */
  gsl_vector_memcpy (gsl_y, &uu.vector);

  /* fail if assigning result to `gsl_y' is not successful */
  fail_unless (GSL_SUCCESS == gsl_blas_dsymv 
               (CblasLower,
                ALPHA1,
                &bb.matrix,
                &uu.vector,
                BETA0,
                gsl_y));

  /* ensure agsl_y = gsl_y = alisp_y, with `Bu' via AmosGSL
     and ALisp respectively */
  fail_unless (1 == gsl_vector_compare (gsl_y, agsl_y));
  fail_unless (1 == gsl_vector_compare (gsl_y, alisp_y));
}
END_TEST


/**
 * BLAS Level 2
 */
TCase *
make_blas_tcase_level2 ()
{
  TCase *tc_level2 = tcase_create ("BLAS Level 2");

  tcase_add_checked_fixture
    (tc_level2, blas_setup_level2, blas_teardown_level2);

  tcase_add_test (tc_level2, test_setup_level2);
  tcase_add_test (tc_level2, test_dgemv);
  tcase_add_test (tc_level2, test_dtrmv);
  tcase_add_test (tc_level2, test_dtrsv);
  tcase_add_test (tc_level2, test_dsymv);

  return tc_level2;
}

Suite *
make_blas2_suite (void)
{
  Suite * s = suite_create ("BLAS Level 2");
  suite_add_tcase (s, make_blas_tcase_level2 ());
  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_blas2_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
