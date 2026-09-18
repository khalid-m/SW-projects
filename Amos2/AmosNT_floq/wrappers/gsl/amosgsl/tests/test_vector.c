/** -*- c-basic-offset: 2; -*- 
 *
 * Description:  Test Vector Initialization and Creation 
 *
 */

#include "test_agsl.h"
#include <gsl/gsl_math.h>
#include <time.h>

#define SIZE 7
#define TEMP_GSL_FILE_TEMPLATE "test_gsl_vector_io_XXXXXX"
#define TEMP_GSL_FILENAME_LENGTH 31
#define TEMP_AMOS_FILE_TEMPLATE "test_amos_vector_io_XXXXXX"
#define TEMP_AMOS_FILENAME_LENGTH 32

AMOS_SETUP_TEST_VARIABLES;

oidtype u, v, a, b;

/* initialization arrays */
double darray [SIZE];
oidtype values;
/* I / O */
char test_gsl_io[TEMP_GSL_FILENAME_LENGTH] = "";
char test_amos_io[TEMP_AMOS_FILENAME_LENGTH] = "";

oidtype stream; /* an amos stream */

int fd = -1;
int gslfd = -1;

FILE * fp;      /* its underlying C stream */
FILE * gslfp;   /* another stream for printing GSL vector */
/**
 * Find Amos test setup define in `amosgsl.h'
 */
void
vector_setup (void)
{
  TEST_AMOS_SETUP ();
}

/**
 *
 */
void
vector_teardown (void)
{
  /* TEST_AMOS_TEARDOWN (); */
}


/**
 * Setup vector for testing init functions
 */
void
vector_setup_init (void)
{
  int i;
  double x;

  /* run preceding setup */
  vector_setup ();
  values = nil;

  /* instantiate amos array representation of a vector */
  a_setf (values, new_array (SIZE, nil));

  /* initialize test array and amos array `values' */
  for (i = 0; i < SIZE; i++)
    {
      x = RANDOM_DOUBLE;
      darray[i] = x;
      a_seta (values, i, mkreal (x));
    }
}


/**
 * Teardown vector for testing init functions
 */
void
vector_teardown_init (void)
{
  vector_teardown ();

  dealloc_object (values);
  a_free (values);
  
}



/**
 * Setup for vector access tests
 */
void
vector_setup_access (void)
{
  int i = 0;
  /* run preceding setup */
  vector_setup ();

  /* initialize test array */
  for (i = 0; i < SIZE; i++)
    {
      darray[i] = RANDOM_DOUBLE;
    }

  /* test vector `u' */
  a_setf (u, agsl_vector_init_array (darray, SIZE));
}

/**
 *
 */
void
vector_teardown_access (void)
{
  vector_teardown ();
  agsl_vector_deallocate (u);
  free_oid (u);
}





/**
 * Setup for vector operations
 */
void
vector_setup_operations (void)
{
  int i = 0;
  
  dcloid (oi);
  dcloid (ox);
  /* run preceding setup */
  vector_setup_access ();

  a = nil;
  b = nil;
  
  /* `+ - * /' operations test on these vectors */
  a_setf (a, agsl_vector_new (SIZE));
  a_setf (b, agsl_vector_new (SIZE));

  for (i = 0; i < SIZE; i++)
    {
      a_setf (oi, mkinteger (i));
      a_setf (ox, mkreal (RANDOM_DOUBLE));
      
      agsl_vector_set (env, a, oi, ox);
      agsl_vector_set (env, b, oi, ox);     
    }

  free_oid (oi); free_oid (ox);
} /* vector_setup_operations */


/**
 *
 */
void
vector_teardown_operations (void)
{
  vector_teardown_access ();
  agsl_vector_deallocate (a); agsl_vector_deallocate (b);
}



/**
** Setup for testing I / O functions
 *
 * - `operations' sets up some vectors we can use for I / O,
 *   `a', `b' and `u'.
 */
