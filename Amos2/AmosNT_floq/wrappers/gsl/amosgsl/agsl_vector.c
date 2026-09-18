/* -*- c-basic-offset: 2; -*- 
 *
 * Description: Amos BLAS/GSL Storage Type Initialization
 *              and Creation. Modelled on SCSQ's
 *              [[AmosNT/scsq/C/numarray.c][numarray]]
 *              storage type.
 */
#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>


/**
 * Print vector to given Amos stream via pipes.
 */
int
print_gsl_vector_to_amos (gsl_vector * vector, oidtype _stream)
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
      read_gsl_vector_from_pipe (mypipe[0], _stream);
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
      write_gsl_vector_to_pipe (mypipe[1], vector);
      return EXIT_SUCCESS;
    }
}

/**
 *  [[http://www.chemie.fu-berlin.de/chemnet/use/info/libc/libc_10.html][libc manual]]

 *  Read characters from pipe, send them to an Amos
 *  stream. This could be in a common util package?
 */
void
read_gsl_vector_from_pipe (int fd, oidtype _stream)
{
  FILE * stream;
  int c;

  stream = fdopen (fd, "r");
  
  a_putc ('{', _stream);
  while ((c = fgetc (stream)) != EOF)
    {
      /* newlines become spaces */
      a_putc ((c == '\n' ? ' ' : c), _stream);
    }
  
  a_putc ('}', _stream);
  
  fclose (stream);
}

/* Write the vector to the pipe. */
void
write_gsl_vector_to_pipe (int fd, gsl_vector * vector)
{
  char * format = "%2.2f";
  FILE * stream = fdopen (fd, "w");

  gsl_vector_fprintf (stream, vector, format);

  fclose (stream);
}

/**
 * Constructor for a GSL vector
 *
** NOTE: Some functions that are similar to those in
 *   compl_fns.c for the complex datatype and matrix
 *   new_iarray function.
 */
oidtype
agsl_vector_new (size_t n)
{
  /* create a new vector of size `n', pad with zeros */
  gsl_vector * v = gsl_vector_alloc (n);

  struct agsl_vector_cell * vectorcell;

  /* TODO: Size of an aligned vector object - what value
  should this be?  - can we use `gsl_vector' size?  stride
  is the size of one element in memory, so `stride * n' is the
  size of the whole vector in memory Perhaps AStorage only
  needs the structure size since GSL is handling memory for
  the actual vector data ? */
  size_t size = sizeof (struct agsl_vector_cell) + (n * v->stride);
  
  /* Allocate new object of type AGSL_VECTOR in the image */
  oidtype vector = new_aligned_object (size, AGSL_VECTOR_TYPE);

  /* Set the vector of the new object */
  vectorcell = dr (vector, agsl_vector_cell);
  vectorcell->filler = size;
  vectorcell->vector = v;

  /* Return the new object */
  return vector;
}

/* Construct new agsl_vector */
oidtype
agsl_vector_make (bindtype env, oidtype _size)
{
  /* get the integer value for size */
  size_t size;
  IntoInteger (_size, size, env);

  return agsl_vector_new (size);
}

/* Set element `v_i' to `x' */
oidtype
agsl_vector_set (bindtype env, oidtype _v, oidtype _i, oidtype _x)
{
  size_t i;
  gsl_vector * v;
  double x;
  
  /* get encapsulated argument values */
  INTO_GSL_VECTOR (_v, v, env);
  IntoInteger (_i, i, env);
  IntoDouble (_x, x, env);

  /* Set vector element, GSL error handler will be angry if
     indices are not within bounds.

     NOTE: the GSL error handler is involved? */
  gsl_vector_set (v, i, x);

  /* Is it standard to return `x' in Amos? */
  return _x;
}

/* Get element `v_i' */
oidtype
agsl_vector_get (bindtype env, oidtype _v, oidtype _i)
{
  int i;
  gsl_vector * v;
  oidtype ox;

  INTO_GSL_VECTOR (_v, v, env);
  IntoInteger (_i, i, env);
  
  a_setf (ox, mkreal (gsl_vector_get (v, i)));
  
  return ox;
}


/*** Print function for agsl_vectors ***/
void
agsl_vector_print (oidtype _vector, oidtype _stream, int princflg)
{
  gsl_vector * vector = GET_GSL_VECTOR (_vector);

  print_gsl_vector_to_amos (vector, _stream);

  return;
}



/**
 * Print to the file stream
 */
