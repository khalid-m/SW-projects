/* -*- c-basic-offset: 2; -*- 
 *
 * Matrix type aand subtypes
 * Subtypes:
 * - 
 */

#ifndef AGSL_MATRIX_H
#define AGSL_MATRIX_H

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_blas_types.h>
/* #include "callout.h" */ /* Include AMOS2 callout library (required) */
#include <amos2/alisp.h>   /* Include Lisp interfaces */

/*
Other stuff that is somewhat useful to know: gsl_cblas.h
enum CBLAS_ORDER {CblasRowMajor=101, CblasColMajor=102};
enum CBLAS_TRANSPOSE {CblasNoTrans=111, CblasTrans=112, CblasConjTrans=113};
enum CBLAS_UPLO {CblasUpper=121, CblasLower=122};
enum CBLAS_DIAG {CblasNonUnit=131, CblasUnit=132};
enum CBLAS_SIDE {CblasLeft=141, CblasRight=142};
*/
BEGIN_C_DECLS

/* Matrix decomposition status and type */
enum AGSL_DECOMPOSE {AgslNotDecomposed=-1,
                     AgslLU=161,
                     AgslCholesky=162,
                     AgslQR=163};
typedef enum AGSL_DECOMPOSE AGSL_DECOMPOSE_t;

/* Symmetric matrix, or not */
enum AGSL_SYMM {AgslSymmetric=151,
                AgslDiagonal=152,
                AgslNonSymmetric=153};
typedef enum AGSL_SYMM AGSL_SYMM_t;
  

struct agsl_matrix_cell
{
  objtags tags;
  HEADFILLER; /* unused */

  /* the data */
  gsl_matrix * matrix;

  /* permutation matrix, possibly for use with decomposed
     matrices, where data in matrix represents two matrices
     L and U */
  gsl_permutation * perm;
  
  /* Type of decomposed matrix, cholesky, LU, QR */
  AGSL_DECOMPOSE_t decomp;

  /* only use upper or lower triangular parts of `matrix' */
  CBLAS_UPLO_t upLo;

  /* logically transpose the matrix */
  CBLAS_TRANSPOSE_t trans;

  /* diagonal values are unitary or not */
  CBLAS_DIAG_t diag;

  /* matrix is symmetric, diagonal or not */
  AGSL_SYMM_t symm;

  /* row / column major storage */
  /* CBLAS_ORDER_t order; */  /* unused - more low-level non-GSL */
};

/* Will hold the type tag of objects of type AGSL_MATRIX */
EXTERN int AGSL_MATRIX_TYPE;
EXTERN oidtype agsl_new_matrix (size_t n1, size_t n2);
oidtype agsl_matrix_identity (bindtype env, oidtype M, oidtype N);

/* Error handling for matrices */
int ARG_NOT_AGSL_MATRIX; /* argument not an agsl matrix */
int AGSL_ENOMEM;         /* out of memory */
int AGSL_EINVAL;         /* invalid argument supplied by user */
int AGSL_EBADLEN;        /* matrix, vector lengths are not conformant */
int AGSL_ENOTSQR;       /* matrix not square */
int AGSL_FAILURE;        /* general failure */


/**
 * Matrix properties. From a BLAS perspective, these
 * properties of the matrix determine how we perform the
 * operations. For other manipulations we take into account
 * the properties of the matrix. 
 *
 * Various macros make use of these variables, for getting,
 *  setting and checking properties of our matrices.
 * 
 */
#define AGSL_MATRIX_UPLO(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->upLo
#define AGSL_MATRIX_TRANS(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->trans
#define AGSL_MATRIX_DIAG(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->diag
#define AGSL_MATRIX_SYMM(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->symm
#define AGSL_MATRIX_DECOMP(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->decomp
#define AGSL_MATRIX_PERM(__agsl_matrix__) (dr (__agsl_matrix__, agsl_matrix_cell))->perm

#define ISUPPER(a) ((AGSL_MATRIX_UPLO (a)) == CblasUpper)
#define ISLOWER(a) ((AGSL_MATRIX_UPLO (a)) == CblasLower)
#define GETUPLO(a) (ISGENERALTRANS (a) || ISUPPER (a) ? CblasUpper : CblasLower)
#define SETUPPER(a) AGSL_MATRIX_UPLO (a) = CblasUpper
#define SETLOWER(a) AGSL_MATRIX_UPLO (a) = CblasLower
#define UNSETUPLO(a) AGSL_MATRIX_UPLO (a) = -1

