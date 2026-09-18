/* -*- c-basic-offset: 2; -*- 
 *
 * Description:  LU decomposition and solving
 *
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "agsl_linalg.h"
#include "amosgsl.h"

/**
 * Helper function for permuting a matrix
 */
int
gsl_permute_matrix (gsl_permutation * p, gsl_matrix * A)
{
  int status = GSL_SUCCESS;

  size_t i = 0;
  
  for (i = 0; i < p->size; i++)
    {
      gsl_vector_view a = gsl_matrix_column (A, i); /* rows of A */

      int status_i = gsl_permute_vector (p, &a.vector);

      if (status_i)
        status = status_i;

    }

  return status;
}

  
/**
 * Helper function for applying the inverse of permutation P
 * to the rows of matrix A
 */
int
gsl_permute_matrix_inverse (gsl_permutation * p, gsl_matrix * A)
{
  int status = GSL_SUCCESS;

  size_t i = 0;
  
  for (i = 0; i < p->size; i++)
    {
      gsl_vector_view a = gsl_matrix_column (A, i);
      
      int status_i = gsl_permute_vector_inverse (p, &a.vector);
      
      if (status_i)
        status = status_i;
    }
  
  return status;
}


/**
 * Factorise a general N x N matrix A into,
 *
 *   P A = L U
 *
 * where P is a permutation matrix, L is unit lower
 * triangular and U is upper triangular.
 *
 * L is stored in the strict lower triangular part of the
 * input matrix. The diagonal elements of L are unity and
 * are not stored.
 *
 * U is stored in the diagonal and upper triangular part of
 * the input matrix.
 * 
 * P is stored in the permutation p. Column j of P is column
 * k of the identity matrix, where k = permutation->data[j]
 *
 * signum gives the sign of the permutation, (-1)^n, where n
 * is the number of interchanges in the permutation.
 *
 * See Golub & Van Loan, Matrix Computations, Algorithm
 * 3.4.1 (Gauss Elimination with Partial Pivoting).
 */
oidtype
agsl_linalg_LU_decomp (bindtype env, const oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("LU decomposition requires a square matrix", GSL_ENOTSQR);
    }
  else
    {
      dcloid (LUP);

      a_setf (LUP, agsl_matrix_copy (env, A));

      if (GSL_SUCCESS != agsl_linalg_LU_dcmp (env, LUP))
        {
          GSL_ERROR ("Failed to LU decompose matrix",
                     GSL_FAILURE);
        }

      return LUP;
    }
}

/**
 * Decompose matrix A in place.
 *
 */
int
agsl_linalg_LU_dcmp (bindtype env, oidtype A)
{
  IsAgslMatrix (env, A);

  if (!ISSQUARE (A))
    {
      GSL_ERROR ("LU decomposition requires square matrix", GSL_ENOTSQR);
    }
  else
    {
      int s;

      gsl_permutation * p = gsl_permutation_alloc (ROWS (A));

      /* generalize matrix */
      agsl_matrix_form (env, A);
      
      if (GSL_SUCCESS != gsl_linalg_LU_decomp (matrix (A), p, &s))
        {
          GSL_ERROR ("LU decomposition failed", GSL_EINVAL);
        }

      SETPERM (A, p);
      SETDECOMPLU (A);

      return GSL_SUCCESS;
    }
}

/**
 * TODO Recompose matrix A into its whole:
 * P A = L U -> A = inv (P) * L * U
 *
 * A x = y for x is solved thus (inv (A) A x = inv (A) y)
 * 
 *  Forward substitution: L z = P y using trsv (L, Pb) (inv (L) z = Py for z)
 * Backward substitution: U x = z   using trsv (U, x) (inv (U) x = z for x)
 *
 * A B = C for B may be solved thus?
 *
 * Forward substitution:
 * L D = P C using trsm (L, PC) (inv (L) D = P C for D)
 *
 * Backward substitution:
 * U B = D using trsm (U, B) (inv (U) B = D for B
 *
 * Must permute matrix C
 * 
 * gsl_permute_vector (p, x)
 *
 * Steps: Pretty important to get these right
 * 1. trmm on L * U (copy upper triangular U from data in LUP)
 * 2. Permute LU with inverse of P
 */