oidtype
agsl_vector_write (bindtype env, oidtype _vector, oidtype _stream)
{
  agsl_vector_print (_vector, outstream (env, _stream), FALSE);

  /*
**** NOTE `return TRUE' gives a segmentation fault, `return
           nil' prints the vector a few times, `return
           FALSE' does as expected.
  */
  return FALSE;
}


/**
 * Initialize a gslmatrix with given array
 */
oidtype
agsl_vector_init_array (double * array, size_t size)
{
  dcloid (ov);
  a_setf (ov, agsl_vector_new (size));
  gsl_vector_view view_v = gsl_vector_view_array (array, size);
  gsl_vector * v = GET_GSL_VECTOR (ov);
  gsl_vector_memcpy (v, &view_v.vector);
  
  return ov;
}


/**
 * Initialize a agsl_vector with given values
 */
oidtype
agsl_vector_init (bindtype env, oidtype _values) 
{
  int i = 0;
  size_t size = a_arraysize (_values);
  double * darray = malloc (sizeof (double) * size);
  
  if (!arrayp (_values)) a_error (ARG_NOT_ARRAY, _values, FALSE);
  
  for (i = 0; i < size; i++)
    {
      /* NUMBER to C double and add to C array */
      darray [i] = coerce_real (env, a_elt (_values, i));
    }
      
  return agsl_vector_init_array (darray, size);
}


/**
 * Type of numerical elements in vector (double,integer,...)
 */
oidtype
agsl_vector_typeof (bindtype env, oidtype _vector) 
{
  /* Returns the subtype of agsl_vector (as defined by kind) */
  /* gsl_vector * vector; */
  /* INTO_GSL_VECTOR (_vector, vector, env); */

  /* The only gsl_vector type we have right now */
  return globval (mksymbol ("_gslvector_"));
}

/**
 * Read a agsl_vector, which is of the form [[1,2,3],[4,5,6],[7,8,9]]
 *
** TODO: Use
 *       [[http://www.gnu.org/software/gsl/manual/html_node/Reading-and-writing-vectors.html][gsl_vector_fscanf]]
 *       with pipes and a temporary stream to read in vector
 *       using AStorage stream reader.
 */
oidtype
agsl_vector_read (bindtype env, oidtype _tag, oidtype _list, oidtype _stream)
{
  int i = 0;
  size_t size = a_length (_list);
  oidtype list = _list; /* list of arguments */
  oidtype vector = agsl_vector_new (size);
  gsl_vector * v;
  double x;

  INTO_GSL_VECTOR (vector, v, env);
  
  for (i = 0; i < size; i++)
    {
      IntoDouble (fhd (list), x, env);
      gsl_vector_set (v, i, x);
      
      list = ftl (list);
    }
  
  return vector;
}

/*** Operations ***/

/**
 * Add two gsl vectors element by element 
 * @param _a one vector to add
 * @param _b the other vector to add
 * @return   a vector of elements of _a added to elements of _b
 */
oidtype
agsl_vector_add (bindtype env, const oidtype _a, const oidtype _b)
{
  const gsl_vector * a;
  const gsl_vector * b;
  gsl_vector * c;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  INTO_GSL_VECTOR (_b, b, env);

  /* allocate memory space for result */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, c, env);


  /* copy a to c, we write-over neither _a nor _b */
  gsl_vector_memcpy (c, a);
  gsl_vector_add (c, b);

  return result;
}


/**
 * Subtract two gsl vectors element by element 
 * @param _a one vector 
 * @param _b the other vector 
 * @return   a vector of elements of _a subtracted by elements of _b
 */
oidtype
agsl_vector_sub (bindtype env, const oidtype _a, const oidtype _b)
{
  const gsl_vector * a;
  const gsl_vector * b;
  gsl_vector * c;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  INTO_GSL_VECTOR (_b, b, env);

  /* allocate memory space for result */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, c, env);


  /* copy a to c as we write-over neither _a nor _b */
  gsl_vector_memcpy (c, a);
  gsl_vector_sub (c, b);

  return result;
}

/**
 * Divide two gsl vectors element by element 
 * @param _a one vector to add
 * @param _b the other vector to add
 * @return   a vector of elements of vector _a divided by elements of vector _b
 */
