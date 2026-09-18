/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: visualize_stream.h,v $
 * $Revision: 1.1 $ $Date: 2011/12/14 18:21:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for sending double numarrays to external 
 * visualization.
 * ===========================================================================
 * $Log: visualize_stream.h,v $
 * Revision 1.1  2011/12/14 18:21:14  larme597
 * *** empty log message ***
 *
 * Revision 1.3  2011/11/05 11:47:36  larme597
 * Added reset functionality to virtual instruments.
 *
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

#ifndef __visualize_stream__
#define __visualize_stream__

#include <extcode.h>
#include "threadbarrier.h"

typedef int (__cdecl *t_visualize_stream_next)(unsigned int *, int32_t);

#include "lv_prolog.h"

typedef struct
{
  int32_t dimSize;
  double elt[1];
} TD1, **TD1Hdl;

#include "lv_epilog.h"

typedef union
{
  int i;
  double d;
  LStrHandle str;
  TD1Hdl arr1DD;
} t_stored_value;

typedef struct
{
  BARRIER barrier, endbarrier;
  t_stored_value *stored_value[2];
  unsigned int *data[2];
  int current;
  int arity;
  int error;
  int reset;
  int callback;
  double callback_value;
} t_visualize_stream, *VISUALIZE_STREAM;

void register_visualize_stream();

#endif
