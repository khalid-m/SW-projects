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
 * Solve the equation \alpha A B + \beta C = D for B.
 *
 * That is, for a square matrix system solve
 *
 *   \alpha LU B = D - \beta C for B
 *
 */
oidtype
agsl_linalg_solve (bindtype env,
                   const oidtype alpha,
                   const oidtype A,
                   const oidtype beta,
                   const oidtype C,
                   const oidtype D)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, C);
  IsAgslMatrix (env, D);
  
  if (ISLUDECOMP (A))
    {
      dcloid (B);
      
      /* solve */
      
      a_setf (B, agsl_linalg_LU_solve (env, alpha, A, beta, C, D));
      
      return B;
    }
  else if (ISCHOLESKY (A))
    {
      GSL_ERROR ("Haven't implemented for a cholesky decomposition yet",
                 GSL_EINVAL);
    }
  else if (ISSQUARE (A) && ISSQUARE (C)  && ISSQUARE (D)
           && ROWS (A) == ROWS (C) && ROWS (A) == ROWS (D))
    {
      /* try LU decomposition on square matrices */
      
      dcloid (LU);
      dcloid (B);

      a_setf (LU, agsl_linalg_LU_decomp (env, A));

      /* solve */
      
      a_setf (B, agsl_linalg_LU_solve (env, alpha, LU, beta, C, D));

      /* free LU */
      
      return B;
    }
  else 
    {
      GSL_ERROR ("Haven't implemented for a non square matrix system yet", GSL_EINVAL);
    }

}

                   
/**
 * Solve A B = C for B
 */
oidtype
agsl_linalg_solve_alpha_ab (bindtype env, const oidtype alpha, const oidtype A, const oidtype C)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, C);

  dcloid (B);

  /* C is general no trans, A is lu decomposed */
  if (ISLUDECOMP (A))
    {
      a_setf (B, agsl_linalg_LU_solve_alpha_ab (env,
                                                alpha, A, C));

      return B;
    }
  else if (ISCHOLESKY (A))
    {
      GSL_ERROR ("Haven't implemented for a cholesky decomposition yet",
                 GSL_EINVAL);
    }
  else if (ISSQUARE (A) && ISSQUARE (C) && ROWS (A) == ROWS (C))
    {
      /* try LU decomposition on square matrices */

      dcloid (AA);

      a_setf (AA, agsl_linalg_LU_decomp (env, A));

      a_setf (B, agsl_linalg_LU_solve_alpha_ab (env, alpha, AA, C));

      return B;
    }
  else
    {
      GSL_ERROR ("Matrix A is not decomposed and / or C is not \n\
general and not transposed - haven't implemented `solve' for \n \
any other case", GSL_EINVAL);
    }
}
