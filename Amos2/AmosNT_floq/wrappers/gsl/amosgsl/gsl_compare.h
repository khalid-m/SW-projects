/** -*- c-basic-offset: 2; -*- 
 *
 * Description: Internal convenience library for comparisons
 */

#ifndef AGSL_COMPARE_H
#define AGSL_COMPARE_H

/* GSL stuff */
#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>

int gsl_matrix_compare (gsl_matrix * A, gsl_matrix * B);
int gsl_vector_compare (gsl_vector * U, gsl_vector * V);
int gsl_permutation_compare (gsl_permutation * P1,
                             gsl_permutation * P2);


#endif /* AGSL_COMMON_H */
