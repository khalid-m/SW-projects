/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: resource.c,v $
 * $Revision: 1.2 $ $Date: 2009/09/02 07:49:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: The datatype RESOURCE for RDF
 * ===========================================================================
 * $Log: resource.c,v $
 * Revision 1.2  2009/09/02 07:49:19  torer
 * Clean plain RDF RESOURCE storage type
 *
 * Revision 1.1  2009/09/02 06:49:19  torer
 * Definition of storage type RDF RESOURCE in separate file resource.c
 *
 ****************************************************************************/

#include "amos.h"

int resource;

struct resourcecell  // Template for storage type RDF RESOURCE 
{
  objtags tags;      // System tags
  short int bytes;   // Total size of object in bytes, incl. header
  short int datatype;// URI reference: 0
                     // plain literals: 1
  char id[1];        // URI identifier padded here
};

oidtype new_R(int datatype, char *str)
     /* Constructor for a RESOURCE objects */
{

  /* Copy str to tmp in case image moves str */
  char *tmp = mystrdup(str);

  /* Allocate a new object of type URI in the image.
     This may move the image and make str invalid */ 
  oidtype res = new_object(sizeof(struct resourcecell) + strlen(tmp), 
			   resource);

  dr(res, resourcecell)->datatype = datatype;
  
  /* Set id part of the new object to str */
  memcpy(dr(res, resourcecell)->id, tmp, strlen(tmp) + 1);
  free(tmp);

  /* Return the new object in image */
  return res;
}

void print_resource(oidtype o, oidtype stream, int princflg)
     /* Print function for RDF resources */
{
  char *id = dr(o, resourcecell)->id;

  a_puts("#[R ",stream);
  a_puts(IntegerToString(dr(o, resourcecell)->datatype),stream);
  a_putc(' ',stream);
  a_printstring(id, stream, FALSE);
  a_putc(']',stream);
  return;
}

oidtype read_resource(bindtype env, oidtype tag, oidtype x, oidtype stream)
     /* Read an #[R ...] object from stream */
{
  char *uri;
  int lit;

  IntoInteger(hd(x), lit, env);
  IntoString(fhd(ftl(x)),uri,env);
  return new_R(lit, uri);
}

int resource_compare(oidtype x, oidtype y)
     /* Function to compare two RESOURCE objects */
{ 
  /* If both resources x and y are either literals or URIs
     compare their string representations */
  if(dr(x,resourcecell)->datatype == dr(y,resourcecell)->datatype)
    return strcmp(dr(x,resourcecell)->id, dr(y,resourcecell)->id);

  /* If x is a URI and y a literal
     return -1 since a literal is regarded as larger than a URI */
  else if(dr(x,resourcecell)->datatype < dr(y,resourcecell)->datatype)
    return -1;

  /* If x is a literal and y a URI => return 1 */ 
  else return 1;
}

unsigned int resource_hash(oidtype x)
     /* Fast hashing of strings */
{
  char *str = dr(x,resourcecell)->id;

  return hash_x33_u4(str, strlen(str));
}

/*** Definitions of foreign ALisp interface functions ***/

oidtype is_rlitfn(bindtype env, oidtype x)
     /* ALisp function to test if a RESOURCE is an RDF literal */
{
  OfType(x,resource,env);
  if(dr(x,resourcecell)->datatype)
    return t;
  else return nil;
}

oidtype make_resourcefn(bindtype env, oidtype dt, oidtype id)
     /* ALisp function to construct RESOURCE object */
{
  char *uri;
  int datatype;

  IntoInteger(dt,datatype,env);
  IntoString(id,uri,env);
  return new_R(datatype,uri);  
}

oidtype resource_idfn(bindtype env, oidtype r)
     /* ALisp function to access ID of RESOURCE */
{
  OfType(r,resource,env);
  return mkstring(dr(r,resourcecell)->id);
}

oidtype resource_datatypefn(bindtype env, oidtype r)
     /* Return the datatype identifier of RESOURCE object */
{
  OfType(r,resource,env);
  return mkinteger(dr(r,resourcecell)->datatype);
}

/*** Definitions of foreign Amos II interface functions ***/

void rbbf(a_callcontext cxt, a_tuple params) 
     /* Amos II TBR implementation to create RESOURCE object */
{
  oidtype r;
  int datatype;
  char uri[1000];

  datatype = a_getintelem(params, 0, FALSE);
  r = new_R(datatype,uri);        
  a_setobjectelem(params, 2, r, FALSE);
  a_emit(cxt, params, FALSE);
}

void rffb(a_callcontext cxt, a_tuple params) 
     /* Amos II TBR implementation to access RESOURCE properties */
{
  oidtype r;

  r = a_getobjectelem(params, 2, FALSE);
  a_setintelem(params, 0, dr(r,resourcecell)->datatype,FALSE);
  a_setstringelem(params, 1, dr(r,resourcecell)->id, FALSE);  
  a_emit(cxt, params, FALSE);
}

void register_resource(void)
     /* Initialize storage type RESOURCE and access functions */
{
  /* Define user defined reader for #[R dt uriref] */
  type_reader_function("R", read_resource);
  
  /* Define user defined datatype RESOURCE */
  resource = a_definetype("resource",dealloc_object,print_resource);
  
  typefns[resource].hashfn = resource_hash;
  typefns[resource].comparefn = resource_compare;

  /* Define Lisp interface functions */
  extfunction1("is-rlit", is_rlitfn);
  extfunction2("make-resource",make_resourcefn);
  extfunction1("resource-id",resource_idfn);
  extfunction1("resource-datatype",resource_datatypefn);

  /* Define AmosQL interface functions */
  a_extfunction("RBBF",rbbf);
  a_extfunction("RFFB",rffb);
}
