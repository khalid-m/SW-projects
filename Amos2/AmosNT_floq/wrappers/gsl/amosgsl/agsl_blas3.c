/** -*- c-basic-offset: 2; -*- 
 *
 * $Description:  Selected BLAS Level 3 Operations for AmosGSL$
 *
** TODO B unchecked for matrix type
 * None of these functions ensure we're using the 
 * appropriate values for B. Need to check type and if it is
 * transposed and memcpy if nessessary. 
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"


/**
 * \alpha A B + \beta C = D.
 *
 * @see agsl_blas_dgmm
 */
oidtype
agsl_blas_dgemm (bindtype env,
                 const oidtype alpha,
                 const oidtype A,
                 const oidtype B,
                 const oidtype beta,
                 const oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);
  IsAgslMatrix (env, C);


  if (COLS (A) != ROWS (B))
    {
      GSL_ERROR ("Columns of A and rows of B must match", GSL_EBADLEN);
    }
  else if (ROWS (A) != ROWS (C) || COLS (B) != COLS (C))
    {
      GSL_ERROR ("C and product A B sizes must match", GSL_EBADLEN);
    }
  else
    {
      dcloid (D);
  
      /* d <- c */
      a_setf (D, agsl_matrix_copy (env, C));
      
      agsl_blas_dgmm (env, alpha, A, B, beta, D);
  
      return D;
    }
}



/**
 * BLAS LEVEL 3 OPERATIONS
 *
 **/

/**
 * BLAS DGEMM operation, uses gsl_blas_dgemm
 *
 * These functions compute the matrix-matrix product and sum
 *
 * C = \alpha op (A) op (B) + \beta C
 *
 * where op (A) = A, A^T, A^H for TransA = CblasNoTrans,
 * CblasTrans and similarly for the parameter TransB.
 *
 */
int
agsl_blas_dgmm (bindtype env,
                const oidtype alpha,
                const oidtype A,
                const oidtype B,
                const oidtype beta,
                oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);
  IsAgslMatrix (env, C);

  if (COLS (A) != ROWS (B))
    {
      GSL_ERROR ("Columns of A and rows of B must match", GSL_EBADLEN);
    }
  else if (ROWS (A) != ROWS (C) || COLS (B) != COLS (C))
    {
      GSL_ERROR ("C and product A B sizes must match", GSL_EBADLEN);
    }
  else
    {
      dcloid (BB);

      int status;

      /* make a copy of B / C if not general */

      a_setf (BB, (ISGENERAL (B) ? B : agsl_matrix_copy (env, B)));

      /* form C in place */
      
      if (!ISGENERALNOTRANS (C))
        {
          agsl_matrix_form (env, C);
        }
  
      status = gsl_blas_dgemm (GETTRANSPOSE (A),
                               GETTRANSPOSE (B),
                               coerce_real (env, alpha),
                               matrix (A),
                               matrix (BB),
                               coerce_real (env, beta),
                               matrix (C));

      /* agsl_matrix_deallocate (BB); */

      if (status != GSL_SUCCESS)          
        {
          GSL_ERROR ("Unsuccessful dgemm", status);
        }
      else
        {
          return GSL_SUCCESS;
        }
    }
}



/**
 * This is a special case of the full DGEMM equation
 *
 *   \alpha A B + \beta C,
 *
 * for when \beta is zero or C is the zero matrix.
 *
 * @see agsl_blas_dgmm
 */
oidtype
agsl_blas_dgemm_alpha_ab (bindtype env,
                          const oidtype alpha,
                          const oidtype A,
                          const oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  if (COLS (A) != ROWS (B))
    {
      GSL_ERROR ("Columns of A and rows of B must match", GSL_EBADLEN);
    }
  else
    {
      dcloid (C);

      int status;

      /* C is an allocated matrix the size of the product A B */
  
      a_setf (C, agsl_matrix_new (ROWS (A), COLS (B)));

      status = agsl_blas_dgmm (env, alpha, A, B, mkreal (BETA0), C);

      if (GSL_SUCCESS != status)
        {
          GSL_ERROR ("agsl_blas_dgmm for `alpha_ab' failed", GSL_EINVAL);
        }
      else
        {
          return C;
        }
    }
}


/**
 * Compute the matrix sum 
 *
 * C = \alpha A + \beta C
 *
 * where A is general. On output C is overwritten with the
 * product.
 */