oidtype
agsl_vector_div (bindtype env, const oidtype _a, const oidtype _b)
{
  const gsl_vector * a;
  const gsl_vector * b;
  gsl_vector * c;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  INTO_GSL_VECTOR (_b, b, env);

  /* allocate memory space for result */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, c, env);


  /* copy a to c as we write-over neither _a nor _b */
  gsl_vector_memcpy (c, a);
  gsl_vector_div (c, b);

  return result;
}


/**
 * Multiply two gsl vectors element by element 
 * @param _a one vector to add
 * @param _b the other vector to add
 * @return   a vector of elements of vector _a multiplied by
 *           elements of vector _b
 */
oidtype
agsl_vector_mul (bindtype env, const oidtype _a, const oidtype _b)
{
  const gsl_vector * a;
  const gsl_vector * b;
  gsl_vector * c;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  INTO_GSL_VECTOR (_b, b, env);

  /* allocate memory space for result */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, c, env);


  /* copy a to c as we write-over neither _a nor _b */
  gsl_vector_memcpy (c, a);
  gsl_vector_mul (c, b);

  return result;
}

/**
 * Multiply a vector by a constant factor
 *  @param _a the vector 
 *  @param _x the constant 
 *  @return a vector of elements of vector _a multiplied by
 *          the constant factor _x
 */
oidtype
agsl_vector_scale (bindtype env, const oidtype _a, const oidtype _x)
{
  const gsl_vector * a;
  double x;
  gsl_vector * b;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  IntoDouble (_x, x, env);
  
  /* allocate memory space for resulting vector */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, b, env);

  /* copy a to b as we don't write-over _a */
  gsl_vector_memcpy (b, a);

  /* scale vector */
  gsl_vector_scale (b, x);

  return result;
}



/**
 * Add a constant factor to elements of a vector
 * @param _a the vector 
 * @param _x the constant 
 * @return   a vector of elements of vector _a with a constant factor _x added
 */
oidtype
agsl_vector_add_constant (bindtype env, const oidtype _a, const oidtype _x)
{
  const gsl_vector * a;
  double x;
  gsl_vector * b;

  oidtype result;
  
  INTO_GSL_VECTOR (_a, a, env);
  IntoDouble (_x, x, env);
  
  /* allocate memory space for resulting vector */
  result = agsl_vector_make (env, mkinteger (a->size));
  INTO_GSL_VECTOR (result, b, env);


  /* copy a to b as we don't write-over _a */
  gsl_vector_memcpy (b, a);

  /* scale vector */
  gsl_vector_add_constant (b, x);

  return result;
}

/**
 * De-allocate gsl vector cell and gsl_vector.
 */
void
agsl_vector_deallocate (oidtype _vector)
{
  if (_vector != nil)
    {
      gsl_vector * v = GET_GSL_VECTOR (_vector);

      /* Free the gsl_vector memory */
      gsl_vector_free (v);

      dealloc_aligned_object (_vector);
    }
}

/*****************************************************************************
 * Initialization
 ****************************************************************************/
void
agsl_vector_register_functions ()
{
#ifdef VERBOSE
  printf ("agsl_vector_register_functions...\n");
#endif
  
  /* Define user defined storage data type `gslvector' */
  AGSL_VECTOR_TYPE = a_definetype ("gslvector", agsl_vector_deallocate, NULL);
  typefns[AGSL_VECTOR_TYPE].printfn = agsl_vector_print;

#ifdef VERBOSE
  printf ("defined type gslvector\n");
#endif
  
  /* Define user defined reader for #[GSLVECTOR a b c d ...] ?*/
  type_reader_function ("GSLVECTOR", agsl_vector_read);

  extfunction1 ("agsl-vector-make", agsl_vector_make); 
  extfunction2 ("agsl-vector-get", agsl_vector_get);
  extfunction3 ("agsl-vector-set", agsl_vector_set);

  /* AmoSQL uses these functions */
  extfunction2 ("agsl-vector-print", agsl_vector_write);
  extfunction1 ("agsl-vector-type-of", agsl_vector_typeof);
  extfunction1 ("agsl-vector-init", agsl_vector_init);

  /* Operations */
  extfunction2 ("agsl-vector-add", agsl_vector_add);
  extfunction2 ("agsl-vector-sub", agsl_vector_sub);
  extfunction2 ("agsl-vector-mul", agsl_vector_mul);
  extfunction2 ("agsl-vector-div", agsl_vector_div);
  extfunction2 ("agsl-vector-scale", agsl_vector_scale);
  extfunction2 ("agsl-vector-add-constant", agsl_vector_add_constant);
  
  return;
}

