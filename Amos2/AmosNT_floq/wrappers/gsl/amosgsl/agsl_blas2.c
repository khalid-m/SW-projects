/** -*- c-basic-offset: 2; -*- 
 *
 * $Description:  Selected BLAS Level 2 Operations for AmosGSL $
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:45:45 $
 *
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"

/**
 * DGEMV
 *
 * Compute the matrix-vector product and sum
 * 
 * v = \alpha op (A)u + \beta v, where op (A) = A, A^T
 * 
 * (or `v = Au')
 *
 * @param env Holds environment
 * @param _a  The agsl matrix op (A) for the equation above
 * @param _u  The agsl vector for u in the equation above
 * @return    The agsl vector for the product v = Au
 */
oidtype
agsl_blas_dgemv (bindtype env, const oidtype _a, const oidtype _u)
{
  gsl_matrix * a;
  gsl_vector * u;

  int e;
  
  gsl_vector * v;

  dcloid (result);
  
  IntoGslMatrix (_a, a, env); /* grab the matrix */
  INTO_GSL_VECTOR (_u, u, env); /* grab the vector */

  /* allocate memory for result vector with a size the number of rows
     of `a'  */
  result = agsl_vector_make (env, mkinteger (a->size1));
  /* handle to results underlying gsl vector */
  INTO_GSL_VECTOR (result, v, env);
  
  /* returns general matrix-vector multiply */
  e = gsl_blas_dgemv (CblasNoTrans, ALPHA1, a, u, BETA0, v);
  
  if (e == GSL_SUCCESS)
    return result;
  else if (e == GSL_ENOMEM)
    return lerror (AGSL_ENOMEM, _a, env);
  else if (e == GSL_EINVAL)
    return lerror (AGSL_EINVAL, _a, env);
  else
    return lerror (NO_ERRNO_ASSIGNED, _a, env);
}


/**
 * Compute the matrix-vector product and sum y = \alpha A x
 * + \beta y for the symmetric matrix A.
 *
 * Variables
 *
 *  y    result vector from AGSL from the equation above
 * yy    test vector GSL from the equation above
 *
 * Global Variables
 *  b    agsl matrix `A' in the equation above
 * bb    test matrix `A'
 *  u    agsl vector `u'
 * uu    test vector `u'
 */
oidtype
agsl_blas_dsymv (bindtype env, const oidtype _a, const oidtype _u)
{
  IsAgslMatrix (env, _a);
  
  const gsl_matrix * a;
  const gsl_vector * u;
  gsl_vector * v;

  dcloid (result);
  
  IntoGslMatrix (_a, a, env); /* grab the matrix */
  INTO_GSL_VECTOR (_u, u, env); /* grab the vector */
  
  /* allocate memory for result vector with a size the
     number of rows of `a'  */
  result = agsl_vector_make (env, mkinteger (a->size1));

  /* handle to result's underlying gsl vector */
  INTO_GSL_VECTOR (result, v, env);

  /* v <- u */
  gsl_vector_memcpy (v, u);

  /* returns general matrix-vector multiply */
  gsl_blas_dsymv (CblasLower, ALPHA1, a, u, BETA0, v);

  /* result contains vector `v' */
  return result;
}

/**
 * Compute the matrix-vector product x = op (A) x for the triangular
 * matrix A, where op (A) = A or A^T
 *
 * Variables
 *
 * y     result vector from AGSL from the equation above
 * yy    test vector GSL from the equation above
 *
 * Global Variables
 * b     agsl matrix `A' in the equation above
 * bb    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
oidtype
agsl_blas_dtrmv (bindtype env, const oidtype _a, const oidtype _u)
{
  const gsl_matrix * a;
  const gsl_vector * u;
  gsl_vector * v;

  dcloid (result);
  
  IntoGslMatrix (_a, a, env); /* grab the matrix */
  INTO_GSL_VECTOR (_u, u, env); /* grab the vector */
  
  /* allocate memory for result vector with a size the number of rows
     of `a'  */
  result = agsl_vector_make (env, mkinteger (a->size1));

  /* handle to results underlying gsl vector */
  INTO_GSL_VECTOR (result, v, env);

  /* v <- u */
  gsl_vector_memcpy (v, u);

  /* returns general matrix-vector multiply */
  gsl_blas_dtrmv (CblasLower, CblasNoTrans, CblasNonUnit, a, v);

  /* result contains vector `v' */
  return result;
}



/**
 * Compute the matrix-vector product x = op (A) x for the triangular
 * matrix A, where op (A) = A or A^T
 *
 * Variables
 *
 * y     result vector from AGSL from the equation above
 * yy    test vector GSL from the equation above
 *
 * Global Variables
 * b     agsl matrix `A' in the equation above
 * bb    test matrix `A'
 * u     agsl vector `u'
 * uu    test vector `u'
 */
oidtype
agsl_blas_dtrsv (bindtype env, const oidtype _a, const oidtype _u)
{
  const gsl_matrix * a;
  const gsl_vector * u;
  gsl_vector * v;

  dcloid (result);
  
  IntoGslMatrix (_a, a, env); /* grab the matrix */
  INTO_GSL_VECTOR (_u, u, env); /* grab the vector */
  
  /* allocate memory for result vector with a size the number of rows
     of `a'  */
  result = agsl_vector_make (env, mkinteger (a->size1));

  /* handle to results underlying gsl vector */
  INTO_GSL_VECTOR (result, v, env);

  /* v <- u */
  gsl_vector_memcpy (v, u);

  /* returns general matrix-vector multiply */
  gsl_blas_dtrsv (CblasLower, CblasNoTrans, CblasNonUnit, a, v);

  /* result contains vector `v' */
  return result;
}









/**********************************************************
 * Initialization
 **********************************************************/
void
agsl_blas_level2_register_functions ()
{
#ifdef VERBOSE
  printf ("agsl_blas_register_functions...\n");
#endif
  
  /* BLAS functions */
  extfunction2 ("agsl-blas-dgemv", agsl_blas_dgemv);
  extfunction2 ("agsl-blas-dsymv", agsl_blas_dsymv);
  extfunction2 ("agsl-blas-dtrmv", agsl_blas_dtrmv);
  extfunction2 ("agsl-blas-dtrsv", agsl_blas_dtrsv);

  return;
}
