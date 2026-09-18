/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: parsetypes.h,v $
 * $Revision: 1.3 $ $Date: 2011/12/14 18:21:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions for setting prototype of fixstream().
 * ===========================================================================
 * $Log: parsetypes.h,v $
 * Revision 1.3  2011/12/14 18:21:13  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:32:36  larme597
 * Added headers.
 *
 ****************************************************************************/

#ifndef __parsetypes__
#define __parsetypes__

#include "callout.h"
#include "extcode.h"

typedef enum
{
  INT2,
  INT4,
  DBL,
  CINT2
} t_streamtype;

typedef struct
{
  int count;
  int32_t datasize;
  int32_t transdatasize;
  t_streamtype *type;
  int *arraysize;
} t_typestruct, *TYPESTRUCT;

int parse_types(char *typestr, TYPESTRUCT type);

void free_types(TYPESTRUCT type);

#endif
