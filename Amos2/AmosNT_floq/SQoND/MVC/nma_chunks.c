/*****************************************************************************
 * AMOS2 
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: nma_chunks.c,v $
 * $Revision: 1.9 $ $Date: 2013/11/23 22:56:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Support for converting the NMAs to and from BINARY chunks
 * ===========================================================================
 * $Log: nma_chunks.c,v $
 * Revision 1.9  2013/11/23 22:56:02  andan342
 * - moved fragment mapper facility into nma.c
 * - added ALisp functions nma-copy, nma-vsum, nmau-scale, nma-scale, nmau-roundto, nma-roundto, nma-round
 *
 * Revision 1.8  2013/07/28 06:23:11  andan342
 * Moved array chunk file generation from dumper.lsp to nma-filedump function in C
 *
 * Revision 1.7  2013/07/19 14:02:25  andan342
 * Re-commit due to repository server failure (BUG FIX with hex chunk caching)
 *
 * Revision 1.6  2013/07/14 11:06:44  andan342
 * Using Integer parameters to nma2chunks function
 *
 * Revision 1.5  2013/07/13 22:35:31  andan342
 * Complete hexadecimal storage of chunks
 *
 * Revision 1.4  2013/07/12 12:41:38  andan342
 * Added hexadecimal string option to store binary data on SQL backend
 *
 * Revision 1.3  2013/02/21 23:33:02  andan342
 * Renamed NMA-PROXY-RESOLVE to APR, using it to define all non-aggregate SciSparql foreign functions as proxy-tolerant
 *
 * Revision 1.2  2013/02/12 23:50:50  andan342
 * Added nma-proxy-has-cache and nma-cache-put functions
 *
 * Revision 1.1  2013/02/08 00:46:44  andan342
 * Added C implementation of NMA chunk cache and NMA-PROXY-RESOLVE
 *
 *
 ****************************************************************************/

#include "nma.h"

struct NMACacheRec* NMACacheRoot = NULL;
long NMACacheTotalSize = 0,
     NMACacheLimit = 0; // nma-cache-setlimit should be used

struct NMAProxyTagTableRec NMAProxyTagTable[NMA_PROXYTAG_TABLE_SIZE];

int NMALastProxyTag = 0,
    NMAProxyLimit = -1; // no limit, use nma-proxy-setlimit to change

int NMA_NOCHUNK_ERROR, NMA_NOCHUNKSIZE_ERROR, NMA_BIGPROXY_ERROR;

int NMAProxyChunkidSampleSize = 16;

/////////////////////////////////// EMITTING CHUNKS

oidtype blob2hex(a_blob b)
{ // Return Charstring object containing hexadecimal representation of given BLOB
	int size, i;
	char *buf, *sbuf;

	a_getBLOBsize(b, &size, FALSE);
	buf = (char*)malloc(size);
	sbuf = (char*)malloc(2*size+1);

	a_getBLOBbytes(b, 0, size, buf, FALSE);
	for (i=0; i < size; i++) 
		sprintf(&(sbuf[2*i]), "%02X", buf[i]);
	
	free(buf);
	return mkstring(sbuf); //TODO: maybe should also free sbuf
}

