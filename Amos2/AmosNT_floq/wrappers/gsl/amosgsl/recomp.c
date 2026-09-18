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
 * Recompose A
 */
oidtype
agsl_linalg_recomp (bindtype env,
                    const oidtype A)
{
  IsAgslMatrix (env, A);
  
  if (!ISDECOMPOSED (A))
    {
      GSL_ERROR ("Matrix not decomposed", GSL_EINVAL);
    }
  else if (ISCHOLESKY (A))
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
  else if (ISLUDECOMP (A))
    {
      /* try LU decomposition on square matrices */
      
      dcloid (B);

      a_setf (B, agsl_linalg_LU_recomp (env, A));

      return B;
    }
  else 
    {
      GSL_ERROR ("Cannot recompose other matrix systems yet",
                 GSL_EINVAL);
    }

}

