/** -*- c-basic-offset: 2; -*-
 *
 * Description:  AGSL header
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:45:48 $
 *
 */

#ifndef AGSL_TYPES_H
#define AGSL_TYPES_H

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>

#include <amos2/alisp.h>   /* ALisp interface */
#include <amos2/callout.h> /* Include AMOS2 callout library (required) */

#include "agsl_vector.h"      /* Vectors */
#include "agsl_matrix.h"      /* Matrices */
#include "agsl_linalg.h"      /* Linear Algebra */
#include "agsl_blas.h"        /* BLAS */
#include "gsl_compare.h"        /* BLAS */

BEGIN_C_DECLS

/* `intstorage.h' */
EXTERN oidtype stdinstream, stdoutstream, stderrstream;
#define instream(str)(((str==t) | (str==nil)) ? stdinstream : \
                (a_streamp(str)?str:lerror(ARG_NOT_STREAM,str,env)))
#define outstream(env,str)((str==t)|(str==nil) ? stdoutstream: \
                (a_streamp(str)?str:lerror(ARG_NOT_STREAM,str,env)))

#define IsReal(env, x) if(!realp(x)) return lerror(ARG_NOT_REAL,x,env)
#define IsInteger(env, x) if(!integerp(x)) return lerror(ARG_NOT_INTEGER,x,env)
#define IsNumber(env, x) if(!(realp(x)||integerp(x))) return lerror(ARG_NOT_REAL,x,env)


#define ONE 1.0
#define ZERO 0.0
#define ALPHA1 ONE
#define BETA0 ZERO

/* clearer amos boolean values */ 
#define AMOS_TRUE t
#define AMOS_FALSE nil

/* Approximate floating point comparison test */
#define EPSILON 0.0001 /* floating-point accuracy */
#define APPROX_EQUAL(x, y) 0 == gsl_fcmp (x, y, EPSILON)
#define APPROX_ZERO(x) ((ZERO - EPSILON) < x && x < (ZERO + EPSILON))
#define APPROX_EQUAL_ZERO(x, y) (APPROX_ZERO (x) && APPROX_ZERO (y))

/* Random double value */
#define RANDOM_DOUBLE ((double) rand() / ((double)(RAND_MAX)+(double)(1)))

END_C_DECLS

#endif /* AGSL_TYPES_H */

