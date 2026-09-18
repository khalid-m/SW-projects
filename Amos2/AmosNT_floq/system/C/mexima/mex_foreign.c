
/*****************************************************************************
* AMOS2
*
* Author: (c) 2011 Thanh Truong, UDBL
* $RCSfile: mex_foreign.c,v $
* $Revision: 1.12 $ $Date: 2014/01/12 16:33:12 $
* $State: Exp $ $Locker:  $
*
* Description: Mexima - Index routines through foreign functions
* ========================================================================
* $Log: mex_foreign.c,v $
* Revision 1.12  2014/01/12 16:33:12  torer
* Apple cc 5.0 safe C code
*
* Revision 1.11  2013/11/18 19:21:14  thatr500
* added mechanism for mapping function
*
* Revision 1.10  2013/08/06 16:20:45  thatr500
* removed OSX warnings
*
* Revision 1.9  2013/02/28 09:49:02  thatr500
* replace reserved C++ keyword 'delete' by 'remove'
*
* Revision 1.8  2013/01/18 14:35:42  thatr500
* - removed printf
* - added commandline assignment3.cmd
*
* Revision 1.7  2012/01/09 09:10:40  thatr500
* modified code to build extent
*
* Revision 1.6  2012/01/04 16:44:13  thatr500
* - maintain counter
* - use array instead of list. It gains 5MB (lesser) than the original MBTREE
*   for one million key/value pairs.
*
* Revision 1.5  2012/01/04 14:50:25  thatr500
* - allowed to extend indexing through Foreign function
* - add XTree as built-in index
*
* Revision 1.4  2012/01/02 08:54:41  thatr500
* skeleton code for defining new indextype through foreign function
*
* Revision 1.3  2011/12/29 08:48:22  thatr500
* add new line at the end of file
*
* Revision 1.2  2011/12/27 10:55:20  thatr500
* M-x indent-region
*
* Revision 1.1  2011/12/27 09:40:46  thatr500
* Index routines through foreign functions
*
**************************************************************************/
#include <callout.h>
#include "mexi_ff.h"
#include "mex_foreign.h"
#include "mexima.h"
#include "index.h"

extern oidtype make_foreign_mexifn(bindtype env, oidtype idxtype);
extern oidtype list_mexiforeign_objectsfn(bindtype env);
extern oidtype restore_mexiforeignfn(bindtype env, oidtype mexiforeign, oidtype listkv);
extern oidtype mexiforeign_ownerfn(bindtype env, oidtype mexiforeign);
extern oidtype mexi_foreign_getidfn(bindtype env, oidtype mexiforeign);
/*------------------------------------------------------------------
MEXIMA-FOREIGN-CREATE
------------------------------------------------------------------*/
oidtype mexf_creator(bindtype env, oidtype indhdr, size_t parm)
{
	oidtype mexiff;
	oidtype idxtype;
	// create an (AMOS) index
	a_let(idxtype, mkinteger(dr(indhdr, indexcell)->type));
	a_let(mexiff, make_foreign_mexifn(env, idxtype));
         OfType(mexiff, MEXIFOREIGNTYPE, env);	
	// set its owner
	a_setf(dr(mexiff, mexiforeigncell)->owner, dr(indhdr, indexcell)->owner);	
	a_return(mexiff);
}

/*------------------------------------------------------------------
MEXIMA-FOREIGN-GET
------------------------------------------------------------------*/
struct kvpair {
	oidtype key;
	oidtype val;
};

oidtype getterfn(a_callcontext cxt, int width, oidtype res[], void *xa){
	struct kvpair* pair = (struct kvpair*) xa;
	if (width > 0) {
		pair->val = res[0];
		if (a_datatype(res[0]) == SYMBOLTYPE) {
			a_setf(pair->val, nil);
		}
	}
	return nil;
}

