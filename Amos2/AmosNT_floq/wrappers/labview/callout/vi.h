#ifndef __vi__
#define __vi__

#include <windows.h>
#include "extcode.h"
#include "callout_vi.h"
#include "scsq.h"
#include "visualize.h"

int vitype;
int vierror;

typedef struct vicell
{
  objtags tags;
  oidtype name;
  LVRefNum ref;
  int isopen;
  HMODULE vi_lib;

  // Pointer to data to use
  void *vi_data;
} *VI;

oidtype vi_openfn(oidtype);
oidtype vi_closefn(oidtype);
oidtype vi_runfn(oidtype);

void register_vi();

#endif
