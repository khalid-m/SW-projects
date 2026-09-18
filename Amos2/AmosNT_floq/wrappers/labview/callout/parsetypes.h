#ifndef __parsetypes__
#define __parsetypes__

#include "scsq.h"
#include <extcode.h>

typedef enum
{
  INT2,
  INT4,
  INT8,
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