void nma2chunks_bbff(a_callcontext cxt, a_tuple tpl)
{ // Amos: emit the contents of tpl[0] NMA 
  // in BINARY or, if tpl[2], hex CHARSTRING chunks of tpl[1] size
	oidtype x = a_getobjectelem(tpl, 0, FALSE),
		    s;
	struct nmacell *dx = dr(x, nmacell);
	int chunkSize = a_getintelem(tpl, 1, FALSE),
		  isHex = a_getintelem(tpl, 2, FALSE),
	    elemSize, ibd, fragmentSize, i, arraySize, remFragmentSize, writeSize, blobPos, blobSize, blobCount, fragmentPos;
	char *pFragment;
	a_blob theBLOB = NULL; 

	if (a_datatype(x) != NMATYPE) lerror(4, x, cxt->env); // OfType without 'return'
	else if (dx->proxyTag) lerror(NMA_PROXY_ERROR, x, cxt->env);

	s = dx->s;
	elemSize = numarray_elemsize(dx->kind);

	ibd = nmacell_get_ibd_fsize(dx, &fragmentSize);	// Get innermost unbroken dimension
	fragmentSize *= elemSize; // Refer to fragment size in bytes

	// Array size is needed to precisely allocate the last emitted BLOB
	arraySize = fragmentSize;
	for (i = 0; i <= ibd; i++) arraySize *= dx->dims[i].psize; // Factor up sizes in all broken dimensions

	blobSize = 0;
	blobCount = 0;

	// Initialize fragment iterator 
	nmacell_iter_reset(dx);
	fragmentPos = nmacell_iter2si(dx) * elemSize;
	remFragmentSize = fragmentSize;

	while (remFragmentSize) // Cycle through fragments, refreshing BLOBs on demand
	{				
		writeSize = (blobSize > remFragmentSize)? remFragmentSize : blobSize; // 0 on 1st pass, since blobSize=0

		if (writeSize) // never on 1st pass
		{
			pFragment = (char*)(dr(s, numarraycell)->cont) + fragmentPos; //s might have been relocated after emit
			a_putBLOBbytes(theBLOB, blobPos, writeSize, pFragment, FALSE);
			blobSize -= writeSize;
			remFragmentSize -= writeSize;
		}

		if (!remFragmentSize) // never on 1st pass
		{ // Proceed to the next fragment			
			for (i=ibd; i>=0; i--) // Iterator increment loop, starting with d as innermost iterated dimension
			{
				dx = dr(x,nmacell); //x might have been relocated after emit
				dx->dims[i].iter++;
				if (dx->dims[i].iter == dx->dims[i].psize) 
					dx->dims[i].iter = 0;
				else {
					fragmentPos = nmacell_iter2si(dx) * elemSize;
					remFragmentSize = fragmentSize;
					break; 
				}
			} 
		} else fragmentPos += writeSize; // Normally proceed through the fragment

		if (!blobSize) // Refresh the BLOB
		{			
			if (theBLOB) // always on the last pass
			{ // If there is a "full" blob - emit it
				a_setintelem(tpl, 3, blobCount, FALSE);
				if (isHex) a_setobjectelem(tpl, 4, blob2hex(theBLOB), FALSE); 
				else a_putBLOBelem(tpl, 4, theBLOB, FALSE);
				a_emit(cxt,tpl,FALSE);
				a_freeBLOB(theBLOB, FALSE); //We are emitting BINARY, BLOB was just an interface
				blobCount++;
			}
			if (arraySize) //Assert remFragmentSize > 0, since arraySize decrements in parallel
			{ // always on 1st pass: Make a new BLOB
				blobSize = (chunkSize > arraySize)? arraySize : chunkSize;
				arraySize -= blobSize;
				theBLOB = a_initBLOB();
				a_newBLOB(theBLOB, blobSize, FALSE);
				blobPos = 0;
			}
		} else blobPos += writeSize;
	}
	
	return;
}					

//////////////////////////////// LOADING CHUNKS

char hexv(char h)
{
	if (h >= '0' && h <= '9') return h - '0';
	else if (h >= 'A' && h <= 'F') return 10 + h - 'A';
	else if (h >= 'a' && h <= 'f') return 10 + h - 'a';
	else return -1;
}

char fromHex(char* buf)
{
	return hexv(buf[0]) * 16 + hexv(buf[1]);
}

long chunksize(oidtype chunk)
{ // Return effective size of the chunk;
	switch a_datatype(chunk) {
		case STRINGTYPE:
			return (dstringlen(dr(chunk, stringcell)) - 1) / 2;
		case BINARYTYPE:
			return binary_size(dr(chunk, binarycell));
		default:
			return -1;
	}
}	

