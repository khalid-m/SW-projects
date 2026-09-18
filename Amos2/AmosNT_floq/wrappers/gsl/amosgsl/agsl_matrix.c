/* -*- c-basic-offset: 2; -*- 
 *
 * Description:  BLAS and GSL Storage Type Initialization and Creation
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:45:46 $
 *
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"


EXTERN oidtype stdoutstream; /* can print directly to this? */

int
agsl_matrix_copy_properties (result, A)
{
  if (ISUPPER (A))
    SETUPPER (result);
  else if (ISLOWER (A))
    SETLOWER (result);
  if (ISTRANSPOSE (A))
    SETTRANSPOSE (result);
  if (ISUNITARY (A))
    SETUNITARY (result);
  if (ISSYMMETRIC (A))
    SETSYMMETRIC (result);
  if (ISDIAGONAL (A))
    SETDIAGONAL (result);
  if (ISDECOMPOSED (A))
    AGSL_MATRIX_DECOMP (result) = AGSL_MATRIX_DECOMP (A);

  return GSL_SUCCESS;
}


/**
 * Constructor for a GSL matrix
 */
oidtype
agsl_matrix_new (size_t size1, size_t size2)
{
  /* instantiate a new gsl matrix and pad with zeros */
  gsl_matrix * m = gsl_matrix_alloc (size1, size2);

#ifdef DEBUG
  gsl_matrix_fprintf (stdout, m, "%d");
  printf ("\n");
#endif
  
  struct agsl_matrix_cell * matrixcell;

  /* TODO: Size of an aligned matrix object - what value
     should this be?  - can we use `gsl_matrix' size?  tda
     is the size of a row in memory, so tda * size2 is the
     matrix size in memory ?*/
  size_t size = sizeof (struct agsl_matrix_cell);
  /* + (m->tda * size2);*/
  
  /* Allocate a new object of type AGSL_MATRIX in the image */
  oidtype matrix = new_aligned_object (size, AGSL_MATRIX_TYPE);

  /* Set the matrix of the new object */
  matrixcell = dr (matrix, agsl_matrix_cell);
  matrixcell->filler = size;
  matrixcell->matrix = m;

  /* Return the new object */
  return matrix;
}

/**
 * De-allocate gsl matrix cell and gsl_matrix.
 */
void
agsl_matrix_deallocate (oidtype A)
{
  IsAgslMatrix (topframe (), A);
  
  /* Free the gsl_matrix memory */
  gsl_matrix_free (matrix (A));

  /* not sure if my matrix is an `aligned object' */
  dealloc_aligned_object (A);
}

/**
 * Make a GSL Matrix
 */
oidtype
agsl_matrix_make (bindtype env, oidtype M, oidtype N)
{
  IsInteger (env, M);
  IsInteger (env, N);

  return agsl_matrix_new (getinteger (M), getinteger (N));
}


/**
 * Make an identity matrix A_{M \times N}
 *
 */
oidtype
agsl_matrix_identity (bindtype env, oidtype M, oidtype N)
{
  /* error checking */
  IsInteger (env, M);
  IsInteger (env, N);
  
  dcloid (A);
  
  /* allocate A */
  a_setf (A, agsl_matrix_make (env, M, N));

  gsl_matrix_set_identity (matrix (A));

  /* logically set as the identity matrix */

  SETDIAGONAL (A);
  SETUNITARY (A);
  
  return A;
}


/**
 * e_ij <- x 
 */