oidtype
agsl_linalg_LU_recomp (bindtype env, const oidtype LUP)
{
  IsAgslMatrix (env, LUP);

  if (!ISLUDECOMP (LUP))
    {
      GSL_ERROR ("Matrix not LU decomposed!", GSL_EINVAL);
    }
  else
    {
      dcloid (A);
  
      a_setf (A, agsl_matrix_softcopy (env, LUP));

      agsl_linalg_LU_rcmp (env, A);

      return A;
    }
}

int
agsl_linalg_LU_rcmp (bindtype env, oidtype LUP)
{
  IsAgslMatrix (env, LUP);
  
  if (!ISLUDECOMP (LUP))
    {
      GSL_ERROR ("Matrix not LU decomposed!", GSL_EINVAL);
    }
  else
    {
      dcloid (A);
  
      a_setf (A, agsl_matrix_upper_copy (env, LUP));

      if (GSL_SUCCESS == gsl_blas_dtrmm (CblasLeft,
                                         CblasLower,
                                         GETTRANSPOSE (LUP),
                                         CblasUnit,
                                         ALPHA1,
                                         matrix (LUP),
                                         matrix (A)));

      /* Apply inverse permutation P on A = L U */
      if (GSL_SUCCESS !=
          gsl_permute_matrix_inverse (gslperm (LUP), matrix (A)))
        {
          GSL_ERROR ("Applying inverse-permutation to matrix failed",
                     GSL_FAILURE);
        }
      else
        {
          matrix (LUP) = matrix (A);

          UNSETDECOMP (LUP);
          
          return GSL_SUCCESS;
        }
    }
}




/**
 * Solve \alpha A B = C for B where P A = L U
 *
 * (1) solve \alpha L D = P C for D then (2) U B = D for B
 *
 */
oidtype
agsl_linalg_LU_solve_alpha_ab (bindtype env,
                               const oidtype alpha,
                               const oidtype LU,
                               const oidtype C)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, LU);
  IsAgslMatrix (env, C);

  if (!ISLUDECOMP (LU))
    {
      GSL_ERROR ("LU matrix must be LU decomposed", GSL_EINVAL);
    }
  if (ROWS (LU) != COLS (LU))
    {
      GSL_ERROR ("LU matrix must be square", GSL_ENOTSQR);
    }
  else if (ROWS (LU) != gslperm (LU)->size)
    {
      GSL_ERROR ("permutation length must match matrix size", GSL_EBADLEN);
    }
  else if (ROWS (LU) != ROWS (C))
    {
      GSL_ERROR ("LU matrix size must match rhs size", GSL_EBADLEN);
    }
  else
    {
      dcloid (B);

      /* Copy B <- C */

      a_setf (B, agsl_matrix_copy (env, C));

      /* solve the system */
      
      agsl_linalg_LU_svx_alpha_ab (env, alpha, LU, B);
      
      return B;
    }
}


/**
 * Solve the square systems \alpha LU B = C for (column
 * vectors of) B in place.

 * On input B should contain the right-hand side C, which is
 * replaced by the solution on output.
 *
 * @see agsl_linalg_LU_solve_alpha_ab
 *
 */
int
agsl_linalg_LU_svx_alpha_ab (bindtype env,
                             const oidtype alpha,
                             const oidtype LU,
                             oidtype B)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, LU);
  IsAgslMatrix (env, B);

  if (!ISLUDECOMP (LU))
    {
      GSL_ERROR ("LU matrix must be LU decomposed", GSL_EINVAL);
    }
  if (ROWS (LU) != COLS (LU))
    {
      GSL_ERROR ("LU matrix must be square", GSL_ENOTSQR);
    }
  else if (ROWS (LU) != gslperm (LU)->size)
    {
      GSL_ERROR ("permutation length must match matrix size", GSL_EBADLEN);
    }
  else if (ROWS (LU) != ROWS (B))
    {
      GSL_ERROR ("LU matrix size must match rhs size", GSL_EBADLEN);
    }
  else
    {
      double alphainv = coerce_real (env, alpha);

      if (alphainv != ALPHA1 && alphainv != BETA0)
        {
          alphainv = 1 / alphainv;
        }
      
      /* Apply permutation to RHS */

      gsl_permute_matrix (gslperm (LU), matrix (B));

      /* Perform forward-substitution, \alpha L D = P C -> D = inv (L) P C / alpha */

      gsl_blas_dtrsm (CblasLeft, CblasLower, CblasNoTrans, CblasUnit,
                      alphainv, matrix (LU), matrix (B));

      /* Perform back-substitution, U B = D  -> B = inv (L) D */

      gsl_blas_dtrsm (CblasLeft, CblasUpper, CblasNoTrans, CblasNonUnit, ALPHA1, matrix (LU), matrix (B));

      return GSL_SUCCESS;
    }
}



