/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Ruslan Fomkin
 * $RCSfile: structs.cpp,v $
 * $Revision: 1.29 $ $Date: 2011/01/18 13:13:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description:
 *	Struct interface for C and AmosQL
 ****************************************************************************
 * $Log: structs.cpp,v $
 * Revision 1.29  2011/01/18 13:13:38  andan342
 * Fixed mapper functions according to new conventions
 *
 * Revision 1.28  2008/09/04 15:54:02  ruslan
 * sobject_transpose is working correctly
 *
 * Revision 1.27  2008/09/04 11:25:00  ruslan
 * reflects renaming. sobject_transpose_tovector in interface
 *
 * Revision 1.26  2008/09/03 14:46:29  ruslan
 * sobject_transpose is fixed
 *
 * Revision 1.25  2008/09/01 11:05:50  ruslan
 * sobject_transpose is added
 *
 * Revision 1.24  2008/09/01 08:11:18  ruslan
 * names of C transpose functions correspond to their AmosQL names
 *
 * Revision 1.23  2008/05/16 11:49:09  ruslan
 * memory leak bug is fixed
 *
 * Revision 1.22  2008/05/15 15:27:06  ruslan
 * multidirection particle-event relationship. interface of root_scan_project_addslots is improved
 *
 * Revision 1.21  2008/03/14 14:21:43  ruslan
 * transpose from sobject to vector is added. not used anywhere
 *
 * Revision 1.20  2008/03/01 10:05:23  ruslan
 * collecting cardinality statistics for vector slots
 *
 * Revision 1.19  2008/02/28 13:11:32  ruslan
 * using sobject
 *
 * Revision 1.18  2008/02/12 10:47:18  ruslan
 * bug in cachefn is fixed
 *
 * Revision 1.17  2008/02/07 08:33:08  ruslan
 * transpose with making additional slots for particles. bug fixing in caching
 *
 * Revision 1.16  2008/02/05 14:42:43  ruslan
 * caching result of function into struct slot
 *
 * Revision 1.15  2008/01/28 14:27:26  ruslan
 * transpose from struct to struct can collect statistics
 *
 * Revision 1.14  2007/12/17 16:56:21  ruslan
 * specific transpose operating on structs
 *
 * Revision 1.13  2007/12/15 15:38:20  ruslan
 * comments are added
 *
 * Revision 1.12  2007/12/05 09:21:23  ruslan
 * test code removed
 *
 * Revision 1.11  2007/12/02 11:24:51  ruslan
 * collecting statistics during setting slots with vectors
 *
 * Revision 1.10  2007/11/24 08:57:33  ruslan
 * bug is fixed in struct_getbag
 *
 * Revision 1.9  2007/11/17 10:00:02  ruslan
 * example, where multidirectional does not close derived query
 *
 * Revision 1.8  2007/11/09 15:08:56  ruslan
 * C implementation of UDFs
 *
 * Revision 1.7  2007/11/07 15:14:54  torer
 * Amos II version 10 with faster basic OjectLog interface to C
 * Aggregation operators can now be defined in C
 *
 * Revision 1.6  2007/11/06 12:45:38  ruslan
 * transpose returning vector of structs
 *
 * Revision 1.5  2007/11/06 11:04:48  ruslan
 * traspose vector of vector into vector of vector
 *
 * Revision 1.4  2007/11/05 14:08:57  torer
 * *** empty log message ***
 *
 * Revision 1.3  2007/11/05 09:07:57  ruslan
 * multidirectional get_slot functions, which ability to return, when index is not provided
 *
 * Revision 1.2  2007/11/03 11:49:32  ruslan
 * AmosQL interface function to create new struct
 *
 * Revision 1.1  2007/11/03 10:10:11  ruslan
 * returning structs
 *
 ****************************************************************************/

#include "structs.h"

bool _struct_stat_ = FALSE;
bool _slot_stat_ = FALSE;
oidtype _struct_stat_fno_;
oidtype true_v;

/**********************************************
 * Basic sobject create and access functions
 *********************************************/

/* Creates new struct for a given vector */
oidtype make_sobjectbbbbf(a_callcontext cxt)
{
	oidtype type = a_arg(cxt,1);
	oidtype src = a_arg(cxt,2);
	oidtype sid = a_arg(cxt,3);
	oidtype cont = a_arg(cxt,4);
	oidtype res;
	struct sobjectcell *dres;
	int i;
	
	if(integerp(cont)) /* Size of struct given */
		res = make_sobject(type, src, sid, (short int)getinteger(cont));
	else {
		OfType(cont,ARRAYTYPE,a_env(cxt));
		res = make_sobject(type, src, sid, (short int)a_arraysize(cont));
		dres = dr(res, sobjectcell);
		for(i=0;i<dres->size;i++)
		{
			a_setf(dres->attributes[i],a_elt(cont,i));
		}
	}
	a_bind(cxt,5,res);
	a_result(cxt);
	return nil;
}

