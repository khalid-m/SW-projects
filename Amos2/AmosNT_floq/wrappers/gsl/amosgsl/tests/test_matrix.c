/** -*- c-basic-offset: 2; -*- 
 *
 * $Description:  Test matrix functionality$
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:46:00 $
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 5
#define SIZE2 5

/* matrices */
oidtype m, a, b;

/* initialization arrays */
double darray [SIZE1 * SIZE2];
oidtype values;
oidtype values2D;


/**
 * Amos can be initialized by calling `init_subsystems' and then connecting.
 */
void
matrix_setup (void)
{
  TEST_AMOS_SETUP ();
}

/**
 *
 */
void
matrix_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}

/**
 * Setup matrix for testing init functions
 */
void
matrix_setup_init (void)
{
  dcloid (row);
  int i, j, idx;
  double x;

  /* run preceding setup */
  matrix_setup ();
  values = nil;
  values2D = nil;
  
  /* amos array's representing our matrix */
  a_setf (values, new_array (SIZE1 * SIZE2, nil));
  a_setf (values2D, new_array (SIZE1, nil));

  /* initialize test array and amos array `values' */
  for (i = 0; i < SIZE1; i++)
    {
      a_setf (row, new_array (SIZE2, nil));

      for (j = 0; j < SIZE2; j++)
        {
          idx = i * SIZE2 + j;
          x = RANDOM_DOUBLE;
          
          darray[idx] = x;

          a_seta (values, idx, mkreal (x));
          a_seta (row, j, mkreal (x));
        }
      /* add row to 2D values array */
      a_seta (values2D, i, row);
    }
}

/**
 * Teardown matrix for testing init functions
 */
void
matrix_teardown_init (void)
{
  matrix_teardown ();

  dealloc_object (values);
  a_free (values);
}

/**
 * Setup for matrix access tests
 */
void
matrix_setup_access (void)
{
  size_t i, j;

  /* run preceding setup */
  matrix_setup ();

  /* initialize test array */
  for (i = 0; i < SIZE1; i++)
    for (j = 0; j < SIZE2; j++)
      darray[i * SIZE2 + j] = RANDOM_DOUBLE;
  
  /* test matrix `m' */
  a_setf (m, agsl_matrix_init_array (darray, SIZE1, SIZE2));
}

/**
 *
 */
void
matrix_teardown_access (void)
{
  matrix_teardown ();
  agsl_matrix_deallocate (m);
  a_free (m);
}



/**
 * Matrix_Setup for matrix operations
 */
void
matrix_setup_operations (void)
{
  int i, j;
  dcloid (oi);
  dcloid (oj);
  dcloid (ox);

  /* run preceding setup */
  matrix_setup_access ();

  /* initialize matrices */
  a = nil;
  b = nil;
  
  /* `+ - * /' operations test on these matrices */
  a_setf (a, agsl_matrix_new (SIZE1, SIZE2));
  a_setf (b, agsl_matrix_new (SIZE1, SIZE2));

  for (i = 0; i < SIZE1; i++)
    {
      a_setf (oi, mkinteger (i));
      
      for (j = 0; j < SIZE2; j++)
        {
          a_setf (oj, mkinteger (j));
          
          a_setf (ox, mkreal (RANDOM_DOUBLE)); /* e_ij = i+j */

          agsl_matrix_set (env, a, oi, oj, ox);
          agsl_matrix_set (env, b, oi, oj, ox);
        }
    }

  a_free (oi); a_free (oj); a_free (ox);
  
} /* matrix_setup_operations */


/**
 *
 */
void
matrix_teardown_operations (void)
{
  matrix_teardown_access ();
  agsl_matrix_deallocate (a);
  agsl_matrix_deallocate (b);
}


/**
 * Test setting up matrices correctly.
 */
START_TEST (test_setup_init)
{
  int i, j, idx;
  double x, y;
  dcloid (row);

  for (i = 0; i < SIZE1; i++)
    {
      for (j = 0; j < SIZE2; j++)
        {
          idx = i * SIZE2 + j;
          x = darray[idx];
          y = coerce_real (env, a_elt (values, idx));

          fail_unless (APPROX_EQUAL (x, y),
                       "Assertion %2.2f = %2.2f failed for index %d",
                       x, y, idx);
        }
    }
}
END_TEST


/**
 *
 */
