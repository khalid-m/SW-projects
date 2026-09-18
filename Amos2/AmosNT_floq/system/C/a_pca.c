/*****************************************************************************
 * AMOS2
 *
 * Author: F. Murtagh 1989, ported to AmosII by Erik Zeitler
 * $RCSfile: a_pca.c,v $
 * $Revision: 1.7 $ $Date: 2014/01/12 16:28:23 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Principal Components Analysis (Karhunen-Loeve expansion).
 *              F. Murtagh and A. Heck, Multivariate Data Analysis,
 *              Kluwer Academic, Dordrecht, 1987.
 * ===========================================================================
 * $Log: a_pca.c,v $
 * Revision 1.7  2014/01/12 16:28:23  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.6  2010/12/26 17:10:29  torer
 * 1. Not using a_global_callcontext
 * 2. Mappers now return oidtype
 *
 * Revision 1.5  2010/09/19 17:06:29  zeitler
 * Fixed PCA on empty set crash
 *
 * Revision 1.4  2009/10/29 20:48:37  zeitler
 * Matrix reset bug fix
 *
 * Revision 1.3  2009/10/29 17:54:29  zeitler
 * Amos errors are raised when pca fails. Optional debug printouts.
 *
 * Revision 1.2  2009/10/20 21:53:00  zeitler
 * pca(bag of vector of number data)
 *     -> <vector of number eigval, vector of vector of number eigvec>
 * returns the eigenvalues and eigenvectors of the covariance matrix of the
 * data vectors.
 *
 * Revision 1.1  2009/10/19 22:14:46  zeitler
 * Basic PCA
 *
 *********************************************************************/

#include "amos.h"
#include "storagetypes.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define SIGN(a, b) ( (b) < 0 ? -fabs(a) : fabs(a) )

//#define PCADEBUG 1

struct pcastate {
  int first;
  int dim;
  double **symmat;
};

double **matrix(int n, int m);
double *vector(int n);
void free_vector(double *v, int n);
void free_matrix(double **mat, int n, int m);
void zeromat(double **mat, int n, int m);
void tred2(double **a, int n, double *d, double *e);
void tqli(double *d, double *e, int n, double **z);

int DIMMIS_ERROR, PCA_ALLOC_FAIL, PCA_QL_ITER;

oidtype pcamapper(a_callcontext cxt, int arity, oidtype *tpl, void *xa) {
  struct pcastate *state;
  oidtype v;
  int j1, j2;

  state = (struct pcastate*)xa;

  if (state->first) {
    state->dim = a_arraysize(tpl[0]);
    state->symmat = matrix(state->dim, state->dim);
    zeromat(state->symmat, state->dim, state->dim);
    state->first = 0;
  }

  v = tpl[0];
  if(a_arraysize(v) != state->dim) {
    a_error(DIMMIS_ERROR, v, FALSE);
  }

  for (j1 = 1; j1 <= state->dim; j1++) {
    for (j2 = j1; j2 <= state->dim; j2++) {
      state->symmat[j1][j2] += coerce_real(cxt->env, a_elt(v, j1-1)) *
	coerce_real(cxt->env, a_elt(v, j2-1));
      state->symmat[j2][j1] = state->symmat[j1][j2];
    }
  }
  return nil;
}