oidtype make_sobjectbbbf(a_callcontext cxt)
{
	oidtype type = a_arg(cxt,1);
	oidtype sid = a_arg(cxt,2);
	oidtype cont = a_arg(cxt,3);
	oidtype res;
	struct sobjectcell *dres;
	int i;
	
	if(integerp(cont)) /* Size of struct given */
		res = make_sobject(type, nil, sid, (short int)getinteger(cont));
	else {
		OfType(cont,ARRAYTYPE,a_env(cxt));
		res = make_sobject(type, nil, sid, (short int)a_arraysize(cont));
		dres = dr(res, sobjectcell);
		for(i=0;i<dres->size;i++)
		{
			a_setf(dres->attributes[i],a_elt(cont,i));
		}
	}
	a_bind(cxt,4,res);
	a_result(cxt);
	return nil;
}

/* Returns size of a struct */
oidtype sobject_sizebf(a_callcontext cxt)
{
	oidtype s = a_arg(cxt,1);
	a_bind(cxt,2,mkinteger(dr(s,sobjectcell)->size));
	a_result(cxt);
	return nil;
}

/* Returns meta-data about sturct type */
oidtype sobject_typebf(a_callcontext cxt)
{
	oidtype s = a_arg(cxt,1);
	a_bind(cxt,2,dr(s,sobjectcell)->typeo);
	a_result(cxt);
	return nil;
}

oidtype sobject_srcbf(a_callcontext cxt)
{
	oidtype s = a_arg(cxt,1);
	oidtype src = dr(s,sobjectcell)->src;
	if(src) {
		a_bind(cxt,2,src);
		a_result(cxt);
	}
	return nil;
}

oidtype sobject_idbf(a_callcontext cxt)
{
	oidtype s = a_arg(cxt,1);
	a_bind(cxt,2,dr(s,sobjectcell)->sid);
	a_result(cxt);
	return nil;
}

/* Returns object for a given slot of a struct. */
oidtype sobject_getbbf(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype s = a_arg(cxt,1);
	int i = getinteger(a_arg(cxt,2));
	
	ds = dr(s,sobjectcell);
	if(i<0 || i>=ds->size) return nil;
	a_bind(cxt,3,ds->attributes[i]);
	a_result(cxt);
	return nil;
}

/* Returns all slots of a sturct */
oidtype sobject_getbff(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype s = a_arg(cxt,1);
	
	ds = dr(s,sobjectcell);
	for (int i=0;i<ds->size;i++) {
		a_bind(cxt,2,mkinteger(i));
		a_bind(cxt,3,ds->attributes[i]);
		a_result(cxt);
	}
	return nil;
}

/**********************************************
 * Collecting statistics for struct slots
 * containing vectors.
 *********************************************/

/* Sets flag to collect statistics. Fails to set if
stat function is unknown. */
oidtype set_structstat(a_callcontext cxt)
{
	oidtype flag = a_arg(cxt,1);
	if (flag == true_v) {
		if (_struct_stat_fno_ == nil)
			return nil;
		_struct_stat_ = TRUE;
		a_result(cxt);
	}
	else _struct_stat_ = FALSE;
	return nil;
}

oidtype set_slotstat(a_callcontext cxt)
{
	oidtype flag = a_arg(cxt,1);
	if (flag == true_v) {
		if (_struct_stat_fno_ == nil)
			return nil;
		_slot_stat_ = TRUE;
		a_result(cxt);
	}
	else _slot_stat_ = FALSE;
	return nil;
}

/* Sets function to collect statistics */
oidtype set_structstatfnb(a_callcontext cxt)
{
	_struct_stat_fno_ = a_arg(cxt,1);
	a_result(cxt);
	return nil;
}

/* Returns stat function */
oidtype get_structstatfnf(a_callcontext cxt)
{
	if (_struct_stat_fno_ != nil)
	{
		a_bind(cxt,1,_struct_stat_fno_);
		a_result(cxt);
	}
	return nil;
}

/* Successfull mapper */
oidtype ok_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	*((int *)xa)=TRUE;
	return nil;
}