START_TEST (test_matrix_new)
{
  m = nil;
  a_setf (m, agsl_matrix_new (SIZE1, SIZE2));

  /* unit test code */
  fail_unless (agslmatrixp (m),
              "New gslmatrix is not of type GSLMATRIX");

  fail_unless (matrix (m)->size1 == SIZE1,
              "Matrix does not have an element size of %d", SIZE1);

  fail_unless (matrix (m)->size2 == SIZE2,
               "Matrix does not have an element size of %d", SIZE2);

  agsl_matrix_deallocate (m);
}
END_TEST /* test_matrix_new */


/**
 * ALisp foreign function agsl-matrix-make
 */
START_TEST (test_matrix_make)
{
  m = nil;
  a_setf (m, agsl_matrix_make (env, mkinteger (SIZE1), mkinteger (SIZE2)));

  /* unit test code */
  fail_unless (agslmatrixp (m),
              "New gslmatrix is not of type GSLMATRIX");

  fail_unless (matrix (m)->size1 == SIZE1,
              "Matrix does not have a element size of %d", SIZE1);

  fail_unless (matrix (m)->size2 == SIZE2,
               "Matrix does not have a element size of %d", SIZE2);

  /* Call `make' through ALisp */
  a_setf (m, call_lisp (mksymbol ("agsl-matrix-make"),
                       env, 2,
                       mkinteger (SIZE1), mkinteger (SIZE2)));
  
  fail_unless (agslmatrixp (m),
               "ALisp: agsl_matrix is not of type GSLMATRIX");

  fail_unless (matrix (m)->size1 == SIZE1,
               "ALisp: agsl_matrix does not have length %d", SIZE1);

  fail_unless (matrix (m)->size2 == SIZE2,
               "ALisp: agsl_matrix does not have length %d", SIZE2);
  
  agsl_matrix_deallocate (m);
}
END_TEST /* test_matrix_make */




/**
 * Initialize matrix from given a_array
 */
START_TEST (test_matrix_init_flat)
{
  int i, j, idx;
  double x, y;
  dcloid (oi); dcloid (oj);
  
  /* "copies" of lisp-undeclared objects */
  dcloid (mm);

  /* initialize matrix with amos array `values' */
  a_setf (m, agsl_matrix_init_flat (env, values, mkinteger (SIZE1), mkinteger (SIZE2)));
  a_setf (mm, call_lisp (mksymbol ("agsl-matrix-init"), env, 1, values2D));

  /* check that each value is what we put in */
  for (i = 0; i < SIZE1; i++)
    {
      a_setf (oi, mkinteger (i));

      for (j = 0; j < SIZE2; j++)
        {
          idx = i * SIZE2 + j;
          a_setf (oj, mkinteger (j));
          
          x = getreal (agsl_matrix_get (env, m, oi, oj));
          y = getreal (a_elt (values, idx));
          fail_unless (APPROX_EQUAL (x, y),
                       "C `init': m_%d%d (%2.2f) not values_%d (%2.2f)",
                       i, j, x, idx, y);

          x = getreal (agsl_matrix_get (env, m, oi, oj));
          y = getreal (a_elt (values, idx));
          fail_unless (APPROX_EQUAL (x, y),
                       "ALisp `init': m_%d%d (%2.2f) not values_%d (%2.2f)",
                       i, j, x, idx, y);
        } 
    } 
 
  agsl_matrix_deallocate (m);
  agsl_matrix_deallocate (mm);

}
END_TEST


/**
 * Initialize matrix from regular c array
 */
START_TEST (test_matrix_init_array)
{
  gsl_matrix_view mm = gsl_matrix_view_array (darray, SIZE1, SIZE2);

  /* initialize matrix with c array `darray' */
  a_setf (m, agsl_matrix_init_array (darray, SIZE1, SIZE2));

  
  fail_unless (1 == gsl_matrix_compare (matrix (m), &mm.matrix));
  
  agsl_matrix_deallocate (m);
}
END_TEST /* test_matrix_init_array */

/**
 * Test functions that return the number of rows / columns of
 * given matrix M.
 * 
 */
START_TEST (test_matrix_size)
{
  fail_unless (getinteger (agsl_matrix_rows (env, m)) == SIZE1);
  fail_unless (getinteger (agsl_matrix_columns (env, m)) == SIZE2);
}
END_TEST /* test_matrix_size */


/**
 * Test functions all / any that return TRUE when given matrix
 * M has all / any non-zero entries.
 * 
 */