int nmacell_loadchunk(struct nmacell *dx, oidtype chunk, int xpos, int start, int size)
{ // ALisp (unsafe): load SIZE bytes at START of CHUNK object into resident array X at position XPOS
	// CHUNK should be either Binary or Charstring type, and contain hexadecimal represenation in the latter case
	struct numarraycell *ds = dr(dx->s, numarraycell);
	char* xc = (char*)ds->cont;
	struct binarycell *dbinary;
	struct stringcell *dstring;
	char* bc;
	int remXSize, remBinarySize, res, i;

  if (a_datatype(chunk) == STRINGTYPE) { 
		dstring = dr(chunk, stringcell);
		bc = dstring->cont.string;
	} else {
		dbinary = dr(chunk, binarycell);
		bc = (char*)dbinary->cont;
	}

	remBinarySize = chunksize(chunk) - start;		
	res = (size > remBinarySize)? remBinarySize : size; //as min(dsize, remBinarySize, remXSize)
	remXSize = numarray_size(ds) - xpos;
	if (remXSize < res) res = remXSize;

	if (res>0) { //do the thing
		if (a_datatype(chunk) == STRINGTYPE) 
			for (i=0; i<res; i++) // convert from hex to binary
				xc[xpos + i] = fromHex(bc + 2 * (start + i));
		else memcpy(xc+xpos, bc+start, res); // copy binary data
	}	
	return res; //return the amount of bytes loaded
}

/* NOT USED:
oidtype nma_loadchunkfn(bindtype env, oidtype x, oidtype binary, oidtype xpos, oidtype start, oidtype size)
{ // ALisp (unsafe): load SIZE bytes at START of CHUNK object into resident array X at position XPOS
	return mkinteger(nmacell_loadchunk(dr(x, nmacell), binary, getinteger(xpos), getinteger(start), getinteger(size)));
}
*/

/////////////////////////////// MANAGINNG CHUNK CACHE 

oidtype nma_cache_setlimitfn(bindtype env, oidtype cachelimit)
{ // ALisp: set NMA cache limit
	OfType(cachelimit, INTEGERTYPE, env);
	NMACacheLimit = getinteger(cachelimit);
	return cachelimit;
}

oidtype nma_proxy_startcachefn(bindtype env, oidtype x)
{ // ALisp (unsafe): start cache for NMA proxy X, return cache size
	struct NMACacheRec* pCache;
	struct nmacell* dx = dr(x, nmacell);
	int cnt, i, 
		  cs = NMAProxyTagTable[dx->proxyTag-1].defaultChunkSize;

	// try to find cache with same S in list
	pCache = NMACacheRoot;
	while (pCache && a_compare(pCache->s, dx->s))
		pCache = pCache->pNext;

	if (!pCache) { // create new cache record
		cnt = (int)ceil(1.0 * nmacell_original_elemcnt(dx) * numarray_elemsize(dx->kind) / cs);
		pCache = (struct NMACacheRec*)malloc(sizeof(struct NMACacheRec) + sizeof(oidtype) * (cnt - 1)); 
		// add to the global list
		pCache->pNext = NMACacheRoot; 
		NMACacheRoot = pCache;
		// initialize as ampty
		pCache->cnt = cnt;
		pCache->rut = clock();
		a_let(pCache->s, dx->s); // use array id from the proxy
		pCache->bytes = 0;
		for (i=0; i < cnt; i++) pCache->chunks[i] = nil;
		a_let(pCache->s, dx->s); // use array id from the proxy		
	} 
	dx->pCache = pCache; // link from X (and all its descendants)
	return mkinteger(pCache->cnt);
}

oidtype nma_proxy_has_cachefn(bindtype env, oidtype x)
{ // ALisp: return T if cache is defined on array proxy X
	if (a_datatype(x) == NMATYPE && dr(x, nmacell)->pCache) return t;
	else return nil;
}

void nma_cache_clear(struct NMACacheRec* pCache) 
{ // clear all BINARY chunks from cache
	int i;
	for (i=0; i < pCache->cnt; i++) 
		if (pCache->chunks[i] != nil) a_free(pCache->chunks[i]);
	pCache->bytes = 0;
}

void nma_cache_clearall()
{
	struct NMACacheRec* pNode = NMACacheRoot;
	while (pNode) {
		if (pNode->bytes) 			
			nma_cache_clear(pNode);		
		pNode = pNode->pNext;
	}
	NMACacheTotalSize = 0;
}

oidtype nma_cache_resetfn(bindtype env) 
{ // ALisp: clear all NMA caches
	nma_cache_clearall();
	return nil;
}

