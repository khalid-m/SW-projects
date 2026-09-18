/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Andrej Andrejev, UDBL
 * $RCSfile: nma.c,v $
 * $Revision: 1.27 $ $Date: 2013/11/23 22:56:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Multidimensonal arrays based on NumArray
 ****************************************************************************
 * $Log: nma.c,v $
 * Revision 1.27  2013/11/23 22:56:01  andan342
 * - moved fragment mapper facility into nma.c
 * - added ALisp functions nma-copy, nma-vsum, nmau-scale, nma-scale, nmau-roundto, nma-roundto, nma-round
 *
 * Revision 1.26  2013/02/21 23:33:01  andan342
 * Renamed NMA-PROXY-RESOLVE to APR, using it to define all non-aggregate SciSparql foreign functions as proxy-tolerant
 *
 * Revision 1.25  2013/02/08 00:46:43  andan342
 * Added C implementation of NMA chunk cache and NMA-PROXY-RESOLVE
 *
 * Revision 1.24  2013/02/05 21:58:06  andan342
 * Projecting NMA descriptors and proxies with C functions nma-project---+ and nma-project--++
 *
 * Revision 1.23  2013/02/05 14:12:31  andan342
 * Renamed nma-init to nma-fill (more general behavior), nma-allocate now takes extra argument,
 * implemented RDF:SUM and RDF:AVG aggregate functions in C
 *
 * Revision 1.22  2013/02/04 12:22:14  andan342
 * Implemented vector sum for NMAs
 *
 * Revision 1.21  2013/02/01 12:00:09  andan342
 * Using same NMA descriptor objects as proxies, major code makeup
 *
 * Revision 1.20  2013/01/11 17:29:19  andan342
 * DUMPBINARY added
 *
 * Revision 1.19  2012/12/17 19:59:05  andan342
 * Added "reverseStorage" option to map easily from column-major storage order
 *
 * Revision 1.18  2012/12/15 01:07:53  andan342
 * Added NMA constructor C interface
 *
 * Revision 1.17  2012/12/13 20:51:26  andan342
 * Implemented C callin interface for in-memory NMA objects
 *
 * Revision 1.16  2012/12/02 18:41:42  andan342
 * Fixed memory leak when emitting BINARY objects
 *
 * Revision 1.15  2012/11/26 01:07:02  andan342
 * Added more safety checks, generalized nma-elemsize to nma-kind2elemsize
 *
 * Revision 1.14  2012/11/20 20:03:11  andan342
 * Fixed a bug when NMA storage was relocated after emit - referring to OIDs
 *
 * Revision 1.13  2012/11/20 15:11:38  andan342
 * Avoid complete printing of arrays bigger than NMA_PRINT_LIMIT = 128 elements
 *
 * Revision 1.12  2012/10/31 00:39:50  andan342
 * Added safety checks
 *
 * Revision 1.11  2012/10/30 17:17:41  andan342
 * Added nma-elemsize function
 *
 * Revision 1.10  2012/10/29 22:29:27  andan342
 * Storing NMAs in ArrayChunks table using new BLOB<->BINARY functionality of JDBC interface
 *
 * Revision 1.9  2012/03/27 14:02:19  andan342
 * Made 'talk.sparql queries work
 *
 * Revision 1.8  2012/03/27 10:26:56  andan342
 * Added C implementations of array aggregates
 *
 * Revision 1.7  2012/03/19 22:02:52  andan342
 * Fixed memory leaks, excessive calls, configurability
 *
 * Revision 1.6  2012/03/17 14:22:59  andan342
 * Added NMA-DUMP,
 * Fixed precision loss when printing/dumping
 *
 * Revision 1.5  2011/08/09 21:21:18  andan342
 * Added new dereference-or-project functionality, AmosQL functions Aref and ASub to translate SciSparQL array expressions to
 *
 * Revision 1.4  2011/07/06 16:19:22  andan342
 * Added array transposition, projection and selection operations, changed printer and reader.
 * Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
 * Added Lisp testcases for this and one SparQL query with array variables
 *
 * Revision 1.3  2011/06/01 06:15:50  andan342
 * Defined basic AmosQL functions to handle Numeric Multidimensional Arrays
 *
 * Revision 1.2  2011/05/31 15:27:43  andan342
 * - changed dimension and index arguments from vectors to lists
 * - implemented reversible printer and lisp-based reader
 * - utilizing garbage collection
 *
 * Revision 1.1  2011/05/30 11:17:16  andan342
 * Implemented multidimensional array storage as NMA type
 *
 * Revision 1.1  2011/05/29 00:01:41  andan342
 * Added stub MS Visual Studion 6.0 project for SQoND storage extensions
 *
 * Revision 1.4  2006/02/13 07:37:48  torer
 *
 ****************************************************************************/

#include "nma.h"

EXPORT int NMATYPE, // Numeric multidimensional array
           NMA_NODIM_ERROR, NMA_DIM_ERROR, NMA_STEP_ERROR;  

///////////// CONSTRUCTORS

oidtype alloc_nma(int ndims)
{ // Allocate new nmacell
	return new_object(sizeof(struct nmacell)+sizeof(struct dimdata)*(ndims-1), NMATYPE);
}

int nmacell_elemcnt(struct nmacell *dx)
{ // Return number of elements
	int k, res = 1;
	for (k=0; k<dx->ndims; k++) { 
		res *= dx->dims[k].psize; 
	}
	return res;
}