oidtype mexf_getter(bindtype env, oidtype indhdr, oidtype mexiforeign,
		    oidtype key){

        struct kvpair pair;
	
	oidtype argl[2];  
	dcl_local_cxt(cxt,env);
	
	// Invoke the foreign function 
	argl[0] = mkinteger(dr(mexiforeign, mexiforeigncell)->id);
	argl[1] = key;
	
	// Only get the value
	pair.key = key;
	pair.val = nil;
	a_mapfunctionC(cxt, mexfsubs_table[dr(indhdr, indexcell)->type].get, 3, 
					argl, getterfn, &pair);  
	a_return(pair.val);
}
/*------------------------------------------------------------------*/
oidtype emptymapperfn(a_callcontext cxt, int width, oidtype res[], void *xa){
	return nil;
}
oidtype mexf_inserter(bindtype env, oidtype indhdr, oidtype xt, 
					  oidtype key,  oidtype val)
{
	oidtype argl[3];
	int type;
	//dcl_local_cxt(cxt, env);
	dcl_global_cxt(cxt);
	argl[0] = mkinteger(dr(xt, mexiforeigncell)->id);
	argl[1] = key;	
	argl[2] = val;	
        type = dr(indhdr, indexcell)->type;
	a_mapfunctionC(cxt,
		       mexfsubs_table[type].insert, 3, argl, emptymapperfn, NULL);
	return nil;	
}

/*------------------------------------------------------------------*/
oidtype mexf_deleter(bindtype env, oidtype indhdr, oidtype mexiff, 
					 oidtype key)
{
	oidtype argl[2];
	dcl_local_cxt(cxt, env);
	
	// Derefrences 
	argl[0] = mkinteger(dr(mexiff, mexiforeigncell)->id);
	argl[1] = key;
	a_mapfunctionC(cxt,
			mexfsubs_table[dr(indhdr, indexcell)->type].remove, 
			3, argl, emptymapperfn, NULL);  
	return t;
}
/*------------------------------------------------------------------*/
int mexf_counter(bindtype env, oidtype indhdr, oidtype xt)
{
	return dr(indhdr, indexcell)->cardinality;
}
/*------------------------------------------------------------------*/
struct mapdata{
	maphash_function mapfn;
	oidtype indhdr;
	bindtype penv;
	void *data;  
};

/*Applying maphash_function to each returned tuple*/
oidtype mapperfn(a_callcontext cxt, int width, oidtype res[], void *xa){
	dcl_oid(key);
	dcl_oid(val);
	int i =0;
	struct mapdata* mdata = (struct mapdata*) xa;  
	
	if (res != NULL) {
	  a_setf(val, res[0]);
	} 
	{unwind_protect_begin;
	// Emit the result
	(mdata->mapfn) (cxt->env, mdata->indhdr, nil, val, mdata->data);
	
	unwind_protect_catch;
	free_oid(key); 
	free_oid(val);	
	unwind_protect_end;}
	return nil;
}

void mexf_mapper(bindtype env, oidtype indhdr, oidtype xt,
				 maphash_function f, void *x) 
{
	struct mapdata mdata;
	oidtype argl[1];
	dcl_local_cxt(cxt, env);
	
	argl[0] = mkinteger(dr(xt, mexiforeigncell)->id);
	mdata.mapfn = f;
	mdata.data = x;
	mdata.indhdr = indhdr;
	mdata.penv = env;
	a_mapfunctionC(cxt, mexfsubs_table[dr(indhdr, indexcell)->type].map, 
			2, argl, mapperfn, &mdata); 
}

struct extentdata{
	oidtype extent;
	bindtype penv;
	int pos;
};

/*Building an extent*/
oidtype mapperextentfn(a_callcontext cxt, int width, oidtype res[], void *xa){
	struct extentdata* mdata = (struct extentdata*) xa;  
	a_seta(mdata->extent, mdata->pos, a_elt(res[0], 1)); 
	a_seta(mdata->extent, mdata->pos + 1, a_elt(res[0], 0)); 	
	mdata->pos = mdata->pos + 2;	
	return nil;
}

