/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Martynas Mickevicius, UDBL
 * $RCSfile: rdfr.c,v $
 * $Revision: 1.8 $ $Date: 2010/02/21 21:52:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: The datatype RDFRESOURCE
 ****************************************************************************/

#define RDFR_TYPES_COUNT 8

#include "rdfr.h"

#include "amos.h"
#include "a_time.h"
#include <cfloat>

/* will use this function instead of a_printstring,
   becouse a_printstring does not use third parameter */
extern string_puts(char *,oidtype,int);

extern oidtype new_date(int, int, int);
extern oidtype new_time(int, int, int);

int rdfresource;

struct rdfrcell       // Template for storage type RDF RESOURCE
{
  objtags tags;       // System tags
  int kind;           // URI reference: 0
                      // literal:       1
                      // blank node:    2
  oidtype datatype;   // datatype for typed literals
  oidtype decoded;    // data in external format (string representation)
  oidtype encoded;    // data in internal format
  char lang[1];       // language will go if any
};

/*
*
* Definitions of encoder and decoder functions
*
*/

oidtype encode_uri(oidtype data)
{
  // uri internal encoding is the same string representation
  return data;
}

oidtype decode_uri(oidtype data)
{
  // not a string passed to create URI
  // raise error
  a_error(error_defs[NTR_ERR_URI_FROM_OBJECT], data, 0);
  return nil;
}

oidtype encode_lit(oidtype data)
{
  // plain literal internal encoding is the same string representation
  return data;
}

oidtype decode_lit(oidtype data)
{
  // not a string passed to create plain literal
  // raise error
  a_error(error_defs[NTR_ERR_LIT_FROM_OBJECT], data, 0);
  return nil;
}

oidtype encode_bnode(oidtype data)
{
  // blank node internal encoding the same string representation
  return data;
}

oidtype decode_bnode(oidtype data)
{
  // not a string passed to create blank node
  // raise error
  a_error(error_defs[NTR_ERR_BNODE_FROM_OBJECT], data, 0);
  return nil;
}

oidtype encode_real(oidtype data)
{
  // handle special cases of real numbers
  if (strcmp(getstring(data), "INF") == 0)
  {
    return mkreal(FLT_MAX);
  }
  else if (strcmp(getstring(data), "-INF") == 0)
  {
    return mkreal(FLT_MIN);
  }
  return mkreal(atof(getstring(data)));
}

oidtype decode_real(oidtype data)
{
  char str_val[32];
  if (integerp(data))
  {
    sprintf(str_val, "%i\0", getinteger(data));
  }
  else
  {
    sprintf(str_val, "%lf\0", getreal(data));
  }
  return mkstring(str_val);
}

oidtype encode_date(oidtype data)
{
  // parse simple date in format yyyy-mm-dd
  char year[4];
  char month[2];
  char day[2];

  strncpy(year, getstring(data), 4);
  strncpy(month, &(getstring(data)[5]), 2);
  strncpy(day, &(getstring(data)[8]), 2);

  return mkdate(atoi(year), atoi(month), atoi(day));
}

oidtype decode_date(oidtype data)
{
  char str_val[11];
  sprintf(str_val, "%04i-%02i-%02i\0", getyear(data), getmonth(data), getday(data));
  return mkstring(str_val);
}

oidtype encode_time(oidtype data)
{
  // parse sime time in format hh-mm-ss
  char hour[2];
  char minute[2];
  char second[2];

  strncpy(hour, getstring(data), 2);
  strncpy(minute, &(getstring(data)[3]), 2);
  strncpy(second, &(getstring(data)[6]), 2);

  return mktime3(atoi(hour), atoi(minute), atoi(second));
}

oidtype decode_time(oidtype data)
{
  char str_val[9];
  sprintf(str_val, "%02i:%02i:%02i\0", gethour(data), getminute(data), getsecond(data));
  return mkstring(str_val);
}

// struct for type table
struct rdfr_type
{
  int kind;                     // used to determine which fn to use
  oidtype (*encodefn)(oidtype); // external -> internal; (string)->(object)
  oidtype (*decodefn)(oidtype); // internal -> external; (object)->(string)
  char *dt_uri;                 // used to determine which fn to use
};

