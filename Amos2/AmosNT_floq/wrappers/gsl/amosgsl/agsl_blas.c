/** -*- c-basic-offset: 2; -*- 
 *
 * $Description:  BLAS Initialization and Creation $
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
 * BLAS LEVEL 1 OPERATIONS
 *
 */

/**
 * BLAS DDOT operation, using gsl_blas_ddot
 *
 * Note: vectors u, v must have the same length
 */
oidtype
agsl_blas_ddot (bindtype env, const oidtype _u, const oidtype _v)
{
  const gsl_vector * u;
  const gsl_vector * v;
  double dot_product;

  INTO_GSL_VECTOR (_u, u, env);
  INTO_GSL_VECTOR (_v, v, env);

  /* Function returns GSL_SUCCESS */
  gsl_blas_ddot (u, v, &dot_product);

  return mkreal (dot_product);
}


/**
 * vector euclidean norm
 *
 * @param env Holds environment
 * @param _u  The vector to calculate norm for
 * @return    The norm of vector u
 */
oidtype
agsl_blas_dnorm (bindtype env, const oidtype _u)
{
  const gsl_vector * u;
  double norm;

  INTO_GSL_VECTOR (_u, u, env);

  /* returns norm of vector u */
  norm = gsl_blas_dnrm2 (u);

  return mkreal (norm);
}

/**
 * absolute sum
 *
 * @param env Holds environment
 * @param _u  The vector to calculate absolute sum
 * @return    The absolute sum
 */
oidtype
agsl_blas_dasum (bindtype env, const oidtype _u)
{
  const gsl_vector * u;
  double asum;
  
  INTO_GSL_VECTOR (_u, u, env);

  /* returns the absolute sum */
  asum = gsl_blas_dasum (u);

  return mkreal (asum);
}




/**********************************************************
 * Initialization
 **********************************************************/
void
agsl_blas_level1_register_functions ()
{
#ifdef VERBOSE
  printf ("agsl_blas_register_functions...\n");
#endif
  
  /* BLAS functions */
  extfunction2 ("agsl-blas-ddot", agsl_blas_ddot);
  extfunction1 ("agsl-blas-dnorm", agsl_blas_dnorm);
  extfunction1 ("agsl-blas-dasum", agsl_blas_dasum);

  return;
}