int nmacell_original_elemcnt(struct nmacell *dx)
{ // Return number of elements in original array
	int k, res = 1;
	for (k=0; k<dx->ndims; k++) { 
		res *= dx->dims[k].size; 
	}
	return res;
}

void nmacell_update_ams(struct nmacell *dac) 
{ // Update access multipliers for logical dimensions 
	int i,j;

	for (i=0; i < dac->ndims; i++) {
		dac->dims[i].am = 1;
		for (j=0; j < dac->ndims; j++) 
			if (dac->dims[j].no > dac->dims[i].no)
				dac->dims[i].am *= dac->dims[j].size;
	}
}			

EXPORT oidtype make_nma0(int ndims)
{ // create descriptor object
	oidtype res = alloc_nma(ndims);
	struct nmacell *dres = dr(res, nmacell);
	dres->ndims = ndims;
	dres->offset = 0;
	dres->pCache = NULL;
	return res;
}

EXPORT void nma_setdim(oidtype x, int i, int size)
{ // set array dimensions (called between make_nma0 and nma_init)
	struct nmacell *dx = dr(x, nmacell);
	dx->dims[i].no = i;
	dx->dims[i].size = size;
	dx->dims[i].lo = 0; //trivial projection
	dx->dims[i].step = 1;
	dx->dims[i].psize = size;
}

EXPORT void nma_init(oidtype x, int kind, int reverseStorage)
{ // create storage object for given dimensions
	struct nmacell *dx = dr(x, nmacell);
	oidtype na = nil;
	int k;

	if (reverseStorage)
		for (k=0; k<dx->ndims; k++) 
			dx->dims[k].no = dx->ndims - 1 - dx->dims[k].no;

	nmacell_update_ams(dx);
	a_let(na, make_numarray(nmacell_elemcnt(dx), numarray_elemsize(kind), kind));	
	dx = dr(x, nmacell); 
	dx->kind = kind;
	dx->isOriginal = 1;
	dx->proxyTag = 0; // creating resident NMA, not a proxy
	a_let(dx->s, na);
	a_free(na);
}

EXPORT void nma_initProxy(oidtype x, int kind, int proxyTag, oidtype s)
{ // make descriptor (with dimensions) a proxy nma
	struct nmacell *dx = dr(x, nmacell);
	nmacell_update_ams(dx);
	dx->kind = kind;
	dx->isOriginal = 1;
	dx->proxyTag = proxyTag;
	a_let(dx->s, s);
}	

oidtype make_nma1(bindtype env, oidtype dims)    
{ // Construct new array with dimensions provided by dims list (called before nma_init) 
	int ndims, i, size;	
	oidtype res;

	if (dims == nil) lerror(NMA_NODIM_ERROR, dims, env);
	OfType(dims, LISTTYPE, env);
	
	ndims = a_length(dims); 	
	res = make_nma0(ndims);
	for (i=0; i < ndims; i++) {
		OfType(hd(dims), INTEGERTYPE, env);
		size = getinteger(hd(dims));
		if (size <= 0) lerror(NMA_DIM_ERROR, hd(dims), env);
		nma_setdim(res, i, size);
		dims = tl(dims);
	} 
	return res;
}

oidtype make_nmafn(bindtype env, oidtype kind, oidtype dims)
{ // ALisp: construct new array of given kind with given dimensions (provided in list)
	oidtype res = make_nma1(env, dims);

	OfType(kind, INTEGERTYPE, env);	

	nma_init(res, getinteger(kind), 0);
	return res;
}

oidtype make_nmaProxyfn(bindtype env, oidtype kind, oidtype dims, oidtype proxyTag, oidtype s)
{ // ALisp: construct new array proxy of given kind, with given dimensions (provided in list), tag and S data
	oidtype res = make_nma1(env, dims);
	int dproxyTag;

	OfType(kind, INTEGERTYPE, env);
	OfType(proxyTag, INTEGERTYPE, env);

	dproxyTag = getinteger(proxyTag);
	if (!dproxyTag) lerror(NMA_PROXYTAG_ERROR, proxyTag, env);
	nma_initProxy(res, getinteger(kind), dproxyTag, s);
	return res;
}

///////////// CLONE, ALLOCATE & COPY

oidtype nma_clone(oidtype x)
{ // copy all NMA attributes except dimdata in DIMS
	oidtype res = alloc_nma(dr(x, nmacell)->ndims);
	struct nmacell *dx = dr(x, nmacell),
								 *dres = dr(res, nmacell);

	dres->kind = dx->kind;
	dres->isOriginal = 0; 
	dres->proxyTag = dx->proxyTag;
	dres->ndims = dx->ndims;
	dres->offset = dx->offset;
	dres->pCache = dx->pCache;
	a_let(dres->s, dx->s);
	return res;
}

oidtype nma_allocate(oidtype x, int newKind)
{ // create an empty resident NMA to contain subset described by X, 
	// with element type newKind or the original if newKind<0
	struct nmacell *dx;
	oidtype res;
	int ndims = dr(x, nmacell)->ndims,
		  k;

	if (!ndims) ndims = 1; // if proxy points to an element -> create singleton array
	res = make_nma0(ndims);

	dx = dr(x, nmacell);
	if (dx->ndims)
		for (k=0; k < dx->ndims; k++)
			nma_setdim(res, k, dx->dims[k].psize);
	else nma_setdim(res, 0, 1);

	nma_init(res, (newKind < 0)? dx->kind : newKind, 0);
	return res;
}