oidtype
agsl_linalg_LU_solve (bindtype env,
                      const oidtype alpha,
                      const oidtype LU,
                      const oidtype beta,
                      const oidtype C,
                      const oidtype D)

{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, LU);
  IsAgslMatrix (env, C);
  IsAgslMatrix (env, D);

  if (!ISLUDECOMP (LU))
    {
      GSL_ERROR ("LU matrix must be LU decomposed", GSL_EINVAL);
    }
  if (!ISSQUARE (LU))
    {
      GSL_ERROR ("LU matrix must be square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (C) || !ISSQUARE (D))
    {
      GSL_ERROR ("rhs must be square", GSL_ENOTSQR);
    }
  else if (ROWS (LU) != gslperm (LU)->size)
    {
      GSL_ERROR ("permutation length must match matrix size", GSL_EBADLEN);
    }
  else if (ROWS (LU) != ROWS (C) || ROWS (LU) != ROWS (D))
    {
      GSL_ERROR ("LU matrix size must match rhs size", GSL_EBADLEN);
    }
  else
    {

      dcloid (B);

      /* Copy B <- C */

      a_setf (B, agsl_matrix_copy (env, D));

      /* solve the system */
      
      agsl_linalg_LU_svx (env, alpha, LU, beta, C, B);
      
      return B;
    }
}

  
/**
 * Solve (1) \alpha A B + \beta C = D for B. That is solve
 * \alpha AB = D - \beta C for B. On input D is right-hand
 * side of (1), on output is the result B.
 *
 */
int
agsl_linalg_LU_svx (bindtype env,
                    const oidtype alpha,
                    const oidtype LU,
                    const oidtype beta,
                    const oidtype C,
                    oidtype D)
{
  IsNumber (env, alpha);
  IsNumber (env, beta);
  IsAgslMatrix (env, LU);
  IsAgslMatrix (env, C);
  IsAgslMatrix (env, D);

  if (!ISLUDECOMP (LU))
    {
      GSL_ERROR ("LU matrix must be LU decomposed", GSL_EINVAL);
    }
  if (!ISSQUARE (LU))
    {
      GSL_ERROR ("LU matrix must be square", GSL_ENOTSQR);
    }
  else if (!ISSQUARE (C) || !ISSQUARE (D))
    {
      GSL_ERROR ("rhs must be square", GSL_ENOTSQR);
    }
  else if (ROWS (LU) != gslperm (LU)->size)
    {
      GSL_ERROR ("permutation length must match matrix size", GSL_EBADLEN);
    }
  else if (ROWS (LU) != ROWS (C) || ROWS (LU) != ROWS (D))
    {
      GSL_ERROR ("LU matrix size must match rhs size", GSL_EBADLEN);
    }
  else
    {
      /* D <-- D - \beta C = - \beta C I + D using dgmm */

      dcloid (I);
      
      a_setf (I, agsl_matrix_identity (env,
                                       mkinteger (ROWS (C)),
                                       mkinteger (COLS (C))));

      /* rearrange equation and rhs to store result in D */

      if (getreal (beta) != BETA0)
        {
          dcloid (minusbeta);

          a_setf (minusbeta, mkreal (- getreal (beta)));
          
          agsl_blas_dgmm (env, minusbeta, C, I, mkreal (ALPHA1), D);
        }
      
      /* solve: D holds the solution */
        
      agsl_linalg_LU_svx_alpha_ab (env, alpha, LU, D);
      
      /* agsl_matrix_deallocate (I);  */

      gsl_matrix_free (matrix (I));

      return GSL_SUCCESS;
    }
}