oidtype
agsl_matrix_set (bindtype env, oidtype A, oidtype _i, oidtype _j, oidtype _x)
{
  IsAgslMatrix (env, A);
  
  size_t i, j;
  double x;

  /* get argument values from input arguments */
  IntoInteger (_i, i, env);
  IntoInteger (_j, j, env);
  IntoDouble (_x, x, env);

  /* make sure indices are within bounds */
  if (i < 0 || i >= ROWS (A))
    {
      return lerror (ARRAY_BOUNDS, _i, env);
    }
  else if (j < 0 || j >= COLS (A))
    {
      return lerror (ARRAY_BOUNDS, _j, env);
    }
  else
    {
      dcloid (oa);

      /* make a hard copy of A */
      a_setf (oa, agsl_matrix_copy (env, A));

      gsl_matrix_set (matrix (oa), i, j, x);

      /* If matrix A is not general, we should check to ensure
         structure is sustained by setting e_ij */
      if (ISUNITARY (oa) && i == j && x != ALPHA1)
        {
          UNSETUNITARY (oa);
        }
      else if ((ISSYMMETRIC (oa) && i != j)
               || (ISLOWER (oa) && i > j)
               || (ISUPPER (oa) && i < j))
        {
          SETGENERAL (oa);
        }
  
      return oa;
    }
}


/**
 * Get number of rows of given matrix A
 */
oidtype
agsl_matrix_rows (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  return mkinteger (ROWS (A));
}

/**
 * Get number of columns of given matrix M.
 */
oidtype
agsl_matrix_columns (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  return mkinteger (COLS (A));
}


/**
 * TRUE when all elements of M are non-zero.
 */
oidtype
agsl_matrix_all (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  size_t i, j = 0;

  gsl_matrix * a;
  
  if (!ISGENERAL (A))
    {
      dcloid (oa);

      a_setf (oa, agsl_matrix_copy (env, A));

      a = matrix (oa);
    }
  else
    {
      a = matrix (A);
    }
  
  /* go through matrix to check for null elements */

  for (i = 0; i < a->size1; i++)

    for (j = 0; j < a->size2; j++)

      if (gsl_matrix_get (a, i, j) == 0.0)

        return AMOS_FALSE; /* found a zero */

  return AMOS_TRUE; /* no zeros */
}

/**
 * TRUE when any elements of M are non-zero.
 * NOTE Not complete
 * TODO Fix 
 */
oidtype
agsl_matrix_any (bindtype env, oidtype _A)
{
  size_t i, j = 0;
  gsl_matrix * A;
  
  IntoGslMatrix (_A, A, env);

  /* go through matrix to check for non-zero elements */
  for (i = 0; i < A->size1; i++)
    for (j = 0; j < A->size2; j++)
      if (gsl_matrix_get (A, i, j) != 0.0)
        {
          fprintf (stdout, "%2.2f\n", gsl_matrix_get (A, i, j));
          return AMOS_TRUE; /* found a non-zero element */
        }

  return AMOS_FALSE; /* all zeros */
}


/**
 * Get e_{ij} from the matrix M. NOTE: Doesn't check structure
 * of matrix.
 */
oidtype
agsl_matrix_get (bindtype env, oidtype A, oidtype i, oidtype j)
{
  double x;
  IsInteger (env, i);
  IsInteger (env, j);
  IsAgslMatrix (env, A);

  /* if matrix is transposed, switch the indices */
  x = (ISTRANSPOSE (A)
       ? gsl_matrix_get (matrix (A),
                         getinteger (j),
                         getinteger (i))
       : gsl_matrix_get (matrix (A),
                         getinteger (i),
                         getinteger (j)));

  return mkreal (x);
}


/**
 * Print matrix to given Amos stream via pipes.
 */
int
print_gsl_matrix_to_amos (gsl_matrix * A, oidtype _stream)
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
      /* This is the child process, close parent. */
      close (mypipe[1]);

      /* number of columns are for formatting */
      read_gsl_matrix_from_pipe
        (mypipe[0], _stream, A->size2);
      
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
      /* This is the parent process, close child. */
      close (mypipe[0]);
      write_gsl_matrix_to_pipe (mypipe[1], A);
      return EXIT_SUCCESS;
    }
}

/**
 *  [[http://www.chemie.fu-berlin.de/chemnet/use/info/libc/libc_10.html][libc manual]]

 *  Read characters from pipe, send them to an Amos
 *  stream. This could be in a common util package?
 */