oidtype nma_allocatefn(bindtype env, oidtype x, oidtype newKind)
{ // ALisp: create an empty resident NMA to contain subset described by X, 
	// with element type at least as wide as minKind
	OfType(x, NMATYPE, env);
	OfType(newKind, INTEGERTYPE, env);

	return nma_allocate(x, getinteger(newKind));
}

struct NMACopyMapperData {
	char *xcont, *rescont;
	int elemsize;
};

int nma_copy_mapper(oidtype x, int si, int fsize, void *xa)
{
	struct NMACopyMapperData *data = xa;
	int fsize_b = fsize * data->elemsize;

	memcpy(data->rescont, data->xcont + (si * data->elemsize), fsize_b);
	data->rescont += fsize_b;
	return 0;
}

oidtype nma_copy(oidtype x)
{ // create a copy of (subset of) NMA described by X
	oidtype res;
	struct NMACopyMapperData data;
	int kind = dr(x, nmacell)->kind;

	res = nma_allocate(x, kind);

	data.xcont = (char*) dr(dr(x, nmacell)->s, numarraycell)->cont;
	data.rescont = (char*) dr(dr(res, nmacell)->s, numarraycell)->cont;	
	data.elemsize = numarray_elemsize(kind);

	nma_mapfragments(x, nma_copy_mapper, (void*)&data);
	return res;
}

oidtype nma_copyfn(bindtype env, oidtype x)
{ // ALisp: create a copy of (subset of) NMA described by X
	OfType(x, NMATYPE, env);

	return nma_copy(x);
}

///////// DESTRUCTOR

void dealloc_nma(oidtype x) 
{
//	printf("Deallocating NMA(%d)\n",nmacell_elemcnt(dr(x,nmacell))); //DEBUG
	a_free(dr(x, nmacell)->s); //either storage object or proxy data
  dealloc_object(x); 
}

///////// PROJECTING LOGICAL INDEX (vector of subscripts) TO STORAGE INDEX

int nmacell_projectidx(struct nmacell *dx, int idx, int k)
{
	return idx * dx->dims[k].step + dx->dims[k].lo;
}

oidtype nma_idxs2si(bindtype env, oidtype x, oidtype idxs) 
{ //transform idxs list into storage index
	int nidxs, i, idx, si;
  struct nmacell *dx = dr(x, nmacell);

  nidxs = a_length(idxs);
  if (nidxs != dx->ndims) lerror(NMA_DIM_ERROR, idxs, env); // TODO: move this check into the loop below
  si = dx->offset;
  for (i=0; i<nidxs; i++) { // use access multipliers to calculate storage index
		idx = getinteger(hd(idxs)); //TODO: add type checks
		if ((idx < 0)||(idx >= dx->dims[i].psize)) lerror(NUMOOB_ERROR, idxs, env);
    si += nmacell_projectidx(dx, idx, i) * dx->dims[i].am;
		idxs = tl(idxs);
	}
	return mkinteger(si);
}

//////////// FIELD ACCESSORS

EXPORT int nma_ndims(oidtype x)
{ // get number of dimensions
  return dr(x, nmacell)->ndims;
}

oidtype nma_ndimsfn(bindtype env, oidtype x)
{ // ALisp: get number of dimensions
	OfType(x, NMATYPE, env);
  return mkinteger(nma_ndims(x));
}

EXPORT int nma_dim(oidtype x, int i)
{ // get i-th dimension
  return dr(x, nmacell)->dims[i].psize;
}

oidtype nma_dimfn(bindtype env, oidtype x, oidtype i)
{ // ALisp: get i-th dimension
  int di;

	OfType(x, NMATYPE, env);
  OfType(i, INTEGERTYPE, env);
  di = getinteger(i);
  if (di >= nma_ndims(x)) lerror(NMA_DIM_ERROR, i, env);
  return mkinteger(nma_dim(x, di));
}

oidtype nma_eltfn(bindtype env, oidtype x, oidtype idxs)
{ // ALisp: get element corresponding to the vector of subscripts IDXS
	oidtype si, res;
	
	OfType(x, NMATYPE, env);
	a_let(si, nma_idxs2si(env,x,idxs));	
  res = naeltfn(env, dr(x, nmacell)->s, si); // access NumArray storage with scalar 'si' index
	a_free(si);
	return res;
}

oidtype nma_setfn(bindtype env, oidtype x, oidtype idxs, oidtype val) //TODO: check VAL type and coerse if necessary
{ // ALisp: set element corresponding to the vector of subscripts IDXS
	oidtype si;
	
	OfType(x, NMATYPE, env); 
	a_let(si, nma_idxs2si(env,x,idxs));
  nasetafn(env, dr(x, nmacell)->s, si, val); // access NumArray storage with scalar 'si' index
	a_free(si);
	return x;
}

oidtype nma_sfn(bindtype env, oidtype x)
{ // ALisp: get storage or proxy S object
	OfType(x, NMATYPE, env); 
  return dr(x, nmacell)->s;
}

EXPORT int nma_kind(oidtype x)
{ // get NMA kind
  return dr(x, nmacell)->kind;
}

oidtype nma_kindfn(bindtype env, oidtype x)
{ // ALisp: get NMA kind
	OfType(x, NMATYPE, env);
  return mkinteger(nma_kind(x));
}

EXPORT int nma_kind2elemsize(int kind)
{ // get element size for NMA kind
  return numarray_elemsize(kind);
}

oidtype nma_kind2elemsizefn(bindtype env, oidtype kind)
{ // ALisp: get element size for NMA kind
	OfType(kind, INTEGERTYPE, env);
  return mkinteger(nma_kind2elemsize(getinteger(kind)));
}