long nma_cache_shrink(long shrinkSize, struct NMACacheRec* pCurrent)
{
	struct NMACacheRec *pFirstPositive = NMACacheRoot,
			               *pNode, *pOldest;

	if (shrinkSize > (NMACacheTotalSize - ((pCurrent)? pCurrent->bytes : 1))) {
		shrinkSize -= NMACacheTotalSize;
		nma_cache_clearall();		
	} else {
		// point pFirstPositive to the first non-empty cache in list
		while (pFirstPositive && !pFirstPositive->bytes) 
			pFirstPositive = pFirstPositive->pNext; 
		
		//TODO: this could have been O(n) if NMACacheRoot list is sorted first.
		while (shrinkSize > 0) {
			pNode = pFirstPositive;
			// select the oldest node among all positive nodes except current one
			pOldest = NULL;
			while (pNode) {
				if (pNode->bytes && (!pOldest || pOldest->rut > pNode->rut) && pNode != pCurrent) pOldest = pNode;
				pNode = pNode->pNext;
			}
			// clear oldest cache
			if (!pOldest) return shrinkSize; //ASSERT: should never happen
			NMACacheTotalSize -= pOldest->bytes;
			shrinkSize -= pOldest->bytes;
			nma_cache_clear(pOldest);		
		}
	}
	return shrinkSize;
}

oidtype nma_cache_get(struct NMACacheRec* pCache, int chunkid)
{ // (unsafe) get BINARY chunk from given cache
	pCache->rut = clock();
	return pCache->chunks[chunkid];
}
		
int nma_cache_put(struct NMACacheRec* pCache, int chunkid, oidtype chunk)
{ // (unsafe) put BINARY chunk into given cache, shrink if necessary
	long csize = chunksize(chunk),
		   shrinkSize = NMACacheTotalSize + csize - NMACacheLimit;
	
	if (csize > NMACacheLimit) return 0; // cannot fit this chunk anyway
	if (shrinkSize > 0) nma_cache_shrink(shrinkSize, pCache);

	pCache->rut = clock();
	a_let(pCache->chunks[chunkid], chunk); //ASSERT: chunks[chunkid] is nil
	pCache->bytes += csize;
	NMACacheTotalSize += csize;
	return 1; //success
}

oidtype nma_cache_putfn(bindtype env, oidtype x, oidtype chunkid, oidtype chunk)
{ // ALisp (unsafe): put BINARY chunk with given chunkid into cache associated with NMA proxy X
	if (nma_cache_put(dr(x, nmacell)->pCache, getinteger(chunkid), chunk)) return t;
	else return nil;
}

////////////////////////////////// DISCOVERING CHUNK IDS

struct NMAMapFragmentData2 {
	int elemsize, chunksize, chunkid, cnt, limit;
	struct NMACacheRec* pCache;
	oidtype res;
};

int nma2chunkids_mapper(oidtype x, int si, int fsize, void *xa)
{
	struct NMAMapFragmentData2 *data = xa;
	int sib = si * data->elemsize,
		  chunkid = sib / data->chunksize,
			chunkpos = sib % data->chunksize,
			remFragmentSize = fsize * data->elemsize;	
			
	while (remFragmentSize > 0) {
		if (chunkid != data->chunkid) { // if new chunk
			if (!data->pCache || nma_cache_get(data->pCache, chunkid) == nil) { // and not in cache
//				if (DEB) printf("discovered chunkid = %d", chunkid); //DEBUG
				a_setf(data->res, cons(mkinteger(chunkid), data->res)); // add chunkid to result list
//				if (DEB) printf(" - in list, ");
				data->cnt++;
			}			
		}
		remFragmentSize -= (data->chunksize - chunkpos); // check if this chunk is sufficient for the fragment
		if (remFragmentSize > 0) { // proceed to next chunks otherwize
			chunkid++;
			chunkpos = 0;
		} else data->chunkid = chunkid; // remember last chunkid generated
	}
//	if (DEB) printf("done!\n");
	return (data->limit > 0) && (data->cnt >= data->limit); // stop if reached limit
}

