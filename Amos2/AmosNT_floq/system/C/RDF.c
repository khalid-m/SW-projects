/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: RDF.c,v $
 * $Revision: 1.15 $ $Date: 2013/12/27 13:10:53 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Basic RDF data structures
 * ===========================================================================
 * $Log: RDF.c,v $
 * Revision 1.15  2013/12/27 13:10:53  torer
 * Dereferencing of string bug
 *
 * Revision 1.14  2013/09/07 19:07:15  andan342
 * Added hex() and unhex() functions
 *
 * Revision 1.13  2013/08/20 13:24:01  silvias
 * USTR(NIL) returns NIL
 *
 * Revision 1.12  2013/03/14 20:32:01  torer
 * Size as unsigned int
 *
 * Revision 1.11  2013/03/14 15:01:19  torer
 * 32/64 bits neutral code
 *
 * Revision 1.10  2013/02/06 17:11:39  silvias
 * Larger buffer for csvrdfstring
 *
 * Revision 1.9  2013/02/06 14:03:45  torer
 * Buffer overflow checks
 *
 * Revision 1.8  2013/02/06 07:48:26  torer
 * New name:
 * csvrdfstring(Vector v, Charstring d)->Charstring
 *
 * Revision 1.7  2013/02/06 07:40:59  torer
 * new function
 *   csvstring(Vector v, Charstring d)->Charstring
 *
 * Revision 1.6  2012/12/13 17:08:15  andan342
 * Exporting *TYPE values and interfaces for time and RDF storage objects
 *
 * Revision 1.5  2012/06/25 20:37:18  andan342
 * Added TypedRDF storage type
 *
 * Revision 1.4  2012/05/24 14:58:45  andan342
 * Removed UB type, #[UB] value and UB() constructor, now using NIL instead
 *
 * Revision 1.3  2012/03/18 17:09:33  andan342
 * Fixed bug with pointers invalidated during image expansion inside URI & USTR
 *
 * Revision 1.2  2011/04/13 20:11:47  andan342
 * Added more RDF-related storage types and readers
 *
 * Revision 1.1  2011/02/09 14:03:24  torer
 * New storage type URI
 *
  ****************************************************************************/

#include "amos.h"

/* UB Type - Not used! */
/*
int ubtype;

struct ubcell
{
  objtags tags;
};

oidtype make_ubfn(bindtype env)
{
	oidtype res;
	res = new_object(sizeof(struct ubcell),ubtype);
	return res;
}

void dealloc_ub(oidtype x)
{
	dealloc_object(x);
}

void print_ub(oidtype x, oidtype stream, int princflg)
{
	a_puts("#[UB]",stream);
}


oidtype read_ub(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
	return make_ubfn(env);
}

int ub_compare(oidtype x, oidtype y)
{
  struct ubcell *dx = dr(x, ubcell), *dy = dr(y, ubcell);

  return 0;
}
*/

/* URI Type */

EXPORT int URITYPE;

struct uricell
{
  objtags tags;
  short int length; /* maintained by system */
  char id[1];
};

EXPORT oidtype make_uri(char* id)
{
	oidtype res;
  struct uricell *dres;  
  int idl = strlen(id);

  res = new_object(sizeof(*dres)+idl, URITYPE);
  dres = dr(res, uricell);
  memcpy(dres->id, id, idl+1);
  return res;  
}

oidtype make_urifn(bindtype env, oidtype id)
     /* Construct new uri with identifier str */
{
  char *did;
 
  IntoStackString(id, did, env);
	return make_uri(did);
}

void dealloc_uri(oidtype x) 
{
  dealloc_object(x);
}

void print_uri(oidtype x, oidtype stream, int princflg) 
{
  struct uricell *dx = dr(x, uricell);

  a_puts("#[URI \"",stream);
  a_puts(dx->id, stream); // does not handle \ and " check with standard
  a_puts("\"]",stream);
}

