/*
 * "ft.c", Pjotr '87.
 */

#include	"fftcomplex.h"
#include	"w.h"

//#define DEBUG

/*
 * Forward Fast Fourier Transform on the n samples of complex array in.
 * The result is placed in out.  The number of samples, n, is arbitrary.
 * The W-factors are calculated in advance.
 */
int fft (in, n, out)
COMPLEX *in;
unsigned n;
COMPLEX *out;
{
	unsigned i;

#ifdef DEBUG
	printf("== fft in  n=%d [ ", n);
	for(i=0; i<n; i++) {
		printf("(%f %f) ", in[i].re, in[i].im);
	}
	printf(" ]\n");
#endif

	for (i = 0; i < n; i++)
		c_conj (in [i]);
	
	if (W_init (n) == -1)
		return -1;

	Fourier (in, n, out);

	for (i = 0; i < n; i++) {
		c_conj (out [i]);
		c_realdiv (out [i], n);
	}

#ifdef DEBUG
	printf("== fft out n=%d [ ", n);
	for(i=0; i<n; i++) {
		printf("(%f %f) ", out[i].re, out[i].im);
	}
	printf(" ]\n");
#endif
	return 0;
}

int fftpart (COMPLEX *in, unsigned n, COMPLEX *out, unsigned NN) {

#ifdef DEBUG
	{
	unsigned i;
	printf("== fftpart in  n=%d [ ", n);
	for(i=0; i<n; i++) {
		printf("(%f %f) ", in[i].re, in[i].im);
	}
	printf(" ]\n");
#endif

	if (W_init (NN) == -1)
		return -1;

	Fourier (in, n, out);

#ifdef DEBUG
	printf("== fftpart out n=%d [ ", n);
	for(i=0; i<n; i++) {
		printf("(%f %f) ", out[i].re, out[i].im);
	}
	printf(" ]\n");
#endif

	return 0;
}

/*
 * Reverse Fast Fourier Transform on the n complex samples of array in.
 * The result is placed in out.  The number of samples, n, is arbitrary.
 * The W-factors are calculated in advance.
 */
int rft (in, n, out)
COMPLEX *in;
unsigned n;
COMPLEX *out;
{
	if (W_init (n) == -1)
		return -1;

	Fourier (in, n, out);

	return 0;
}
