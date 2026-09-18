/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Tore Risch, Erik Zeitler, UDBL
 * $RCSfile: storagetypes.c,v $
 * $Revision: 1.35 $ $Date: 2013/10/28 21:33:23 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Definition of new storage types
 *
 * ===========================================================================
 * $Log: storagetypes.c,v $
 * Revision 1.35  2013/10/28 21:33:23  torer
 * Introduced record scan interface
 *
 * Revision 1.34  2013/10/28 19:52:19  torer
 * Removed record type SSRC
 *
 * Revision 1.33  2013/04/17 21:50:44  torer
 * Object in function arguments not externalized
 *
 * Revision 1.32  2012/09/06 20:45:45  torer
 * New Lisp functions (IS-STREAMTYPE TPO) and (IS-STREAM-GENERATOR O)
 *
 * Revision 1.31  2012/08/10 06:42:23  torer
 * Bag function definitions marshalled only for transient objects
 *
 * Revision 1.30  2011/09/13 18:23:23  torer
 * New C function
 *   int is_bag(oidtype x)
 *
 * Revision 1.29  2011/05/31 18:58:07  torer
 * Optimized record access
 *
 * Revision 1.28  2011/05/31 16:48:49  torer
 * Checking type of make-record argument
 *
 * Revision 1.27  2011/05/31 14:55:04  torer
 * Bug in record equality
 *
 * Revision 1.26  2011/05/31 14:25:37  roka4241
 * Record equality.
 *
 * Revision 1.25  2011/04/20 10:06:54  torer
 * new C function
 *   int generator_width(bindtype env, oidtype g)
 *
 * Revision 1.24  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.23  2010/02/01 20:50:14  torer
 * New function CLOSURE-FUNCTION
 *
 * Revision 1.22  2009/11/12 10:38:45  torer
 * Compact printing of generators on stdoutstream
 *
 * Revision 1.21  2009/09/02 12:44:14  zeitler
 * OSQL record/streamsrc printer
 *
 * Revision 1.20  2009/09/01 13:56:15  zeitler
 * record extended with /kind/
 *
 * Revision 1.17  2009/08/20 17:41:11  zeitler
 * - Record is extended with /kind/ attribute
 * - kind 1 is used to carry stream source definitions
 *
 * Revision 1.16  2008/10/01 16:17:37  zeitler
 * port is extended with subscriber id
 *
 * Revision 1.15  2008/09/04 15:40:47  ruslan
 * bug in compare is fixed
 *
 * Revision 1.14  2008/09/04 11:23:32  ruslan
 * renaming id to sid in sobject type implementation
 *
 * Revision 1.13  2008/03/01 15:58:07  ruslan
 * type of sobject in Lisp
 *
 * Revision 1.12  2008/02/28 13:11:06  ruslan
 * new data type sobject for streamed objects
 *
 * Revision 1.11  2006/12/08 19:12:40  torer
 * 6% faster allocation of type STRUCT objects
 *
 * Revision 1.10  2006/12/08 18:23:55  torer
 * Bug in deallocation of type STRUCT
 *
 * Revision 1.9  2006/11/14 23:46:20  zeitler
 * Added extraction functions for port
 *
 * Revision 1.8  2006/11/03 17:22:34  zeitler
 * Fixed equal fcn for generators, added fcn headers in comm.h
 *
 * Revision 1.7  2006/10/25 17:31:11  zeitler
 * Better impl of generator equality functions
 *
 * Revision 1.6  2006/10/24 14:02:23  zeitler
 * generator comparison functions
 *
 * Revision 1.5  2006/10/24 11:29:44  zeitler
 * added protocol attrib to port
 *
 * Revision 1.4  2006/10/23 15:33:42  zeitler
 * New storagetype HOSTPORT, carrying socket info
 *
 * Revision 1.3  2006/04/26 16:55:50  torer
 * Changed Lisp constructor for STRUCT
 *
 * Revision 1.2  2006/04/26 12:23:52  torer
 * Storage type STRUCT implemented
 *
 * Revision 1.1  2006/04/26 09:33:34  torer
 * New source file for definining storage types
 *
 ***************************************************************************/