void
read_gsl_matrix_from_pipe
(int file, oidtype _stream, size_t cols)
{
  FILE * stream;
  int c;
  size_t current = 0;

  stream = fdopen (file, "r");
  
  a_putc ('{', _stream);
  while ((c = fgetc (stream)) != EOF)
    {
      /* newlines become spaces, except at end of row */
      if (c == '\n' && ++current%cols == 0)
        a_putc ('\n', _stream);
      if (c == '\n')
        a_putc (' ', _stream);
      else
        a_putc (c, _stream);
    }
  
  a_putc ('}', _stream);
  
  fclose (stream);
}

/* Write the matrix to the pipe. */
void
write_gsl_matrix_to_pipe (int fd, gsl_matrix * A)
{
  char * format = "%f";
  FILE * stream = fdopen (fd, "w");

  gsl_matrix_fprintf (stream, A, format);

  fclose (stream);
}


/***
 * Print function for double precision floating point
 * arrays. a)should we use GSL print instead?  b)relevance
 * of the format of the output?
 ***/
void
agsl_matrix_print (oidtype A, oidtype _stream, int princflg)
{
  IsAgslMatrix (topframe (), A);

  dcloid (oa);

  /* make a copy of the matrix -- possibly sort-of expensive */
  a_setf (oa, agsl_matrix_copy (topframe (), A));
  print_gsl_matrix_to_amos (matrix (oa), _stream);

  return GSL_SUCCESS;
}

/**
 * Use GSL function to print to the file stream
 */
oidtype
agsl_matrix_write (bindtype env, oidtype A, oidtype _stream)
{
  IsAgslMatrix (env, A);
  
  agsl_matrix_print (A, outstream (env, _stream), FALSE);

  /*
**** NOTE `return TRUE' gives a segmentation fault, `return
          nil' prints the matrix a few times, `return FALSE'
          does as expected.
  */
  return FALSE;
}

/**
 * Initialize a gslmatrix with given array 
 */
oidtype
agsl_matrix_init_array (double * array, size_t size1, size_t size2)
{
  dcloid (oa);

  gsl_matrix * A = gsl_matrix_alloc (size1, size2);

  gsl_matrix_view view_a = gsl_matrix_view_array (array, size1, size2);

  gsl_matrix_memcpy (A, &view_a.matrix);

  a_setf (oa, agsl_matrix_assign (A));
  
  return oa;
}

/**
 * Initialize a gslmatrix with given values 
 */
oidtype
agsl_matrix_init_flat (bindtype env, oidtype _values, oidtype _size1, oidtype _size2) 
{
  int i, j, idx;
  size_t size1 = getinteger (_size1);
  size_t size2 = getinteger (_size2);
  double * darray = malloc (sizeof (double) * size1 * size2);
  double x;
  oidtype row;

  if (!arrayp (_values)) a_error (ARG_NOT_ARRAY, _values, FALSE);

  /* for each row */
  for (i = 0; i < size1; i++)
    {
      /* add e_{ij} to darray[i * size1 + j] */
      for (j = 0; j < size2; j++)
        {
          idx = i * size2 + j;
          
          IntoDouble (a_elt (_values, idx), x, env); /* x = e_{ij} */

          darray[idx] = x;
        }
    }

  /* populate matrix with regular c array of doubles */
  return agsl_matrix_init_array (darray, size1, size2);
}

/**
 * Set all elements of `A' to `x'.
 */
oidtype
agsl_matrix_set_all (bindtype env, oidtype _A, oidtype _x)
{
  IsAgslMatrix (env, _A);
  IsNumber (env, _x);

  dcloid (A);

  double x = coerce_real (env, _x);

  a_setf (A, agsl_matrix_copy (env, _A));
  
  if (x == 0)
    {
      gsl_matrix_set_zero (matrix (A));
    }
  else
    {
      gsl_matrix_set_all (matrix (A), x);
    }
  
  return A;
}



/**
 * Randomize elements of new MxN matrix
 *
 * TODO Improve by creating an array of random numbers instead
 * of creating a random number at each indice.
 */