EXPORT int nma_proxytag(oidtype x)
{ // get NMA proxy tag (0 if resident)
  return dr(x, nmacell)->proxyTag;
}

oidtype nma_proxytagfn(bindtype env, oidtype x)
{ // ALisp: get NMA proxy tag (0 if resident)
	OfType(x, NMATYPE, env);
  return mkinteger(nma_proxytag(x));
}

oidtype nma_isOriginalfn(bindtype env, oidtype x)
{ // ALisp: return T if NMA refers to all elements of its storage object (i.e. no subsets defined)
	OfType(x, NMATYPE, env);
	if (dr(x, nmacell)->isOriginal) return t;
	else return nil;
}

oidtype nma_elemcntfn(bindtype env, oidtype x)
{ // ALisp: return total number of elements
	OfType(x, NMATYPE, env);
	return mkinteger(nmacell_elemcnt(dr(x, nmacell)));
}

//////////////// ITERATOR FUNCTIONALITY

void nmacell_iter_reset(struct nmacell *dx)
{ // Start array iteration
	int i;

	for (i=0; i < dx->ndims; i++)
		dx->dims[i].iter = 0;
}

EXPORT void nma_iter_reset(oidtype x)
{ // start array iteration
	nmacell_iter_reset(dr(x, nmacell));
}

oidtype nma_iter_resetfn(bindtype env, oidtype x)
{ // ALisp: start array iteration
	OfType(x, NMATYPE, env);
	nma_iter_reset(x);
	return nil;
}

void nmacell_iter_setidx(struct nmacell* dx, int k, int idx)
{ // Set iterator index
	dx->dims[k].iter = idx;
}

EXPORT void nma_iter_setidx(oidtype x, int k, int idx)
{ // set iterator index
	nmacell_iter_setidx(dr(x, nmacell), k, idx);
}

EXPORT int nma_iter_getidx(oidtype x, int k)
{ // get iteratior index 
	return dr(x, nmacell)->dims[k].iter;
}

int nmacell_iter_next(struct nmacell* dx)
{ // Iterate through array, return 0 if end of iteration
	int i;

	for (i=dx->ndims-1; i>=0; i--)
	{
		dx->dims[i].iter++;
		if (dx->dims[i].iter == dx->dims[i].psize) 
			dx->dims[i].iter = 0;
		else return 1; //return 1 if iterated normally at some depth
	}
	return 0; //return 0 if set all ITER values to 0 (end of iteration)
}

EXPORT int nma_iter_next(oidtype x)
{ // iterate through array, return 0 if end of iteration
	return nmacell_iter_next(dr(x, nmacell));
}

oidtype nma_iter_nextfn(bindtype env, oidtype x)
{ // ALisp: iterate through array, return 0 if end of iteration
	OfType(x, NMATYPE, env);
	if (nma_iter_next(x) > 0) return t;
	else return nil;
}

int nmacell_yiter2xsi(struct nmacell* dx, struct nmacell* dy)
{ // get X storage index similarly to nma_idxs2si, use iterator of Y
	// assume all Y iterator subscripts are valid for X
	int i, res; 

	res = dx->offset;
	for (i=0; i<dx->ndims; i++)
		res += nmacell_projectidx(dx, dy->dims[i].iter, i) * dx->dims[i].am;
	return res;
}

int nmacell_iter2si(struct nmacell* dx)
{ // get storage index similarly to nma_idxs2si
	return nmacell_yiter2xsi(dx, dx);	
}

EXPORT void* nma_iter2pointer(oidtype x)
{ // get pointer to iterator's current element
	struct nmacell *dx = dr(x, nmacell);
	struct numarraycell *ds = dr(dx->s, numarraycell);
	char* base = (char*)(ds->cont);
	return base + nmacell_iter2si(dx) * nma_kind2elemsize(ds->kind);
}

oidtype nma_iter_curfn(bindtype env, oidtype x)
{ // ALisp: get iterator's current element
	struct nmacell *dx = dr(x, nmacell);
	oidtype si, res;
	
	OfType(x, NMATYPE, env);
	a_let(si, mkinteger(nmacell_iter2si(dx)));
  res = naeltfn(env, dx->s, si); // access NumArray storage with scalar 'si' index
	a_free(si);
	return res;
}

oidtype nma_iter_setcurfn(bindtype env, oidtype x, oidtype val) //TODO: check VAL type and coerse if necessary
{ // ALisp: set iterator's current element
	struct nmacell *dx = dr(x, nmacell);
	oidtype si;
	
	OfType(x, NMATYPE, env);
	a_let(si, mkinteger(nmacell_iter2si(dx)));
  nasetafn(env, dx->s, si, val); // access NumArray storage with scalar 'si' index
	a_free(si);
	return x;
}

///////// PRINT, DUMP & READ

void print_nma_rec(struct nmacell *dx, oidtype stream, int k, int start)
{ // print contents of a resident NMA (recursive)
	int i, j;
	struct numarraycell *ds = dr(dx->s,numarraycell);
	char buf[100];
	double *dcont = (double*)ds->cont;
	COMPLEX *ccont = (COMPLEX *)ds->cont;

	a_puts("(", stream);	
	for (i=0; i < dx->dims[k].psize; i++) {
		j = start + nmacell_projectidx(dx, i, k) * dx->dims[k].am;
		if (i>0) a_puts(" ", stream);
		if (k == (dx->ndims-1)) { // print values
			switch (ds->kind) {
				case 0: sprintf(buf, "%d", ds->cont[j]); break;
				case 1: sprintf(buf, "%.16g", dcont[j]); break; //TODO: might require even greater print precision.
				case 2: sprintf(buf, "#[C %g %g]", ccont[j].re, ccont[j].im); break;
			}
			a_puts(buf, stream);
		} else print_nma_rec(dx, stream, k+1, j); // print subarrays (recursive)
	}
	a_puts(")", stream);
}

