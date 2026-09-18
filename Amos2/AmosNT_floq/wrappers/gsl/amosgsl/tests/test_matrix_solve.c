/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test matrix solving
 *
 */

#include "test_agsl.h"

AMOS_SETUP_TEST_VARIABLES;

#define SIZE1 4
#define SIZE2 4

oidtype A, C;

double a_data[] = { 0.18, 0.60, 0.57, 0.96,
                    0.41, 0.24, 0.99, 0.58,
                    0.14, 0.30, 0.97, 0.66,
                    0.51, 0.13, 0.19, 0.85 };

double c_data[] = { 0.67, 0.87, 0.27, 0.10,
                    0.80, 0.31, 0.17, 0.97,
                    0.70, 0.51, 0.44, 0.01,
                    0.59, 0.20, 0.80, 0.41 };

gsl_matrix_view a;

gsl_matrix_view c;

/**
 *
 * Solving A B = C for B with different A and general C A is
 * setup here, then we test for lower A, upper A, unitary and
 * non unitary, symmetric A, decomposed A and the like. C is
 * general.
 * 
 */
void
solve_setup (void)
{
  TEST_AMOS_SETUP ();


  a = gsl_matrix_view_array (a_data, SIZE1, SIZE2);

  c = gsl_matrix_view_array (c_data, SIZE1, SIZE2);
   
  A = nil; C = nil;

  a_setf (A, agsl_matrix_assign (&a.matrix));
  a_setf (C, agsl_matrix_assign (&c.matrix));
}


void
solve_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */

  /* agsl_matrix_deallocate (A); */

  /* agsl_matrix_deallocate (C); */

  /* free_oid (A); */

  /* free_oid (C); */
}


void
test_matrix_solve (gsl_matrix_view Bview)
{
  dcloid (B);

  a_setf (B, agsl_linalg_solve_alpha_ab (env, mkreal (ALPHA1), A, C));

  gsl_matrix * b = matrix (B);

  /* B = &Bview.matrix */

  print_matrix (b);
  
  print_matrix (&Bview.matrix);
  
  fail_unless (gsl_matrix_compare (b, &Bview.matrix));
}