typedef struct rdfr_type rdfr_type_t;

//  rdfr type table
rdfr_type_t rdfr_type_table[RDFR_TYPES_COUNT] =
{
  {0, encode_uri, decode_uri, NULL},
  {1, encode_lit, decode_lit, NULL},
  {2, encode_bnode, decode_bnode, NULL},
  {3, encode_real, decode_real, "http://www.w3.org/2001/XMLSchema#float"},
  {3, encode_real, decode_real, "http://www.w3.org/2001/XMLSchema#decimal"},
  {3, encode_real, decode_real, "http://www.w3.org/2001/XMLSchema#double"},
  {4, encode_date, decode_date, "http://www.w3.org/2001/XMLSchema#date"},
  {5, encode_time, decode_time, "http://www.w3.org/2001/XMLSchema#time"}
};

int get_type_table_index_by_datatype(oidtype dt)
      // type table seach funtion by datatype
{
  int i;

  // if datatype object is string
  // most probably it is just an entry string.
  // return index of plain literal entry
  if (stringp(dt))
    return 1;

  // itarate through type table searching for datatype match
  for (i = 0; i < RDFR_TYPES_COUNT; i++)
  {
    if (rdfr_type_table[i].dt_uri != NULL && strcmp(rdfr_type_table[i].dt_uri, getstring(dr(dt, rdfrcell)->decoded)) == 0)
    {
      return i;
    }
  }
  // if no datatype match found,
  // return index of plain literal type
  return 1;
}

int get_type_table_index_by_kind(int k)
      // type table seach funtion by kind
{
  int i;
  // iterate through type table searching for kind match
  for (i = 0; i < RDFR_TYPES_COUNT; i++)
  {
    if (rdfr_type_table[i].kind == k)
    {
      return i;
    }
  }
  return -1;
}

oidtype new_rdfr(int kind, oidtype data, char *lang, oidtype datatype)
      // Constructor for a RDFRESOURCE objects
{
  char *langtmp;
  oidtype rdfr = nil;
  int type_table_index;

  // Copy strings in case image moves them
  if (lang != NULL)
    langtmp = mystrdup(lang);
  else
    langtmp = mystrdup("");

  // Allocate a new object of type RDFRESOURCE in the image.
  // This may move the image and make strings invalid
  rdfr = new_object(
    sizeof(struct rdfrcell) + // basic size of structure (this includes \0 size of lang string)
    strlen(langtmp),          // size for lang string
    rdfresource
  );

  // set kind part
  dr(rdfr, rdfrcell)->kind = kind;

  // set lang part
  memcpy(dr(rdfr, rdfrcell)->lang, langtmp, strlen(langtmp) + 1);
  free(langtmp);

  dr(rdfr, rdfrcell)->decoded = nil;
  dr(rdfr, rdfrcell)->encoded = nil;
  dr(rdfr, rdfrcell)->datatype = nil;

  if (kind == 1)
  {
    // literal, either typed or not
    // following function will return index to
    // plain literal type table entry, if no index found by specified datatype
    type_table_index = get_type_table_index_by_datatype(datatype);

    if (stringp(data))
    {
      // encode
      a_setf(dr(rdfr, rdfrcell)->decoded, data);
      a_setf(dr(rdfr, rdfrcell)->encoded, (*rdfr_type_table[type_table_index].encodefn)(data));
    }
    else
    {
      // decode
      a_setf(dr(rdfr, rdfrcell)->decoded, (*rdfr_type_table[type_table_index].decodefn)(data));
      a_setf(dr(rdfr, rdfrcell)->encoded, data);
    }
    dr(rdfr, rdfrcell)->kind = rdfr_type_table[type_table_index].kind;
    a_setf(dr(rdfr, rdfrcell)->datatype, datatype);
  }
  else
  {
    // kind is known
    type_table_index = get_type_table_index_by_kind(kind);
    if (type_table_index != -1)
    {
      if (stringp(data))
      {
        // encode
        a_setf(dr(rdfr, rdfrcell)->decoded, data);
        a_setf(dr(rdfr, rdfrcell)->encoded, (*rdfr_type_table[type_table_index].encodefn)(data));
      }
      else
      {
        // decode
        a_setf(dr(rdfr, rdfrcell)->decoded, (*rdfr_type_table[type_table_index].decodefn)(data));
        a_setf(dr(rdfr, rdfrcell)->encoded, data);
      }

      // set datatype according to type table index
      if (rdfr_type_table[type_table_index].dt_uri != NULL)
      {
        a_setf(dr(rdfr, rdfrcell)->datatype, new_rdfr(0, mkstring(rdfr_type_table[type_table_index].dt_uri), NULL, nil));
      }
    }
    else
    {
      // no encoder/decoder was found by kind
      a_error(error_defs[NTR_ERR_NO_CODEC_BY_KIND], mkinteger(kind), 0);
    }
  }

  // Return the new object in image
  return rdfr;
}

