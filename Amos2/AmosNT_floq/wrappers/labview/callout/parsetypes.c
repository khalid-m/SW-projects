#include <windows.h>
#include <stdio.h>
#include "parsetypes.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "strings.h"

int parse_types(char *typestr, TYPESTRUCT type)
{
  int i;
  size_t strptr;
  char **typearr;
  int datasize, transdatasize;

  type->datasize = type->transdatasize = 0;
  type->count = explode(&typearr, typestr, ',');;
  type->type = malloc(type->count * (sizeof (t_streamtype) + sizeof (int)));
  type->arraysize = &type->type[type->count];
  //type->arraysize = type->type + type->count * sizeof (t_streamtype);

  for (i = 0; i < type->count; ++i)
    {
      // Get type
      if (strncmp(typearr[i], "i2", 2) == 0)
	{
	  type->type[i] = INT2;
	  strptr = 2;
	  datasize = sizeof(short int);
	  transdatasize = sizeof(int);
	}
      else if (strncmp(typearr[i], "i4", 2) == 0)
	{
	  type->type[i] = INT4;
	  strptr = 2;
	  datasize = transdatasize = sizeof(int);
	}
      else if (strncmp(typearr[i], "i8", 2) == 0)
	{
	  type->type[i] = INT8;
	  strptr = 2;
	  datasize = sizeof(__int64);
	  transdatasize = sizeof(int);
	}
      else if (strncmp(typearr[i], "d", 1) == 0)
	{
	  type->type[i] = DBL;
	  strptr = 1;
	  datasize = transdatasize = sizeof(double);
	}
      else if (strncmp(typearr[i], "ci2", 3) == 0)
	{
	  type->type[i] = CINT2;
	  strptr = 3;
	  datasize = 2 * sizeof(short int);
	  transdatasize = sizeof(COMPLEX);
	}
      else
	{
	  free(typearr);
	  free(type->type);
	  //free(type->arraysize);
	  return -1;
	}

      if (strlen(typearr[i]) == strptr)
	{
	  type->arraysize[i] = 1;
	  type->datasize += datasize;
	  type->transdatasize += transdatasize;
	}
      else
	{
	  // Get array
	  type->arraysize[i] = atoi(&typearr[i][strptr + 1]);
	  type->datasize += (datasize * type->arraysize[i]);
	  type->transdatasize += (transdatasize * type->arraysize[i]);
	}
    }

  free(typearr);
  return 0;
}

void free_types(TYPESTRUCT type)
{
  free(type->type);
}
