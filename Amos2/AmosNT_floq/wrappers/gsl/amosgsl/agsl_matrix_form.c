/* -*- c-basic-offset: 2; -*- 
 *
 * Transform logically stored matrices in-place.
 *
 * Description: A matrix may be tranposed, triangular,
 * symmetric or decomposed. Check these conditions and
 * transform data values of the logically typed matrix
 * in-place to the values they should be.
 *
 */
#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"


/**
 * Helper function: copy ones to the main diagonal of A. 
 */
void
gsl_matrix_set_unitary (gsl_matrix * A)
{
  gsl_vector_view diagA = gsl_matrix_diagonal (A);

  gsl_vector_set_all (&diagA.vector, ALPHA1);
}

/**
 * Make a copy of matrix A. This one is the interface to the
 * other more specific versions of memcpy.
 **/
int
agsl_matrix_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  /*
   * Copy the logical matrix into a generalized
   *
   * Order is important since
   *
   * - a decomposed matrix may be symmetric (cholesky)
   *
   * - a symmetric matrix stores data in upper or lower
   *
   */
  if (ISDECOMPOSED (A))
    {
      /* don't do anything with a decomposed matrix, just
         print it DEBUG should tell us that! */
      /* agsl_matrix_recomp_form (env, A); */
    }
  else if (ISSYMMETRIC (A))
    {
      agsl_matrix_symmetric_form (env, A);
    }
  else if (ISTRIANGULAR (A))
    {
      agsl_matrix_triangular_form (env, A);
    }
  else if (ISTRANSPOSE (A))
    {
      agsl_matrix_transpose_form (env, A);
    }
  else if (ISUNITARY (A))
    {
      gsl_matrix_set_unitary (matrix (A));
    }

  return GSL_SUCCESS;
}

/**
 * Make a generalized triangular matrix from a possibly
 * logically triangular matrix. If given matrix is not
 * triangular, make a lower triangular matrix.
 */
int
agsl_matrix_triangular_form (bindtype env, oidtype T)
{
  IsAgslMatrix(env, T);
  
  if (ISSYMMETRIC (T))
    {
      GSL_ERROR ("Matrix is symmetric, try symmetric_form",
                 GSL_EINVAL);
    }
  else if (!(ISUPPER (T) || ISLOWER (T)))
    {
      GSL_ERROR ("Matrix is not upper / lower, try agsl_matrix_form",
                 GSL_EINVAL);
    }
  else if (ISUPPERTRI (T))
    {
      /* make an upper triangular matrix */

      agsl_matrix_upper_form (env, T);

      return GSL_SUCCESS;
    }
  else if (ISLOWERTRI (T))
    {
      /* make an lower triangular matrix */

      agsl_matrix_lower_form (env, T);

      return GSL_SUCCESS;
    }
  else
    {
      GSL_ERROR ("Unknown error occurred", GSL_FAILURE);
    }
}

/**
 * Make a generalized diagonal matrix from a logically
 * diagonal matrix.
 */
int
agsl_matrix_diagonal_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  gsl_matrix * d = gsl_matrix_alloc (ROWS (A), COLS (A));

  gsl_matrix_set_identity (d);

  if (!ISUNITARY (A))
    {
      gsl_matrix_diagonal_memcpy (d, matrix (A));
    }
  else
    {
      SETUNITARY (A);
    }
  /* replace matrix with diagonal matrix */

  matrix (A) = d;

  UNSETUPLO (A); UNSETTRANSPOSE (A); UNSETSYMMETRIC (A);

  SETDIAGONAL (A);
  
  return GSL_SUCCESS;
}


/**
 * Make a generalized transposed matrix from a logically
 * transposed matrix.
 */
int
agsl_matrix_transpose_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (ISDECOMPOSED (A))
    {
      GSL_ERROR ("Cannot transpose a decomposed matrix",
                 GSL_EINVAL);
    }
  else if (!ISTRANSPOSE (A))
    {
      GSL_ERROR ("Matrix is not transposed", GSL_EINVAL);
    }
  else if (!ISGENERAL (A))
    {
      GSL_ERROR ("Matrix is not general", GSL_EINVAL);
    }
  else 
    {
      gsl_matrix_transpose (matrix (A));

      UNSETTRANSPOSE (A);
      
      /* set ones on diagonal if matrix is unitary */

      if (ISUNITARY (A))
        {
          gsl_matrix_set_unitary (matrix (A));
        }
      
      return GSL_SUCCESS;
    }
}




/**
 * Lower triangular matrix of given matrix.
 *
 * @param A the matrix 
 * @return   lower-triangular part of A
 */
int
agsl_matrix_lower_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  dcloid (AA);

  if (ISGENERALTRANS (A))
    {
      SETUPPER (A);
    }
  else if (ISLUDECOMP (A))
    {
      /* grab L instead */
      
      SETLOWER (A); UNSETTRANSPOSE (A); SETUNITARY (A);
    }
  else if (ISSYMMETRICLO (A))
    {
      UNSETTRANSPOSE (A); /* shouldn't be transposed anyway */
    }
  else if (ISSYMMETRICUP (A))
    {
      SETTRANSPOSE (A);
    }

  /* make AA for diagonal and upper triangular matrices */

  if (ISUPPERTRI (A) || ISDIAGONAL (A))
    {
      a_setf (AA, agsl_matrix_identity (env,
                                        mkinteger(ROWS (A)),
                                        mkinteger(COLS (A))));
      
      if (ISUNITARY (A))
        {
          SETUNITARY (A);
        }
      else
        {
          gsl_matrix_diagonal_memcpy (matrix (AA), matrix (A));
        }

      SETDIAGONAL (A);
    }
  else
    {
      a_setf (AA, agsl_blas_dtrmm_alpha_a (env, mkreal (ALPHA1), A));
    }
  
  /* A <- AA */
  
  matrix (A) = matrix (AA);
  
  SETLOWER (A);
  UNSETTRANSPOSE (A);
  
  return GSL_SUCCESS;
}

