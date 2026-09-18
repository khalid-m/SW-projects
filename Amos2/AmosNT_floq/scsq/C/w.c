/*
 * "w.c", Pjotr '87.
 */

#include	"fftcomplex.h"
#include	"w.h"
#include <stdlib.h>

//#define DEBUG

COMPLEX *W_factors = 0;		/* array of W-factors */
unsigned Nfactors = 0;		/* number of entries in W-factors */

/*
 * W_init puts Wn ^ k (= e ^ (2pi * i * k / n)) in W_factors [k], 0 <= k < n.
 * If n is equal to Nfactors then nothing is done, so the same W_factors
 * array can used for several transforms of the same number of samples.
 * Notice the explicit calculation of sines and cosines, an iterative approach
 * introduces substantial errors.
 */
int W_init (n)
unsigned n;
{
	unsigned k;

	if (n == Nfactors)
		return 0;
	if (Nfactors != 0 && W_factors != 0)
		free ((char *) W_factors);
	if ((Nfactors = n) == 0)
		return 0;
	if ((W_factors = (COMPLEX *) malloc (n * sizeof (COMPLEX))) == 0)
		return -1;

	for (k = 0; k < n; k++) {
		c_re (W_factors [k]) = cos (2 * M_PI * k / n);
		c_im (W_factors [k]) = sin (2 * M_PI * k / n);
	}

#ifdef DEBUG
	printf("W [ ");
	for (k = 0; k < n; k++) {
		printf("(%f %f) ", W_factors[k].re, W_factors[k].im);
	}
	printf("]\n");
#endif
	return 0;
}