void print_nma(oidtype x, oidtype stream, int princflg) 
{ // Standard printer for NMA
	struct nmacell *dx = dr(x,nmacell);
	int i;

	a_puts("#[NMA ",stream); //1. print tag
	a_puts(IntegerToString(dx->kind), stream); // 2. print kind
	a_puts(" (", stream);
	for (i=0; i < dx->ndims; i++) { //3. print dimensions
    if (i>0) a_puts(" ", stream);
		a_puts(IntegerToString(dx->dims[i].psize), stream);
	}

	a_puts(") ", stream);
	if (dx->proxyTag) { //print proxy 
		a_puts("PROXY ", stream);
		a_puts(IntegerToString(dx->proxyTag), stream);
		a_puts(" ", stream);
		a_prin1(dx->s, stream, FALSE); // print S data as lisp object
		if (!dx->isOriginal) { // print ranges
			a_puts(" \"", stream);
			a_puts(IntegerToString(dx->offset), stream);
			a_puts("+", stream);
			for (i=0; i < dx->ndims; i++) {
				if (i>0) a_puts(",", stream);
				if (dx->dims[i].size == dx->dims[i].psize) a_puts(":", stream);
				else {
					a_puts(IntegerToString(dx->dims[i].lo), stream);
					a_puts(":", stream);
					a_puts(IntegerToString(dx->dims[i].step), stream);
					a_puts(":", stream);
					a_puts(IntegerToString(dx->dims[i].psize), stream);
				}				
			}
			a_puts("\"", stream);
		}
	} else if (nmacell_elemcnt(dx) <= NMA_PRINT_LIMIT && dx->ndims) // print contents recursively
		print_nma_rec(dx, stream, 0, dx->offset);
	else a_puts("... ", stream); // don't print contents
	a_puts("]", stream);
}

oidtype nma_dumpfn(bindtype env, oidtype x, oidtype stream)
{ // ALisp: print a resident NMA in Turtle-style (only the contents) 
	struct nmacell *dx  = dr(x,nmacell);
	OfType(x, NMATYPE, env);
	if (dx->proxyTag) lerror(NMA_PROXY_ERROR, x, env);
	print_nma_rec(dx, stream, 0, dx->offset);
	return nil;
}

void nmacell_fill_rec(bindtype env, struct nmacell *dx, oidtype list, int k)  //TODO: check types and coerse if necessary
{ // read a list of numbers into NMA (recursive)
	oidtype y, si;
	int i, isList = listp(list);

	y = list;
	for (i=0; i < dx->dims[k].psize; i++) {
		nmacell_iter_setidx(dx, k, i);		
		if (k == (dx->ndims-1))  { // read values
			a_let(si, mkinteger(nmacell_iter2si(dx)));
			nasetafn(env, dx->s, si, (isList)? hd(y) : list);
			a_free(si);
		}
		else nmacell_fill_rec(env, dx, (isList)? hd(y) : list, k+1); // read subarrays (recursive)
		if (isList) y = tl(y); //ASSERT: should be length of dx->dims[k].psize
	}
}

oidtype nma_fillfn(bindtype env, oidtype x, oidtype list)
{ // ALisp: initialize a resident NMA from a nested list of numbers
	struct nmacell *dx  = dr(x,nmacell);

	OfType(x, NMATYPE, env);
	if (dx->proxyTag) lerror(NMA_PROXY_ERROR, x, env);

	nmacell_fill_rec(env, dx, list, 0);
	return x;
}
	
oidtype read_nma(bindtype env, oidtype tag, oidtype x, oidtype stream) 
{ // Standard reader for NMA
	int kind, proxyTag;
	oidtype res;

	OfType(hd(x), INTEGERTYPE, env);
	kind = getinteger(hd(x));

	x = tl(x); //go to size-list
	res = make_nma1(env, hd(x)); 	

	x = tl(x); // go to contents list or proxy part
	if (hd(x) == nil) lerror(NMA_READER_ERROR, x, env);
	else if (symbolp(hd(x)) && strcmp(getpname(hd(x)), "PROXY")==0) { // init as proxy
		x = tl(x);
		OfType(hd(x), INTEGERTYPE, env);
		proxyTag = getinteger(hd(x));
		if (!proxyTag) lerror(NMA_PROXYTAG_ERROR, hd(x), env); //proxy tag can't be 0
		x = tl(x);
		if (hd(x) == nil) lerror(NMA_READER_ERROR, x, env); //proxy data can't be nil
		nma_initProxy(res, kind, proxyTag, hd(x));
	} else if (listp(hd(x))) { // init as resident NMA and read elements list
		nma_init(res, kind, 0);
		nmacell_fill_rec(env, dr(res, nmacell), hd(x), 0); 
	} else lerror(NMA_READER_ERROR, x, env); // neither contents list nor proxy part
	
	if (tl(x) != nil) lerror(NMA_READER_ERROR, x, env); //unexpected elements

	return res;
}

///////////// EQUALITY & HASHING

