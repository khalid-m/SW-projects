/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $Revision: 1.5 $
 * $State: Exp $
 *
 * Description: Type checking funtions
 * ===========================================================================
 * $Log: typecheck.c,v $
 * Revision 1.5  2011/12/29 07:35:17  torer
 * Checking tuple types
 *
 * Revision 1.4  2011/09/13 18:23:23  torer
 * New C function
 *   int is_bag(oidtype x)
 *
 * Revision 1.3  2011/04/06 15:04:22  torer
 * type tag macro OIDTYPE changed to SURROGATETYPE to not confuse with C typedef 'oidtype'
 *
 * Revision 1.2  2009/11/03 19:57:16  torer
 * Inferring types of materialized bags
 *
 * Revision 1.1  2008/12/05 12:38:43  torer
 * Added type checking functions
 *
 ****************************************************************************/

#include "amos.h"

oidtype _bindings_, amostypesymbol, _tupletag_, 
        infer_bagtype, infer_tupletype;
extern oidtype _object_;
#define binding_type(x) a_elt(x,3)
#define binding_var(x) a_elt(x,1)

oidtype getbindingfn(bindtype env, oidtype v, oidtype noerror)
     /*** Get the current binding of variable v in *BINDINGS* ***/
{
  oidtype b, p;

  for(p=evalfn(env,_bindings_);listp(p);p=ftl(p))
    {
      b = fhd(p);
      if(binding_var(b)==v) return b;
    }
  if(noerror!=nil) return nil;
  return call_lisp(amos_error,env,2,mkstring("Undefined variable: "),v);
}

oidtype type_of_varfn(bindtype env, oidtype v, oidtype bndl)
     /*** Get the type of variable x in binding list bndl ***/
{
  oidtype b, p;

  for(p=bndl;listp(p);p=ftl(p))
    {
      b = fhd(p);
      if(binding_var(b)==v)
	{
	  oidtype res = binding_type(b);

	  if(listp(res) && hd(res)!=globval(_tupletag_)) return hd(res);
	  return res;
	}
    }
  return nil;
}

extern oidtype aggr_bag, aggr_tuple;
oidtype arg_typesfn(bindtype env, oidtype x)
     /*** Compute the type set of object x ***/
{
  unsigned int tt;
  oidtype tag, typeatm, amostype, res;
  static int init_arg_types = FALSE;
  static oidtype _charstring_, _integer_, _real_, _vector_, _boolean_;
  static oidtype function_resulttypes, _bag_, castSymbol;

  tt = a_datatype(x);
  if(!init_arg_types)
    {
      _charstring_ = mksymbol("_charstring_");
      _integer_ = mksymbol("_integer_");
      _real_ = mksymbol("_real_");
      _vector_ = mksymbol("_vector_");
      _boolean_ = mksymbol("_boolean_");
      _bag_ = mksymbol("_bag_");
      castSymbol = mksymbol("cast");
      function_resulttypes = mksymbol("function-resulttypes");
      init_arg_types = TRUE;
    }
  if(x==nil) return get_allsupertypes(globval(_object_));
  if(listp(x) && hd(x)==castSymbol)
    return get_allsupertypes(call_lisp(mksymbol("cast-to-type"),env,1,x));
  typeatm = mksymbol(typefns[tt].name);
  amostype = getpropfn(env,typeatm,amostypesymbol);
  if(amostype != nil)
    {
      oidtype temp;

      temp=call_lisp(amostype,env,1,x);
      res = get_allsupertypes(temp);
      if(res!=nil) return res;
    }
  switch(tt)
    {
    case SURROGATETYPE: 
      {
	oidtype res = oid_types(x);
	if(res!=nil) return res;
	return call_lisp(amos_error,env,2,
			 mkstring("Object has no type: "), x);
      }
    case STRINGTYPE: return get_allsupertypes(globval(_charstring_));
    case INTEGERTYPE: return get_allsupertypes(globval(_integer_));
    case REALTYPE: return get_allsupertypes(globval(_real_));
    case ARRAYTYPE: return get_allsupertypes(globval(_vector_));
    case SYMBOLTYPE:
      if(booleanpfn(env,x)!=nil) return get_allsupertypes(globval(_boolean_));
      else return cons(binding_type(getbindingfn(env,x,nil)),nil);
    case LISTTYPE:
      tag = fhd(x);
      if(tag == aggr_bag) 
	return  get_allsupertypes(call_lisp(infer_bagtype, env, 1, x));
      if(tag == globval(_tupletag_)) 
        return get_allsupertypes(call_lisp(infer_tupletype, env, 1, x));
      return call_lisp(function_resulttypes,env,1,x);
    default:
      return call_lisp(amos_error,env,2,
		       mkstring("Unknown type of object: "),x);
    }
}

oidtype arg_typefn(bindtype env, oidtype x)
     /*** Compute the most specific type of an object x ***/
{
  oidtype res,temp;

  temp = arg_typesfn(env,x); /* May fail */
  a_let(res,most_specific_type(temp)); /* The rest never fails */
  if(listp(res) && hd(res)!=globval(_tupletag_))
    {
      a_setf(res,hd(res));
      release(temp);
      a_return(res);
    }
  release(temp);
  a_return(res);
}

EXPORT int is_bag(oidtype x)
{
  int dt = a_datatype(x);

  if(dt==generatortype) return TRUE;
  if(dt==LISTTYPE && fhd(x)==aggr_bag) return TRUE;
  return FALSE;
}

void register_typecheck_functions(void)
{
  _bindings_ = mksymbol("*bindings*");
  _tupletag_ = mksymbol("_tupletag_");
  amostypesymbol = mksymbol("amostype");
  infer_bagtype = mksymbol("infer-bagtype");
  infer_tupletype = mksymbol("infer-tupletype");
  extfunction2("getbinding",getbindingfn);
  extfunction1("arg-types",arg_typesfn);
  extfunction2("type-of-var",type_of_varfn);
  extfunction1("arg-type",arg_typefn);
  return;
}