START_TEST (test_matrix_allany)
{
  dcloid (result);
  
  a_setf (result, call_lisp (mksymbol ("agsl-matrix-all"),
                             env, 1, m));
  fail_unless (result == AMOS_TRUE);
  a_setf (result, call_lisp (mksymbol ("agsl-matrix-any"),
                             env, 1, m));
  fail_unless (result == AMOS_TRUE);

  fail_unless (agsl_matrix_all (env, m) == AMOS_TRUE);
  fail_unless (agsl_matrix_any (env, m) == AMOS_TRUE);

  /* zero out matrix and try again */
  agsl_matrix_set_all (env, m, mkreal (0.0));
  gsl_matrix_fprintf (stdout, matrix (m), "%2.2f");

  a_setf (result, call_lisp (mksymbol ("agsl-matrix-all"),
                             env, 1, m));
  fail_unless (result == AMOS_FALSE);
  a_setf (result, call_lisp (mksymbol ("agsl-matrix-any"),
                             env, 1, m));
  fail_unless (result == AMOS_FALSE);

  fail_unless (agsl_matrix_all (env, m) == AMOS_FALSE);
  fail_unless (agsl_matrix_any (env, m) == AMOS_FALSE);
}
END_TEST /* test_matrix_allany */

/**
 * Get matrix type
 */
/**
 * Get matrix element
 */
START_TEST (test_matrix_get)
{
  int i, j, idx = 0;
  double x;

  dcloid (oi);  dcloid (oj);  dcloid (ox);
  
  /* test all elements */
  for (i = 0; i < SIZE1; i++)
    {
      a_setf (oi, mkinteger (i)); /* oi <- i */
      for (j = 0; j < SIZE2; j++)
        {
          idx = i * SIZE2 + j;
          a_setf (oj, mkinteger (j)); /* oi <- i */
          
          x = getreal (agsl_matrix_get (env, m, oi, oj));
          fail_unless (APPROX_EQUAL (x, darray[idx]),
                       "m_%d%d (%2.2f) != darray[%d] (%2.2f)",
                       i, j, x, idx, darray[idx]);

          /* Call `get' through ALisp */
          a_setf (ox, call_lisp (mksymbol ("agsl-matrix-get"),
                                 env, 3,
                                 m, oi, oj));

          fail_unless (APPROX_EQUAL (getreal (ox), darray[idx]),
                       "m_%d%d (%2.2f) != darray[%d] (%2.2f)",
                       i, j, getreal (ox), idx, darray[idx]);
          

        }
    }
}
END_TEST /* test_matrix_get */

/**
 * Set matrix element
 */
START_TEST (test_matrix_set)
{
  int i, j, idx = 0;
  double x = 0.0;
  dcloid (oi);
  dcloid (oj);
  dcloid (ox);

  /* test all elements */
  for (i = 0; i < SIZE1; i++)
    {
      a_setf (oi, mkinteger (i)); /* oi <- i */
      for (j = 0; j < SIZE2; j++)
        {
          idx = i * SIZE2 + j;
          a_setf (oj, mkinteger (j)); /* oi <- i */
          a_setf (ox, mkreal (darray[idx]));
          
          agsl_matrix_set (env, m, oi, oj, ox);
          x = getreal (agsl_matrix_get (env, m, oi, oj));
          fail_unless (APPROX_EQUAL (x, darray[idx]),
                       "C `set': m_%d%d (%2.2f) != darray[%d] (%2.2f)",
                       i, j, x, idx, darray[idx]);

          call_lisp (mksymbol ("agsl-matrix-set"),
                     env, 4,
                     m, oi, oj, ox);
          
          x = getreal (agsl_matrix_get (env, m, oi, oj));
          fail_unless (APPROX_EQUAL (x, darray[idx]),
                       "ALisp `set': m_%d%d (%2.2f) != darray[%d] (%2.2f)",
                       i, j, x, idx, darray[idx]);
        }
    }
  free_oid (oi);
  free_oid (oj);
  free_oid (ox);
}
END_TEST /* test_matrix_set */

/**
 * Print matrix - not sure how to test this :)
 */
START_TEST (test_matrix_print)
{
  fail ("Not implemented yet");
}
END_TEST /* test_matrix_print */

/**
 * Read matrix - not sure how to test this :)
 */
START_TEST (test_matrix_read)
{
  fail ("Not implemented yet");
}
END_TEST /* test_matrix_read */

/**
 * Write matrix - not sure how to test this :)
 */
START_TEST (test_matrix_write)
{
  
  fail ("Not implemented");
}
END_TEST /* test_matrix_write */

/**
 * Add matrices
 */
