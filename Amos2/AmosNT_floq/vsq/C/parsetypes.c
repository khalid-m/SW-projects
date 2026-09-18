/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: parsetypes.c,v $
 * $Revision: 1.3 $ $Date: 2011/12/14 18:19:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions for setting prototype of fixstream().
 * ===========================================================================
 * $Log: parsetypes.c,v $
 * Revision 1.3  2011/12/14 18:19:43  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include <windows.h>
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