oidtype nma_chunkid_list(oidtype x, int limit, int checkCache)
{ // return list of chunkid:s needed to reslove NMA proxy X, 
	// except those found in cache if checkCache
  // limit the list if limit > 0
	struct nmacell *dx = dr(x, nmacell);
	struct NMAMapFragmentData2 data;
	
	data.res = nil;
	data.chunkid = -1;
	data.cnt = 0;
	data.limit = limit;
	data.chunksize = NMAProxyTagTable[dx->proxyTag-1].defaultChunkSize; 
	data.pCache = (checkCache)? dx->pCache : NULL;
	data.elemsize = numarray_elemsize(dx->kind);

	nma_mapfragments(x, nma2chunkids_mapper, (void*)&data);
	
	return data.res;
}

oidtype nma_chunkid_listfn(bindtype env, oidtype x, oidtype limit, oidtype checkCache)
{ // Alisp: return list of chunkid:s needed to reslove NMA proxy X, 
	// except those found in cache if checkCache not NIL,
  // limit the list if limit > 0	
	OfType(x, NMATYPE, env);
	OfType(limit, INTEGERTYPE, env);
	if (!NMAProxyTagTable[dr(x, nmacell)->proxyTag-1].defaultChunkSize)
		lerror(NMA_NOCHUNKSIZE_ERROR, x, env);

	return nma_chunkid_list(x, getinteger(limit), (checkCache != nil));
}

////////////////////////////  RESOLVING NMA PROXIES 

oidtype nma_register_proxytagfn(bindtype env, oidtype resolveFn, oidtype getChunkFn, oidtype cacheChunksByPatternFn) 
{ // ALisp: register proxy-handling functions and return new proxytag value
	//  resolveFn - resolve a proxy (NIL if built-in chunk-based resolver is to be used)
	//  getChunkFn - get chunk with specified id (only if resolveFn is not specified)
	//  cacheChunksByPatternFn - cache chinks based on pattern mined from id lis
	//  isHex - use hexadecimal string representation of chunks
	OfType(resolveFn, SYMBOLTYPE, env);
	OfType(getChunkFn, SYMBOLTYPE, env);
	OfType(cacheChunksByPatternFn, SYMBOLTYPE, env);

	if (NMALastProxyTag < NMA_PROXYTAG_TABLE_SIZE) {
		NMALastProxyTag++;
		NMAProxyTagTable[NMALastProxyTag-1].resolveFn = resolveFn; // store the symbols, no reference counting
		NMAProxyTagTable[NMALastProxyTag-1].getChunkFn = getChunkFn;		
		NMAProxyTagTable[NMALastProxyTag-1].cacheChunksByPatternFn = cacheChunksByPatternFn;
		NMAProxyTagTable[NMALastProxyTag-1].defaultChunkSize = 0; // nma-proxy-set-default-chunksize should be used
		return mkinteger(NMALastProxyTag); // return generated proxy tag
	} else return nil; // proxy tag table is full
}

oidtype nma_proxy_set_default_chunksizefn(bindtype env, oidtype proxyTag, oidtype defaultChunkSize)
{ // ALisp : set default chunk size for the registered proxy tag
	int dproxyTag;

	OfType(proxyTag, INTEGERTYPE, env);
	OfType(defaultChunkSize, INTEGERTYPE, env);
	
	dproxyTag = getinteger(proxyTag);
	if (dproxyTag > 0 && dproxyTag <= NMALastProxyTag) 
		NMAProxyTagTable[dproxyTag-1].defaultChunkSize = getinteger(defaultChunkSize);		
	else lerror(NMA_PROXYTAG_ERROR, proxyTag, env);
	return defaultChunkSize;
}

oidtype nma_proxy_enabledfn(bindtype env)
{ //ALisp: return T if there are any proxy tags registered
	if (NMALastProxyTag) return t;
	else return nil;
}

oidtype nma_proxy_setlimitfn(bindtype env, oidtype limit)
{ // ALisp: set NMA proxy limit - never resolve proxies containing more elements
	OfType(limit, INTEGERTYPE, env);
	NMAProxyLimit = getinteger(limit);
	return limit;
}