oidtype pcabf(a_callcontext cxt) {
  struct pcastate state;
  oidtype bag;
  volatile oidtype eigvalo = nil, eigveco = nil;

  bag = a_arg(cxt, 1);

  state.first = 1;
  {
    int i, j;
    double *evals, *interm;
    unwind_protect_begin;
    a_mapbag(cxt, bag, pcamapper, (void*)&state);

#ifdef PCADEBUG
    printf("PCA covariance matrix:\n");
    for (i = 1; i <= state.dim; i++) {
      for (j = 1; j <= state.dim; j++)  {
	printf("%7.1f ", state.symmat[i][j]);
      }
      printf("\n");
    }
#endif

	if (state.first) {
		return nil;
	}

    evals = vector(state.dim);     /* vector of eigenvalues */
    interm = vector(state.dim);    /* 'intermediate' vector */
    tred2(state.symmat, state.dim, evals, interm); /* Triangular decomp. */
    tqli(evals, interm, state.dim, state.symmat);  /* Reduction */
    /* evals now contains the eigenvalues,
       columns of symmat now contain the associated eigenvectors
       NB: We dont know if the eigvals and eigvecs are really
           corresponding. eigvecs might need to be reversed */

    a_setf(eigvalo, new_array(state.dim, nil));
    for (i = 0; i < state.dim; i++) {
      a_seta(eigvalo, i, mkreal(evals[i + 1]));
    }

    // NB: The final result might have to be transposed. 
    // compare pca.c 'v' option to this program, with pca(minusavg) in p.osql

    a_setf(eigveco, new_array(state.dim, nil));
    for (i = 0; i < state.dim; i++) {
      a_seta(eigveco, i, new_array(state.dim, nil));
      for (j = 0; j < state.dim; j++) {
	a_seta(a_elt(eigveco, i), j, mkreal(state.symmat[j+1][i+1]));
      }
    }

    a_bind(cxt, 2, eigvalo);
    a_bind(cxt, 3, eigveco);
    a_result(cxt);

    unwind_protect_catch;
    if (!state.first) {
      free_matrix(state.symmat, state.dim, state.dim);
      free_vector(evals, state.dim);
      free_vector(interm, state.dim);
    }
    a_free(eigvalo);
    a_free(eigveco);
    unwind_protect_end;
  }
  return nil;
}

double *vector(int n) {
  // Allocate a double vector with range [1..n]. 
  double *v;

  v = (double *) malloc ((unsigned) n*sizeof(double));
  if (!v)
    a_error(PCA_ALLOC_FAIL, mkinteger(0), FALSE);
  return v-1;
}

void zeromat(double **mat, int n, int m) {
  int i, j;
  for (i = 1; i <= n; i++) {
    for (j = 1; j <= m; j++) {
      mat[i][j] = 0.0;
    }
  }
}

double **matrix(int n, int m) {
  // Allocate a double matrix with range [1..n][1..m].
  int i;
  double **mat;

  // Allocate pointers to rows. 
  mat = (double **) malloc((unsigned) (n)*sizeof(double*));
  if (!mat)
    a_error(PCA_ALLOC_FAIL, mkinteger(1), FALSE);
  mat -= 1;

  // Allocate rows and set pointers to them. 
  for (i = 1; i <= n; i++) {
    mat[i] = (double *) malloc((unsigned) (m)*sizeof(double));
    if (!mat[i])
      a_error(PCA_ALLOC_FAIL, mkinteger(2), FALSE);
    mat[i] -= 1;
  }

  // Return pointer to array of pointers to rows. 
  return mat;
}

void free_vector(double *v, int n) {
  // Free a double vector allocated by vector(). 
  free((char*) (v+1));
}

void free_matrix(double **mat, int n, int m) {
  // Free a double matrix allocated by matrix(). 
  int i;
  for (i = n; i >= 1; i--) {
    free ((char*) (mat[i]+1));
  }
  free ((char*) (mat+1));
}