oidtype read_uri(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
  oidtype id = nil;
  a_setf(id, hd(x));
  return make_urifn(env,id);
}  

EXPORT char* uri_id(oidtype uri)
{
	struct uricell *duri = dr(uri, uricell);
  return duri->id;
}


oidtype uri_idfn(bindtype env, oidtype uri)
{
  OfType(uri, URITYPE, env);
  return mkstring(uri_id(uri));
}

int uri_compare(oidtype x, oidtype y)
{
  char *dx = dr(x, uricell)->id, *dy = dr(y, uricell)->id;

  return strcmp(dx,dy);
}

unsigned int uri_hash(oidtype x)
     /* Fast hashing of strings */
{
  char *str = dr(x,uricell)->id;

  return hash_x33_u4(str, strlen(str));
}

/* UniString type */

EXPORT int UNISTRINGTYPE;

struct unistringcell
{
  objtags tags;
  oidtype str;
  char lang[1];
};

EXPORT oidtype make_unistring(oidtype str, char* lang)
{ //Makes USTR from standard Amos String, lang parameter can be NULL
  oidtype res;
  struct unistringcell *dres;
	int langlen;

	if (!lang) langlen = 0;
	else langlen = strlen(lang);
  
  res = new_object(sizeof(struct unistringcell) + langlen, UNISTRINGTYPE);
  dres = dr(res, unistringcell);

  memcpy(dres->lang, (lang)? lang : "", langlen+1);

	dres->str = nil;
  a_setf(dres->str, str);

  return res;  
}

oidtype make_unistringfn(bindtype env, oidtype str, oidtype lang)
{
	if (str == nil) return nil; //BUG FIX
	OfType(str, STRINGTYPE, env);
  if (lang == nil) return make_unistring(str, NULL);
	else {
		OfType(lang, STRINGTYPE, env);
		return make_unistring(str, getstring(lang));	
	}
}

void dealloc_unistring(oidtype x) 
{
  a_free(dr(x, unistringcell)->str);
  dealloc_object(x);
}

void print_unistring(oidtype x, oidtype stream, int princflg) 
{
  struct unistringcell *dx = dr(x, unistringcell);

  a_puts("#[USTR \"",stream);
  a_prin1(dx->str, stream, 1);
  if (strlen(dx->lang) > 0)
  {
	a_puts("\" \"",stream);
	a_puts(dx->lang, stream);	
  }
  a_puts("\"]",stream);
}

oidtype read_unistring(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
  oidtype str = nil,
	      lang = nil;
  a_setf(str, hd(x));
  if (tl(x) != nil)
  {
	x = tl(x);
    a_setf(lang, hd(x));
  }
  return make_unistringfn(env,str,lang);
}  

EXPORT oidtype unistring_str(oidtype us)
{
  struct unistringcell *dus = dr(us, unistringcell);
  return dus->str;
}

oidtype unistring_strfn(bindtype env, oidtype us)
{
  OfType(us, UNISTRINGTYPE, env);  
  return unistring_str(us);
}

EXPORT char* unistring_lang(oidtype us)
{ 
  struct unistringcell *dus = dr(us, unistringcell);
  return dus->lang;
}

oidtype unistring_langfn(bindtype env, oidtype us)
{   
  OfType(us, UNISTRINGTYPE, env);
  return mkstring(unistring_lang(us));
}

int unistring_compare(oidtype x, oidtype y)
{ // Two UniStrings are equal if their str are equal and lang values are equal
  struct unistringcell *dx = dr(x, unistringcell),
	                   *dy = dr(y, unistringcell);

  int res = a_compare(dx->str, dy->str);
  if (res == 0)
	res = strcmp(dx->lang,dy->lang);
  return res;
}

unsigned int unistring_hash(oidtype x)
     /* Fast hashing of strings */
{
  return compute_hash_key(dr(x, unistringcell)->str);
}


/* TypedRDF type */

EXPORT int TYPEDRDFTYPE;

