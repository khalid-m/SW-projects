/* -*- c-basic-offset: 2; -*- 
 *
 * `memcpy' for logically stored matrix
 *
 * Description: A matrix may be tranposed, triangular,
 * symmetric or decomposed. Check these conditions and
 * transform data in a copy of the logically typed matrix to
 * the values they should be.
 *
 */
#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"

/**
 * Helper function: copy the diagonal of A to D 
 */
int
gsl_matrix_diagonal_memcpy (gsl_matrix * D, const gsl_matrix * A)
{
  gsl_vector_const_view diagA = gsl_matrix_const_diagonal (A);
  gsl_vector_view diagD = gsl_matrix_diagonal (D);

  return gsl_vector_memcpy (&diagD.vector, &diagA.vector);
}

/**
 * General matrix copy, does not accept any other type but may
 * be unitary.
 */
oidtype
agsl_matrix_general_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISGENERALNOTRANS (A))
    {
      GSL_ERROR ("Matrix is not general", GSL_EINVAL);
    }
  else
    {
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, B));
  
      agsl_matrix_form (env, B);
  
      return B;
    }
}


/**
 * Make a copy of matrix A. This one is the interface to the
 * other more specific versions of memcpy.
 **/
oidtype
agsl_matrix_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, A));

      agsl_matrix_form (env, B);
      
      return B;
    }
}




/**
 * Make a hard copy triangular matrix from a possibly
 * logically triangular matrix. If given matrix is not
 * triangular, make a lower triangular matrix.
 */
oidtype
agsl_matrix_triangular_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, A));

      agsl_matrix_triangular_form (env, B);
      
      return B;
    }
}

/**
 * Make a hard copy diagonal matrix from a logically
 * diagonal matrix.
 */
oidtype
agsl_matrix_diagonal_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, A));

      agsl_matrix_diagonal_form (env, B);
      
      return B;
    }
}


/**
 * Make a hard copy transposed matrix from a logically
 * transposed matrix.
 */
oidtype
agsl_matrix_transpose_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, A));

      agsl_matrix_transpose_form (env, B);
      
      return B;
    }
}




/**
 * Lower triangular matrix of given matrix.
 *
 * @param A the matrix 
 * @return   lower-triangular part of A
 */
oidtype
agsl_matrix_lower_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (L);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (L, agsl_matrix_softcopy (env, A));

      agsl_matrix_lower_form (env, L);
      
      return L;
    }
}


/**
 * Create upper-triangular matrix from the given matrix.
 *
 * @param A the matrix 
 * @return   upper-triangular part of A
 */
oidtype
agsl_matrix_upper_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (U);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (U, agsl_matrix_softcopy (env, A));

      agsl_matrix_upper_form (env, U);
      
      return U;
    }
}


/**
 * Create a symmetric matrix from the given matrix A. If A
 * is lower triangular copy lower triangular part to upper
 * triangular part. If A is upper triangular do the
 * opposite.
 *
 * @param A the matrix 
 * @return   symmetric matrix of A
 */
oidtype
agsl_matrix_symmetric_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (S);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (S, agsl_matrix_softcopy (env, A));

      agsl_matrix_symmetric_form (env, S);
      
      return S;
    }
}



/**
 * Make a hard copy matrix A out of given decomposed
 * matrices.
 */
oidtype
agsl_matrix_recomp_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_recomp_form (env, A));

      agsl_matrix_upper_form (env, B);
      
      return B;
    }
}


/**
 * Decompose matrix A into LU, QR, Cholesky depending on
 * type of matrix.
 *
 * Choice order: cholesky (symm), lu (square), qr
 *               (rectangular)
 */
oidtype
agsl_matrix_decomp_copy (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("A is not square", GSL_ENOTSQR);
    }
  else
    {  
      dcloid (B);

      /* easy way - copy A and use `form' to copy */
  
      a_setf (B, agsl_matrix_softcopy (env, A));

      agsl_matrix_decomp_form (env, B);
      
      return B;
    }
}