int
agsl_blas_dgmm_alpha_a_beta_c (bindtype env,
                               const oidtype alpha,
                               const oidtype A,
                               const oidtype beta,
                               oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, C);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (ROWS (A) != ROWS (C) || COLS (A) != COLS (C))
    {
      GSL_ERROR ("C and A sizes must match", GSL_EBADLEN);
    }
  else
    {
      /* \alpha A I + \beta C, I is the identity matrix */

      gsl_matrix * I = gsl_matrix_alloc (COLS (A), ROWS (A));
      
      gsl_matrix_set_identity (I);

      if (GSL_SUCCESS != gsl_blas_dgemm (GETTRANSPOSE (A),
                                         CblasNoTrans,
                                         coerce_real (env, alpha),
                                         matrix (A),
                                         I,
                                         coerce_real (env, beta),
                                         matrix (C)))
        {
          gsl_matrix_free (I);
          
          GSL_ERROR ("GSL DGEMM failed", GSL_FAILURE);
        }    
      else
        {
          gsl_matrix_free (I);

          return GSL_SUCCESS;
        }
    }
}





/**
 * Compute a A = B for general matrix A
 *
 */
oidtype
agsl_blas_dgemm_alpha_a (bindtype env,
                         const oidtype alpha,
                         const oidtype A)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);

  dcloid (B);
  
  /* create and allocate a new matrix */
  a_setf (B, agsl_matrix_new (ROWS (A), COLS (A)));

  if (GSL_SUCCESS != agsl_blas_dgmm_alpha_a_beta_c
      (env, alpha, A, mkreal (BETA0), B))
    {
      agsl_matrix_deallocate (B);
      
      GSL_ERROR ("dgemm did not succeed", GSL_EINVAL);
    }    
  else
    {
      return B;
    }
}


/**
 * BLAS DSYMM operation, using gsl_blas_dsymm
 *
 * Compute the matrix-matrix product and sum
 *
 * D = \alpha A B + \beta C
 *
 * for D where the matrix A is symmetric.
 */
oidtype
agsl_blas_dsymm (bindtype env,
                 const oidtype alpha,
                 const oidtype A,
                 const oidtype B,
                 const oidtype beta,
                 oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);

  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);
  IsAgslMatrix (env, C);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (ROWS (A) != ROWS (C) || COLS (B) != COLS (C))
    {
      GSL_ERROR ("C and product A B sizes must match", GSL_EBADLEN);
    }
  else
    {
      dcloid (D);
 
      /* D <- C */
      
      a_setf (D, agsl_matrix_copy (env, C));

      if (GSL_SUCCESS != agsl_blas_dsmm (env, alpha, A, B, beta, D))
        {
          GSL_ERROR ("agsl_blas_dsmm failed", GSL_EINVAL);
        }
      else
        {
          return C;
        }
    }
}



/**
 * BLAS DSYMM operation, using gsl_blas_dsymm
 *
 * Compute the matrix-matrix product and sum 
 *
 * C = \alpha A B + \beta C
 *
 * where the matrix A is symmetric. On output C is overwritten
 * with the product.
 */
int
agsl_blas_dsmm (bindtype env,
                const oidtype alpha,
                const oidtype A,
                const oidtype B,
                const oidtype beta,
                oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);

  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);
  IsAgslMatrix (env, C);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (ROWS (A) != ROWS (C) || COLS (B) != COLS (C))
    {
      GSL_ERROR ("C and product A B sizes must match", GSL_EBADLEN);
    }
  else
    {
      if (GSL_SUCCESS != gsl_blas_dsymm (CblasLeft,
                                         GETUPLO (A),
                                         coerce_real (env, alpha),
                                         matrix (A),
                                         matrix (B),
                                         coerce_real (env, beta),
                                         matrix (C)))
        {
          GSL_ERROR ("GSL DSYMM failed", GSL_FAILURE);
        }    
      else
        {
          return GSL_SUCCESS;
        }
    }
}

/**
 * Compute the matrix sum 
 *
 * C = \alpha A + \beta C
 *
 * where the matrix A is symmetric. On output C is overwritten
 * with the product.
 */