#include "amos.h"
#include "storagetypes.h"
#include <sys/stat.h>
#include <limits.h>

oidtype _stream_;

/***************************************************************************/
/*                           port                                          */
/***************************************************************************/

int porttype;                                    /* Type tag for type PORT */

oidtype read_port(bindtype env, oidtype tag, oidtype x, oidtype stream) {
  oidtype proto, hostname, portno, subscriber;

  proto = hd(x);
  x = ftl(x);
  hostname = hd(x);
  x = ftl(x);
  portno = hd(x);
  x = ftl(x);
  subscriber = hd(x);
  return make_portfn(env, proto, hostname, portno, subscriber);
}

oidtype make_portfn(bindtype env, oidtype proto, oidtype hostname,
            oidtype portno, oidtype subscriber) {
  oidtype res;
  struct portcell *dres;

  res = new_object(sizeof(*dres),porttype);
  dres = dr(res,portcell);

  a_let(dres->proto,proto);
  a_let(dres->hostname,hostname);
  a_let(dres->portno,portno);
  a_let(dres->subscriber,subscriber);
  return res;
}

EXPORT oidtype port_gethostnamefn(bindtype env, oidtype port) {
  struct portcell *d = dr(port,portcell);
  return d->hostname;
}

EXPORT oidtype port_getprotofn(bindtype env, oidtype port) {
  struct portcell *d = dr(port,portcell);
  return d->proto;
}

EXPORT oidtype port_getportnofn(bindtype env, oidtype port) {
  struct portcell *d = dr(port,portcell);
  return d->portno;
}

EXPORT oidtype port_getsubfn(bindtype env, oidtype port) {
  struct portcell *d = dr(port,portcell);
  return d->subscriber;
}

void free_port(oidtype x) {
  struct portcell *dx = dr(x,portcell);

  a_free(dx->proto);
  a_free(dx->hostname);
  a_free(dx->portno);
  a_free(dx->subscriber);
  dealloc_object(x);
}

void print_port(oidtype x, oidtype stream, int princflg) {
  struct portcell *dx = dr(x, portcell);
  oidtype proto = dx->proto;
  oidtype hostname = dx->hostname;
  oidtype portno = dx->portno;
  oidtype subscriber = dx->subscriber;

  a_puts("#[PORT ",stream);
  a_prin1(proto, stream, princflg);
  a_putc(' ',stream);
  a_prin1(hostname, stream, princflg);
  a_putc(' ',stream);
  a_prin1(portno, stream, princflg);
  a_putc(' ',stream);
  a_prin1(subscriber, stream, princflg);
  a_putc(']',stream);
}


/***************************************************************************/
/*                         stream generators                               */
/***************************************************************************/

EXPORT int generatortype;                   /* Type tag for type GENERATOR */

oidtype make_generatorfn(bindtype env, oidtype type, oidtype fn, 
                         oidtype params) 
{
  oidtype res;
  struct generatorcell *dres;

  inittype2(generatortype, res, dres, generatorcell); // Object size TWO!
  a_let(dres->type,type);
  a_let(dres->fn,fn);
  a_let(dres->params,params);
  return res;
}

void free_generator(oidtype x) 
{
  struct generatorcell *dx = dr(x,generatorcell);

  a_free(dx->type);
  a_free(dx->fn);
  a_free(dx->params);
  free2(x,doid(x)); /* Fits in object size 2 */
}

extern oidtype transientpfn(bindtype,oidtype);
oidtype externalize_functionfn(bindtype env, oidtype fn) 
{
  if(transientpfn(env, fn)==nil) return fn;
  return call_lisp(mksymbol("get-orgcode"),env,2,fn,t);
}

oidtype externalize_typefn(bindtype env, oidtype tp) 
{
  return call_lisp(mksymbol("decode-type"),env,1,tp);
}

oidtype internalize_typefn(bindtype env, oidtype tpdesc) 
{
  return call_lisp(mksymbol("encode-type"),env,1,tpdesc);
}

oidtype internalize_functionfn(bindtype env, oidtype fn) 
{
  return evalfn(env,fn);
}