void
vector_setup_io (void)
{

  /* run init setup */
  vector_setup_operations ();

  strcpy (test_amos_io, TEMP_AMOS_FILE_TEMPLATE);
  if ((fd = mkstemp (test_amos_io)) == -1 ||
      (fp = fdopen (fd, "w")) == NULL) {
    if (fd != -1) {
      unlink (test_amos_io);
      close (fd);
    }
    fprintf (stderr, "%s: %s\n", test_amos_io, strerror (errno));
  }

  strcpy (test_gsl_io, TEMP_GSL_FILE_TEMPLATE);
  if ((gslfd = mkstemp (test_gsl_io)) == -1 ||
      (gslfp = fdopen (gslfd, "w")) == NULL) {
    if (gslfd != -1) {
      unlink (test_gsl_io);
      close (gslfd);
    }
    fprintf (stderr, "%s: %s\n", test_gsl_io, strerror (errno));
  }
  
}


/**
 * Teardown for testing I / O functions
 */
void
vector_teardown_io (void)
{
  vector_teardown_operations ();
}


/**
 * @values ALisp array of values
 */
START_TEST (test_setup_init)
{
  int i;
  double x, y;

  for (i = 0; i < SIZE; i++)
    {
      x = darray[i];
      y = coerce_real (env, a_elt (values, i));
      
      fail_unless (APPROX_EQUAL (x, y));
    }
}
END_TEST

/**
 * @values Create a vector using `agsl_vector_init'
 */
START_TEST (time_init)
{
  dcloid (q);
  /* time it */
  clock_t start, end;
  double cpu_ms_used;
  int i = 0;
  int status;
  /* run for 6^1, 6^2, ..., 6^9 */
  long size = (long) gsl_pow_int (SIZE, _i);
  double * qarray = malloc (sizeof (double) * size);
  /* initialize test array */
  for (i = 0; i < size; i++)
    {
      qarray[i] = RANDOM_DOUBLE;
    }

  /* test gsl */
  i = 0;
  start = clock ();
  do
    {
      gsl_vector_view view_v = gsl_vector_view_array (qarray, size);
      gsl_vector * v = gsl_vector_alloc (size);
      gsl_vector_memcpy (v, &view_v.vector);

      i++;
      end = clock ();
    }
  while (end < start + CLOCKS_PER_SEC);
  cpu_ms_used = (end - start) / ((double) i) / ((double) CLOCKS_PER_SEC / 1000.0);
  fprintf (stdout, "GSL: (%d, %E)\n", size, cpu_ms_used);
 
  /* test agsl vector `q' */
  i = 0;
  start = clock ();
  do
    {
      a_setf (q, agsl_vector_init_array (qarray, size));
      end = clock ();
      i++;
    }
  while (end < start + CLOCKS_PER_SEC);

  cpu_ms_used = (end - start) / ((double) i) / ((double) CLOCKS_PER_SEC / 1000.0);
  fprintf (stdout, "AGSL: (%d, %E)\n", size, cpu_ms_used);

}
END_TEST


/**
 *
 */
START_TEST (test_agsl_vector_new)
{
  v = nil;
  a_setf (v, agsl_vector_new (SIZE));

  /* unit test code */
  fail_unless (AGSL_VECTOR_P (v),
              "New gslvector is not of type GSLVECTOR");

  fail_unless (GET_GSL_VECTOR (v)->size == SIZE,
              "Vector does not have a element size of %d", SIZE);

  agsl_vector_deallocate (v);
}
END_TEST /* test_agsl_vector_new */


/**
 * ALisp foreign function agsl-vector-make
 */
START_TEST (test_agsl_vector_make)
{
  v = nil;
  a_setf (v, agsl_vector_make (env, mkinteger (SIZE)));

  /* unit test code */
  fail_unless (AGSL_VECTOR_P (v),
               "New gslvector is not of type AGSL_VECTOR_TYPE");

  fail_unless (GET_GSL_VECTOR (v)->size == SIZE,
               "Vector does not have a element size of %d", SIZE);

  /* Call `make' through ALisp */
  a_setf (v, call_lisp
          (mksymbol ("agsl-vector-make"),
                       env, 1,
                       mkinteger (SIZE)));
  
  fail_unless (AGSL_VECTOR_P (v),
               "ALisp agsl_vector is not of type AGSL_VECTOR_TYPE");

  fail_unless (GET_GSL_VECTOR (v)->size == SIZE,
               "ALisp agsl_vector does not have length %d", SIZE);
  
  agsl_vector_deallocate (v);
}
END_TEST /* test_agsl_vector_make /

/**
 * Get vector element
 */
