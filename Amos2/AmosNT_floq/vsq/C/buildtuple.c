/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: buildtuple.c,v $
 * $Revision: 1.3 $ $Date: 2011/12/14 18:19:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: "build_data" converts byte array to contain data that is
 *              easier to parse into scsq types.
 *              "build_tuple" converts byte array into variables
 *              recognized by scsq.
 * ===========================================================================
 * $Log: buildtuple.c,v $
 * Revision 1.3  2011/12/14 18:19:42  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "buildtuple.h"
#include "parsetypes.h"
#include "numarray.h"
#include "fftcomplex.h"

void build_data(TYPESTRUCT type, uint8_t *indata, uint8_t *outdata)
{
  int i, j;
  short int *li2;
  int *li4;
  COMPLEX *r;
  int size;

  for (i = 0; i < type->count; ++i)
    {
      switch (type->type[i])
	{
	case INT2:
	  li2 = (short int *) indata;
	  li4 = (int *) outdata;
	  for (j = 0; j < type->arraysize[i]; ++j)
	    li4[j] = (int) li2[j];
	  indata += (sizeof(short int) * type->arraysize[i]);
	  outdata += (sizeof(int) * type->arraysize[i]);
	  break;
	case INT4:
	  size = sizeof(int) * type->arraysize[i];
	  memcpy(outdata, indata, size);
	  indata += size;
	  outdata += size;
	  break;
	case DBL:
	  size = sizeof(double) * type->arraysize[i];
	  memcpy(outdata, indata, size);
	  indata += size;
	  outdata += size;
	  break;
	case CINT2:
	  r = (COMPLEX *) outdata;
	  for (j = 0; j < type->arraysize[i]; ++j)
	    {
	      r[j].re = *(short int *) indata;
	      indata += sizeof(short int);
	      r[j].im = *(short int *) indata;
	      indata += sizeof(short int);
	    }
	  outdata += (sizeof(COMPLEX) * type->arraysize[i]);
	  break;
	}
    }
}

void build_tuple(oidtype v, TYPESTRUCT type, uint8_t *data)
{
  oidtype oid;
  struct numarraycell *dr;
  int i;

  for (i = 0; i < type->count; ++i)
    {
      switch (type->type[i])
	{
	case INT2:
	case INT4:
	  if (type->arraysize[i] > 1)
	    {
	      oid = make_numarray(type->arraysize[i], sizeof(int), 0);
	      dr = dr(oid, numarraycell);

	      memcpy(dr->cont, data, sizeof(int) * type->arraysize[i]);
	      data += (sizeof(int) * type->arraysize[i]);
	      a_seta(v, i, oid);
	    }
	  else
	    {
	      a_seta(v, i, mkinteger(*(int *) data));
	      data += sizeof(int);
	    }
	  break;
	case DBL:
	  oid = make_numarray(type->arraysize[i], sizeof(double), 1);
	  dr = dr(oid, numarraycell);

	  memcpy(dr->cont, data, sizeof(double) * type->arraysize[i]);
	  data += (sizeof(double) * type->arraysize[i]);
	  a_seta(v, i, oid);
	  break;
	case CINT2:
	  oid = make_numarray(type->arraysize[i], sizeof(COMPLEX), 2);
	  dr = dr(oid, numarraycell);

	  memcpy(dr->cont, data, sizeof(COMPLEX) * type->arraysize[i]);
	  data += (sizeof(COMPLEX) * type->arraysize[i]);
	  a_seta(v, i, oid);
	  break;
	}
    }
}