void print_generator(oidtype x, oidtype stream, int princflg) 
{
  struct generatorcell *dx = dr(x, generatorcell);
  oidtype type = dx->type;
  oidtype fn = dx->fn;
  oidtype params = dx->params;
  oidtype l, oc = nil;

  a_setf(oc, externalize_functionfn(varstack,fn));
  a_puts("#[GENERATOR ",stream);
  a_prin1(externalize_typefn(varstack,type), stream, princflg);
  a_putc(' ',stream);
  if(stream!=stdoutstream)
    {
      a_prin1(oc, stream, princflg);
      for(l=params;listp(l);l=ftl(l))
    {
      a_putc(' ',stream);
      a_prin1(fhd(l), stream, princflg);
    }
    }
  else a_puts("..",stream);
  a_putc(']',stream);
  a_free(oc);
}

int equal_functionfn(oidtype x, oidtype y) 
{
  struct generatorcell *dx = dr(x, generatorcell);
  struct generatorcell *dy = dr(y, generatorcell);
  oidtype xfn, yfn;

  yfn = externalize_functionfn(varstack, dy->fn);
  xfn = externalize_functionfn(varstack, dx->fn);
  return equal(xfn,yfn);
}

int equal_typefn(oidtype x, oidtype y) 
{
  struct generatorcell *dx = dr(x, generatorcell);
  struct generatorcell *dy = dr(y, generatorcell);
  oidtype xt, yt;

  yt = externalize_functionfn(varstack, dy->type);
  xt = externalize_functionfn(varstack, dx->type);
  return equal(xt,yt);
}

int equal_paramsfn(oidtype x, oidtype y) 
{
  struct generatorcell *dx = dr(x, generatorcell);
  struct generatorcell *dy = dr(y, generatorcell);
  oidtype xpar, ypar;

  xpar = dx->params;
  ypar = dy->params;
  return equal(xpar,ypar);
}

int equal_generatorfn(oidtype x, oidtype y) 
{
  if (equal_typefn(x,y)) 
    {
      if (equal_functionfn(x,y)) 
	{
	  return equal_paramsfn(x,y);
	}
    }
  return 0;
}

oidtype inspect_generatorfn(bindtype env, oidtype x) 
{
  oidtype ret = nil;
  struct generatorcell *dx = dr(x,generatorcell);
  OfType(x, generatortype, env);

  printf("Encoded type ");
  a_print(dx->type);
  printf("; Encoded function ");
  a_print(dx->fn);
  printf("; Params ");
  a_print(dx->params);
  return ret;
}

oidtype read_generator(bindtype env, oidtype tag, oidtype x, oidtype stream) 
{
  oidtype type, fn, args;

  type = internalize_typefn(env,hd(x));
  x = ftl(x);
  fn = internalize_functionfn(env,hd(x));
  args = ftl(x);
  return make_generatorfn(env, type, fn, args);
}

EXPORT oidtype generator_typefn(bindtype env, oidtype g)
{
  OfType(g, generatortype, env);
  return dr(g,generatorcell)->type;
}

EXPORT oidtype generator_functionfn(bindtype env, oidtype g) 
{
  OfType(g, generatortype, env);
  return dr(g,generatorcell)->fn;
}

EXPORT oidtype generator_paramsfn(bindtype env, oidtype g) 
{
  OfType(g, generatortype, env);
  return dr(g,generatorcell)->params;
}

EXPORT int generator_width(bindtype env, oidtype g)
{
  static oidtype type_parameters=NULLH;

  if(type_parameters==NULLH) type_parameters = mksymbol("type-parameters");
  return a_length(getobjectfn(env,generator_typefn(env,g),type_parameters));
}

EXPORT oidtype generator_widthfn(bindtype env, oidtype g)
{
  return mkinteger(generator_width(env, g));
}

extern oidtype osql_subtypepfn(bindtype env, oidtype x, oidtype y, 
                               oidtype strict);
oidtype is_streamtypefn(bindtype env, oidtype o)
{
  if(a_datatype(o)==SURROGATETYPE && 
     osql_subtypepfn(env, o, globval(_stream_), nil)!=nil) return t;
  return nil;
}

