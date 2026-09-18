/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: ssdm.h,v $
 * $Revision: 1.5 $ $Date: 2013/02/04 12:22:53 $
 * $State: Exp $ $Locker:  $
 *
 * Description: C interface to SSDM, not part of ssdm.dll project
 * ===========================================================================
 * $Log: ssdm.h,v $
 * Revision 1.5  2013/02/04 12:22:53  andan342
 * Syntax fix
 *
 * Revision 1.4  2013/02/01 12:01:12  andan342
 * Added interface to create proxies
 *
 * Revision 1.3  2012/12/17 19:58:42  andan342
 * Added "reverseStorage" option to map easily from column-major storage order
 *
 * Revision 1.2  2012/12/15 01:08:23  andan342
 * Added NMA constructor C interface
 *
 * Revision 1.1  2012/12/13 20:51:00  andan342
 * Implemented C callin interface for in-memory NMA objects
 *
 *
 ****************************************************************************/

#include "storage.h"

#define NMA_INTEGER 0
#define NMA_DOUBLE 1
#define NMA_COMPLEX 2
#define NMA_AUTO -1

EXTERN int NMATYPE;

// Constructor
EXPORT oidtype make_nma0(int ndims);
EXPORT void nma_setdim(oidtype x, int i, int size);
EXPORT void nma_init(oidtype x, int kind, int reverseStorage);
EXPORT void nma_initProxy(oidtype x, int kind, int proxyTag, oidtype s);

// Metadata access
EXPORT int nma_ndims(oidtype x);
EXPORT int nma_dim(oidtype x, int i);
EXPORT int nma_kind(oidtype x);
EXPORT int nma_kind2elemsize(int kind);
EXPORT int nma_proxytag(oidtype x);

// Iterator interface
EXPORT void nma_iter_reset(oidtype x);
EXPORT int nma_iter_next(oidtype x);
EXPORT void nma_iter_setidx(oidtype x, int i, int idx);
EXPORT int nma_iter_getidx(oidtype x, int i);

// Obtaining pointers to NMA elements
EXPORT void* nma_iter2pointer(oidtype x);

