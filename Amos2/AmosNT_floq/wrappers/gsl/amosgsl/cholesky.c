/* -*- c-basic-offset: 2; -*- 
 *
 * Description:  BLAS and GSL Storage Type Initialization and Creation
 *
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"


/**
 *
 */
oidtype
agsl_linalg_cholesky_decomp (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("Cholesky decomposition requires a square matrix", GSL_ENOTSQR);
    }
  else
    {
      dcloid (CHOL);

      a_setf (CHOL, agsl_matrix_copy (env, A));

      if (GSL_SUCCESS != agsl_linalg_cholesky_dcmp (env, CHOL))
        {
          GSL_ERROR ("Failed to do Cholesky decomposition on matrix",
                     GSL_FAILURE);
        }

      return CHOL;
    }
}



/**
 * Decompose matrix A in place.
 *
 */
int
agsl_linalg_cholesky_dcmp (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("Cholesky decomposition requires a square matrix",
                 GSL_ENOTSQR);
    }
  else
    {
      /* generalize matrix - easy but wasteful since gsl
         cholesky decomposition uses only the lower triangular
         and diagonal parts of the matrix */
      
      agsl_matrix_form (env, A);
      
      if (GSL_SUCCESS != gsl_linalg_cholesky_decomp (matrix (A)))
        {
          GSL_ERROR ("Cholesky decomposition failed", GSL_EINVAL);
        }

      SETCHOLESKY (A);

      return GSL_SUCCESS;
    }
}



/**
 *
 */
oidtype
agsl_linalg_cholesky_recomp (bindtype env, oidtype CHOL)
{
  IsAgslMatrix (env, CHOL);

  GSL_ERROR ("Not written yet", GSL_EINVAL);
  
  if (!ISLUDECOMP (CHOL))
    {
      GSL_ERROR ("Matrix not LU decomposed!", GSL_EINVAL);
    }
  else
    {
      dcloid (A);
  
      a_setf (A, agsl_matrix_softcopy (env, CHOL));

      agsl_linalg_LU_rcmp (env, A);

      return A;
    }
}

int
agsl_linalg_cholesky_rcmp (bindtype env, oidtype CHOL)
{
  IsAgslMatrix (env, CHOL);

  GSL_ERROR ("Not written yet", GSL_EINVAL);

  if (!ISLUDECOMP (CHOL))
    {
      GSL_ERROR ("Matrix not LU decomposed!", GSL_EINVAL);
    }
  else
    {
      dcloid (A);
  
      a_setf (A, agsl_matrix_upper_copy (env, CHOL));

      if (GSL_SUCCESS == gsl_blas_dtrmm (CblasLeft,
                                         CblasLower,
                                         GETTRANSPOSE (CHOL),
                                         CblasUnit,
                                         ALPHA1,
                                         matrix (CHOL),
                                         matrix (A)));

      /* Apply inverse permutation P on A = L U */
      if (GSL_SUCCESS !=
          gsl_permute_matrix_inverse (gslperm (CHOL), matrix (A)))
        {
          GSL_ERROR ("Applying inverse-permutation to matrix failed",
                     GSL_FAILURE);
        }
      else
        {
          matrix (CHOL) = matrix (A);

          UNSETDECOMP (CHOL);
          
          return GSL_SUCCESS;
        }
    }
}



/**
 *
 */
oidtype
agsl_linalg_cholesky_solve_alpha_ab
(bindtype env, const oidtype alpha, const oidtype CHOL, const oidtype C)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, CHOL);
  IsAgslMatrix (env, C);

  if (!ISCHOLESKY (CHOL))
    {
      GSL_ERROR ("matrix A must be Cholesky decomposed", GSL_EINVAL);
    }
  if (ROWS (CHOL) != COLS (CHOL))
    {
      GSL_ERROR ("Cholesky matrix must be square", GSL_ENOTSQR);
    }
  else if (ROWS (CHOL) != ROWS (C))
    {
      GSL_ERROR ("Cholesky matrix row size must match rhs row size", GSL_EBADLEN);
    }
  else
    {
      dcloid (B);

      double alphainv = coerce_real (env, alpha);

      if (alphainv != ALPHA1 && alphainv != BETA0)
        {
          alphainv = 1 / alphainv;
        }

      /* Copy B <- C */

      a_setf (B, agsl_matrix_copy (env, C));

      /* Solve for D using forward-substitution, L D = B */

      gsl_blas_dtrsm (CblasLeft, CblasLower, CblasNoTrans, CblasNonUnit, alphainv, matrix (CHOL), matrix (B));

      /* Perform back-substitution, U B = D */

      gsl_blas_dtrsm (CblasLeft, CblasUpper, CblasNoTrans, CblasNonUnit, ALPHA1, matrix (CHOL), matrix (B));

      return B;
    }
}