START_TEST (test_agsl_vector_get)
{
  int i = 0;
  double x;
  dcloid (ox);
  
  for (i = 0; i < SIZE; i++)
    {
      x = getreal (agsl_vector_get (env, u, mkinteger (i)));

      fail_unless (APPROX_EQUAL (x, darray[i]),
                 "C `get': u[%d] (%2.2f) != %2.2f", i, x, darray[i]);

      /* Call `get' through ALisp */
      a_setf (ox, call_lisp (mksymbol ("agsl-vector-get"),
                             env, 2,
                             u, mkinteger (i)));
      
      fail_unless (APPROX_EQUAL (getreal (ox), darray[i]),
                   "ALisp `get': v[%d] (%.2f) != %.2f",
                   i, getreal (ox), darray[i]);
    }

  free_oid (ox);
}
END_TEST /* test_agsl_vector_get */

/**
 * Set vector element
 */
START_TEST (test_agsl_vector_set)
{
  int i = 0;
  double x = 0.0;
  dcloid (ox);

  for (i = 0; i < SIZE; i++)
    {
      x = darray[i];
      agsl_vector_set (env, u, mkinteger (i), mkreal (x));

      x = getreal (agsl_vector_get (env, u, mkinteger (i)));
      fail_unless (APPROX_EQUAL (x, darray[i]),
                   "C `set': u_%d (%.2f) != %2.2f", i, x, darray[i]);

      /* Call `set' through ALisp */
      a_setf (ox, mkreal (x));
      call_lisp (mksymbol ("agsl-vector-set"),
                 env, 3, u, mkinteger (i), ox);

      x = getreal (agsl_vector_get (env, u, mkinteger (i)));
      fail_unless (APPROX_EQUAL (x, darray[i]),
                   "ALisp `set': v[%d] (%.2f) != %.2f", i, x, darray[i]);
    }

  free_oid (ox);

}
END_TEST /* test_agsl_vector_set */


/**
 * Add vectors
 */
START_TEST (test_agsl_vector_add)
{
  int i = 0;
  double ax, bx, cx;
  dcloid (oi);
  dcloid (c);
  dcloid (cc); /* ALisp a+b = cc */

  /* add together the vectors */
  a_setf (c, agsl_vector_add (env, a, b));
  a_setf (cc, call_lisp (mksymbol ("agsl-vector-add"),
                        env, 2, a, b));
  
  /* test that c_i = a_i + b_i */
  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      bx = getreal (agsl_vector_get (env, b, oi));
      
      cx = getreal (agsl_vector_get (env, c, oi));

      fail_unless (APPROX_EQUAL (cx, ax + bx), 
                   "c_%d (%2.2f) != a_%d + b_%d (%2.2f) ",
                   i, cx, i, i, ax + bx);

      cx = getreal (agsl_vector_get (env, cc, oi));

      fail_unless (APPROX_EQUAL (cx, ax + bx));
    }

  free_oid (oi);
  free_oid (c);
  free_oid (cc); /* ALisp a+b = cc */  
}
END_TEST /* test_agsl_vector_add */

/**
 * Vector subtraction operation
 */
START_TEST (test_agsl_vector_sub)
{
  int i = 0;
  double ax, bx, cx;
  dcloid (oi);
  dcloid (c);
  dcloid (cc);
  
  a_setf (c, agsl_vector_sub (env, a, b));

  a_setf (cc, call_lisp (mksymbol ("agsl-vector-sub"),
                        env, 2, a, b));
  
  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      bx = getreal (agsl_vector_get (env, b, oi));
      cx = getreal (agsl_vector_get (env, c, oi));
      
      fail_unless (APPROX_EQUAL (cx, ax - bx), 
                   "c_%d (%2.2f) != a_%db_%d (%2.2f) ",
                   i, cx, i, i, ax - bx);

      cx = getreal (agsl_vector_get (env, cc, oi));
      fail_unless (APPROX_EQUAL (cx, ax - bx));    
    }
}
END_TEST /* test_agsl_vector_sub */

