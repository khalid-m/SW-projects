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

typedef void (__cdecl *t_fixstream_open)(char *);
typedef void (__cdecl *t_fixstream_next)(uint8_t *, int32_t);
typedef void (__cdecl *t_fixstream_close)();

typedef struct
{
  t_fixstream_open open;
  t_fixstream_next next;
  t_fixstream_close close;
  t_typestruct type;

  HANDLE thread_id;
  BARRIER barrier, endbarrier;
  uint8_t *data;
  uint8_t *transdata[2];
} t_fixstream, *FIXSTREAM;

oidtype call_fixstream(a_callcontext cxt);

oidtype bind_fixstreamfn(bindtype env, oidtype val);

void register_fixstream();

#endif
