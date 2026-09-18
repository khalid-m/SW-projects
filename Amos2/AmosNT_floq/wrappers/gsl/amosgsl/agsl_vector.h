/* -*- c-basic-offset: 2; -*- 
 *
 * Description:  BLAS and GSL Storage Types
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:45:47 $
 *
 */

#ifndef AGSL_VECTOR_H
#define AGSL_VECTOR_H

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <gsl/gsl_vector.h>
#include <amos2/alisp.h>


/* Error handling for vector's */
#define ARG_NOT_AGSL_VECTOR ILLEGAL_ARGUMENT
#define IS_AGSL_VECTOR(env, agsl_vector) OfType (agsl_vector, AGSL_VECTOR_TYPE, env)
#define AGSL_VECTOR_P(agsl_vector) (a_datatype (agsl_vector) == AGSL_VECTOR_TYPE)

/* Get gsl_vector object from given agsl_vector */
#define GET_GSL_VECTOR(_agsl_vector)            \
  dr (_agsl_vector, agsl_vector_cell)->vector

/* Check agsl_vector type, place gsl_vector into `vector' */
#define INTO_GSL_VECTOR(agsl_vector, vector, env)       \
  if (AGSL_VECTOR_P (agsl_vector))                      \
    vector = GET_GSL_VECTOR (agsl_vector);              \
  else                                                  \
    return lerror (ARG_NOT_AGSL_VECTOR,                 \
                   agsl_vector,                         \
                   env)

#define AGSL_VECTOR_PRINT "agsl-vector-print"
#define AGSL_VECTOR_MAKE "agsl-vector-make"
#define AGSL_VECTOR_GET "agsl-vector-get"
#define AGSL_VECTOR_SET "agsl-vector-set"
/* #define AGSL_VECTOR_READ "agsl-vector-read" */
/* #define AGSL_VECTOR_WRITE "agsl-vector-write" */

BEGIN_C_DECLS

/* Template for agsl_vectors */
struct agsl_vector_cell
{
  objtags tags;
  size_t filler; /* total size in bytes - unused */
  gsl_vector * vector;  /* the actual vector */
};
EXTERN int AGSL_VECTOR_TYPE; /* Holds the type tag of objects of type GSLVECTOR */


/* Construct a new agsl_vector */
oidtype agsl_vector_new (size_t size);

/* Make a new agsl_vector */
oidtype agsl_vector_make (bindtype env, oidtype size);
oidtype agsl_vector_set (bindtype env, oidtype agsl_vector, oidtype index, oidtype element);
oidtype agsl_vector_get (bindtype env, oidtype agsl_vector, oidtype index);
oidtype agsl_vector_read (bindtype env, oidtype tag, oidtype list, oidtype stream);
oidtype agsl_vector_write (bindtype env, oidtype agsl_vector, oidtype stream);

oidtype agsl_vector_init (bindtype env, oidtype values);

void agsl_vector_print (oidtype agsl_vector, oidtype stream, int princflg);

/* helper functions for `agsl_vector_print' */
int pipe_gsl_vector_to_amos(gsl_vector * vector, oidtype stream);
void read_gsl_vector_from_pipe (int file, oidtype stream);
void write_gsl_vector_to_pipe (int file, gsl_vector * vector);

void agsl_vector_deallocate (oidtype agsl_vector);

void agsl_vector_register_functions ();

END_C_DECLS


#endif /* AGSL_VECTOR_H */