/**
 * Vector multiplication operation
 */
START_TEST (test_agsl_vector_mul)
{
  int i = 0;
  double ax, bx, cx; /* a_i, b_i, c_i */

  dcloid (oi); /* lisp index */
  dcloid (c);
  a_setf (c, agsl_vector_mul (env, a, b));

  dcloid (cc);

  a_setf (cc, call_lisp (mksymbol ("agsl-vector-mul"),
                        env, 2, a, b));

  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      bx = getreal (agsl_vector_get (env, b, oi));
      cx = getreal (agsl_vector_get (env, c, oi));
      
      fail_unless (APPROX_EQUAL (cx, ax * bx), 
                   "c_%d != a_%db_%d", i, i, i);

      cx = getreal (agsl_vector_get (env, cc, oi));
      fail_unless (APPROX_EQUAL (cx, ax *bx));
    }
}
END_TEST /* test_agsl_vector_mul */

/**
 * Vector division operation
 */
START_TEST (test_agsl_vector_div)
{
  dcloid (oi);
  dcloid (c);
  dcloid (cc);
  int i = 0;
  double ax, bx, cx;
  a_setf (c, agsl_vector_div (env, a, b));

  a_setf (cc, call_lisp (mksymbol ("agsl-vector-div"),
                        env, 2, a, b));
  
  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      bx = getreal (agsl_vector_get (env, b, oi));
      cx = getreal (agsl_vector_get (env, c, oi));

      fail_unless ( (isnan (cx) && isnan (ax / bx))
                    || (APPROX_EQUAL (cx, (ax / bx))), 
                    "%2.2f != %2.2f / %2.2f = %2.2f",
                    cx, ax, bx, ax / bx);
      
      cx = getreal (agsl_vector_get (env, cc, oi));
      
      fail_unless ( (isnan (cx) && isnan (ax / bx))
                    || (APPROX_EQUAL (cx, ax / bx)));
    }
}
END_TEST /* test_agsl_vector_div */


/**
 * Scale vector
 */
START_TEST (test_agsl_vector_scale)
{
  int i = 0;
  double x = RANDOM_DOUBLE;
  double ax, cx;
  
  dcloid (oi);
  dcloid (ox);
  dcloid (c);
  dcloid (cc); /* ALisp a+x = cc */
  
  a_setf (ox, mkreal (x));
  a_setf (c, agsl_vector_scale (env, a, ox));
  a_setf (cc, call_lisp (mksymbol ("agsl-vector-scale"),
                        env, 2, a, ox));
  
  /* test that c_i = a_i * x */
  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      cx = getreal (agsl_vector_get (env, c, oi));

      fail_unless (APPROX_EQUAL (cx, ax * x),
                   "c_%d (%2.2f) != a_%d (%2.2f) * %2.2f (%2.2f) ",
                   i, cx, i, ax, x, ax * x);

      cx = getreal (agsl_vector_get (env, cc, oi));

      fail_unless (APPROX_EQUAL (cx, ax * x));
    }

  free_oid (oi);
  free_oid (ox);
  free_oid (c);
  free_oid (cc);
}
END_TEST /* test_agsl_vector_scale */


/**
 * Add constant to vector
 */
START_TEST (test_agsl_vector_add_constant)
{
  int i = 0;
  double x = RANDOM_DOUBLE;
  double ax, cx;

  dcloid (oi);
  dcloid (ox);
  dcloid (cc); /* ALisp a+x = cc */
  dcloid (c);
  
  a_setf (ox, mkreal (x));

  a_setf (c, agsl_vector_add_constant (env, a, ox));

  a_setf (cc, call_lisp (mksymbol ("agsl-vector-add-constant"),
                        env, 2, a, ox));
  
  /* test that c_i = a_i + x */
  for (i = 0; i < SIZE; i++)
    {
      oi = mkinteger (i);
      ax = getreal (agsl_vector_get (env, a, oi));
      cx = getreal (agsl_vector_get (env, c, oi));

      fail_unless (APPROX_EQUAL (cx, ax + x),
                   "C `add-constant': c_%d (%2.2f) != a_%d (%2.2f) + %2.2f (%2.2f) ",
                   i, cx, i, ax, x, ax + x);

      cx = getreal (agsl_vector_get (env, cc, oi));

      fail_unless (APPROX_EQUAL (cx, ax + x),
                   "ALisp `add-constant': c_%d (%2.2f) != a_%d (%2.2f) + %2.2f (%2.2f) ",
                   i, cx, i, ax, x, ax + x);
    }
}
END_TEST /* test_agsl_vector_add_constant */


