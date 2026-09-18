/** -*- c-basic-offset: 2; -*-
 *
 * Description:  AGSL BLAS Header
 * $URL$
 * $Author: tilo8123 $
 * $Date: 2009/07/14 13:45:45 $
 *
 */

#ifndef AGSL_BLAS_H
#define AGSL_BLAS_H

#include <gsl/gsl_blas.h>

BEGIN_C_DECLS


/**
 * =========================================================
 * Level 1
 * =========================================================
 */
oidtype
agsl_blas_ddot (bindtype env, const oidtype _u, const oidtype _v);

oidtype
agsl_blas_dnorm (bindtype env, const oidtype _u);

oidtype
agsl_blas_dasum (bindtype env, const oidtype _u);

/**
 * =========================================================
 * Level 2
 * =========================================================
 */
oidtype
agsl_blas_dgemv (bindtype env, const oidtype _a, const oidtype _u);

oidtype
agsl_blas_dtrmv (bindtype env, const oidtype _a, const oidtype _u);

oidtype
agsl_blas_dtrsv (bindtype env, const oidtype _a, const oidtype _u);

oidtype
agsl_blas_dsymv (bindtype env, const oidtype _a, const oidtype _u);

/**
 * =========================================================
 * Level 3
 * =========================================================
 */
oidtype
agsl_matrix_dgemm (bindtype env, const oidtype _a, const oidtype _b);

END_C_DECLS

#endif /* AGSL_BLAS_H */
