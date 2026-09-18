/* -*- c-basic-offset: 2; -*- 
 *
 * Solve
 *
 *   A B = C
 *
 *     for B with logically typed matrices A and C
 *
 * Description: Matrix A may be tranposed, triangular,
 * symmetric or decomposed. Check these conditions and
 * solve A B = C for B 
 *
 */
#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"

/**
 * Decompose A, choose decomposition depending on matrix
 * structure
 */
oidtype
agsl_linalg_decomp (bindtype env,
                    const oidtype A)
{
  IsAgslMatrix (env, A);
  
  if (ISDECOMPOSED (A))
    {
      GSL_ERROR ("Matrix already decomposed", GSL_EINVAL);
    }
  else if (ISSYMMETRIC (A))
    {
      /* test positive definiteness too */
      GSL_ERROR ("Haven't implemented for a cholesky decomposition yet",
                 GSL_EINVAL);
    }
  /* else if (ROWS (A) >> COLS (A) || COLS (A) >> ROWS (A)) */
  /*   { */
  /*     /\* test positive definiteness too *\/ */
  /*     GSL_ERROR ("Haven't implemented for QR decomposition yet", */
  /*                GSL_EINVAL); */
  /*   } */
  else if (ISSQUARE (A))
    {
      /* try LU decomposition on square matrices */
      
      dcloid (LU);

      a_setf (LU, agsl_linalg_LU_decomp (env, A));

      return LU;
    }
  else 
    {
      GSL_ERROR ("No decomp for non-square matrix system yet",
                 GSL_EINVAL);
    }

}