oidtype
agsl_matrix_rand (bindtype env, oidtype _M, oidtype _N)
{
  IsInteger (env, _M);
  IsInteger (env, _N);
  
  dcloid (oa);
  size_t i, j, M, N;
  
  IntoInteger (_M, M, env);
  IntoInteger (_N, N, env);

  gsl_matrix * A = gsl_matrix_alloc (M, N);

  for (i = 0; i < M; i++)
    for (j = 0; j < N; j++)
      gsl_matrix_set (A, i, j, RANDOM_DOUBLE);
 
  a_setf (oa, agsl_matrix_assign (A));

  return oa;
}



/**
 * Initialize a gslmatrix with given `values', an Amos
 * vector of vectors of numbers.
 */
oidtype
agsl_matrix_init (bindtype env, oidtype _values) 
{
  dcloid (row);
  int i, j, idx;
  double * darray;
  size_t size1;
  size_t size2;
  double x;
  
  a_setf (row, a_elt (_values, 0));

  if (!arrayp (row)) a_error (ARG_NOT_ARRAY, row, FALSE);

  size1 = a_arraysize (_values);
  size2 = a_arraysize (row);
  
  darray = malloc (sizeof (double) * size1 * size2);

  if (!arrayp (_values)) a_error (ARG_NOT_ARRAY, _values, FALSE);

  /* for each row */
  for (i = 0; i < size1; i++)
    {
      a_setf (row, a_elt (_values, i));
      
      /* add e_{ij} to darray[i * size1 + j] */
      for (j = 0; j < size2; j++)
        {
          idx = i * size2 + j;
          
          x = coerce_real (env, a_elt (row, j)); /* x = e_{ij} */

          darray[idx] = x;
        }
    }

  /* populate matrix with regular c array of doubles */
  return agsl_matrix_init_array (darray, size1, size2);
}

/**
 * Type of numerical elements in matrix (double, integer, ...)
 */
oidtype
agsl_matrix_typeof (bindtype env, oidtype A) 
{
  IsAgslMatrix (env, A);

  if (ISDECOMPOSED (A))
    {
      if (ISLUDECOMP (A))
        {
          return globval (mksymbol ("_ludecomposedmatrix_"));
        }
      else if (ISCHOLESKY (A))
        {
          return globval (mksymbol ("_choleskymatrix_"));
        }
    }
  else if (ISSYMMETRIC (A))
    {
      if (ISDIAGONAL (A))
        {
          return globval (mksymbol (ISUNITARY (A)
                                    ? "_identitymatrix_"
                                    : "_diagonalmatrix_"));
        }
      else
        {
          return globval (mksymbol ("_symmetricmatrix_"));
        }
    }
  else if (ISLOWERTRI (A))
    {    
      return globval (mksymbol ((ISUNITARY (A)
                                 ? "_unitlowertriangularmatrix_"
                                 : "_lowertriangularmatrix_")));
    }
  else if (ISUPPERTRI (A))
    {
      return globval (mksymbol ((ISUNITARY (A)
                                 ? "_unituppertriangularmatrix_"
                                 : "_uppertriangularmatrix_")));
    }
  else
    {
      /* General matrix type we have is `_matrix_' */
      return globval (mksymbol ("_matrix_"));
    }
}

/**
 * Read a matrix, which is of the form [[1,2,3],[4,5,6],[7,8,9]]
 *
 * TODO: Use gsl_matrix_scan and a file buffer to read in
 *       matrix using astorage stream reader
 */
