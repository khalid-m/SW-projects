#include <gsl/gsl_vector.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_permutation.h>
#include "amosgsl.h"

const size_t MAX = 15;

void
print_matrix (gsl_matrix * A)
{
  size_t i, j, M, N, MM, NN;

  MM = A->size1;
  NN = A->size2;
  M = (MM < MAX ? MM : MAX);
  N = (NN < MAX ? NN : MAX);
  
  for (i = 0; i < M; i++)
    {
      for (j = 0; j < N; j++)
        {
          double x = gsl_matrix_get (A, i, j);
          printf (x >= 0 ? " %.5f  " : "%.5f  ", x);
        }
      fprintf (stdout, (NN != N ? "...\n" : "\n"));
    }
  fprintf (stdout, (MM != M ? ":\n\n" : "\n\n")); /* \vdot */
}

/**
 * Compare two matrices by testing all elements of (A - B)
 * are null.
 */
int
gsl_matrix_compare (gsl_matrix * A, gsl_matrix * B)
{
  double min;
  double max;

  gsl_matrix * result = gsl_matrix_alloc (A->size1, A->size2);
  
  gsl_matrix_memcpy (result, A);

  gsl_matrix_sub (result, B);

  /* grab minimum and maximum and ensure nearly zero */

  gsl_matrix_minmax (result, &min, &max);

  fprintf (stdout, "min (A - B) = %8.18f, max (A - B) = %8.18f\n", min, max);

  if (APPROX_EQUAL_ZERO (min, max))
    {
      gsl_matrix_free (result);

      return 1;
    }
  else
    {
      gsl_matrix_free (result);

      return 0;
    }
}
/**
 * Compare two vectors by testing all elements of (A - B)
 * are null.
 */
int
gsl_vector_compare (gsl_vector * U, gsl_vector * V)
{
  double min;
  double max;

  gsl_vector * result = gsl_vector_alloc (U->size);
  
  gsl_vector_memcpy (result, U);

  gsl_vector_sub (result, V);
  /* grab minimum and maximum and ensure nearly zero */
  gsl_vector_minmax (result, &min, &max);

  if (APPROX_EQUAL (min, max))
    {
      return 1;
    }
  else
    {
      return 0;
    }
}


/**
 * Compare two permutation
 */
int
gsl_permutation_compare (gsl_permutation * P1, gsl_permutation * P2)
{
  size_t i;

  if (P1->size != P2->size)
    {
      return 0;
    }
  else
    {
      for (i = 0; i < P1->size; i++)
        {
          if (gsl_permutation_get (P1, i) != gsl_permutation_get (P2, i))
            {
              return 0;
            }
        }
      return 1;
    }
}