/* Sets collected statistics */
bool collect_stat(a_callcontext cxt, oidtype s, int v_size, int i, oidtype stat_fno)
{
	oidtype s_type = dr(s,sobjectcell)->typeo;
	oidtype argl = new_array(3,nil);
	oidtype i_oid = mkinteger(i);
	int OK=FALSE;
	oidtype v_size_oid = mkinteger(v_size);
	a_seta(argl, 0, s_type);
	a_seta(argl, 1, i_oid);
	a_seta(argl, 2, v_size_oid);
	a_mapfunction(cxt,stat_fno,argl, ok_mapper, (void *)&OK);
	if(!OK)
		return false;
	return true;
}


/* Sets a slot for sobject and collect statistics if necessary and possible */
oidtype sobject_set_stat(a_callcontext cxt, oidtype s, int i, oidtype v)
{
	if (_slot_stat_ && arrayp(v) && (_struct_stat_fno_ != nil))
		collect_stat(cxt, s, a_arraysize(v), i, _struct_stat_fno_);
	sobject_set(s,i,v);
	return v;
}

oidtype sobject_set_advstat(a_callcontext cxt, oidtype s, int i, oidtype v)
{
	if (_struct_stat_ && (_struct_stat_fno_ != nil))
		collect_stat(cxt, s, a_arraysize(v), i, _struct_stat_fno_);
	sobject_set(s,i,v);
	return v;
}

/* Sets slot of a sturct. Interfacing to AmosQL */
oidtype sobject_setbbb(a_callcontext cxt) {
	oidtype s = a_arg(cxt,1);
	int i = getinteger(a_arg(cxt,2));
	oidtype v = a_arg(cxt,3);

	sobject_set_stat(cxt,s,i,v);
	a_result(cxt);
	return nil;
}

/* Set slot of a struct to vector. Can collect statistics */
oidtype sobject_setvectorbbb(a_callcontext cxt)
{
	oidtype s = a_arg(cxt,1);
	int i = getinteger(a_arg(cxt,2));
	oidtype v = a_arg(cxt,3);
	
	sobject_set_advstat(cxt,s,i,v);
	a_result(cxt);
	return nil;
}

/* Set slot of a struct to vector. Can collect statistics using given fucntion */
oidtype sobject_setvectorbbbb(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype s = a_arg(cxt,1);
	int i = getinteger(a_arg(cxt,2));
	oidtype v = a_arg(cxt,3);
	oidtype stat_fno = a_arg(cxt,4);
	
	if (_struct_stat_)
		collect_stat(cxt, s, a_arraysize(v), i, stat_fno);
	ds = dr(s,sobjectcell);
	if(i<0 || i>=ds->size) return nil;
	a_setf(ds->attributes[i],v);
	a_result(cxt);
	return nil;
}

/* Returns bag for a vector slot of a struct. */
oidtype sobject_getbagbbf(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype s = a_arg(cxt,1);
	int i = getinteger(a_arg(cxt,2));
	oidtype v;
	
	//  OfType(s, structtype, env);
	ds = dr(s,sobjectcell);
	if(i<0 || i>=ds->size) return nil;
	v = ds->attributes[i];
	for (int j=0; j<a_arraysize(v); j++)
	{
		a_bind(cxt,3,a_elt(v,j));
		a_result(cxt);
	}
	return nil;
}

/**********************************************
 * Transpose for particles.
 *********************************************/

oidtype vector_transpose(a_callcontext cxt)
{
	oidtype v = a_arg(cxt,1);
	oidtype vi, ri, r;
	int n = a_arraysize(v);
	int m = a_arraysize(a_elt(v,0));
	
	r = new_array(m,nil);
	for(int i=0; i<n; i++) {
		vi = a_elt(v,i);
		for(int j=0;j<m;j++) {
			if (i==0) 
			{
				ri = new_array(n,nil);
				a_seta(r,j,ri);
			} else ri = a_elt(r,j);
			a_seta(ri,i,a_elt(vi,j));
		}
	}
	a_bind(cxt,2,r);
	a_result(cxt);
	return nil;
}