oidtype
agsl_matrix_read (bindtype env, oidtype _tag, oidtype _list, oidtype _stream)
{
  int i = 0, j = 0;
  oidtype list = _list;
  oidtype row = fhd (list);;
  size_t size1 = a_length (list); /* number of rows */
  size_t size2 = a_length (row); /* number of columns */
  oidtype matrix = agsl_matrix_new (size1, size2);
  gsl_matrix * m;
  /* element of matrix */
  double x;
  
  IntoGslMatrix (matrix, m, env);
  
  for (i = 0; i < size1; i++)
    {
    for (j = 0; i < size2; j++)
      {
        IntoDouble (fhd (row), x, env); /* x <-- e_{ij} */
        gsl_matrix_set (m, i, j, x);
        
        row = ftl (row); 
      }
    
    list = ftl (list);
    }
  return matrix;
}

/*** Operations ***/

/**
 * Add two gsl matrices using gemm, trmm or symm
 *
 * memcpy B, run gemm or symm depending on if A is symmetric
 * 
 * 1.0 * A I + 1.0 * B = A + B
 * A B + 1.0 * C
 *
 * @param _a one matrix to add
 * @param _b the other matrix to add
 * @return   a matrix of elements of _a added to elements of _b
 */
oidtype
agsl_matrix_add (bindtype env, const oidtype _a, const oidtype _b)
{
  IsAgslMatrix (env, _a);
  IsAgslMatrix (env, _b);
  
  if (ROWS (_a) != ROWS (_b) || COLS (_a) != COLS (_b))
    {
      GSL_ERROR ("matrices must have same dimensions", GSL_EBADLEN);
    }
  else
    {
      dcloid (result); /* copy of _a */
      dcloid (B); /* copy of _b */

      a_setf (result, agsl_matrix_copy (env, _a));
      a_setf (B, agsl_matrix_copy (env, _b));
      
      /* add elements */
      gsl_matrix_add (matrix (result), matrix (B));

      return result;
    }
}


/**
 * Subtract two gsl matrixs element by element 
 * @param _a one matrix 
 * @param _b the other matrix 
 * @return   a matrix of elements of _a subtracted by elements of _b
 */
oidtype
agsl_matrix_sub (bindtype env, const oidtype _a, const oidtype _b)
{
  IsAgslMatrix (env, _a);
  IsAgslMatrix (env, _b);

  if (ROWS (_a) != ROWS (_b) || COLS (_a) != COLS (_b))
    {
      GSL_ERROR ("matrices must have same dimensions", GSL_EBADLEN);
    }
  else
    {
      dcloid (result); /* copy of _a */
      dcloid (B); /* copy of _b */

      a_setf (result, agsl_matrix_copy (env, _a));
      a_setf (B, agsl_matrix_copy (env, _b));
      
      /* add elements */
      gsl_matrix_sub (matrix (result), matrix (B));

      return result;     
    }
}

/**
 * Divide two gsl matrixs element by element 
 * @param _a one matrix to add
 * @param _b the other matrix to add
 * @return   a matrix of elements of matrix _a divided by elements of matrix _b
 */
oidtype
agsl_matrix_div_elements (bindtype env, const oidtype _a, const oidtype _b)
{
  IsAgslMatrix (env, _a);
  IsAgslMatrix (env, _b);
 
  if (ROWS (_a) != ROWS (_b) || COLS (_a) != COLS (_b))
    {
      GSL_ERROR ("matrices must have same dimensions", GSL_EBADLEN);
    }
  else
    {
      dcloid (result); /* copy of _a */
      dcloid (B); /* copy of _b */

      a_setf (result, agsl_matrix_copy (env, _a));
      a_setf (B, agsl_matrix_copy (env, _b));
      
      /* add elements */
      gsl_matrix_div_elements (matrix (result), matrix (B));

      return result;     
    }
}


/**
 * Multiply two gsl matrixs element by element 
 * @param _a one matrix to add
 * @param _b the other matrix to add
 * @return   a matrix of elements of matrix _a multiplied by elements of matrix _b
 */