START_TEST (test_matrix_solve_from_general)
{
  /* A B = C for B */

  double b_data[] = { 0.450887, -0.425167, -0.954190,  3.422136,
                      0.075704,  1.006399, -2.253910,  2.033956,
                      0.416112,  0.055358,  0.028222,  0.197985,
                      0.318994,  0.324100,  1.852098, -1.926260 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);
  
  fprintf (stdout, "GENERAL: \n");

  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_general_transposed)
{
  double b_data[] = { 2.06782,  1.01065, -0.11886,  2.82317,
                      3.28371,  3.58784, -0.49312,  1.92319,
                     -3.63777, -3.62410,  0.88474, -3.33100,
                     -1.05733, -0.54031,  0.72492, -1.43203 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  fprintf (stdout, "GENERAL TRANSPOSED: \n");
  SETTRANSPOSE (A);
    
  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_upper)
{
  double b_data[] = { -2.86025,   5.03837,  -0.27577, -14.96793,
                       0.62726,  -0.78537,  -0.79571,   4.18728,
                       0.2493,    0.36568,  -0.18678,  -0.31789,
                       0.69412,   0.23529,   0.94118,   0.48235 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  fprintf (stdout, "UPPER: \n");
  SETUPPER (A);

  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_upper_transposed)
{
  double b_data[] = { 3.72222,   4.83333,   1.50000,   0.55556,
                     -5.97222, -10.79167,  -3.04167,   2.65278,
                      4.62973,   8.69974,   2.67655,  -3.02363,
                     -3.02949,  -4.61490,  -0.75571,   0.39253 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  SETUPPER (A); SETTRANSPOSE (A);
  fprintf (stdout, "UPPER TRANSPOSED: \n");

  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_symmetric_upper)
{
  double b_data[] = { -0.12507,  -0.77801,   0.77895,   0.29637,
                      -0.16548,   0.15993,   0.35400,  -1.27347,
                       0.67590,   0.28835,  -0.51488,   0.94171,
                       0.42348,   0.78096,   0.21966,   0.28538 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  SETSYMMETRIC (A); SETUPPER (A);
  fprintf (stdout, "SYMMETRIC UPPER: \n");

  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_symmetric_lower)
{
  double b_data[] = { 1.089427,  -0.465790,   0.173379,   2.618333,
                      1.350585,   2.089758,  -0.602176,   0.579852,
                      0.187448,  -0.095735,   0.452625,  -0.330803,
                     -0.207999,   0.216558,   0.828071,  -1.103386 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  SETSYMMETRIC (A); SETLOWER (A);
  fprintf (stdout, "SYMMETRIC LOWER: \n");

  test_matrix_solve (Bview);
}
END_TEST
                        
START_TEST (test_matrix_solve_from_diagonal)
{
  double b_data[] = { 3.722222,   4.833333,   1.500000,   0.555556,
                      3.333333,   1.291667,   0.708333,   4.041667,
                      0.721649,   0.525773,   0.453608,   0.010309,
                      0.694118,   0.235294,   0.941176,   0.482353 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);
  
  SETDIAGONAL (A);
  fprintf (stdout, "SOLVE DIAGONAL: \n");
 
  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_lower)
{
  double b_data[] = { 3.722222,   4.833333,   1.500000,   0.555556,
                     -3.025463,  -6.965278,  -1.854167,   3.092593,
                      1.120132,   1.982388,   0.810567,  -1.026346,
                     -1.326880,  -2.042550,   0.143569,  -0.094547 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  SETLOWER (A);
  fprintf (stdout, "LOWER: \n");

  test_matrix_solve (Bview);
}

END_TEST

START_TEST (test_matrix_solve_from_lower_transposed)
{
  double b_data[] = {-3.768588,   2.507523,  -1.061666,  -9.596194,
                      2.225243,   0.564610,  -0.138038,   3.885607,
                      0.585688,   0.479685,   0.269254,  -0.084172,
                      0.694118,   0.235294,   0.941176,   0.482353 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  fprintf (stdout, "LOWER TRANSPOSED: \n");
    /* Test A as solve-trianguler and transposed */
  SETLOWER (A); SETTRANSPOSE (A);

  test_matrix_solve (Bview);
}
END_TEST

START_TEST (test_matrix_solve_from_decomposed)
{
  double b_data[] = { 0.450887, -0.425167, -0.954190,  3.422136,
                      0.075704,  1.006399, -2.253910,  2.033956,
                      0.416112,  0.055358,  0.028222,  0.197985,
                      0.318994,  0.324100,  1.852098, -1.926260 };

  gsl_matrix_view Bview
    = gsl_matrix_view_array (b_data, SIZE1, SIZE2);

  fprintf (stdout, "DECOMPOSED: \n");
  dcloid (TMP);

  a_setf (TMP, agsl_matrix_copy (env, A));

  a_setf (A, agsl_linalg_LU_decomp (env, TMP));

  test_matrix_solve (Bview);

  agsl_matrix_deallocate (TMP);
}
END_TEST




/**
 * Solve triangular conversion tests
 */
TCase *
make_solve_tcase ()
{
  TCase * tc_solve = tcase_create ("Solve");

  tcase_add_checked_fixture (tc_solve, solve_setup, solve_teardown);
  
  tcase_add_test (tc_solve, test_matrix_solve_from_general);
  tcase_add_test (tc_solve, test_matrix_solve_from_general_transposed);
  tcase_add_test (tc_solve, test_matrix_solve_from_lower);
  tcase_add_test (tc_solve, test_matrix_solve_from_lower_transposed);
  tcase_add_test (tc_solve, test_matrix_solve_from_upper);
  tcase_add_test (tc_solve, test_matrix_solve_from_upper_transposed);
  tcase_add_test (tc_solve, test_matrix_solve_from_symmetric_lower);
  tcase_add_test (tc_solve, test_matrix_solve_from_symmetric_upper);
  tcase_add_test (tc_solve, test_matrix_solve_from_diagonal);
  tcase_add_test (tc_solve, test_matrix_solve_from_decomposed);

  return tc_solve;
}


Suite *
make_solve_suite (void)
{
  Suite * s = suite_create ("Convert to Solve Triangular");

  suite_add_tcase (s, make_solve_tcase ());

  return s;
}


int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_solve_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