#define ISTRANSPOSE(a) ((AGSL_MATRIX_TRANS (a)) == CblasTrans || (AGSL_MATRIX_TRANS (a)) == CblasConjTrans)
/* A may be transposed only if not decomposed or symmetric */
#define GETTRANSPOSE(a) (!ISDECOMPOSED (a) && ISTRANSPOSE (a) ? CblasTrans : CblasNoTrans)
#define SETTRANSPOSE(a) AGSL_MATRIX_TRANS (a) = CblasTrans
#define UNSETTRANSPOSE(a) AGSL_MATRIX_TRANS (a) = CblasNoTrans

#define ISDIAGONAL(a) (AGSL_MATRIX_SYMM (a) == AgslDiagonal)
#define GETDIAGONAL(a) (ISDIAGONAL (a) ? AGSL_MATRIX_SYMM (a))
#define SETDIAGONAL(a) AGSL_MATRIX_SYMM (a) = AgslDiagonal

#define ISSYMMETRIC(a) ((AGSL_MATRIX_SYMM (a)) == AgslSymmetric || (AGSL_MATRIX_SYMM (a)) == AgslDiagonal)
#define GETSYMMETRY(a) ((ISSYMMETRIC (a)) ? (AGSL_MATRIX_SYMM (a)) : AgslNonSymmetric)
#define SETSYMMETRIC(a) AGSL_MATRIX_SYMM (a) = AgslSymmetric
#define UNSETSYMMETRIC(a) AGSL_MATRIX_SYMM (a) = AgslNonSymmetric

#define SETSYMMETRICUP(a) SETSYMMETRIC (a) ; SETUPPER(a)
#define SETSYMMETRICLO(a) SETSYMMETRIC (a) ; SETLOWER(a)

/* A unitary matrix may be diagonal, upper or lower triangular */
#define ISUNITARY(a)                            \
  ((ISDIAGONAL (a) || ISTRIANGULAR (a))         \
   && (AGSL_MATRIX_DIAG (a)) == CblasUnit)

/* A may be unitary only for upper or lower triangular matrices */
#define GETUNITARY(a) ((ISUNITARY (a) && (ISUPPERTRI (a) || ISLOWERTRI (a))) ? CblasUnit : CblasNonUnit)
#define SETUNITARY(a) AGSL_MATRIX_DIAG (a) = CblasUnit
#define UNSETUNITARY(a) AGSL_MATRIX_DIAG (a) = CblasNonUnit

/* Some decomposition macros */
#define ISDECOMPOSED(a) ((AGSL_MATRIX_DECOMP (a)) == AgslLU || (AGSL_MATRIX_DECOMP (a)) == AgslQR || (AGSL_MATRIX_DECOMP (a)) == AgslCholesky)

#define SETCHOLESKY(a) AGSL_MATRIX_DECOMP (a) = AgslCholesky
#define SETDECOMPLU(a) AGSL_MATRIX_DECOMP (a) = AgslLU
#define SETDECOMPQR(a) AGSL_MATRIX_DECOMP (a) = AgslQR
#define ISCHOLESKY(a) (AGSL_MATRIX_DECOMP (a) == AgslCholesky)
#define ISLUDECOMP(a) (AGSL_MATRIX_DECOMP (a) == AgslLU)
#define ISQRDECOMP(a) (AGSL_MATRIX_DECOMP (a) == AgslQR)
#define UNSETDECOMP(a) AGSL_MATRIX_DECOMP (a) = AgslNotDecomposed

/* The permutation */
#define gslperm(a) AGSL_MATRIX_PERM (a)
#define SETPERM(a,p) AGSL_MATRIX_PERM (a) = p
#define UNSETPERM(a) AGSL_MATRIX_PERM (a) = NULL

/* General matrix */
#define ISGENERAL(a) (!(ISUPPER (a) || ISLOWER (a) || ISSYMMETRIC (a) || ISDECOMPOSED (a)))
/* Convenient logical different matrix types */
#define ISGENERALTRANS(a) (ISGENERAL (a) && ISTRANSPOSE (a))
#define ISGENERALNOTRANS(a) (ISGENERAL (a) && !ISTRANSPOSE (a))