/**
 * Initialize vector from given a_array
 */
START_TEST (test_vector_init)
{
  int i;
  double x;
  double y;

  /* "copies" of lisp-undeclared objects */
  dcloid (vv);
  
  /* initialize vector with amos array `values' */
  a_setf (v, agsl_vector_init (env, values));
  a_setf (vv, call_lisp (mksymbol ("agsl-vector-init"), env, 1, values));

  /* check that each value is what we put in */
  for (i = 0; i < SIZE; i++)
    {
      x = coerce_real (env, agsl_vector_get (env, v, mkinteger (i)));
      y = coerce_real (env, a_elt (values, i));
      fail_unless (APPROX_EQUAL (x, y),
                   "C `init': v_%d=%2.2f != values_%d=%2.2f",
                   i, x, i, y);

      x = coerce_real (env, agsl_vector_get (env, vv, mkinteger (i)));
      y = coerce_real (env, a_elt (values, i));
      fail_unless (APPROX_EQUAL (x, y),
                   "ALisp `init': vv_%d=%2.2f != values_%d=%2.2f",
                   i, x, i, y);

    }

  agsl_vector_deallocate (v);
  agsl_vector_deallocate (vv);

  free_oid (vv);
}
END_TEST

/**
 * Initialize vector from regular c array
 */
START_TEST (test_vector_init_array)
{
  int i;
  double x,y;

  /* initialize vector with c array `darray' */
  a_setf (v, agsl_vector_init_array (darray, SIZE));
  
  for (i = 0; i < SIZE; i++)
    {
      x = darray [i];
      y = coerce_real (env, agsl_vector_get (env, v, mkinteger (i)));
      fail_unless (APPROX_EQUAL (x, y),
                   "Internal C `init_array': darray_%d (%2.2f) != values_%d (%2.2f)",
                   i, x, i, y);
    }

  agsl_vector_deallocate (v);
}
END_TEST

int
read_gsl_vector (int fd, FILE * out)
{
  FILE * in;
  int c;

  in = fdopen (fd, "r");

  putc ('{', out);
  while ((c = fgetc (in)) != EOF)
    {
      if (c == '\n')
        putc (' ', out); /* newlines become spaces */
      else 
        putc (c, out);
    }
  putc ('}', out);

  fclose (in);
  fflush (out); /* (do i need this?) flush stream */

  return EXIT_SUCCESS;
}

/* Print vector to given stream */
int
test_vector_fprintf (gsl_vector * vector, FILE * stream)
{
  pid_t pid;
  int mypipe[2];

  /* Create the pipe. */
  if (pipe (mypipe))
    {
      fprintf (stderr, "Pipe failed.\n");
      return EXIT_FAILURE;
    }

  /* Create the child process. */
  pid = fork ();
  if (pid == (pid_t) 0)
    {
      /* This is the child, close the parent first */
      close (mypipe[1]);
      
      read_gsl_vector (mypipe[0], stream);
      return EXIT_SUCCESS;
    }
  else if (pid < (pid_t) 0)
    {
      /* The fork failed. */
      fprintf (stderr, "Fork failed.\n");
      return EXIT_FAILURE;
    }
  else
    {
      /* This is the parent, close the child first. */
      close (mypipe[0]);
      
      write_gsl_vector_to_pipe (mypipe[1], vector);
      return EXIT_SUCCESS;
    }
}

/**
 * Test print vector - compare two streams for equality
 */