oidtype is_stream_generatorfn(bindtype env, oidtype x)
{
  oidtype gtpo;

  if(a_datatype(x)!=generatortype) return nil;
  gtpo = generator_typefn(env, x);
  return is_streamtypefn(env, gtpo);
}

/***************************************************************************/
/*                         records                                         */
/***************************************************************************/

EXPORT int recordtype;                         /* Type tag for type RECORD */

EXPORT oidtype make_recordfn(bindtype env, oidtype fields) 
{
  oidtype res;
  struct recordcell *dres;

  if(fields==nil) fields=new_array(0,nil);
  OfType(fields, ARRAYTYPE, env);
  inittype1(recordtype, res, dres, recordcell); // Object size class ONE!
  dres = dr(res, recordcell);
  a_let(dres->fields, fields);
  return res;
}

void free_record(oidtype x) 
{
  struct recordcell *dx = dr(x,recordcell);

  a_free(dx->fields);
  free1(x,doid(x)); /* Fits in object of size class 1 */
}

void print_record(oidtype rec, oidtype stream, int princflg) 
{
  struct record_scan rs;

  open_record_scan(rec, &rs, FALSE); 
  a_puts("#[RECORD",stream);
  while(!record_scan_empty(&rs))
    {
      a_putc(' ',stream);
      a_prin1(record_scan_key(&rs), stream, princflg);
      a_putc(' ',stream);
      a_prin1(record_scan_value(&rs), stream, princflg);
      record_scan_next(&rs);
    }
  a_putc(']',stream);
}

oidtype read_record(bindtype env, oidtype tag, oidtype x, oidtype stream) 
{
  if(x==nil) return make_recordfn(env, nil);
  else return make_recordfn(env, listtoarrayfn(env, x));
}

oidtype record_fieldsfn(bindtype env, oidtype r) 
{
  OfType(r, recordtype, env);
  return dr(r,recordcell)->fields;
}

EXPORT int open_record_scan(oidtype r, struct record_scan *rs, int catcherror)
{
  if(a_datatype(r)!=recordtype) 
    return a_error(ILLEGAL_ARGUMENT, r, catcherror);
  rs->scan = dr(r,recordcell)->fields;
  rs->scanpos=0;
  rs->size=a_arraysize(rs->scan);
  return 0;
}

EXPORT oidtype record_getfn(bindtype env, oidtype r, oidtype key) 
{
  struct arraycell *fields;
  register int i, size;

  OfType(r, recordtype, env);
  fields = dr(dr(r,recordcell)->fields,arraycell);
  size = fields->size;
  for(i=0;i<size;i=i+2)
    {
      if(equal(fields->cont[i],key)) return fields->cont[i+1];
    }
  return nil;
}

EXPORT oidtype record_putfn(bindtype env, oidtype r, oidtype key, oidtype val) 
{
  oidtype fields;
  int i, size;

  OfType(r, recordtype, env);
  fields = dr(r,recordcell)->fields;
  size = a_arraysize(fields);
  for(i=0;i<size;i=i+2)
    {
      if(equal(a_elt(fields,i),key))
	{
	  a_seta(fields,i+1,val);
          return fields;
        }
    }
  if(!adjust_array(fields, size+2))
    {
      /* Array size could not be adjusted need to allocate new one */
      a_setf(dr(r,recordcell)->fields,
             copy_array(env,fields,size+2,FALSE));
    }
  a_seta(dr(r,recordcell)->fields, size, key);
  a_seta(dr(r,recordcell)->fields, size+1, val);
  return r;
}

int equal_record(oidtype x, oidtype y)
{
  struct recordcell *dx = dr(x, recordcell);
  struct recordcell *dy = dr(y, recordcell);
  struct arraycell *fx = dr(dx->fields,arraycell);
  struct arraycell *fy = dr(dy->fields,arraycell);   
  int sy = fy->size, sx = fx->size;
  register int i, j;   

  if(sx!=sy) return FALSE;
  for(i=0;i<sx;i=i+2)
    {
      oidtype k = fx->cont[i];

      for(j=0; j<sx; j=j+2)
        {
          if(equal(k,fy->cont[j]))
	    {
	      if(!equal(fx->cont[i+1],fy->cont[j+1])) return FALSE;
	    }
	}
    }
  return TRUE;
}

