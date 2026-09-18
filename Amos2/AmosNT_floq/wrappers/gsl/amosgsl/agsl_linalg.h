/* -*- c-basic-offset: 2; -*-
 *
 * Description: Linear Algebra decomposition and solving,
 *              including AB=C where C is unknown.
 */

#include <stdio.h>
#include "amosgsl.h"
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_blas_types.h>

oidtype agsl_linalg_LU_decomp (bindtype env, const oidtype A);
oidtype agsl_linalg_LU_recomp (bindtype env, const oidtype LUP);
oidtype agsl_linalg_LU_solve_alpha_ab (bindtype env, const oidtype alpha, const oidtype LU, const oidtype C);

int agsl_linalg_LU_svx (bindtype env, const oidtype alpha, const oidtype LU, const oidtype beta, const oidtype C, oidtype D);

int agsl_linalg_LU_svx_alpha_ab (bindtype env, const oidtype alpha, const oidtype LU, oidtype B);

oidtype agsl_linalg_QR_decomp (bindtype env, const oidtype A);
oidtype agsl_linalg_QR_recomp (bindtype env, const oidtype LUP);
oidtype agsl_linalg_QR_solve_alpha_ab (bindtype env, const oidtype alpha, const oidtype LU, const oidtype C);

oidtype agsl_linalg_cholesky_decomp (bindtype env, const oidtype A);
oidtype agsl_linalg_cholesky_recomp (bindtype env, const oidtype LUP);
oidtype agsl_linalg_cholesky_solve_alpha_ab (bindtype env, const oidtype alpha, const oidtype LU, const oidtype C);

oidtype agsl_linalg_solve_alpha_ab (bindtype env, const oidtype alpha, const oidtype A, const oidtype C);
oidtype agsl_linalg_solve (bindtype env, const oidtype alpha, const oidtype A, const oidtype beta, const oidtype C, const oidtype D);