START_TEST (test_agsl_vector_print)
{
  FILE * read_gslfp;
  FILE * read_fp;
  char c1, c2;
  unsigned long l = 0;
  
  gsl_vector * uu = GET_GSL_VECTOR (u); /* `gsl_vector' to print */

  /* new stream for I / O tests */
  a_setf (stream, new_stream (fp));

  test_vector_fprintf (uu, gslfp);
  
  agsl_vector_print (u, stream, TRUE);

  fail_if ( (fp = fdopen (fd, "r")) == NULL);
  fail_if ( (gslfp = fdopen (gslfd, "r")) == NULL);

  /* reset file pointers to start of file */
  fseek (fp, 0L, SEEK_SET);
  fseek (gslfp, 0L, SEEK_SET);

  
  /* compare the printed vector streams */
  fail_if (feof (gslfp) || feof (fp));
  while (!feof (gslfp))
    {
      c1 = fgetc (gslfp);

      fail_if (ferror (gslfp), "Error reading GSL stream");

      fail_if (feof (fp), "No data left in Amos stream");
      c2 = fgetc (fp);

      fail_if (ferror (fp), "Error reading Amos stream");

      fail_unless (c1 == c2,
                   "Streams differ at byte number %lu: %c != %c",
                   l, c1, c2);
    
      l++; /* increase counter */
    }
  fail_if (!feof (fp));
}
END_TEST /* test_agsl_vector_print */

/**
 * Read vector - not sure how to test this :)
 */
START_TEST (test_agsl_vector_read)
{
  fail ("Not implemented yet");
}
END_TEST /* test_agsl_vector_read */

/**
 * Write vector - not sure how to test this :)
 */
START_TEST (test_agsl_vector_write)
{
  fail ("Not implemented");
}
END_TEST /* test_agsl_vector_write */


Suite *
make_vector_suite (void)
{
  Suite *s = suite_create ("Vector");

  /* Core test case , creation, destruction, initialization */
  TCase *tc_core = tcase_create ("Core");
  tcase_add_checked_fixture (tc_core, vector_setup, vector_teardown);
  tcase_add_test (tc_core, test_agsl_vector_new);
  tcase_add_test (tc_core, test_agsl_vector_make);
  suite_add_tcase (s, tc_core);

  TCase *tc_io = tcase_create ("I / O");
  tcase_add_checked_fixture (tc_io, vector_setup_io, vector_teardown_io);
  tcase_add_test (tc_io, test_agsl_vector_print);
  /* tcase_add_test (tc_io, test_agsl_vector_read); */
  /* tcase_add_test (tc_io, test_agsl_vector_write); */
  suite_add_tcase (s, tc_io);

  TCase *tc_init = tcase_create ("Initalizing");
  tcase_add_checked_fixture (tc_init, vector_setup_init, vector_teardown_init);
  tcase_add_test (tc_init, test_setup_init);
  tcase_add_test (tc_init, test_vector_init);
  tcase_add_test (tc_init, test_vector_init_array);
  tcase_add_loop_test (tc_init, time_init, 1, 9);
  tcase_set_timeout (tc_init, 45);
  suite_add_tcase (s, tc_init);

  /* Element access */
  TCase *tc_access = tcase_create ("Access");
  tcase_add_checked_fixture (tc_access, vector_setup_access, vector_teardown_access);
  tcase_add_test (tc_access, test_agsl_vector_get);
  tcase_add_test (tc_access, test_agsl_vector_set);
  suite_add_tcase (s, tc_access);
  
  /* Arithmetical operations (+ - * /) */
  TCase *tc_operations = tcase_create ("Operations");
  tcase_add_checked_fixture (tc_operations, vector_setup_operations, vector_teardown_operations);
  tcase_add_test (tc_operations, test_agsl_vector_add);
  tcase_add_test (tc_operations, test_agsl_vector_sub);
  tcase_add_test (tc_operations, test_agsl_vector_mul);
  tcase_add_test (tc_operations, test_agsl_vector_div);
  tcase_add_test (tc_operations, test_agsl_vector_scale);
  tcase_add_test (tc_operations, test_agsl_vector_add_constant);
  suite_add_tcase (s, tc_operations);

  return s;
}

int
main (void)
{
  int number_failed;
  SRunner * sr = srunner_create (make_vector_suite ());
  srunner_run_all (sr, CK_VERBOSE);
  number_failed = srunner_ntests_failed (sr);
  srunner_free (sr);

  return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}