int nmacell_compareDims(struct nmacell *dx, struct nmacell *dy)
{ // compare array dimensions, return 0 if equal, positive if X includes Y, -1 otherwise
	int k, r0, res = dx->ndims - dy->ndims;

	if (res) return -1; 
	for (k=0; k < dx->ndims; k++) {
		r0 = dx->dims[k].psize - dy->dims[k].psize;
		if (r0 < 0) return -1;
		res += r0; //0 is retained only if all r0 values are 0
	}
	return res;
}

int equal_nma_rec(struct nmacell *dx, struct nmacell *dy, int k, int xstart, int ystart)
{ // elements of 2 NMAs for equaliy, recursive
	int i, xj, yj;
	struct numarraycell *dxs, *dys;
	double *xdcont, *ydcont;
	COMPLEX *xccont, *yccont;
		
	if (k == (dx->ndims - 1))  {
		dxs = dr(dx->s,numarraycell);
		xdcont = (double*)dxs->cont;
		xccont = (COMPLEX *)dxs->cont;
		dys = dr(dy->s,numarraycell);
		ydcont = (double*)dys->cont;
		yccont = (COMPLEX *)dys->cont;
	}
		
	for (i=0; i < dx->dims[k].psize; i++) {	
		xj = xstart + nmacell_projectidx(dx,i,k) * dx->dims[k].am;
		yj = ystart + nmacell_projectidx(dy,i,k) * dy->dims[k].am;
		if (k == (dx->ndims - 1)) { //Compare elements
			switch (dxs->kind) {
				case 0: if (dxs->cont[xj] != dys->cont[yj]) return FALSE; break;
				case 1: if (xdcont[xj] != ydcont[yj]) return FALSE; break;
				case 2: if (((xccont[xj].re != yccont[yj].re))||((xccont[xj].im != yccont[yj].im))) return FALSE; break;
			}
		} else if (equal_nma_rec(dx, dy, k+1, xj, yj) == FALSE) return FALSE; //Compare subarrays (recursive)
	}
	return TRUE;
}

int equal_nmafn(oidtype x, oidtype y) 
{ // Standard comparison function for NMA 
  struct nmacell *dx = dr(x, nmacell),
		             *dy = dr(y, nmacell);
	int k;

	if (dx->kind != dy->kind) return FALSE; // 1. compare kind	

	if (dx->proxyTag != dy->proxyTag) return FALSE; // 2. check whether both are resident or same-tagged proxies

	if (nmacell_compareDims(dx, dy)) return FALSE; // 3. compare dimensions

	if (dx->proxyTag) { // 4.a. if proxies - compare S data, offsets, lo & step values
		if (!equal(dx->s, dy->s) || (dx->offset != dy->offset)) return FALSE;
		for (k=0; k < dx->ndims; k++)
			if ((dx->dims[k].lo != dy->dims[k].lo) || (dx->dims[k].step != dy->dims[k].step)) return FALSE;
		return TRUE;
	} else return equal_nma_rec(dx, dy, 0, dx->offset, dy->offset); // 4.b. recursively compare elements
}

unsigned int nma_hash(oidtype x)    
{ // Standard hash function for NMA
  struct nmacell *dx = dr(x, nmacell);
  
	if (dx->proxyTag) return compute_hash_key(dx->s); 
  else return numarray_hash(dx->s); //TODO: maybe included in compute_hash_key
}

///////////// ARRAY OPERATIONS

int nma_validate_x_dim(bindtype env, oidtype x, oidtype dim, int catchError)
{ // if cacheError, return -1 on invalid X or DIM values, raise an error otherwise
	oidtype dim0 = aprfn(env, dim); // resolve dim if proxy
	int ddim;

	if (a_datatype(x) != NMATYPE) {
		if (catchError) return -1;
		else lerror(4, x, env);
	}
	if (a_datatype(dim0) != INTEGERTYPE) {
		if (catchError) return -1;
		else lerror(4, dim0, env);
	}
	ddim = getinteger(dim0);
	if (ddim < 0 || ddim >= dr(x, nmacell)->ndims) {
		if (catchError) return -1;
		else lerror(NMA_DIM_ERROR, dim, env);
	}
	return ddim;
}

int nma_validate_idx(bindtype env, oidtype x, int k, oidtype idx, int catchError)
{ // if catchError, return -1 on invalid IDX value, raise an error otherwise
	oidtype idx0 = aprfn(env, idx);
	int didx;

  if (a_datatype(idx0) != INTEGERTYPE) {
		if (catchError) return -1;
		else lerror(4, idx0, env);
	}
	didx = getinteger(idx0);
	if (didx < 0 || didx >= dr(x, nmacell)->dims[k].psize) {
		if (catchError) return -1;
		else lerror(NUMOOB_ERROR, idx0, env);
	}
	return didx;
}

oidtype permute_nmafn(bindtype env, oidtype x, oidtype positions)
{ // ALisp: rearrange dimensions (generalized transposition)
	int i, pos;
	oidtype res;
	struct nmacell *dx, *dres;

	OfType(x, NMATYPE, env);
	if (dr(x, nmacell)->proxyTag) lerror(NMA_PROXY_ERROR, x, env); //TODO: actually, can work on proxies
	res = nma_clone(x);
	dx = dr(x, nmacell);
  dres = dr(res, nmacell);
	
	// ASSERT: positions is vector of length da->ndims of non-repeating integer indexes (currently checked in nma-permute--+)
	for (i=0; i < dx->ndims; i++) {
		pos = getinteger(hd(positions));
		if (pos >= dx->ndims) lerror(NMA_DIM_ERROR, positions, env);
		dres->dims[i] = dx->dims[pos]; //copy entire mnacell:s
		positions = tl(positions);
	}
	return res;
}