/***************************************************************************/
/*                           structures                                    */
/***************************************************************************/

int structtype;                                /* Type tag for type STRUCT */

/* Size of structcell with s slots in bytes: */
#define struct_size(s)sizeof(struct structcell)+ ((s)-1)*sizeof(oidtype) 

oidtype make_struct(oidtype typeo, short int size)
{
  oidtype res;
  struct structcell *dres;
  int i;

  inittypen(structtype,res,dres,struct_size(size),structcell);
  a_let(dres->typeo,typeo);
  dres->size = size;
  for(i=0;i<size;i++) dres->attributes[i] = nil;
  return res;
}

void free_struct(oidtype x)
{
  struct structcell *dx = dr(x,structcell);
  int i;

  for(i=0;i<dx->size;i++)
    { 
      a_free(dx->attributes[i]);
    }
  a_free(dx->typeo);
  freebytes(x,struct_size(dx->size));
}  

oidtype struct_get(bindtype env, oidtype s, int i)
{
  struct structcell *ds;

  OfType(s, structtype, env);
  ds = dr(s,structcell);
  if(i<0 || i>=ds->size) return lerror(ILLEGAL_ARGUMENT,s,env);
  return ds->attributes[i];
}

oidtype struct_set(bindtype env, oidtype s, int i, oidtype v)
{
  struct structcell *ds;

  OfType(s, structtype, env);
  ds = dr(s,structcell);
  if(i<0 || i>=ds->size) return lerror(ILLEGAL_ARGUMENT,s,env);
  a_setf(ds->attributes[i],v);
  return v;
}

/******************** Lisp interface ***************************************/

oidtype make_structfn(bindtype env, oidtype type, 
                                       oidtype cont)
{
  oidtype res;
  struct structcell *dres;
  int i;
  
  if(integerp(cont)) /* Size of struct given */
    return make_struct(type, (short int)getinteger(cont));
  OfType(cont,ARRAYTYPE,env);
  res = make_struct(type, (short int)a_arraysize(cont));
  dres = dr(res, structcell);
  for(i=0;i<dres->size;i++)
    {
      a_setf(dres->attributes[i],a_elt(cont,i));
    }
  return res;
}

oidtype struct_getfn(bindtype env, oidtype s, oidtype indx)
{
  int i;
 
  IntoInteger(indx, i, env);
  return struct_get(env, s, i);
}

oidtype struct_setfn(bindtype env, oidtype s, oidtype indx, oidtype v)
{
  int i;

  IntoInteger(indx, i, env);
  return struct_set(env, s, i, v);
}

oidtype struct_typefn(bindtype env, oidtype s)
{
  OfType(s, structtype, env);
  return dr(s,structcell)->typeo;
}

oidtype struct_sizefn(bindtype env, oidtype s)
{
  OfType(s, structtype, env);
  return mkinteger(dr(s,structcell)->size);
}

/***************************************************************************/
/*                  streamed objects                                       */
/***************************************************************************/

int sobjecttype;                                /* Type tag for type SOBJECT */

/* Size of structcell with s slots in bytes: */
#define sobject_size(s)sizeof(struct sobjectcell)+ ((s)-1)*sizeof(oidtype) 

oidtype make_sobject(oidtype typeo, oidtype src, oidtype sid, short int size)
{
  oidtype res;
  struct sobjectcell *dres;
  int i;

  inittypen(sobjecttype,res,dres,sobject_size(size),sobjectcell);
  a_let(dres->typeo,typeo);
  if (src)
    a_let(dres->src,src);
  a_let(dres->sid,sid);
  dres->size = size;
  for(i=0;i<size;i++) dres->attributes[i] = nil;
  return res;
}