oidtype sobject_transpose_tovector(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype v = a_arg(cxt,1); //vector of indexes
	oidtype s = a_arg(cxt,2); //input struct
	oidtype rest = a_arg(cxt,3); //output struct type
	oidtype vi, ri, r;
	int n = a_arraysize(v);
	int m;
	int ve;
	oidtype s_key;

	ds = dr(s,sobjectcell);
	ve = getinteger(a_elt(v,0));
	vi = ds->attributes[ve];
	m = a_arraysize(vi);
	if (m==0) { // No particles are presented. An event vector attribute is empty.
		return nil;
	}

	s_key = new_array(2,nil);
	a_seta(s_key,0,ds->src);
	a_seta(s_key,1,ds->sid);

	r = new_array(m,nil);
	for(int i=0; i<n; i++) {
		ve = getinteger(a_elt(v,i));
		vi = ds->attributes[ve];
		for(int j=0;j<m;j++) {
			if (i==0) 
			{
				ri = make_sobject(rest,s_key,mkinteger(j),n);
				a_seta(r,j,ri);
			} else ri = a_elt(r,j);
			sobject_set(ri,i,a_elt(vi,j));
		}
	}
	a_bind(cxt,4,r);
	a_result(cxt);
	return nil;
}

/* Transpose from sobject into sobjects */
oidtype sobject_transpose(a_callcontext cxt)
{
	typedef oidtype* oidp;
	struct sobjectcell *ds;
	oidtype v = a_arg(cxt,1); //vector of indexes
	oidtype s = a_arg(cxt,2); //input struct
	oidtype rest = a_arg(cxt,3); //output struct type
	oidtype ri,vi;
	int n = a_arraysize(v);
//	oidp* attv;
	int m;
	int ve;
	oidtype s_key;
	int j,i;

	ds = dr(s,sobjectcell);
/*	attv = new oidp[n];
	for (i=0;i<n;i++) {
		ve = getinteger(a_elt(v,0));
		attv[i] = &(ds->attributes[ve]);
	}
	m = a_arraysize(*(attv[0]));*/
	ve = getinteger(a_elt(v,0));
	vi = ds->attributes[ve];
	m = a_arraysize(vi);


	if (m==0) { // No particles are presented. An event vector attribute is empty.
		return nil;
	}

	s_key=new_array(2,nil);
	a_seta(s_key,0,ds->src);
	a_seta(s_key,1,ds->sid);
	for(j=0;j<m;j++) {
		ri = make_sobject(rest,s_key,mkinteger(j),n);
		for(i=0; i<n; i++) {
			ve = getinteger(a_elt(v,i));
			vi = ds->attributes[ve];
//			vi=*(attv[i]);
			sobject_set(ri,i,a_elt(vi,j));
		}
		a_bind(cxt,4,ri);
		a_result(cxt);
	}
	return nil;
}

/* Transpose from sobject into sobject and materialize in the stream object */
oidtype mat_sobject_transpose(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype v = a_arg(cxt,1); //vector of indexes
	oidtype s = a_arg(cxt,2); //input and output struct
	oidtype rest = a_arg(cxt,3); //output struct type
	oidtype i_oid = a_arg(cxt, 4); //slot for output structs
	oidtype vi, ri, r;
	int n = a_arraysize(v);
	int m;
	int ve;
	oidtype s_key;

	ds = dr(s,sobjectcell);
	ve = getinteger(a_elt(v,0));
	vi = ds->attributes[ve];
	m = a_arraysize(vi);


	if (m==0) {
		if (_struct_stat_ && (_struct_stat_fno_ != nil))
			collect_stat(cxt, s, m, getinteger(i_oid), _struct_stat_fno_);
		a_result(cxt);
		return nil;
	}

	s_key=new_array(2,nil);
	a_seta(s_key,0,ds->src);
	a_seta(s_key,1,ds->sid);
	r = new_array(m,nil);
	for(int i=0; i<n; i++) {
		ve = getinteger(a_elt(v,i));
		vi = ds->attributes[ve];
		for(int j=0;j<m;j++) {
			if (i==0) 
			{
				ri = make_sobject(rest,s_key,mkinteger(j),n);
				a_seta(r,j,ri);
			} else ri = a_elt(r,j);
			sobject_set(ri,i,a_elt(vi,j));
		}
	}
	sobject_set_advstat(cxt,s,getinteger(i_oid),r);
	a_result(cxt);
	return nil;
}