oidtype subset_nmafn(bindtype env, oidtype x, oidtype k, oidtype lo, oidtype step, oidtype hi)
{ // ALisp: return subarray with specified bounds and step in k-th dimension 
	int dk = nma_validate_x_dim(env, x, k, FALSE),
	    dlo = nma_validate_idx(env, x, dk, lo, FALSE),
		  dhi = nma_validate_idx(env, x, dk, hi, FALSE),
	    dstep, i;
	oidtype step0 = aprfn(env, step),
		      res;
	struct nmacell *dx, *dres;
	
	OfType(step0, INTEGERTYPE, env);
	dstep = getinteger(step0);
	if (dstep < 1) lerror(NMA_STEP_ERROR, step0, env);

	res = nma_clone(x);
  dres = dr(res, nmacell);
	dx = dr(x, nmacell);

	for (i=0; i< dx->ndims; i++) {
		dres->dims[i] = dx->dims[i]; 
		if (i==dk) {
			dres->dims[i].lo = nmacell_projectidx(dx, dlo, i);
			dres->dims[i].step *= dstep;
			dres->dims[i].psize = (nmacell_projectidx(dx, dhi, i) - dres->dims[i].lo) / dres->dims[i].step +1;
		} 
	}
	return res;
}

oidtype nma_project(oidtype x, int ddim, int didx)
{ // project array in the given dimension on the given index
	int i, k;
	oidtype si, res;
	struct nmacell *dx = dr(x, nmacell),
		             *dres;

	if (dx->ndims == 1 && !dx->proxyTag) { //project to a single element
		a_let(si, mkinteger(dx->offset + nmacell_projectidx(dx, didx, 0) * dx->dims[0].am));
	  res = naeltfn(varstacktop, dx->s, si); // access NumArray storage with scalar 'si' index
		a_free(si);
	} else { //project towards slice of ndims-1 dimensions, can resilt in 0-dims proxy
		res = nma_clone(x);
		dx = dr(x, nmacell);
	  dres = dr(res, nmacell);
		dres->ndims = dx->ndims-1; //one dimension goes away

		k = 0; //retain all dims except one
		for (i=0; i< dx->ndims; i++) if (i != ddim) {
			dres->dims[k] = dx->dims[i];
			k++;
		}
	
		for (i=0; i < dx->ndims; i++) // similar to nma_idxs2si()
	    dres->offset += nmacell_projectidx(dx, ((i == ddim)? didx : 0), i) * dx->dims[i].am;
	}
	return res;
}

oidtype nma_projectfn(bindtype env, oidtype x, oidtype projdim, oidtype projidx)
{ // ALisp: project array in the given dimension on the given index
	int ddim = nma_validate_x_dim(env, x, projdim, FALSE),
	    didx = nma_validate_idx(env, x, ddim, projidx, FALSE);

	return nma_project(x, ddim, didx);
}

void nma_project_bbbf(a_callcontext cxt, a_tuple tpl)
{ // Amos: project tpl[0] array in the tpl[1] dimension on tpl[2] index
	oidtype x = a_getobjectelem(tpl, 0, FALSE);
	int ddim = nma_validate_x_dim(cxt->env, x, a_getobjectelem(tpl, 1, FALSE), TRUE),
		  didx = (ddim < 0)? -1 : nma_validate_idx(cxt->env, x, ddim, a_getobjectelem(tpl, 2, FALSE), TRUE);

	if (didx < 0) return;
	a_setobjectelem(tpl, 3, nma_project(x, ddim, didx), FALSE);
	a_emit(cxt, tpl, FALSE);
}

void nma_project_bbff(a_callcontext cxt, a_tuple tpl)
{ // Amos: generate all projections of tpl[0] array in the tpl[1] dimension
	oidtype x = a_getobjectelem(tpl, 0, FALSE);
	int ddim = nma_validate_x_dim(cxt->env, x, a_getobjectelem(tpl, 1, FALSE), TRUE),
		  psize = dr(x, nmacell)->dims[ddim].psize,
	    idx;

	if (ddim < 0) return; //signal from inside nma_validate_x_dim

	for (idx = 0; idx < psize; idx++) {
		a_setintelem(tpl, 2, idx, FALSE); 
		a_setobjectelem(tpl, 3, nma_project(x, ddim, idx), FALSE);
		a_emit(cxt, tpl, FALSE);
	}
}	

////////////// DEBUG PRINTER

oidtype inspect_nmafn(bindtype env, oidtype x)
{ // ALisp (unsafe): print array descriptor internals
	int i;
	struct nmacell *dx = dr(x, nmacell);

	printf("ndims = %d, offset = %d\n", dx->ndims, dx->offset);
	printf("size no   lo   step am   psize\n");
	for (i=0; i < dx->ndims; i++) 
		printf("%-4d %-4d %-4d %-4d %-4d %d\n", dx->dims[i].size, dx->dims[i].no,
						dx->dims[i].lo, dx->dims[i].step, dx->dims[i].am, dx->dims[i].psize);
	return nil;
}

////////////// DISCOVERING AND MAPPING FRAGMENTS 