void free_sobject(oidtype x)
{
  struct sobjectcell *dx = dr(x,sobjectcell);
  int i;
  for(i=0;i<dx->size;i++)
    { 
      a_free(dx->attributes[i]);
    }
  a_free(dx->typeo);
  a_free(dx->src);
  a_free(dx->sid);
  freebytes(x,sobject_size(dx->size));
}  

int compare_sobject(oidtype s1, oidtype s2)
{
  struct sobjectcell *ds1, *ds2;
  int cmp;
  ds1 = dr(s1,sobjectcell);
  ds2 = dr(s2,sobjectcell);
  cmp = a_compare(ds1->typeo,ds2->typeo);
  if (cmp) return cmp;
  cmp = a_compare(ds1->src,ds2->src);
  if (cmp) return cmp;
  return a_compare(ds1->sid,ds2->sid);
}

oidtype sobject_get(oidtype s, int i)
{
  struct sobjectcell *ds;

  ds = dr(s,sobjectcell);
  if(i<0 || i>=ds->size) {
    a_error(ARRAY_BOUNDS, i, FALSE);
    return nil;
  }
  return ds->attributes[i];
}

oidtype sobject_set(oidtype s, int i, oidtype v)
{
  struct sobjectcell *ds;

  ds = dr(s,sobjectcell);
  if(i<0 || i>=ds->size) {
    a_error(ARRAY_BOUNDS, i, FALSE);
    return nil;
  }
  a_setf(ds->attributes[i],v);
  return v;
}

oidtype sobject_typefn(bindtype env, oidtype s)
{
  OfType(s, sobjecttype, env);
  return dr(s,sobjectcell)->typeo;
}


oidtype closure_functionfn(bindtype env, oidtype clo)
{
  OfType(clo, CLOSURETYPE, env);
  return dr(clo,closurecell)->function;
}

/***************************************************************************/
/*   Register new storage types with associated Lisp function              */
/***************************************************************************/

void register_storagetypes(void)
{
  _stream_ = mksymbol("_stream_");

  generatortype = a_definetype("generator",free_generator,NULL);
  extfunction3("make-generator", make_generatorfn);
  extfunction1("generator-function", generator_functionfn);
  extfunction1("generator-params", generator_paramsfn);
  extfunction1("generator-type", generator_typefn);
  extfunction1("externalize-function",externalize_functionfn);
  extfunction1("internalize-function",internalize_functionfn);
  extfunction1("inspect-generator",inspect_generatorfn);
  typefns[generatortype].equalfn = equal_generatorfn;
  typefns[generatortype].printfn = print_generator;
  type_reader_function("GENERATOR", read_generator);
  extfunction1("generator-width", generator_widthfn);
  extfunction1("is-streamtype", is_streamtypefn);
  extfunction1("is-stream-generator", is_stream_generatorfn);

  recordtype = a_definetype("record", free_record, NULL);
  extfunction1("make-record", make_recordfn);
  extfunction1("record-fields", record_fieldsfn);
  extfunction2("record-get", record_getfn);
  extfunction3("record-put", record_putfn);
  typefns[recordtype].equalfn = equal_record;
  typefns[recordtype].printfn = print_record;
  type_reader_function("RECORD", read_record);

  structtype = a_definetype("struct",free_struct,NULL);
  extfunction2("make-struct", make_structfn);
  extfunction2("struct-get", struct_getfn);
  extfunction3("struct-set", struct_setfn);
  extfunction1("struct-type", struct_typefn);
  extfunction1("struct-size", struct_sizefn);

  porttype = a_definetype("port", free_port, NULL);
  typefns[porttype].printfn = print_port;
  type_reader_function("PORT", read_port);
  extfunction4("new-port", make_portfn);
  extfunction1("port-gethostname", port_gethostnamefn);
  extfunction1("port-getproto", port_getprotofn);
  extfunction1("port-getportno", port_getportnofn);
  extfunction1("port-getsubscriber", port_getsubfn);

  sobjecttype = a_definetype("sobject",free_sobject,NULL);
  typefns[sobjecttype].comparefn =  compare_sobject;
  extfunction1("sobject-type", sobject_typefn);

  extfunction1("closure-function", closure_functionfn);
}