oidtype mexiff_buildextentfn(bindtype env, oidtype indhdr, oidtype xt) 
{
	struct mexiforeigncell *ex;
	struct indexcell *dx;
	struct extentdata mdata;
	oidtype argl[1];
	dcl_local_cxt(cxt, env);
	
	// Derefrences 
	ex = dr(xt, mexiforeigncell);
	dx = dr(indhdr, indexcell);

	argl[0] = mkinteger(ex->id);
	mdata.penv = env;
	mdata.pos = 0;
	a_let(mdata.extent, new_adjarray(2 * dx->cardinality, nil));
	a_mapfunctionC(cxt, mexfsubs_table[ex->indextype].map, 
			2, argl, mapperextentfn, &mdata); 
	a_return(mdata.extent);
}

oidtype restore_extent_mexifffn(bindtype env, oidtype indhdr,oidtype mexiff,
								oidtype extent)
{
	struct mexiforeigncell *ex;
	struct indexcell *dx;
	oidtype argl[3];
	int pos;
	int len;
	dcl_local_cxt(cxt, env);

	// Derefrences 
	ex = dr(mexiff, mexiforeigncell);
	dx = dr(indhdr, indexcell);

	argl[0] = mkinteger(ex->id);
	len = 2 * dx->cardinality;
	for (pos = 0; pos < len; pos = pos + 2) 
	{
		argl[1] = a_elt(extent, pos);	
		argl[2] = a_elt(extent, pos + 1);	
		a_mapfunctionC(cxt,
			mexfsubs_table[dx->type].insert, 3, argl, emptymapperfn, NULL);
	}
	return nil;
}

/*------------------------------------------------------------------*/
oidtype mex_foreign_register_indextype(bindtype env, oidtype oidname, oidtype stubs)
{
	struct index_properties idxpro;	
	char*name;
	int indextype;
	
	IntoString(oidname, name, env);
	strcpy(idxpro.name, name);	
	
	idxpro.creator = mexf_creator;
	idxpro.mapper = mexf_mapper;
	idxpro.getter = mexf_getter;
	idxpro.inserter = mexf_inserter;
	idxpro.deleter = mexf_deleter;
	idxpro.counter = mexf_counter;
	idxpro.dropper = NULL;
	
	indextype = define_index_type(idxpro);	
	if (mexfsubs_table == NULL) {
		mexfsubs_table = (mexfsubs*) malloc(sizeof(mexfsubs) * MAX_INDEX_TYPES); 
	}
	a_let(mexfsubs_table[indextype].create, a_nth(stubs, 0));
	a_let(mexfsubs_table[indextype].insert, a_nth(stubs, 1));
	a_let(mexfsubs_table[indextype].remove, a_nth(stubs, 2));
	a_let(mexfsubs_table[indextype].get,    a_nth(stubs, 3));
	a_let(mexfsubs_table[indextype].clear,  a_nth(stubs, 4));
	a_let(mexfsubs_table[indextype].map,    a_nth(stubs, 5));	
	return t;
}

void register_mexf(){     
	/*register a storagetype MEXIFOREIGNTYPE*/
	register_mexiforeign();
	/*register internal Lisp implementation in C*/
	extfunction2("register-indextype1", mex_foreign_register_indextype);	
	extfunction1("mexi-foreign-getid", mexi_foreign_getidfn);		
	extfunction0("list-mexiff-objects", list_mexiforeign_objectsfn);	
	extfunction2("restore-mexiff", restore_mexiforeignfn);	
	extfunction1("mexiff-owner", mexiforeign_ownerfn);
	extfunction1("mexi-foreign-count", mexi_foreign_countfn);
	extfunction2("mexiff-buildextent", mexiff_buildextentfn);
	extfunction3("restore-extent-mexiff", restore_extent_mexifffn);
}