START_TEST (test_matrix_add)
{
  gsl_matrix * ab = gsl_matrix_alloc (SIZE1, SIZE2);  /* ((ab = a + b) == c == cc) ? */
  dcloid (c);
  dcloid (cc); /* ALisp a+b = cc */

  a_setf (c, agsl_matrix_add (env, a, b));
  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-add"),
                         env, 2, a, b));

  gsl_matrix_memcpy (ab, matrix (a));
  gsl_matrix_add (ab, matrix (b));
  
  fail_unless (1 == gsl_matrix_compare (matrix (c), ab));
  
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ab));
  
  agsl_matrix_deallocate (c);
  agsl_matrix_deallocate (cc);
  gsl_matrix_free (ab);
}
END_TEST /* test_matrix_add */

/**
 * Matrix subtraction operation
 */
START_TEST (test_matrix_sub)
{
  /* ((ab = a - b) == c == cc) ? */
  gsl_matrix * ab = gsl_matrix_alloc (SIZE1, SIZE2);
  dcloid (c);
  dcloid (cc);
  
  gsl_matrix_memcpy (ab, matrix (a));
  gsl_matrix_sub (ab, matrix (b));
  
  a_setf (c, agsl_matrix_sub (env, a, b));

  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-sub"),
                         env, 2, a, b));

  fail_unless (1 == gsl_matrix_compare (matrix (c), ab));
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ab));
  
  agsl_matrix_deallocate (c);
  agsl_matrix_deallocate (cc);
  gsl_matrix_free (ab);
}
END_TEST /* test_matrix_sub */

/**
 * Matrix element by element multiplication operation
 */
START_TEST (test_matrix_mul_elements)
{
  /* is c = cc = a * b at (i,j) for all i, j? */
  gsl_matrix * ab = gsl_matrix_alloc (SIZE1, SIZE2); /* ab = a X b */
  dcloid (c);
  dcloid (cc); 

  gsl_matrix_memcpy (ab, matrix (a));
  gsl_matrix_mul_elements (ab, matrix (b));
  
  a_setf (c, agsl_matrix_mul_elements (env, a, b));
  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-mul-elements"),
                         env, 2, a, b));

  fail_unless (1 == gsl_matrix_compare (matrix (c), ab));
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ab));
  
  agsl_matrix_deallocate (c);
  agsl_matrix_deallocate (cc);
  gsl_matrix_free (ab);
}
END_TEST /* test_matrix_mul_elements */

/**
 * Matrix division of elements operation
 */
START_TEST (test_matrix_div_elements)
{
  /* ab = a / b */
  gsl_matrix * ab = gsl_matrix_alloc (SIZE1, SIZE2);

  /* is c = cc = a / b at (i,j) for all i,j? */
  dcloid (c);
  dcloid (cc); 

  gsl_matrix_memcpy (ab, matrix (a));
  gsl_matrix_div_elements (ab, matrix (b));

  fprintf (stdout, "A / B = \n");
  print_matrix (ab);

  
  a_setf (c, agsl_matrix_div_elements (env, a, b));
  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-div-elements"),
                         env, 2, a, b));
  

  fprintf (stdout, "C = A / B = \n");
  print_matrix (matrix (c));

  fail_unless (1 == gsl_matrix_compare (matrix (c), ab));
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ab));
  
  agsl_matrix_deallocate (c);
  agsl_matrix_deallocate (cc);
  gsl_matrix_free (ab);
}
END_TEST /* test_matrix_div_elements */

/**
 * Scale matrix
 */
START_TEST (test_matrix_scale)
{
  /* is ((ax = a X x) = c = cc)?, where x is scalar */
  double x = RANDOM_DOUBLE;
  gsl_matrix * ax = gsl_matrix_alloc (SIZE1, SIZE2); 
  dcloid (c);
  dcloid (cc);

  gsl_matrix_memcpy (ax, matrix (a));
  gsl_matrix_scale (ax, x);

  a_setf (c, agsl_matrix_scale (env, a, mkreal (x)));
  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-scale"),
                         env, 2, a, mkreal (x)));

  fail_unless (1 == gsl_matrix_compare (matrix (c), ax));
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ax));

  {
    gsl_matrix_free (ax);
    agsl_matrix_deallocate (c);
    agsl_matrix_deallocate (cc);
    free_oid (c);
    free_oid (cc);
  }
}
END_TEST /* test_matrix_scale */




/**
 * Add constant to matrix
 */