struct NMAResolveFromChunksData {
	bindtype env;
	int chunksize, prevChunkId, respos;
	oidtype res, chunk;
};

oidtype mmacell_getchunk(bindtype env, struct nmacell *dx, int chunkid)
{
	struct NMACacheRec* pCache = dx->pCache; //dx might become invalid after call_lisp
	oidtype res;

	if (pCache) 
		res = nma_cache_get(pCache, chunkid); // no reference counting, since no external calls are made while working with same chunk
	else res = nil;
	// if not found and getChunkFn is defined - try calling it
	if (res == nil && NMAProxyTagTable[dx->proxyTag-1].getChunkFn != nil) {
		res = call_lisp(NMAProxyTagTable[dx->proxyTag-1].getChunkFn, env, 2, dx->s, mkinteger(chunkid)); //TODO: trace for chunkid being freed
		if (pCache) nma_cache_put(pCache, chunkid, res); // put into cache the chunk just retrieved
	}
	return res;
}

int nma_proxy_resolve_from_chunks_mapper(oidtype x, int si, int fsize, void *xa)
{
	struct NMAResolveFromChunksData* data = xa;
	struct nmacell *dx = dr(x, nmacell);
	int remFragmentSize = fsize * numarray_elemsize(dx->kind),
			sib = si * numarray_elemsize(dx->kind),
		  chunkid = sib / data->chunksize,
			chunkpos = sib % data->chunksize,
			bytesread;

	while (remFragmentSize > 0) {
		if (chunkid != data->prevChunkId) { // 1. Retrieve next chunk
			// try to get next chunk from cache
			data->chunk = mmacell_getchunk(data->env, dx, chunkid);
			if (data->chunk == nil) lerror(NMA_NOCHUNK_ERROR, dr(x, nmacell)->s, data->env);
			data->prevChunkId = chunkid;
		}
		// 2. Copy binary data from chunk into result NMA
		bytesread = nmacell_loadchunk(dr(data->res, nmacell), data->chunk, data->respos, chunkpos, remFragmentSize);
		remFragmentSize -= bytesread;
		data->respos += bytesread;
		if (remFragmentSize >0) { // 3. Proceed to next chunk for the this fragment
			chunkid++;
			chunkpos = 0;
		}
	}
	return 0;
}

oidtype nma_proxy_resolve_from_chunks(bindtype env, oidtype x) 
{ // (unsafe) standard resolver for chunk-based NMA proxies
	struct nmacell* dx = dr(x, nmacell);
	struct NMAResolveFromChunksData data;
	oidtype chunkids, res1;	
	int proxyIdx = dx->proxyTag - 1;

	// 1. Determine chunk size
	data.chunksize = NMAProxyTagTable[proxyIdx].defaultChunkSize;
	if (!data.chunksize) lerror(NMA_NOCHUNKSIZE_ERROR, x, env);

	// 2. Try to pre-cache either all chunks or by pattern, building a sample chunkid list 
	if (dx->pCache && NMAProxyTagTable[proxyIdx].cacheChunksByPatternFn != nil) { // if aggegated chunk retrieval is possible
		if (dx->isOriginal) chunkids = t; // cache all the chunks
		else a_let(chunkids, nma_chunkid_list(x, NMAProxyChunkidSampleSize, TRUE)); // or create a sample chunkid list
		if (chunkids != nil)
			call_lisp(NMAProxyTagTable[proxyIdx].cacheChunksByPatternFn, env, 2, x, chunkids); // do retrieve & cache
		a_free(chunkids);
	}

	// 3. Allocate new NMA, initialize fragment iteration
	data.res = nma_allocate(x, -1); //create resulting or temporary NMA	
	data.env = env;	
	data.respos = 0;
	data.prevChunkId = -1;
	data.chunk = nil;

	// 4. Iterate through fragments of source proxy, read data from cached chunks if availabe
	dx = dr(x, nmacell); // dx might have been invalidated during nmacell_allocate
	if (dx->ndims) {
		nma_mapfragments(x, nma_proxy_resolve_from_chunks_mapper, (void*)&data); // resolve all fragments
		return data.res;
	} else {
		nma_proxy_resolve_from_chunks_mapper(x, dx->offset, 1, (void*)&data); // resolve single fragment
		res1 = naeltfn(env, dr(data.res, nmacell)->s, mkinteger(0)); // extract single element
		a_free(data.res); // remove temporary NMA
		return res1;
	}
}

