/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Andrej Andrejev, UDBL
 * $RCSfile: nma.h,v $
 * $Revision: 1.16 $ $Date: 2013/11/23 22:56:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Multidimensonal arrays based on NumArray
 ****************************************************************************
 * $Log: nma.h,v $
 * Revision 1.16  2013/11/23 22:56:01  andan342
 * - moved fragment mapper facility into nma.c
 * - added ALisp functions nma-copy, nma-vsum, nmau-scale, nma-scale, nmau-roundto, nma-roundto, nma-round
 *
 * Revision 1.15  2013/07/28 06:23:10  andan342
 * Moved array chunk file generation from dumper.lsp to nma-filedump function in C
 *
 * Revision 1.14  2013/07/12 12:41:38  andan342
 * Added hexadecimal string option to store binary data on SQL backend
 *
 * Revision 1.13  2013/02/21 23:33:02  andan342
 * Renamed NMA-PROXY-RESOLVE to APR, using it to define all non-aggregate SciSparql foreign functions as proxy-tolerant
 *
 * Revision 1.12  2013/02/12 23:50:50  andan342
 * Added nma-proxy-has-cache and nma-cache-put functions
 *
 * Revision 1.11  2013/02/08 00:46:44  andan342
 * Added C implementation of NMA chunk cache and NMA-PROXY-RESOLVE
 *
 * Revision 1.10  2013/02/05 21:58:06  andan342
 * Projecting NMA descriptors and proxies with C functions nma-project---+ and nma-project--++
 *
 * Revision 1.9  2013/02/05 14:12:31  andan342
 * Renamed nma-init to nma-fill (more general behavior), nma-allocate now takes extra argument,
 * implemented RDF:SUM and RDF:AVG aggregate functions in C
 *
 * Revision 1.8  2013/02/04 12:22:14  andan342
 * Implemented vector sum for NMAs
 *
 * Revision 1.7  2013/02/01 12:00:09  andan342
 * Using same NMA descriptor objects as proxies, major code makeup
 *
 * Revision 1.6  2012/12/13 20:51:26  andan342
 * Implemented C callin interface for in-memory NMA objects
 *
 * Revision 1.5  2012/11/26 01:07:03  andan342
 * Added more safety checks, generalized nma-elemsize to nma-kind2elemsize
 *
 * Revision 1.4  2012/11/20 15:11:38  andan342
 * Avoid complete printing of arrays bigger than NMA_PRINT_LIMIT = 128 elements
 *
 * Revision 1.3  2012/10/29 22:29:27  andan342
 * Storing NMAs in ArrayChunks table using new BLOB<->BINARY functionality of JDBC interface
 *
 * Revision 1.2  2012/03/27 10:26:56  andan342
 * Added C implementations of array aggregates
 *
 * 
 *****************************************************************************/

#include "amos.h"
#include "storage.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "binary.h"

#include "nma_chunks.h"

EXPORT int NMATYPE, NMA_NODIM_ERROR, NMA_DIM_ERROR, NMA_STEP_ERROR, NMA_READER_ERROR, NMA_PROXY_ERROR, NMA_PROXYTAG_ERROR;

struct dimdata {
  int no, //physical nesting order
      size, //size of array in this dimension
      am, //access multiplier (derived)
			lo, //lower bound of projection
			step, //step of projection
			psize, //size of projection (derived)
			iter; //iterator position
};

struct nmacell
{
  objtags tags;
  oidtype s; //numarray as storage, any lisp data if proxy
  int ndims, //number of dimensions
      offset, //overall storage offset
			kind, //0=int, 1=double, 2=complex
			isOriginal, //1 if referes to all elements of (external) storage object,
			proxyTag; //0 if not a proxy, proxy type tag otherwise
	struct NMACacheRec* pCache;
  struct dimdata dims[1]; //dimdata for each dimension
};

/// nma_chunks declarations

struct NMACacheRec
{
	struct NMACacheRec* pNext;
	clock_t rut; //recently-used timestamp
	int cnt; //size of chunks array
	long bytes; //total size of all cached BINARY objects	
	oidtype s; //lisp value identifying the array
	oidtype chunks[1];
};

#define NMA_PROXYTAG_TABLE_SIZE 4

struct NMAProxyTagTableRec {
	oidtype resolveFn, getChunkFn, cacheChunksByPatternFn;
	int defaultChunkSize;
};

oidtype aprfn(bindtype env, oidtype x);

/// end of nma_chunks decalarations

static int NMA_PRINT_LIMIT = 128; //elements

void register_nma(void);

/* NMA interface */

oidtype nma_allocate(oidtype x, int minKind);
oidtype nma_copy(oidtype x);

/* NMA cell C interface */

int nmacell_elemcnt(struct nmacell *dx);
int nmacell_original_elemcnt(struct nmacell *dx);
void nmacell_fill_rec(bindtype env, struct nmacell *dx, oidtype list, int k);
int nmacell_compareDims(struct nmacell *dx, struct nmacell *dy);

/* NMA iterator C interface */
void nmacell_iter_setidx(struct nmacell* dx, int k, int idx);
void nmacell_iter_reset(struct nmacell* dx);
int nmacell_iter_next(struct nmacell* dx);
int nmacell_iter2si(struct nmacell* dx);
int nmacell_yiter2xsi(struct nmacell* dx, struct nmacell* dy);

/* NMA fragment mapper interface */
typedef int (*NMAFragmentMapper)(oidtype x, int si, int fsize, void *xa);

int nmacell_get_ibd_fsize(struct nmacell *dx, int *fsize);
void nma_mapfragments(oidtype x, NMAFragmentMapper mapperFn, void *xa);