void dealloc_rdfr(oidtype r)
      // deallocate RDFRESOURCE object
{
  a_free(dr(r, rdfrcell)->datatype);
  a_free(dr(r, rdfrcell)->encoded);
  a_free(dr(r, rdfrcell)->decoded);

  dealloc_object(r);
}

char *rdfr_get_lang(oidtype o)
      // get language of RDFRESROURCE
{
    return dr(o, rdfrcell)->lang;
}

void print_rdfr(oidtype o, oidtype stream, int princflg)
      // Print function for RDFRESOURCE
{
  a_puts("#[RDFR ", stream);
  a_puts(IntegerToString(dr(o, rdfrcell)->kind), stream);
  a_putc(' ', stream);

  a_putc('"', stream);
  a_prin1(dr(o, rdfrcell)->decoded, stream, 1);
  a_putc('"', stream);

  a_putc(' ', stream);
  a_printstring(rdfr_get_lang(o), stream, FALSE);
  a_putc(' ', stream);
  a_prin1(dr(o, rdfrcell)->datatype, stream, princflg);
  a_putc(']', stream);
  return;
}

oidtype read_rdfr(bindtype env, oidtype tag, oidtype x, oidtype stream)
      // Read an #[RDFR ...] object from stream
{
  int kind;
  char *langtmp;
  char *lang;
  oidtype data = nil;
  oidtype datatype = nil;
  oidtype object = nil;

  a_setf(object, x);

  IntoInteger(hd(object), kind, env);

  a_setf(object, tl(object));
  a_setf(data, hd(object));

  a_setf(object, tl(object));
  IntoString(hd(object), langtmp, env);
  lang = mystrdup(langtmp);

  a_setf(object, tl(object));
  if (hd(object) != nil)
    a_setf(datatype, hd(object));

  return new_rdfr(kind, data, lang, datatype);
}

int rdfr_compare(oidtype x, oidtype y)
     // Function to compare two RDFRESOURCE objects
{
  // Scenarious of possible x and y values
  // *  x and y are of the same kind. Then these may be decoded to
  //    amos objects. If this is the case, compare them as objects
  // *  x and y are of the different kinds. Compare kinds as integers
  if(dr(x, rdfrcell)->kind == dr(y, rdfrcell)->kind)
  {
    // both RDFResources x and y are of the same kind
    return a_compare(dr(x, rdfrcell)->encoded, dr(y, rdfrcell)->encoded);
  }
  // If x is a y are of different kinds, compare kinds as numbers
  else
  {
    // if x kind is lesser than y kind, return -1
    if(dr(x, rdfrcell)->kind < dr(y, rdfrcell)->kind) return -1;

    // if x kind is equal to y, return 0
    // if x kind is greater than y, return 1
    return dr(x, rdfrcell)->kind > dr(y, rdfrcell)->kind;
  }

  return 0;
}

unsigned int rdfr_hash(oidtype r)
      // hashing of RDFRESOURCE objects
{
  return compute_hash_key(dr(r, rdfrcell)->encoded);
}

/*
*
* Definitions of foreign ALisp interface functions
*
*/

