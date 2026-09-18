#ifndef __visualize__
#define __visualize__

#include <extcode.h>
#include <windows.h>
#include "scsq.h"
#include "parsetypes.h"
#include "language.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "threadbarrier.h"
#include "visualize_labview.h"

typedef void (__cdecl *t_visualize_next)(double *, int32_t);
typedef void (__cdecl *t_visualize_next2)(double *, int32_t, 
					  double *, int32_t);
typedef void (__cdecl *t_visualize_next3)(double *, int32_t, 
					  double *, int32_t, 
					  double *, int32_t);

int visualizetype;
int visualizeerror;

typedef struct visualizecell
{
  objtags tags;
  BARRIER barrier, endbarrier;
  int initialized;
  double *data[2][3];
  int arity;
  int32_t numelems[3];
  int current;
} *VISUALIZE;

void register_visualize();

#endif