struct typedrdfcell
{
  objtags tags;
  oidtype str;
	oidtype typeuri;
};

EXPORT oidtype make_typedrdf(oidtype str, oidtype typeuri)
{
  oidtype res = new_object(sizeof(struct typedrdfcell), TYPEDRDFTYPE);
  struct typedrdfcell *dres = dr(res, typedrdfcell); 

	dres->str = nil;
	dres->typeuri = nil;

  a_setf(dres->str, str);
	a_setf(dres->typeuri, typeuri);

  return res;  
}

oidtype make_typedrdffn(bindtype env, oidtype str, oidtype typeuri)
{
	OfType(str, STRINGTYPE, env);
	OfType(typeuri, URITYPE, env);
	return make_typedrdf(str, typeuri);  
}

void dealloc_typedrdf(oidtype x) 
{
	struct typedrdfcell *dx = dr(x, typedrdfcell);
  a_free(dx->str);
	a_free(dx->typeuri);
  dealloc_object(x);
}

void print_typedrdf(oidtype x, oidtype stream, int princflg) 
{
  struct typedrdfcell *dx = dr(x, typedrdfcell);

  a_puts("#[TYPEDRDF \"",stream);
  a_prin1(dx->str, stream, 1);  
	a_puts("\" \"",stream);
  a_puts(dr(dx->typeuri, uricell)->id, stream);  
  a_puts("\"]",stream);
}

oidtype read_typedrdf(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
  oidtype str = nil, typeuri = nil;	      
  a_setf(str, hd(x));
  if (tl(x) != nil)
  {
		x = tl(x);
    a_setf(typeuri, make_urifn(env,hd(x)));
  }
  return make_typedrdffn(env,str,typeuri);
}  

EXPORT oidtype typedrdf_str(oidtype x)
{
  return dr(x, typedrdfcell)->str;
}

EXPORT oidtype typedrdf_typeuri(oidtype x)
{
  return dr(x, typedrdfcell)->typeuri;
}

oidtype typedrdf_strfn(bindtype env, oidtype x)
{
  OfType(x, TYPEDRDFTYPE, env);
  return typedrdf_str(x);
}

oidtype typedrdf_typeurifn(bindtype env, oidtype x)
{
  OfType(x, TYPEDRDFTYPE, env);
  return typedrdf_typeuri(x);
}

int typedrdf_compare(oidtype x, oidtype y)
{ // Two UniStrings are equal if their str are equal and lang values are equal
  struct typedrdfcell *dx = dr(x, typedrdfcell),
	                    *dy = dr(y, typedrdfcell);

	int res = uri_compare(dx->typeuri, dy->typeuri);
	if (res == 0)
		res = a_compare(dx->str, dy->str);  
  return res;
}

unsigned int typedrdf_hash(oidtype x)
     /* Fast hashing of strings */
{
  return compute_hash_key(dr(x, typedrdfcell)->str);
}

oidtype csvrdfstringBBF(a_callcontext cxt)
     /* Convert vectors of RDF resources represented as strings 
        to a CSV string */
{
  oidtype row = a_arg(cxt,1);
  oidtype delim = a_arg(cxt,2);
  struct arraycell *drow;
  char dchar[2]; //Delimiter string
  int i, dim;
  char buff[10000]; // result string

  if(a_datatype(row)!=ARRAYTYPE) return nil;
  if(a_datatype(delim)!=STRINGTYPE) return nil;
  drow = dr(row,arraycell);
  dim = drow->size;
  dchar[0] = getstring(delim)[0];
  dchar[1] = '\0';
  buff[0]='\0';
  if(dim==0) return nil;
  for(i=0;i<dim;i++)
    {
      oidtype e = drow->cont[i];

      if(i>0) strcat(buff,dchar);
      if(a_datatype(e)==STRINGTYPE)
	{
	  char *str = getstring(e);
  
	  switch(str[0])
	    {
	    case('"'): // Literal
	      {
		size_t len = strcspn(str+1,"\"");
		char lits[5000];
           
                if(len>=sizeof(lits))
		  {
                    printf("Literal size %u too large:\n'%s'\n", len, str);
                    break;
                  }
		memcpy(lits,str+1,len);
		lits[len] = '\0';
                if(strlen(buff)+strlen(lits) >= sizeof(buff)-1)
                  {
                    printf("Buffer exhausted when adding\n'%s'\nto\n'%s'\n", 
                           lits, buff);
                    break;
                  }
		strcat(buff,lits);
		break;
              }
	    case('<'): // URI
	    default:
                if(strlen(buff)+strlen(str) >= sizeof(buff))
                  {
                    printf("Buffer exhausted when adding\n'%s'\nto\n'%s'\n", 
                           str, buff);
                    break;
                  }
              
	      strcat(buff,str);
	    }
	}
    }  
  a_bind(cxt,3,mkstring(buff));
  a_result(cxt);
  return nil;
}