START_TEST (test_matrix_add_constant)
{
  /* is ((ax = a + x) = c = cc)?, where x is scalar */
  double x = RANDOM_DOUBLE;
  gsl_matrix * ax = gsl_matrix_alloc (SIZE1, SIZE2); 
  dcloid (c);
  dcloid (cc);

  gsl_matrix_memcpy (ax, matrix (a));
  gsl_matrix_add_constant (ax, x);

  a_setf (c, agsl_matrix_add_constant (env, a, mkreal (x)));
  a_setf (cc, call_lisp (mksymbol ("agsl-matrix-add-constant"),
                         env, 2, a, mkreal (x)));
  
  fail_unless (1 == gsl_matrix_compare (matrix (c), ax));
  fail_unless (1 == gsl_matrix_compare (matrix (cc), ax));
  

  {
    gsl_matrix_free (ax);
    agsl_matrix_deallocate (c);
    agsl_matrix_deallocate (cc);
    free_oid (c);
    free_oid (cc);
  }
}
END_TEST /* test_matrix_add_constant */


/**
 * Compare two matrices by testing all elements of (A - B)
 * are null.
 */
int
gsl_matrix_compare (gsl_matrix * A, gsl_matrix * B)
{
  size_t i, j;
  gsl_matrix * result = gsl_matrix_alloc (A->size1,  A->size2);

  gsl_matrix_memcpy (result, A);
  gsl_matrix_sub (result, B);

  return gsl_matrix_isnull (result);
}


/**
 * Transpose matrix test
 */
START_TEST (test_matrix_transpose_copy)
{
  dcloid (c);
  /* A^T: Transpose of A */
  gsl_matrix * aT = gsl_matrix_alloc (SIZE2, SIZE1);
  gsl_matrix * _c = gsl_matrix_alloc (SIZE2, SIZE1);
  a_setf (c, agsl_matrix_assign (_c));
  
  gsl_matrix_transpose_memcpy (aT, matrix (a));

  SETTRANSPOSE (a);
  
  a_setf (c, agsl_matrix_transpose_copy (env, a));
  
  fail_unless (1 == gsl_matrix_compare (matrix (c), aT));
  
  {
    gsl_matrix_free (aT);
    agsl_matrix_deallocate (c);
    free_oid (c);
  }
}
END_TEST /* test_matrix_transpose_hardcpy */


Suite *
make_matrix_suite (void)
{
  Suite *s = suite_create ("Matrix");

  /* Core test case , creation, destruction, initialization */
  TCase *tc_core = tcase_create ("Core");
  tcase_add_checked_fixture (tc_core, matrix_setup, matrix_teardown);
  tcase_add_test (tc_core, test_matrix_new);
  tcase_add_test (tc_core, test_matrix_make);
  suite_add_tcase (s, tc_core);
  
  /* Element access */
  TCase *tc_access = tcase_create ("Access");
  tcase_add_checked_fixture (tc_access, matrix_setup_access, matrix_teardown_access);
  tcase_add_test (tc_access, test_matrix_get);
  tcase_add_test (tc_access, test_matrix_set);
  suite_add_tcase (s, tc_access);

  TCase *tc_init = tcase_create ("Initalizing");
  tcase_add_checked_fixture (tc_init, matrix_setup_init, matrix_teardown_init);
  tcase_add_test (tc_init, test_setup_init);
  tcase_add_test (tc_init, test_matrix_init_array);
  tcase_add_test (tc_init, test_matrix_init_flat);
  suite_add_tcase (s, tc_init);

  TCase *tc_props = tcase_create ("Properties");
  tcase_add_checked_fixture (tc_props, matrix_setup_operations, matrix_teardown_operations);
  tcase_add_test (tc_props, test_matrix_size);
  tcase_add_test (tc_props, test_matrix_allany);
  suite_add_tcase (s, tc_props);
  
  /* Arithmetical operations (+ - * /) and some others */
  TCase *tc_operations = tcase_create ("Operations");
  tcase_add_checked_fixture (tc_operations, matrix_setup_operations, matrix_teardown_operations);
  tcase_add_test (tc_operations, test_matrix_size);
  tcase_add_test (tc_operations, test_matrix_add);
  tcase_add_test (tc_operations, test_matrix_sub);
  tcase_add_test (tc_operations, test_matrix_mul_elements);
  tcase_add_test (tc_operations, test_matrix_div_elements);
  tcase_add_test (tc_operations, test_matrix_scale);
  tcase_add_test (tc_operations, test_matrix_add_constant);

  tcase_add_test (tc_operations, test_matrix_transpose_copy);

  suite_add_tcase (s, tc_operations);

  return s;
}



int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_matrix_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