oidtype rdfr_isuri_alisp_fn(bindtype env, oidtype x)
      // ALisp function to test if a RDFRESOURCE is an uri
{
  OfType(x, rdfresource, env);
  if(dr(x, rdfrcell)->kind == 0)
    return t;
  else return nil;
}

oidtype rdfr_islit_alisp_fn(bindtype env, oidtype x)
      // ALisp function to test if a RDFRESOURCE is aliteral
{
  OfType(x, rdfresource, env);
  if(dr(x, rdfrcell)->kind == 1)
    return t;
  else return nil;
}

oidtype rdfr_isbnode_alisp_fn(bindtype env, oidtype x)
      // ALisp function to test if a RDFRESOURCE is blank node
{
  OfType(x, rdfresource, env);
  if(dr(x, rdfrcell)->kind == 2)
    return t;
  else return nil;
}

oidtype rdfr_make_alisp_fn(bindtype env, oidtype ty, oidtype da, oidtype la, oidtype dt)
      // ALisp function to construct RDFRESOURCE object
{
  int kind;
  char *lang;

  IntoInteger(ty, kind, env);
  IntoString(la, lang, env);

  return new_rdfr(kind, da, lang, dt);
}

oidtype rdfr_kind_alisp_fn(bindtype env, oidtype r)
      // ALisp function to access kind of RDFRESOURCE
{
  OfType(r, rdfresource, env);
  return mkinteger(dr(r, rdfrcell)->kind);
}

oidtype rdfr_data_alisp_fn(bindtype env, oidtype r)
      // ALisp function to access data of RDFRESOURCE
{
  OfType(r, rdfresource, env);
  return dr(r, rdfrcell)->encoded;
}

oidtype rdfr_lang_alisp_fn(bindtype env, oidtype r)
      // ALisp function to access lang of RDFRESOURCE
{
  OfType(r, rdfresource, env);
  return mkstring(rdfr_get_lang(r));
}

oidtype rdfr_datatype_alisp_fn(bindtype env, oidtype r)
      // ALisp function to access datatype of RDFRESOURCE
{
  OfType(r, rdfresource, env);
  return dr(r, rdfrcell)->datatype;
}

oidtype rdfr_print_alisp_fn(bindtype env, oidtype o, oidtype stream)
      // Print in n-triples format function for RDFRESOURCE
{
  int kind = -1;

  kind = dr(o, rdfrcell)->kind;

  if (kind == 0)
  {
    // print URI
    a_putc('<', stream);
    a_prin1(dr(o, rdfrcell)->decoded, stream, 1);
    a_putc('>', stream);
  }
  else if (kind == 1)
  {
    // print literal
    a_putc('"', stream);
    a_prin1(dr(o, rdfrcell)->decoded, stream, 1);
    a_putc('"', stream);
    if (*rdfr_get_lang(o) != '\0')
    {
      // print lang
      a_putc('@', stream);
      string_puts(rdfr_get_lang(o), stream, TRUE);
    }
    else if (dr(o, rdfrcell)->datatype != nil)
    {
      // print datatype
      string_puts("^^", stream, TRUE);
      rdfr_print_alisp_fn(env, dr(o, rdfrcell)->datatype, stream);
    }
  }
  else if (kind == 2)
  {
    // print blank node
    string_puts("_:", stream, TRUE);
    a_prin1(dr(o, rdfrcell)->decoded, stream, 1);
  }
  else
  {
    // print custom resource
    a_putc('"', stream);
    a_prin1(dr(o, rdfrcell)->decoded, stream, 1);
    string_puts("\"^^<", stream, TRUE);
    string_puts(rdfr_type_table[dr(o, rdfrcell)->kind].dt_uri, stream, TRUE);
    a_putc('>', stream);
  }

  return t;
}

/*
*
* Definitions of foreign Amos II interface functions
*
*/

