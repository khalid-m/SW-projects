/* -*- c-basic-offset: 2; -*-
 *
 * Description: Linear Algebra decomposition and solving,
 *              including AB=C where C is unknown.
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include "amosgsl.h"


/***********************************************************************
 * Register Linear Algebra Functions
 **********************************************************************/
void
agsl_linalg_register_functions ()
{
#ifdef VERBOSE
  printf ("Register ALisp AGSL Linear Algebra Foreign Functions...\n");
#endif

  /* Solve \alpha A B + \beta C = D for B  */
  extfunction5 ("agsl-linalg-solve", agsl_linalg_solve);

  /* Solve \alpha A B = C for B */
  extfunction3 ("agsl-linalg-solve-alpha-ab", agsl_linalg_solve_alpha_ab);

  /* LU decomposition and solving */
  extfunction1 ("agsl-linalg-lu-decomp", agsl_linalg_LU_decomp);
  extfunction1 ("agsl-linalg-lu-recomp", agsl_linalg_LU_recomp);
  extfunction3 ("agsl-linalg-lu-solve-alpha-ab", agsl_linalg_LU_solve_alpha_ab);

  /* QR decomposition and solving */
  extfunction1 ("agsl-linalg-qr-decomp", agsl_linalg_QR_decomp);
  extfunction1 ("agsl-linalg-qr-recomp", agsl_linalg_QR_recomp);
  extfunction3 ("agsl-linalg-qr-solve-alpha-ab", agsl_linalg_QR_solve_alpha_ab);

  /* Cholesky decomposition and solving */
  extfunction1 ("agsl-linalg-cholesky-decomp", agsl_linalg_cholesky_decomp);
  extfunction1 ("agsl-linalg-cholesky-recomp", agsl_linalg_cholesky_recomp);
  extfunction3 ("agsl-linalg-cholesky-solve-alpha-ab", agsl_linalg_cholesky_solve_alpha_ab);

  return;
}