//////////////////// STRING UTILITIES

oidtype hexfn(bindtype env, oidtype i, oidtype width)
{ //ALisp: convert initeger to its hexadecimal string representation (uppercase)
  char buf[9];

  OfType(i, INTEGERTYPE, env);
  OfType(width, INTEGERTYPE, env);

  sprintf(buf, "%0*X", getinteger(width), getinteger(i));
  return mkstring(buf);
}

char hexv(char h)
{
	if (h >= '0' && h <= '9') return h - '0';
	else if (h >= 'A' && h <= 'F') return 10 + h - 'A';
	else if (h >= 'a' && h <= 'f') return 10 + h - 'a';
	else return -1;
}

oidtype unhexfn(bindtype env, oidtype s)
{ //ALisp: extract an integer from its hexadecimal string representation
  char* ds;
  int res = 0,
      i = 0;

  OfType(s, STRINGTYPE, env);
  ds = getstring(s);

  for (i=0; i < strlen(ds); i++) {
    res *= 16;
    res += hexv(ds[i]);
  }
  return mkinteger(res);
}


/* REGISTER RDF TYPES */

void register_rdf(void)
{
  /* URI Type */
  URITYPE = a_definetype("uri", dealloc_uri, print_uri);
  typefns[URITYPE].comparefn = uri_compare;
  typefns[URITYPE].hashfn = uri_hash;
  
  extfunction1("uri",make_urifn);
  extfunction1("uri-id",uri_idfn);
  type_reader_function("URI", read_uri);

  /* UB Type - Not used! */
/*  ubtype = a_definetype("ub", dealloc_ub, print_ub);
  typefns[ubtype].comparefn = ub_compare;

  extfunction0("ub",make_ubfn);
  type_reader_function("UB", read_ub); */

  /* USTR Type */
  UNISTRINGTYPE = a_definetype("ustr", dealloc_unistring, print_unistring);
  typefns[UNISTRINGTYPE].comparefn = unistring_compare;
  typefns[UNISTRINGTYPE].hashfn = unistring_hash;

  extfunction2("ustr", make_unistringfn);
  extfunction1("ustr-str", unistring_strfn);
  extfunction1("ustr-lang", unistring_langfn);
  type_reader_function("USTR", read_unistring);

	/* TypedRDF Type */
  TYPEDRDFTYPE = a_definetype("typedrdf", dealloc_typedrdf, print_typedrdf);
  typefns[TYPEDRDFTYPE].comparefn = typedrdf_compare;
  typefns[TYPEDRDFTYPE].hashfn = typedrdf_hash;

  extfunction2("typedrdf", make_typedrdffn);
  extfunction1("typedrdf-str", typedrdf_strfn);
  extfunction1("typedrdf-typeuri", typedrdf_typeurifn);
  type_reader_function("TYPEDRDF", read_typedrdf);

  a_extimpl("csvrdfstring--+",csvrdfstringBBF);	  

  extfunction2("hex", hexfn);
  extfunction1("unhex", unhexfn);
}