/**
 * Create upper-triangular matrix from the given matrix.
 *
 * @param A the matrix 
 * @return   upper-triangular part of A
 */
int
agsl_matrix_upper_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);
  
  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {
      dcloid (U);

      if (ISGENERALNOTRANS (A) || ISLUDECOMP (A))
        {
          /* take upper triangular part of A for decomposed
             and general matrices */

          SETUPPER (A); UNSETTRANSPOSE (A);
        }
      else if (ISSYMMETRICLO (A) || ISGENERALTRANS (A))
        {
          /* take lower triangular part of A and transpose it
             for lower symmetric and general transposed
             matrices */

          SETLOWER (A); SETTRANSPOSE (A);
        }
      else if (ISSYMMETRICUP (A))
        {
          /* make sure upper symmetric matrix A is not
             transposed */
          
          UNSETTRANSPOSE (A);
        }

      /* make U for diagonal and lower triangular matrices */

      if (ISLOWERTRI (A) || ISDIAGONAL (A))
        {
          a_setf (U, agsl_matrix_identity (env,
                                           mkinteger (ROWS (A)),
                                           mkinteger (COLS (A))));
      
          if (ISUNITARY (A))
            {
              SETUNITARY (A);
            }
          else
            {
              gsl_matrix_diagonal_memcpy (matrix (U), matrix (A));
            }

          SETDIAGONAL (A);
        }
      else
        {
          a_setf (U, agsl_blas_dtrmm_alpha_a (env, mkreal (ALPHA1), A));
        }
  
      /* A <- U */

      matrix (A) = matrix (U);  

      /* resulting matrix is upper triangular */
      UNSETTRANSPOSE (A);

      SETUPPER (A);

      return GSL_SUCCESS;
    }
}

/**
 * Create a symmetric matrix from the given matrix A. If A
 * is lower triangular copy lower triangular part to upper
 * triangular part. If A is upper triangular do the
 * opposite.
 *
 * @param A the matrix 
 * @return  symmetric matrix of A
 * @see     agsl_matrix_symmetric_copy
 */
int
agsl_matrix_symmetric_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {
      dcloid (S);
      
      if (ISDECOMPOSED (A))
        {
          /* form decomposed symmetric matrix A */

          agsl_matrix_decomp_form (env, A);
        }
      else if (ISUNITARY (A))
        {
          /* write ones on the main diagonal */

          gsl_matrix_set_unitary (matrix (A));
        }

      if (ISDIAGONAL (A))
        {
          /* A is a diagonal matrix */

          a_setf (S, agsl_matrix_identity (env,
                                           mkinteger (ROWS (A)),
                                           mkinteger (COLS (A))));

          if (ISUNITARY (A))
            {
              SETUNITARY (A);
            }
          else
            {
              gsl_matrix_diagonal_memcpy (matrix (S), matrix (A));
            }

          SETDIAGONAL (A);
        }
      else 
        {
          /* A is general, lower or upper. dsymm uses upLo to
             choose which part to use for the soon to be
             symmetrical matrix */
      
          a_setf (S, agsl_blas_dsymm_alpha_a (env, mkreal (ALPHA1), A));

          /* matrix is symmetric , point to data in the lower triangle */

          SETSYMMETRICLO (A);
        }

      /* A <-- S */

      matrix (A) = matrix (S);

      return GSL_SUCCESS;
    }
}


/**
 * Make a generalized matrix A out of given decomposed
 * matrices.
 */
int
agsl_matrix_recomp_form (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISDECOMPOSED (A))
    {
      GSL_ERROR ("Can't recomp a non decomposed matrix",
                 GSL_EINVAL);
    }
  else if (ISLUDECOMP (A))
    {
      agsl_linalg_LU_rcmp (env, A);
    }
  else if (ISCHOLESKY (A))
    {
      GSL_ERROR ("Cholesky recomp not implemented",
                 GSL_EINVAL);
      /* agsl_linalg_chol_rcmp (env, A); */
    }
  else if (ISQRDECOMP (A))
    {
      GSL_ERROR ("QR recomp not implemented",
                 GSL_EINVAL);
      /* agsl_linalg_qr_rcmp (env, A); */
    }

  return GSL_SUCCESS;
}


/**
 * Decompose matrix A into LU, QR, Cholesky depending on
 * type of matrix.
 *
 * Choice order: cholesky (symm), lu (square), qr
 *               (rectangular)
 */
int
agsl_matrix_decomp_form (bindtype env, oidtype A)
{
  if (ISDECOMPOSED (A))
    {
      GSL_ERROR ("Matrix is already decomposed, can't do it again",
                 GSL_EINVAL);
    }
  else if (ISSYMMETRIC (A))
    {
      GSL_ERROR ("Cholesky recomp not implemented yet",
                 GSL_EINVAL);

      /* dcloid (LU); */
      /* agsl_linalg_chol_dcmp (env, A); */
      /* return C; */
    }
  else if (ISSQUARE (A))
    {
      /* LU decomposition if A is square */

      agsl_linalg_LU_dcmp (env, A);

      return GSL_SUCCESS;
    }
  else 
    {
      GSL_ERROR ("Other decomp's not implemented",
                 GSL_EINVAL);
    }
}