oidtype aprfn(bindtype env, oidtype x) 
{ // ALisp: if X is NMA proxy, resolve it
	struct nmacell *dx;

	if (a_datatype(x) == NMATYPE) { // else not an NMA - return unchanged
		dx = dr(x, nmacell);
		if (dx->proxyTag) { // else resident NMA - return unchanged
			if (dx->proxyTag < 0 || dx->proxyTag > NMALastProxyTag) 
				lerror(NMA_PROXYTAG_ERROR, x, env); // invalid proxy tag - can't resolved
			else if (NMAProxyLimit >= 0 && nmacell_elemcnt(dx) > NMAProxyLimit)
				lerror(NMA_BIGPROXY_ERROR, x, env); // proxy exceeds the defined limit
			else if (NMAProxyTagTable[dx->proxyTag-1].resolveFn != nil)
				return call_lisp(NMAProxyTagTable[dx->proxyTag-1].resolveFn, env, 1, x); // call lisp function to resolve
			else return nma_proxy_resolve_from_chunks(env, x); // use built-in resolver		
		}
	}
	return x; 
}

void apr_bf(a_callcontext cxt, a_tuple tpl)
{ // Amos: if X is NMA proxy, resolve it, return unchanged otherwise, NIL-tolerant
	oidtype res = aprfn(cxt->env, a_getobjectelem(tpl, 0, FALSE));
	a_setobjectelem(tpl, 1, res, FALSE);
	a_emit(cxt, tpl, FALSE);
}

////////////////////////////////// OTHER CHUNK UTILITIES 

/* NOT USED!
oidtype dumpbinaryfn(bindtype env, oidtype stream, oidtype binary)
{ // ALisp (unsafe): print HEX representation of BINARY into Lisp stream
	struct binarycell *dbinary = dr(binary, binarycell);
	unsigned char* bc = (unsigned char*)dbinary->cont;
	unsigned int i;
	char buf[3];

	for (i=0; i < binary_size(dbinary); i++) {
		sprintf(buf, "%02X", bc[i]);
		a_puts(buf, stream);
	}
	return nil;
}
*/

FILE* dump_fout = NULL;
double dump_fsize = 0;

struct DumpNMAData {
	int arrayid, chunksize;
	double filesize_max;
	bindtype env;
	oidtype getfilenamefn;	
};

oidtype nma_filedump_closefn(bindtype env)
{ //ALisp: close nma filedump
	if (dump_fout) {
		fclose(dump_fout);
		dump_fout = NULL;
		dump_fsize = 0;
		return t;
	}
	return nil;
}

void nma_filedump_prepare(struct DumpNMAData* data, int dumpsize)
{ //common part of nma_hexdump_mapper() and nma_bindump_mapper()
	//ASSERT: dumpsize <= data.filesize_max
	char* filename;	
	// close file if size limit is going to be exceeded
	if (dump_fsize + dumpsize > data->filesize_max)
		nma_filedump_closefn(NULL);
	// open a new file
	if (!dump_fout) {
		filename = getstring(call_lisp(data->getfilenamefn, data->env, 0));
		printf("Writing file %s...\n", filename);
		dump_fout = fopen(filename, "wb");
	}
	// update file size
	dump_fsize += dumpsize;
}

oidtype nma_hexdump_mapper(a_callcontext cxt, int width, oidtype tpl[], void *xa)
{
	struct DumpNMAData* data = xa;
	char c0A = 0x0A;

	nma_filedump_prepare(data, 12 + data->chunksize * 2);
	// write arraid, chunkid, chunk
	fprintf(dump_fout, "%d,%d,%s", data->arrayid, getinteger(tpl[0]), getstring(tpl[1]));
	fwrite(&c0A, 1, 1, dump_fout);
	return nil;
}