void tred2(double **a, int n, double *d, double *e) {
  // Reduce a real, symmetric matrix to a symmetric, tridiag. matrix.
  // Householder reduction of matrix a to tridiagonal form.
  // Algorithm: Martin et al., Num. Math. 11, 181-195, 1968.
  // Ref: Smith et al., Matrix Eigensystem Routines -- EISPACK Guide
  //      Springer-Verlag, 1976, pp. 489-494.
  //      W H Press et al., Numerical Recipes in C, Cambridge U P,
  //      1988, pp. 373-374.	
  int l, k, j, i;
  double scale, hh, h, g, f;
	
  for (i = n; i >= 2; i--) {
    l = i - 1;
    h = scale = 0.0;
    if (l > 1) {
      for (k = 1; k <= l; k++)
	scale += fabs(a[i][k]);
      if (scale == 0.0) {
	e[i] = a[i][l];
      } else {
	for (k = 1; k <= l; k++) {
	  a[i][k] /= scale;
	  h += a[i][k] * a[i][k];
	}
	f = a[i][l];
	g = f>0 ? -sqrt(h) : sqrt(h);
	e[i] = scale * g;
	h -= f * g;
	a[i][l] = f - g;
	f = 0.0;
	for (j = 1; j <= l; j++) {
	  a[j][i] = a[i][j]/h;
	  g = 0.0;
	  for (k = 1; k <= j; k++)
	    g += a[j][k] * a[i][k];
	  for (k = j+1; k <= l; k++)
	    g += a[k][j] * a[i][k];
	  e[j] = g / h;
	  f += e[j] * a[i][j];
	}
	hh = f / (h + h);
	for (j = 1; j <= l; j++) {
	  f = a[i][j];
	  e[j] = g = e[j] - hh * f;
	  for (k = 1; k <= j; k++)
	    a[j][k] -= (f * e[k] + g * a[i][k]);
	}
      }
    } else
      e[i] = a[i][l];
    d[i] = h;
  }
  d[1] = 0.0;
  e[1] = 0.0;
  for (i = 1; i <= n; i++) {
    l = i - 1;
    if (d[i]) {
      for (j = 1; j <= l; j++) {
	g = 0.0;
	for (k = 1; k <= l; k++)
	  g += a[i][k] * a[k][j];
	for (k = 1; k <= l; k++)
	  a[k][j] -= g * a[k][i];
      }
    }
    d[i] = a[i][i];
    a[i][i] = 1.0;
    for (j = 1; j <= l; j++)
      a[j][i] = a[i][j] = 0.0;
  }
}

void tqli(double *d, double *e, int n, double **z) {
  //	Tridiagonal QL algorithm -- Implicit
  int m, l, iter, i, k;
  double s, r, p, g, f, dd, c, b;

  for (i = 2; i <= n; i++)
    e[i-1] = e[i];
  e[n] = 0.0;
  for (l = 1; l <= n; l++) {
    iter = 0;
    do {
      for (m = l; m <= n-1; m++) {
	dd = fabs(d[m]) + fabs(d[m+1]);
	if (fabs(e[m]) + dd == dd) break;
      }
      if (m != l) {
	if (iter++ == 30)
	  a_error(PCA_QL_ITER, mkinteger(iter), FALSE);
	g = (d[l+1] - d[l]) / (2.0 * e[l]);
	r = sqrt((g * g) + 1.0);
	g = d[m] - d[l] + e[l] / (g + SIGN(r, g));
	s = c = 1.0;
	p = 0.0;
	for (i = m-1; i >= l; i--) {
	  f = s * e[i];
	  b = c * e[i];
	  if (fabs(f) >= fabs(g)) {
	    c = g / f;
	    r = sqrt((c * c) + 1.0);
	    e[i+1] = f * r;
	    c *= (s = 1.0/r);
	  } else {
	    s = f / g;
	    r = sqrt((s * s) + 1.0);
	    e[i+1] = g * r;
	    s *= (c = 1.0/r);
	  }
	  g = d[i+1] - p;
	  r = (d[i] - g) * s + 2.0 * c * b;
	  p = s * r;
	  d[i+1] = g + p;
	  g = c * r - b;
	  for (k = 1; k <= n; k++) {
	    f = z[k][i+1];
	    z[k][i+1] = s * z[k][i] + c * f;
	    z[k][i] = c * z[k][i] - s * f;
	  }
	}
	d[l] = d[l] - p;
	e[l] = g;
	e[m] = 0.0;
      }
    }  while (m != l);
  }
}

void register_pca(void) {
  a_extimpl("PCABF", pcabf);
  DIMMIS_ERROR = a_register_error("Dimension mismatch");
  PCA_ALLOC_FAIL = a_register_error("PCA allocation failure");
  PCA_QL_ITER = a_register_error("Too many iterations in QL");
}