oidtype mat_sobject_transpose_and_add_slots(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype v = a_arg(cxt,1); //vector of indexes
	oidtype s = a_arg(cxt,2); //input and output struct
	oidtype rest = a_arg(cxt,3); //output struct type
	oidtype i_oid = a_arg(cxt, 4); //slot for output structs
	int add_slots = getinteger(a_arg(cxt,5)); //slots to add
	oidtype vi, ri, r;
	int n = a_arraysize(v);
	int m;
	int ve;
	oidtype s_key;

	ds = dr(s,sobjectcell);
	ve = getinteger(a_elt(v,0));
	vi = ds->attributes[ve];
	m = a_arraysize(vi);


	if (m==0) {
		if (_struct_stat_ && (_struct_stat_fno_ != nil))
			collect_stat(cxt, s, m, getinteger(i_oid), _struct_stat_fno_);
		a_result(cxt);
		return nil;
	}

	s_key = new_array(2,nil);
	a_seta(s_key,0,ds->src);
	a_seta(s_key,1,ds->sid);
	r = new_array(m,nil);
	for(int i=0; i<n; i++) {
		ve = getinteger(a_elt(v,i));
		vi = ds->attributes[ve];
		for(int j=0;j<m;j++) {
			if (i==0) 
			{
				ri = make_sobject(rest,s_key,mkinteger(j),n+add_slots);
				a_seta(r,j,ri);
			} else ri = a_elt(r,j);
			sobject_set(ri,i,a_elt(vi,j));
		}
	}
	sobject_set_advstat(cxt,s,getinteger(i_oid),r);
	a_result(cxt);
	return nil;
}
/**********************************************
 * Cache function in stucts
 *********************************************/

struct bagvalues
{
	oidtype val;
	bagvalues* next;
};

struct cacheclosure
{
	bagvalues* curval;
	bagvalues* firstval;
	int size;
};

oidtype cache_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
	struct cacheclosure *cc;
	bagvalues *newval = new bagvalues;
	newval->val = nil;
	
	a_setf(newval->val,restpl[0]);
	cc = (struct cacheclosure *)xa;
	cc->size++;
	if (cc->curval)
		cc->curval->next = newval;
	else
		cc->firstval = newval;
	cc->curval = newval;
	return nil;
}

oidtype cachefn(a_callcontext cxt)
{
	struct sobjectcell *ds;
	oidtype s = a_arg(cxt,3);
	oidtype f = a_arg(cxt,1);
	oidtype res;
	int slot = getinteger(a_arg(cxt,2));

	ds = dr(s,sobjectcell);
	if (ds->attributes[slot] == nil)
	{
		oidtype argl = new_array(1,nil);
		bagvalues* curval, *nextval;
		struct cacheclosure cc;
		cc.size = 0;
		cc.curval = 0;
		a_seta(argl, 0, s);
		a_mapfunction(cxt,f,argl, cache_mapper, (void *)&cc);
		res = new_array(cc.size,nil);
		curval = cc.firstval;
		for (int i = 0; i < cc.size; i++) {
			a_seta(res,i,curval->val);
			a_free(curval->val);
			nextval = curval->next;
			delete curval;
			curval = nextval;
		}
		sobject_set_advstat(cxt,s,slot,res);
	} else
		res = ds->attributes[slot];
	for (int i = 0; i < a_arraysize(res); i++) {
		a_bind(cxt,4,a_elt(res,i));
		a_result(cxt);
	}
	return nil;
}


/**********************************************
 * Initialization and registration of interface.
 *********************************************/

void register_structsfns(void)
{
	true_v = mksymbol("TRUE");
	_struct_stat_fno_ = nil;
	a_extimpl("sobject_setbbb",sobject_setbbb);
	a_extimpl("sobject_getbbf",sobject_getbbf);
	a_extimpl("sobject_getbff",sobject_getbff);
	a_extimpl("sobject_sizebf",sobject_sizebf);
	a_extimpl("sobject_typebf",sobject_typebf);
	a_extimpl("sobject_srcbf",sobject_srcbf);
	a_extimpl("sobject_idbf",sobject_idbf);
	a_extimpl("make_sobjectbbbbf",make_sobjectbbbbf);
	a_extimpl("make_sobjectbbbf",make_sobjectbbbf);
	a_extimpl("vector_transpose",vector_transpose);
	a_extimpl("sobject_getbagbbf",sobject_getbagbbf);
	a_extimpl("set_structstat",set_structstat);
	a_extimpl("set_slotstat",set_slotstat);
	a_extimpl("set_structstatfnb",set_structstatfnb);
	a_extimpl("get_structstatfnf",get_structstatfnf);
	a_extimpl("sobject_setvectorbbb",sobject_setvectorbbb);
	a_extimpl("sobject_setvectorbbbb",sobject_setvectorbbbb);
	a_extimpl("sobject_transpose",sobject_transpose);
	a_extimpl("sobject_transpose_tovector",sobject_transpose_tovector);
	a_extimpl("mat_sobject_transpose",mat_sobject_transpose);
	a_extimpl("cachefn",cachefn);
	a_extimpl("mat_sobject_transpose_and_add_slots",mat_sobject_transpose_and_add_slots);
}