int nmacell_get_ibd_fsize(struct nmacell *dx, int *fsize)
{ // Get innermost broken dimension (-1 if none) and size of its fragments
	int d = dx->ndims-1,
		  unbroken = ((dx->dims[d].am == 1) && (dx->dims[d].step == 1)); // Criterion for the innermost dimension

	*fsize = 1;	
	while (unbroken)
	{
		*fsize = dx->dims[d].am * dx->dims[d].psize;
		d--;		
		if (d<0) break;		
		unbroken = ((dx->dims[d+1].lo == 0) && (dx->dims[d].step == 1)
			          && (dx->dims[d].am == *fsize)); // Recurrent criterion for dimensions ndims-2, ndims-3, .. 0
	}	
	return d;
}

int mma_mapfragments_rec(oidtype x, int k, int ibd, int fsize, NMAFragmentMapper mapperFn, void *xa) 
{
	struct nmacell *dx = dr(x, nmacell);
	int i, stop;

	if (k > ibd) stop = (*mapperFn)(x, nmacell_iter2si(dx), fsize, xa);		
	else for (i = 0; i < dx->dims[k].psize; i++) {
		nmacell_iter_setidx(dx, k, i);
		stop = mma_mapfragments_rec(x, k + 1, ibd, fsize, mapperFn, xa); //recursive
		if (stop) return stop; // stop signal
	}
	return stop;
}

void nma_mapfragments(oidtype x, NMAFragmentMapper mapperFn, void *xa)
{ // Amos: emit the ids and fragment sizes of tpl[0] NMA of chunks given tpl[1] chunksize
	struct nmacell *dx = dr(x, nmacell);
	int k, ibd, fragmentSize;

	ibd = nmacell_get_ibd_fsize(dx, &fragmentSize);	// Get innermost unbroken dimension
	for (k = ibd + 1; k < dx->ndims; k++) nmacell_iter_setidx(dx, k, 0); // set all inner subscripts to 0
	mma_mapfragments_rec(x, 0, ibd, fragmentSize, mapperFn, xa); // recursively iterate over broken dimensions and call mapperFn
}

///////////////////////////////// EMITTING STORAGE INDICES (in bytes) FOR EACH FRAGMENT

struct NMAMapFragmentData {
	int elemsize;
	a_callcontext cxt;
	a_tuple tpl;
};

int nma2gragmentSIs_mapper(oidtype x, int si, int fsize, void *xa) 
{
	struct NMAMapFragmentData *data = xa;

	a_setintelem(data->tpl, 1, si * data->elemsize, FALSE);
	a_setintelem(data->tpl, 2, fsize * data->elemsize, FALSE);
	a_emit(data->cxt, data->tpl, FALSE);
	return 0;
}

void nma2fragmentSIs_bff(a_callcontext cxt, a_tuple tpl)
{ // Amos: emit storage indices and fragement sizes in bytes
	struct NMAMapFragmentData data;
	oidtype x = a_getobjectelem(tpl, 0, FALSE);

	if (a_datatype(x) != NMATYPE) lerror(4, x, cxt->env); // OfType without 'return'

	data.cxt = cxt;
	data.tpl = tpl;
	data.elemsize = numarray_elemsize(dr(x, nmacell)->kind);

	nma_mapfragments(x, nma2gragmentSIs_mapper, (void*)&data);
}


///////////////////////////////////////////////

void register_nma(void)
{
	NMATYPE = a_definetype("nma", dealloc_nma, print_nma);
	typefns[NMATYPE].equalfn = equal_nmafn;
	typefns[NMATYPE].hashfn = nma_hash;
	type_reader_function("NMA", read_nma);

	NMA_NODIM_ERROR = a_register_error("Dimensions list empty");
	NMA_DIM_ERROR = a_register_error("Dimensionality mismatch");
	NMA_STEP_ERROR = a_register_error("Subset step should be 1 or greater");
	NMA_READER_ERROR = a_register_error("Malformed or incomplete NMA text representation");
	NMA_PROXY_ERROR = a_register_error("Function cannot be applied to array proxies");
	NMA_PROXYTAG_ERROR = a_register_error("Invalid proxy tag");

	extfunction2("make-nma", make_nmafn);
	extfunction4("make-nmaproxy", make_nmaProxyfn);
	extfunction2("nma-allocate", nma_allocatefn);
	extfunction1("nma-copy", nma_copyfn);
	extfunction2("nma-fill", nma_fillfn);
	extfunction1("nma-ndims", nma_ndimsfn);
	extfunction2("nma-dim", nma_dimfn);
	extfunction2("nma-elt", nma_eltfn);
	extfunction3("nma-set", nma_setfn);
	extfunction1("nma-s", nma_sfn);
	extfunction2("nma-dump", nma_dumpfn);
	extfunction1("nma-kind", nma_kindfn);
	extfunction1("nma-kind2elemsize", nma_kind2elemsizefn);
	extfunction1("nma-proxytag", nma_proxytagfn);
	extfunction1("nma-is-original", nma_isOriginalfn);
	extfunction1("nma-elemcnt", nma_elemcntfn);
	extfunction2("nma-permute", permute_nmafn);
	extfunction5("nma-subset", subset_nmafn);
	extfunction3("nma-project", nma_projectfn);
	extfunction1("nma-inspect", inspect_nmafn);
	extfunction1("nma-iter-reset", nma_iter_resetfn);
	extfunction1("nma-iter-next", nma_iter_nextfn);
	extfunction1("nma-iter-cur", nma_iter_curfn);
	extfunction2("nma-iter-setcur", nma_iter_setcurfn);
		
	a_extfunction("nma-project---+", nma_project_bbbf);
	a_extfunction("nma-project--++", nma_project_bbff);			
	a_extfunction("NMA2FragmentSIs-++", nma2fragmentSIs_bff);
}

  