/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: visualize.h,v $
 * $Revision: 1.3 $ $Date: 2011/11/05 11:47:36 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for sending double numarrays to external 
 * visualization.
 * ===========================================================================
 * $Log: visualize.h,v $
 * Revision 1.3  2011/11/05 11:47:36  larme597
 * Added reset functionality to virtual instruments.
 *
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

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
#include "vsq_labview.h"

typedef int (__cdecl *t_visualize_next)(double *, int32_t);
typedef int (__cdecl *t_visualize_next2)(double *, int32_t, 
					 double *, int32_t);
typedef int (__cdecl *t_visualize_next3)(double *, int32_t, 
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
  int reset;
} *VISUALIZE;

void register_visualize();

#endif