oidtype nma_bindump_mapper(a_callcontext cxt, int width, oidtype tpl[], void *xa)
{
	struct DumpNMAData* data = xa;
	struct binarycell *dbinary = dr(tpl[1], binarycell);	
	int act_chunksize = binary_size(dbinary),
		  chunkid = getinteger(tpl[0]),
			i;
	char c4 = 4, 
		   c0 = 0;

	nma_filedump_prepare(data, 12 + data->chunksize);
	// write arraid, chunkid, chunk
	fwrite(&c4, 1, 1, dump_fout);
	fwrite(&(data->arrayid), 4, 1, dump_fout);
	fwrite(&c4, 1, 1, dump_fout);
	fwrite(&chunkid, 4, 1, dump_fout);
	fwrite(&(data->chunksize), 2, 1, dump_fout);
	fwrite(dbinary->cont, act_chunksize, 1, dump_fout);
	// pad rest of chunk field with 0x00
	for (i = act_chunksize; i < data->chunksize; i++)
		fwrite(&c0, 1, 1, dump_fout);
	return nil;
}

oidtype nma_filedumpfn(bindtype args, bindtype env)
{ // ALisp (unsafe): write NMA (arg 1) identified by ARRAYID (arg 2) in CHUNKSIZE (arg 3) chunks into CSV HEX (if arg 4)
	// or otherwise binary file(s) of size <= FILESIZE_MAX (arg 5, double) with names provided by GETFILENAMEFN() (arg 6)
	dcl_oid(nma2chunksfn);
	dcl_global_cxt(cxt);
	oidtype chunksize = nthargval(args, 3),
		      isHex = nthargval(args, 4),
					n2cargs[3];
	struct DumpNMAData data;

	// prepare to call function nma2chunks() with following args:
	a_setf(nma2chunksfn, a_getfunctionnamed("NMA.INTEGER.INTEGER.NMA2CHUNKS->INTEGER.BINARY", FALSE));
	n2cargs[0] = nthargval(args, 1); //NMA
	n2cargs[1] = chunksize; 
	n2cargs[2] = isHex; 

	// use the following data in a mapper
	data.arrayid = getinteger(nthargval(args, 2));
	data.chunksize = getinteger(chunksize);
	data.filesize_max = getreal(nthargval(args, 5));
	data.env = env;
	data.getfilenamefn = nthargval(args, 6); //a function or closure to generate filenames to write to

	a_mapfunctionC(cxt, nma2chunksfn, 3, n2cargs, (getinteger(isHex)==1)? nma_hexdump_mapper : nma_bindump_mapper, &data);

	free_oid(nma2chunksfn);
	return nil;
}

void register_nma_chunks(void)
{
	NMA_NOCHUNK_ERROR = a_register_error("Chunk not found while resolving array");
	NMA_NOCHUNKSIZE_ERROR = a_register_error("Cannot determine chunk size while resolving array");
	NMA_BIGPROXY_ERROR = a_register_error("Array to resolve exceeds defined limit");

//	extfunction5("nma-load-chunk", nma_loadbinaryfn); not used
//	extfunction2("dumpbinary", dumpbinaryfn);  not used
	extfunctionn("nma-filedump", nma_filedumpfn);
	extfunction0("nma-filedump-close", nma_filedump_closefn);

	extfunction1("nma-cache-setlimit", nma_cache_setlimitfn);
	extfunction1("nma-proxy-startcache", nma_proxy_startcachefn);
	extfunction1("nma-proxy-has-cache", nma_proxy_has_cachefn);
	extfunction0("nma-cache-reset", nma_cache_resetfn);
	extfunction3("nma-cache-put", nma_cache_putfn);
	
	extfunction3("nma-register-proxytag", nma_register_proxytagfn);
	extfunction2("nma-proxy-set-default-chunksize", nma_proxy_set_default_chunksizefn);
	extfunction0("nma-proxy-enabled", nma_proxy_enabledfn);
	extfunction1("nma-proxy-setlimit", nma_proxy_setlimitfn);

	extfunction3("nma-chunkid-list", nma_chunkid_listfn);
	extfunction1("apr", aprfn);

	a_extfunction("NMA2Chunks--++", nma2chunks_bbff);	
	a_extfunction("APR-+", apr_bf);
}
