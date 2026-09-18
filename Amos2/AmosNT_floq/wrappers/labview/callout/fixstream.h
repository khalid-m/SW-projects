#ifndef __fixstream__
#define __fixstream__

#include <extcode.h>
#include <windows.h>
#include "scsq.h"
#include "parsetypes.h"
#include "buildtuple.h"
#include "language.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "threadbarrier.h"
#include "fixstream_labview.h"
#include "vi.h"

int fixstreamtype;
int fixstreamerror;

typedef struct fixstreamcell
{
  objtags tags;
  oidtype vi;
  t_typestruct type;
  BARRIER barrier, endbarrier;
  uint8_t *data;
  uint8_t *transdata[2];
  int current;
} *FIXSTREAM;

void register_fixstream();

#endif
