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

typedef void (__cdecl *t_visualize_next)(LVRefNum *, double *, int32_t);
typedef void (__cdecl *t_visualize_next2)(LVRefNum *, double *, int32_t, 
					       double *, int32_t);
typedef void (__cdecl *t_visualize_next3)(LVRefNum *, double *, int32_t, 
					       double *, int32_t, 
					       double *, int32_t);

typedef struct
{
  t_visualize_next next;
  t_visualize_next2 next2;
  t_visualize_next3 next3;

  HANDLE thread_id;
  BARRIER barrier, endbarrier;
  int initialized;
  double *data[2][3];
  int arity;
  int numelems[3];
  int current;
} t_visualize, *VISUALIZE;

oidtype call_visualize(a_callcontext cxt);

oidtype bind_visualizefn(bindtype env, oidtype val);

void register_visualize();

#endif