oidtype rdfrbbbbf(a_callcontext cxt)
      // Amos II TBR implementation to create RDFRESOURCE object
{
  int i;
  oidtype kind = a_arg(cxt, 1);
  oidtype data = a_arg(cxt, 2);
  oidtype lang = a_arg(cxt, 3);
  oidtype datatype = a_arg(cxt, 4);

  IntoInteger(kind, i, a_env(cxt));
  OfType(lang, STRINGTYPE, a_env(cxt));

  a_bind(cxt, 5, new_rdfr(
    i,
    data,
    getstring(lang),
    datatype
  ));
  a_result(cxt);

  return nil;
}

oidtype rdfrffffb(a_callcontext cxt)
      // Amos II TBR implementation to access RDFRESOURCE properties
{
  oidtype r;

  r = a_arg(cxt, 5);

  OfType(r, rdfresource, a_env(cxt));

  a_bind(cxt, 1, mkinteger(dr(r, rdfrcell)->kind));
  a_bind(cxt, 2, dr(r, rdfrcell)->encoded);
  a_bind(cxt, 3, mkstring(rdfr_get_lang(r)));
  a_bind(cxt, 4, dr(r, rdfrcell)->datatype);

  a_result(cxt);

  return nil;
}

oidtype rdfr_kind_fn(a_callcontext cxt)
      // Amos II TBR implementation to access RDFRESOURCE kind
{
  oidtype r = a_arg(cxt, 1);
  OfType(r, rdfresource, a_env(cxt));
  a_bind(cxt, 2, mkinteger(dr(r, rdfrcell)->kind));
  a_result(cxt);
  return nil;
}

oidtype rdfr_data_fn(a_callcontext cxt)
      // Amos II TBR implementation to access RDFRESOURCE data
{
  oidtype r = a_arg(cxt, 1);
  OfType(r, rdfresource, a_env(cxt));
  a_bind(cxt, 2, dr(r, rdfrcell)->encoded);
  a_result(cxt);
  return nil;
}

oidtype rdfr_lang_fn(a_callcontext cxt)
      // Amos II TBR implementation to access RDFRESOURCE lang
{
  oidtype r = a_arg(cxt, 1);
  OfType(r, rdfresource, a_env(cxt));
  a_bind(cxt, 2, mkstring(rdfr_get_lang(r)));
  a_result(cxt);
  return nil;
}

oidtype rdfr_datatype_fn(a_callcontext cxt)
      // Amos II TBR implementation to access RDFRESOURCE datatype
{
  oidtype r = a_arg(cxt, 1);
  OfType(r, rdfresource, a_env(cxt));
  a_bind(cxt, 2, dr(r, rdfrcell)->datatype);
  a_result(cxt);
  return nil;
}

void register_rdfr(void)
      // Initialize storage type RDFRESOURCE and access functions
{
  // Define user defined reader for #[RDFR type data lang datatype]
  type_reader_function("RDFR", read_rdfr);

  // Define user defined datatype RDFRRESOURCE
  rdfresource = a_definetype("rdfr", dealloc_rdfr, print_rdfr);

  typefns[rdfresource].hashfn = rdfr_hash;
  typefns[rdfresource].comparefn = rdfr_compare;

  // Define Lisp interface functions
  extfunction1("rdfr-isuri", rdfr_isuri_alisp_fn);
  extfunction1("rdfr-islit", rdfr_islit_alisp_fn);
  extfunction1("rdfr-isbnode", rdfr_isbnode_alisp_fn);
  extfunction4("rdfr-make", rdfr_make_alisp_fn);
  extfunction1("rdfr-kind", rdfr_kind_alisp_fn);
  extfunction1("rdfr-data", rdfr_data_alisp_fn);
  extfunction1("rdfr-lang", rdfr_lang_alisp_fn);
  extfunction1("rdfr-datatype", rdfr_datatype_alisp_fn);
  extfunction2("rdfr-print", rdfr_print_alisp_fn);

  /* Define AmosQL interface functions */
  a_extimpl("rdfrbbbbf", rdfrbbbbf);
  a_extimpl("rdfrffffb", rdfrffffb);
  a_extimpl("rdfr-kind", rdfr_kind_fn);
  a_extimpl("rdfr-data", rdfr_data_fn);
  a_extimpl("rdfr-lang", rdfr_lang_fn);
  a_extimpl("rdfr-datatype", rdfr_datatype_fn);
}