int
agsl_blas_dsmm_alpha_a_beta_c (bindtype env,
                               const oidtype alpha,
                               const oidtype A,
                               const oidtype beta,
                               oidtype C)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, C);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (ROWS (A) != ROWS (C) || COLS (A) != COLS (C))
    {
      GSL_ERROR ("C and A sizes must match", GSL_EBADLEN);
    }
  else
    {
      /* \alpha A I + \beta C, I is the identity matrix */

      gsl_matrix * I = gsl_matrix_alloc (COLS (A), ROWS (A));
      
      gsl_matrix_set_identity (I);

      if (GSL_SUCCESS != gsl_blas_dsymm (CblasLeft,
                                         GETUPLO (A),
                                         coerce_real (env, alpha),
                                         matrix (A),
                                         I,
                                         coerce_real (env, beta),
                                         matrix (C)))
        {
          gsl_matrix_free (I);
          
          GSL_ERROR ("GSL DSYMM failed", GSL_FAILURE);
        }    
      else
        {
          gsl_matrix_free (I);

          return GSL_SUCCESS;
        }
    }
}


/**
 * For solving the equation: a A B
 *
 * Note this is simpler than the full dsymm equation. It is
 * for cases in which \beta is zero or we wish not to add an
 * additional third matrix.
 *
 */
oidtype
agsl_blas_dsymm_alpha_ab (bindtype env,
                          const oidtype alpha,
                          const oidtype A,
                          const oidtype B)
{
  IsNumber (env, alpha);

  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  dcloid (C);

  /* C is an allocated matrix the size of the product A B */
  
  a_setf (C, agsl_matrix_new (ROWS (A), COLS (B)));
  
  if (GSL_SUCCESS != agsl_blas_dsmm (env, alpha, A, B, mkreal (BETA0), C))
    {
      GSL_ERROR ("agsl_blas_dsmm for `alpha_ab' failed", GSL_EINVAL);
    }
  else
    {
      return C;
    }
}


/**
 * Compute a A = B for symmetric matrix A
 *
 */
oidtype
agsl_blas_dsymm_alpha_a (bindtype env,
                         const oidtype alpha,
                         const oidtype A)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);

  dcloid (B);
  
  /* create and allocate a new matrix */
  a_setf (B, agsl_matrix_new (ROWS (A), COLS (A)));

  if (GSL_SUCCESS != agsl_blas_dsmm_alpha_a_beta_c
      (env, alpha, A, mkreal (BETA0), B))
    {
      agsl_matrix_deallocate (B);
      
      GSL_ERROR ("dsymm did not succeed", GSL_EINVAL);
    }    
  else
    {
      SETSYMMETRICLO (B);
      
      return B;
    }
}



/**
 * BLAS DTRMM operation, using gsl_blas_dtrmm
 *
 * Note: matrices a, b and c must have dimensions s.t. ab = c is
 * possible
 *
 * Example of matrix multiplication
 *
 *  [ 0.11 0.12 0.13 ]  [ 1011 1012 ]     [ 367.76 368.12 ]
 *  [ 0.21 0.22 0.23 ]  [ 1021 1022 ]  =  [ 674.06 674.72 ]
 *                      [ 1031 1032 ]
 *
 * Compute the matrix-matrix product B = \alpha op (A) B for
 * Side is CblasLeft and B = \alpha B op (A) for Side is
 * CblasRight. The matrix A is triangular and op (A) = A,
 * A^T
 *
 */
oidtype
agsl_blas_dtrmm (bindtype env,
                 const oidtype alpha,
                 const oidtype A,
                 const oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (B))
    {
      GSL_ERROR ("B is not square", GSL_ENOTSQR);
    }
  else
    {
      dcloid (C);
  
      a_setf (C, agsl_matrix_copy (env, B));

      if (GSL_SUCCESS != agsl_blas_dtmm (env, alpha, A, C))
        {
          GSL_ERROR ("GSL DTRMM failed", GSL_FAILURE);
        }
      else
        {
          return C;
        }
    }
}


/**
 * Matrix-matrix product A B = B in place for A triangular and
 * B general.
 *
 */
int
agsl_blas_dtmm (bindtype env,
                const oidtype alpha,
                const oidtype A,
                oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (B))
    {
      GSL_ERROR ("B is not square", GSL_ENOTSQR);
    }
  else
    {
      if (GSL_SUCCESS != gsl_blas_dtrmm (CblasLeft,
                                         GETUPLO (A),
                                         GETTRANSPOSE (A),
                                         GETUNITARY (A),
                                         getreal (alpha),
                                         matrix (A),
                                         matrix (B)))
        {
          GSL_ERROR ("GSL DTRMM failed", GSL_FAILURE);
        }
      else
        {
          return GSL_SUCCESS;
        }
    }
}


/**
 * Scalar-Matrix product \alpha A = B where A is triangular
 *
 */
