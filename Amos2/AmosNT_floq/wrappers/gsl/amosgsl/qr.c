/* -*- c-basic-offset: 2; -*- 
 *
 * Description:  QR decomposition
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
agsl_linalg_QR_decomp (bindtype env, oidtype A)
{
  GSL_ERROR ("Not written yet", GSL_EINVAL);
}


/**
 *
 */
oidtype
agsl_linalg_QR_recomp (bindtype env, oidtype QR)
{
  GSL_ERROR ("Not written yet", GSL_EINVAL);
}


/**
 * Not relevant?
 */
oidtype
agsl_linalg_QR_solve_alpha_ab (bindtype env,
                               const oidtype alpha,
                               oidtype QR,
                               oidtype C)
{
  IsNumber (env, alpha);
  IsAgslMatrix (env, QR);
  IsAgslMatrix (env, C);

  GSL_ERROR ("Not relevant?", GSL_EINVAL);
}