oidtype
agsl_matrix_mul_elements (bindtype env, const oidtype _a, const oidtype _b)
{
  IsAgslMatrix (env, _a);
  IsAgslMatrix (env, _b);

  if (ROWS (_a) != ROWS (_b) || COLS (_a) != COLS (_b))
    {
      GSL_ERROR ("matrices must have same dimensions", GSL_EBADLEN);
    }
  else
    {
      dcloid (result); /* copy of _a */
      dcloid (B); /* copy of _b */

      a_setf (result, agsl_matrix_copy (env, _a));
      a_setf (B, agsl_matrix_copy (env, _b));
      
      /* add elements */
      gsl_matrix_mul_elements (matrix (result), matrix (B));

      return result;
    }
}

/**
 * Multiply a matrix by a constant factor
 * @param A the matrix 
 * @param _x the constant
 * @return   a matrix of elements of matrix A multiplied by the
 *           constant factor _x
 */
oidtype
agsl_matrix_scale (bindtype env, const oidtype A, const oidtype _x)
{
  IsAgslMatrix (env, A);
  IsNumber (env, _x);

  dcloid (result);
  
  a_setf (result, agsl_matrix_copy (env, A));

  /* scale matrix */

  gsl_matrix_scale (matrix (result), coerce_real (env, _x));

  return result;
}



/**
 * Add a constant factor to elements of a matrix
 * @param A the matrix 
 * @param _x the constant
 * @return   a matrix of elements of matrix A with a constant *
 *           factor _x added
 */
oidtype
agsl_matrix_add_constant (bindtype env, const oidtype A, const oidtype _x)
{
  IsAgslMatrix (env, A);
  IsNumber (env, _x);
  
  dcloid (result);
  
  a_setf (result, agsl_matrix_copy (env, A));

  /* add constant */

  gsl_matrix_add_constant (matrix (result), coerce_real (env, _x));

  return result;
}


/**
 * Transpose matrix
 * @param A matrix to transpose
 * @return   a transposed matrix
 *
 */
oidtype
agsl_matrix_transpose (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  dcloid (result); /* copy of A */

  a_setf (result, agsl_matrix_copy (env, A));

  SETTRANSPOSE (result);
  
  return result;
}


/**
 * WARNING Good? Create an alternative "view" of A. Copy agsl
 * matrix cell of A but use the same underlying data as
 * A. 
 *
 * @param  A the matrix structure to view
 * @return   an agsl_matrix copy of A using A's matrix
 */
oidtype
agsl_matrix_view (oidtype A)
{
  dcloid (B);
  gsl_matrix * a;
  a_setf (B, agsl_matrix_assign (matrix (A)));
    
  /* copy A's properties too */
  agsl_matrix_copy_properties (B, A);
  
  /* Return the new object */
  return B;
}


/**
 * Copy a logical matrix as is without analyzing matrix types
 * and cleaning data up.
 *
 * @param  A the matrix structure to copy
 * @return   an agsl_matrix copy of A 
 */
oidtype
agsl_matrix_softcopy (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);
  
  dcloid (B);

  gsl_matrix * a = gsl_matrix_alloc (matrix (A)->size1,
                                     matrix (A)->size2);
  
  gsl_matrix_memcpy (a, matrix (A));
                     
  a_setf (B, agsl_matrix_assign (a));
    
  /* copy A's properties too */

  agsl_matrix_copy_properties (B, A);

  if (ISLUDECOMP (A))
    {
      SETPERM (B, gslperm (A));
    }
  
  /* return the new object */

  return B;
}


/**
 * Create agsl matrix out of given gsl_matrix
 *
 * @param  m the matrix 
 * @return   an agsl_matrix holding `m'
 */
oidtype
agsl_matrix_assign (gsl_matrix * m)
{
  dcloid (matrix);
  struct agsl_matrix_cell * matrixcell;
  size_t size = sizeof (struct agsl_matrix_cell);

  /* Allocate a new object of type AGSL_MATRIX in the image */
  a_setf (matrix, new_aligned_object (size, AGSL_MATRIX_TYPE));

  /* Set the matrix of the new object */
  matrixcell = dr (matrix, agsl_matrix_cell);
  /* matrixcell->filler = size; */
  matrixcell->matrix = m;

  /* Return the new object */
  return matrix;
}