oidtype
agsl_blas_dtrmm_alpha_a (bindtype env,
                         const oidtype alpha,
                         const oidtype A)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {
      dcloid (B);

      /* NOTE: good practice to set identity size as that of A
         transposed (A is MxN, I should be NxM) */
      a_setf (B, agsl_matrix_identity (env,
                                       mkinteger (COLS (A)),
                                       mkinteger (ROWS (A))));

      if (GSL_SUCCESS != agsl_blas_dtmm (env, alpha, A, B))
        {
          GSL_ERROR ("GSL DTRMM for B <- A B failed", GSL_FAILURE);
        }
      else
        {
          return B;
        }
    }
}



/**
 * BLAS DTRSM operation, using gsl_blas_dtrsm
 *
 * Note: matrices a, b and c must have dimensions s.t. ab = c is
 * possible
 *
 * Example of matrix multiplication
 *
 *  [ 0.11 0.12 0.13 ]  [ 1011 1012 ]     [ 367.76 368.12 ]
 *  [ 0.21 0.22 0.23 ]  [ 1021 1022 ]  =  [ 674.06 674.72 ]
 *                      [ 1031 1032 ]
 *
 * Compute the inverse-matrix matrix product B = \alpha op
 * (inv (A))B for Side is CblasLeft and B = \alpha B op (inv
 * (A)) for Side is CblasRight. The matrix A is triangular
 * and op (A) = A, A^T, A^H for TransA = CblasNoTrans,
 * CblasTrans, CblasConjTrans. When Uplo is CblasUpper then
 * the upper triangle of A is used, and when Uplo is
 * CblasLower then the lower triangle of A is used. If Diag
 * is CblasNonUnit then the diagonal of A is used, but if
 * Diag is CblasUnit then the diagonal elements of the
 * matrix A are taken as unity and are not referenced.
 */
oidtype
agsl_blas_dtrsm (bindtype env,
                 const oidtype alpha,
                 const oidtype A,
                 const oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (B))
    {
      GSL_ERROR ("B is not square", GSL_ENOTSQR);
    }
  else
    {
      dcloid (C);

      /* c <- b */
      a_setf (C, agsl_matrix_copy (env, B));

      if (GSL_SUCCESS != agsl_blas_dtsm (env, alpha, A, C))
        {
          GSL_ERROR ("GSL DTRMM failed", GSL_FAILURE);
        }
      else
        {
          return C;
        }
    }
}


/**
 * Solve B <-- \alpha A B = C for B in place.
 * 
 * @see agsl_blas_dtrsm
 */
int
agsl_blas_dtsm (bindtype env,
                const oidtype alpha,
                const oidtype A,
                oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, A);
  IsAgslMatrix (env, B);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (B))
    {
      GSL_ERROR ("B is not square", GSL_ENOTSQR);
    }
  else
    {
      if (GSL_SUCCESS != gsl_blas_dtrsm (CblasLeft,
                                         GETUPLO (A),
                                         GETTRANSPOSE (A),
                                         GETUNITARY (A),
                                         getreal (alpha),
                                         matrix (A),
                                         matrix (B)))
        {
          GSL_ERROR ("GSL DTRSM failed", GSL_FAILURE);
        }
      else
        {
          return GSL_SUCCESS;
        }
    }
}


/**********************************************************
 * Initialization
 **********************************************************/
void
agsl_blas_level3_register_functions ()
{
#ifdef VERBOSE
  printf ("agsl_blas_register_functions...\n");
#endif

  /* BLAS functions */
  extfunction5 ("agsl-blas-dgemm", agsl_blas_dgemm);
  extfunction3 ("agsl-blas-dgemm-alpha-ab", agsl_blas_dgemm_alpha_ab);
  extfunction2 ("agsl-blas-dgemm-alpha-a", agsl_blas_dgemm_alpha_a);

  extfunction5 ("agsl-blas-dsymm", agsl_blas_dsymm);
  extfunction3 ("agsl-blas-dsymm-alpha-ab", agsl_blas_dsymm_alpha_ab);
  extfunction2 ("agsl-blas-dsymm-alpha-a", agsl_blas_dsymm_alpha_a);

  extfunction3 ("agsl-blas-dtrmm", agsl_blas_dtrmm);
  extfunction2 ("agsl-blas-dtrmm-alpha-a", agsl_blas_dtrmm_alpha_a);
  
  extfunction3 ("agsl-blas-dtrsm", agsl_blas_dtrsm);

  
  return;
}
