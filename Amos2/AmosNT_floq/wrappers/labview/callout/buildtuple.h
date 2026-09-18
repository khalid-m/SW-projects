#ifndef __buildtuple__
#define __buildtuple__

#include "scsq.h"
#include "parsetypes.h"
#include <extcode.h>

void build_data(TYPESTRUCT type, uint8_t *indata, uint8_t *outdata);

void build_tuple(oidtype v, TYPESTRUCT type, uint8_t *data);

#endif