/**
 * Error codes in use
 */
void
agsl_matrix_register_error_codes ()
{
  ARG_NOT_AGSL_MATRIX = a_register_error ("Argument not an Agsl Matrix");
  AGSL_ENOMEM = a_register_error ("Out of Memory");
  AGSL_EINVAL = a_register_error ("Invalid matrix argument supplied by user");
  AGSL_EBADLEN = a_register_error ("Matrix / Vector Lengths are not conformant");
  AGSL_ENOTSQR = a_register_error ("Matrix is not square");
  AGSL_FAILURE = a_register_error ("Agsl function failed");
  
}





/*****************************************************************************
 * Initialization
 *****************************************************************************/
void
agsl_matrix_register_functions ()
{
#ifdef VERBOSE
  printf ("agsl_matrix_register_functions...\n");
#endif
  
  /* Define user defined storage data type `gslmatrix' */
  AGSL_MATRIX_TYPE = a_definetype ("matrix", agsl_matrix_deallocate, agsl_matrix_print);

#ifdef VERBOSE
  printf ("defined type matrix\n");
#endif
  
  /* Define user defined reader for #[MATRIX a b c d ...] ?*/
  type_reader_function ("MATRIX", agsl_matrix_read);

  /* Information */
  extfunction1 ("agsl-matrix-rows", agsl_matrix_rows); 
  extfunction1 ("agsl-matrix-columns", agsl_matrix_columns); 

  extfunction1 ("agsl-matrix-all", agsl_matrix_all); 
  extfunction1 ("agsl-matrix-any", agsl_matrix_any); 

  extfunction2 ("agsl-matrix-make", agsl_matrix_make); 
  extfunction3 ("agsl-matrix-get", agsl_matrix_get);
  extfunction4 ("agsl-matrix-set", agsl_matrix_set);

  /* AmoSQL uses these functions */
  extfunction2 ("agsl-matrix-print", agsl_matrix_write);
  extfunction1 ("agsl-matrix-type-of", agsl_matrix_typeof);

  /* Some init functions */
  extfunction1 ("agsl-matrix-init", agsl_matrix_init);
  extfunction2 ("agsl-matrix-set-all", agsl_matrix_set_all);
  extfunction2 ("agsl-matrix-rand", agsl_matrix_rand);
  extfunction2 ("agsl-matrix-eye", agsl_matrix_identity);


  /* Operations */
  extfunction2 ("agsl-matrix-add", agsl_matrix_add);
  extfunction2 ("agsl-matrix-sub", agsl_matrix_sub);
  extfunction2 ("agsl-matrix-mul-elements", agsl_matrix_mul_elements);
  extfunction2 ("agsl-matrix-div-elements", agsl_matrix_div_elements);
  extfunction2 ("agsl-matrix-scale", agsl_matrix_scale);
  extfunction2 ("agsl-matrix-add-constant", agsl_matrix_add_constant);
  extfunction1 ("agsl-matrix-transpose", agsl_matrix_transpose);

  /* Subtypes */
  extfunction1 ("agsl-matrix-tril", agsl_matrix_lower_copy);
  extfunction1 ("agsl-matrix-triu", agsl_matrix_upper_copy);
  extfunction1 ("agsl-matrix-symm", agsl_matrix_symmetric_copy);
  extfunction1 ("agsl-matrix-diag", agsl_matrix_diagonal_copy);
  extfunction1 ("agsl-matrix-decomp", agsl_matrix_decomp_copy);
  extfunction1 ("agsl-matrix-recomp", agsl_matrix_recomp_copy);

  extfunction1 ("agsl-matrix-qr-decomp", agsl_linalg_QR_decomp);
  extfunction1 ("agsl-matrix-cholesky-decomp", agsl_linalg_cholesky_decomp);
  extfunction1 ("agsl-matrix-lu-decomp", agsl_linalg_LU_decomp);

  /* Registor Error Codes */
  agsl_matrix_register_error_codes ();
  
  return;
}