#define SETGENERAL(a) UNSETUNITARY (a); UNSETSYMMETRIC (a);     \
  UNSETUPLO (a); UNSETTRANSPOSE (a)

/* Lower-triangular matrix */
#define ISLOWERTRI(a) (!ISSYMMETRIC (a) && (ISLOWERNOTRANS (a) || ISUPPERTRANS (a)))
#define ISUPPERTRI(a) (!ISSYMMETRIC (a) && (ISUPPERNOTRANS (a) || ISLOWERTRANS (a)))
#define ISTRIANGULAR(a) (ISUPPERTRI (a) || ISLOWERTRI (a))


#define ISSYMMETRICUP(a) (ISSYMMETRIC (a) && ISUPPER(a))
#define ISSYMMETRICLO(a) (ISSYMMETRIC (a) && !ISUPPER(a))


#define ISUPPERTRANS(a) (ISUPPER (a) && ISTRANSPOSE (a))
#define ISUPPERNOTRANS(a) (ISUPPER (a) && !ISTRANSPOSE (a))
#define ISLOWERTRANS(a) (ISLOWER (a) && ISTRANSPOSE (a))
#define ISLOWERNOTRANS(a) (ISLOWER (a) && !ISTRANSPOSE (a))


/* rows and columns */
#define ROWS(A) ((GETTRANSPOSE (A) == CblasNoTrans) ? matrix (A)->size1 : matrix (A)->size2)
#define COLS(A) ((GETTRANSPOSE (A) == CblasNoTrans) ? matrix (A)->size2 : matrix (A)->size1)

/* check squareness of matrix */
#define ISSQUARE(A) (ROWS (A) == COLS (A))

/* Similar to Amos II macros for data types like integer */
#define IsAgslMatrix(env, A)        \
  OfType (A, AGSL_MATRIX_TYPE, env)
#define agslmatrixp(A)                        \
  (a_datatype (A) == AGSL_MATRIX_TYPE)
#define matrix(__A__)                        \
  (dr (__A__, agsl_matrix_cell))->matrix
#define IntoGslMatrix(A, a, env)                   \
  if (agslmatrixp (A)) { a = matrix (A); }      \
  else { return lerror (ARG_NOT_AGSL_MATRIX, A, env); }


void agsl_matrix_print (oidtype A, oidtype stream, int princflg);
void agsl_matrix_deallocate (oidtype A);

oidtype agsl_matrix_make (bindtype env, oidtype size1, oidtype size2);
oidtype agsl_matrix_set (bindtype env, oidtype A, oidtype i, oidtype j, oidtype element);
oidtype agsl_matrix_get (bindtype env, oidtype A, oidtype i, oidtype j);
oidtype agsl_matrix_write (bindtype env, oidtype A, oidtype stream);
oidtype agsl_matrix_read (bindtype env, oidtype tag, oidtype list, oidtype stream);

/* lower-triangular */
oidtype agsl_matrix_lower (bindtype env, oidtype A);
/* upper-triangular */
oidtype agsl_matrix_upper (bindtype env, oidtype A); 

oidtype agsl_matrix_all (bindtype env, oidtype A);
oidtype agsl_matrix_any (bindtype env, oidtype A);
oidtype agsl_matrix_rows (bindtype env, oidtype A);
oidtype agsl_matrix_columns (bindtype env, oidtype A);


oidtype agsl_matrix_init (bindtype env, oidtype values);
oidtype agsl_matrix_init_flat (bindtype env, oidtype values, oidtype size1, oidtype size2);

oidtype agsl_matrix_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_full_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_transpose_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_triangular_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_symmetric_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_lower_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_upper_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_lowerunit_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_upperunit_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_diagonal_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_recomp_copy (bindtype env, const oidtype A);
oidtype agsl_matrix_decomp_copy (bindtype env, const oidtype A);


/* used internally to assign a matrix to an agsl_matrix */
oidtype agsl_matrix_assign (gsl_matrix * a);

oidtype agsl_matrix_softcopy (bindtype env, oidtype A);


/* helper functions for `agsl_matrix_print,' */
int print_gsl_matrix_to_amos (gsl_matrix * matrix, oidtype stream);
void read_gsl_matrix_from_pipe (int file, oidtype stream, size_t columns);
void write_gsl_matrix_to_pipe (int file, gsl_matrix * matrix);

void agsl_matrix_register_functions ();



END_C_DECLS

#endif /* AGSL_MATRIX_H */

