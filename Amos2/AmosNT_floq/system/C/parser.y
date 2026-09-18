/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1993-2006 Martin Sköld, Tore Risch, Vanja Josifovski, 
 *                       EDSLAB, UDBL
 * $RCSfile: parser.y,v $
 * $Revision: 1.29 $ $Date: 2013/12/18 13:11:44 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Parser for AmosQL
 * ===========================================================================
 * $Log: parser.y,v $
 * Revision 1.29  2013/12/18 13:11:44  torer
 * removed function record(), replaced with make_record()
 * New function empty_record()
 *
 * Revision 1.28  2012/05/15 18:39:43  torer
 * Wrong priority for ^
 *
 * Revision 1.27  2011/12/30 15:26:55  torer
 * Introduced flex_c, the last character read in a flexstream
 *
 * Revision 1.26  2011/12/18 16:51:31  torer
 * Memory leaks
 *
 * Revision 1.25  2011/11/20 19:56:43  torer
 * mixup of parser line buffers between SQL and AmosQL scanners
 *
 * Revision 1.24  2011/11/17 21:44:33  torer
 * A more modular C interface to parsers fro different languages
 *
 * Revision 1.23  2011/11/16 12:12:37  torer
 * Support for multiple parsers
 *
 * Revision 1.22  2011/05/16 20:49:21  torer
 * 'for each original' now default.
 *
 * Revision 1.21  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.20  2011/01/30 18:57:01  torer
 * Local declarations allowed inside 'loop' and 'while' statements
 *
 * Revision 1.19  2011/01/28 09:17:26  torer
 * 'result' -> PSM's 'return'
 * 
 * Revision 1.18  2011/01/27 21:05:14  torer
 * Added nomore(Scan)
 * and the PSM control structures 'loop' and 'while'
 *
 * Revision 1.17  2011/01/26 20:58:51  torer
 * Mulitiple assinments allowed in procedural functions
 *
 * Revision 1.16  2010/12/27 10:16:20  torer
 * C warnings removed
 *
 * Revision 1.15  2010/01/19 22:38:54  torer
 * JSON syntax for record construction
 *
 * Revision 1.14  2009/12/12 14:46:19  torer
 * Own IN functions
 *
 * Revision 1.13  2009/11/20 15:00:02  zeitler
 * power(Number, Number)->Number infix operator ^
 * elempower(Vector of Number, Number)->Vector of Number infix operator .^
 *
 * Revision 1.12  2009/09/30 15:05:45  zeitler
 * DOTDOV, DOTMUL: element-wise vector operations
 *
 * Revision 1.11  2008/11/17 20:22:24  torer
 * General functional expressions as function bodies
 *
 * Revision 1.10  2008/11/13 08:39:37  torer
 * #'foo' now evaluated by parser.
 * Enables computed result types for tclose(function,object)->object
 *
 * Revision 1.9  2008/11/05 16:16:22  torer
 * select after 'as' optional
 *
 * Revision 1.8  2008/09/27 15:36:06  torer
 * New syntax for 'vector selection' as in SCSQ:
 *
 * vselect iota(2,10); <=> vectorof(select iota(2,20));
 *
 * Revision 1.7  2008/09/27 10:58:51  torer
 * Functional constants #'iota' <=> theresolvent('iota')
 *
 * Revision 1.6  2008/08/18 14:23:36  torer
 * Setting bag values allowed
 *
 * Revision 1.5  2008/08/13 21:26:11  torer
 * Variable assignable to value of select expression
 *
 * Revision 1.4  2006/12/14 18:18:25  torer
 * Minor memory leak fixed
 *
 * Revision 1.3  2006/05/03 19:56:35  torer
 * Infix 'in' operator
 *
 * Revision 1.2  2006/04/15 18:48:24  torer
 * Possibility to specify 'key' on multidirectional implementation
 *
 * Revision 1.1  2006/04/14 19:11:16  torer
 * AmosQL parser added to repository
 *
 ****************************************************************************/

/* %pure_parser */


%{

#include "amos.h"

extern void yyerror(char *);
#define yyin_fs ((flexstream *)yyin)

#define YY_USE_PROTOS 1

  extern int flex_c;
  extern FILE *yyin;
  extern oidtype parse_return;
  int illegal_interval_makefunction, illegal_timetype;

  //yydebug = 1;
  void p_error(int no,oidtype arg)
  {
    static int initialized = FALSE;

    if(!initialized)
      {
	initialized = TRUE;
	illegal_interval_makefunction =
	  a_register_error("Illegal interval make function");
	illegal_timetype =
	  a_register_error("Illegal timeinterval type");
      }
    a_error(no,arg,FALSE);
  }

  oidtype packlist(oidtype l)
    /* Make contatenated symbol from symbols in l */
    {
      char packbuff[1000];
      oidtype x;

      strcpy(packbuff,"");
      for(x=l;listp(x);x=ftl(x))
	{
          char *pn;

          pn = getpname(fhd(x));
 
          if(strlen(pn)+strlen(packbuff)>=1000) break;
          strcat(packbuff,pn);
        }
      return mksymbol(packbuff);
    }

  oidtype vectortypename(oidtype of)
    {
      return call_lisp(mksymbol("name-of-vectortype"),varstack,1,of);
    }

  %}

%union { oidtype oidval; };

%token <oidval> _INTEGER_CONST
%token <oidval> _REAL_CONST
%token <oidval> _BOOLEAN_CONST
%token <oidval> _STRING_CONST
%token <oidval> _ID
%token <oidval> _IVAR
%token _PLUS _MINUS _TIMES _DIVIDE _DOTTIMES _DOTDIVIDE _CARET _DOTCARET
%token _AND _OR _EQUAL _LESS _GREATER _LESSEQ _GREATEREQ _UNEQUAL
%token _LEFTPAREN _RIGHTPAREN _LEFTBRACKET _RIGHTBRACKET _LEFTCURL _RIGHTCURL
%token _COMMA _DOT _SEMICOLON _COLON _BAR _BEGIN _DECLARE _END
%token _CREATE _DELETE _SET _ADD _TO _REMOVE _FROM _ARROW _AS _KEY _NONKEY 
%token _STORED _FOREIGN
%token _TYPE _SUBTYPE _UNDER _SUPERTYPE _FUNCTION _FUNCTIONS _ON _OFF 
%token _PROPERTIES _INSTANCES
%token _RULE _WHEN _DO _ACTIVATE _DEACTIVATE _PRIORITY _STRICT
%token _MULTIDIRECTIONAL _SELECT _DISTINCT _ORIGINAL _FOR _EACH _WHERE _BAG 
%token _OF _VECTOR _RETURN _HASH _VSELECT
%token _COST _REWRITER _VALIDATE _CASE
%token _IF _THEN _ELSE
%token _OPEN _INTO _CLOSE _FETCH _SAVE _EXIT
%token _LOGGING _IMAGESIZE _COMMIT _ROLLBACK _LISP _QUIT _EXIT _EOF
%token _AT _ALPHAB _WITHIN _DERIVED
%token _UPDATED _ADDED _REMOVED _CREATED _DELETED _AFTER _BEFORE
%token _OIDTAG _CAST _IN _LOOP _WHILE _LEAVE

/* operator precedence */
%left _TPL
%left _OR
%left _AND
%left _ANDNOT
%left _IN
%left _AFTER
%left _BEFORE
%left _LESS _GREATER _LESSEQ _GREATEREQ _EQUAL _UNEQUAL 
%left _PLUS _MINUS 
%left _TIMES _DIVIDE _DOTTIMES _DOTDIVIDE 
%left _CARET _DOTCARET
%left _UMINUS

/* intial rule */
%start start

%%

constant:
numeric_constant { $<oidval>$ = $<oidval>1; }
| _BOOLEAN_CONST { $<oidval>$ = $<oidval>1; }
| _STRING_CONST { $<oidval>$ = $<oidval>1; }
| _OIDTAG oid_descr _RIGHTBRACKET
{ $<oidval>$ = oid_internalize(varstack,$<oidval>2);
 release($<oidval>2);}
;
numeric_constant:
_INTEGER_CONST { $<oidval>$ = $<oidval>1; }
| _REAL_CONST { $<oidval>$ = $<oidval>1; }
;

oid_descr:
| _INTEGER_CONST { $<oidval>$ = a_list($<oidval>1, NULL); }
| _INTEGER_CONST _STRING_CONST
{ $<oidval>$ = a_list($<oidval>1, 
		      $<oidval>2, 
		      NULL); }
;

id_commalist:
_ID { $<oidval>$ = a_list($<oidval>1, NULL); }
| id_commalist _COMMA _ID
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

id_dotlist:
simple_type { $<oidval>$ = $<oidval>1; } /* includes _ID */	
| id_dotlist _DOT simple_type { }
{ $<oidval>$ = nconc($<oidval>1,
		     cons(mksymbol("."), 
			  $<oidval>3),
		     NULL); }
;

function_name:
id_dotlist
{ $<oidval>$ =
    packlist($<oidval>1); release($<oidval>1);
}
| id_dotlist _ARROW id_dotlist
{ oidtype temp = nconc($<oidval>1,
		       cons(mksymbol("->"), 
			    $<oidval>3),
		       NULL);
 $<oidval>$ =
   packlist(temp); release(temp);
}
| _IN
{ $<oidval>$ = mksymbol("in");}
;

variable_name: _ID { $<oidval>$ = $<oidval>1; }
;

variable_name_commalist:
variable_name { $<oidval>$ = a_list($<oidval>1,NULL); }
|variable_name_commalist _COMMA variable_name 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

interface_variable_name: _IVAR { $<oidval>$ = $<oidval>1;}
;

gen_variable_name:
variable_name { $<oidval>$ = $<oidval>1; }
| interface_variable_name { $<oidval>$ = $<oidval>1; }
;

gen_variable_name_commalist:
gen_variable_name { $<oidval>$ = a_list($<oidval>1,NULL); }
| gen_variable_name_commalist _COMMA gen_variable_name
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

type_name:
simple_type { $<oidval>$ = $<oidval>1; }
| aggr_type { $<oidval>$ = $<oidval>1; }
;

type_name_commalist:
type_name { $<oidval>$ = $<oidval>1; }
| type_name_commalist _COMMA type_name
{ $<oidval>$ = nconc($<oidval>1,
		     $<oidval>3,
		     NULL); }
;

simple_type:
_ID { $<oidval>$ = a_list($<oidval>1, NULL); }
| _ID _ALPHAB _ID {$<oidval>$ = a_list(a_list($<oidval>1,
					     $<oidval>3, 
					     NULL),
				      NULL);}
| _FUNCTION { $<oidval>$ = a_list(mksymbol("function"), NULL); }
| _RULE { $<oidval>$ = a_list(mksymbol("rule"),NULL); }
| _TYPE { $<oidval>$ = a_list(mksymbol("type"),NULL); }
| _BAG { $<oidval>$ = a_list(mksymbol("bag"),NULL); }
| _VECTOR { $<oidval>$ = a_list(mksymbol("vector"),NULL); }
;

tuple_type:
type_name { $<oidval>$ = $<oidval>1; }
| _LESS type_name_commalist _GREATER { $<oidval>$ = $<oidval>2; }
| _LEFTPAREN type_name_commalist _RIGHTPAREN { $<oidval>$ = $<oidval>2; }
;

aggr_type:
simple_type _OF tuple_type 
{ $<oidval>$ =
    nconc($<oidval>1,
	  a_list(mksymbol("of"),
		 $<oidval>3,
		 NULL),
	  NULL); }
;

create_keyword:
_CREATE { $<oidval>$ = yyin_fs->key_pos; }
;

create_type_stmt:
_CREATE _TYPE _ID properties 
{ $<oidval>$ = 
    a_list(mksymbol("create-type"),
	   $<oidval>3,nil,
	   $<oidval>4,
	   NULL); }
| _CREATE _TYPE _ID _SUBTYPE _OF id_commalist properties
{ $<oidval>$ =
    a_list(mksymbol("create-type"),
	   $<oidval>3,
	   $<oidval>6,
	   $<oidval>7,
	   NULL); }
| _CREATE _TYPE _ID _UNDER id_commalist properties
{ $<oidval>$ =
    a_list(mksymbol("create-type"),
	   $<oidval>3,
	   $<oidval>5,
	   $<oidval>6,
	   NULL); }
;

/*****************************************************************************
 *                       Derived types syntax block
 *****************************************************************************/

create_derived_type_stmt:
_CREATE _DERIVED _TYPE _ID derived_subtypeof_clause  
derived_key_clause derived_supertypeof_clause  properties
{ $<oidval>$ = a_list(mksymbol("create-derived-type"),
		      $<oidval>4,
		      $<oidval>5,
		      $<oidval>6,
		      $<oidval>7,
		      $<oidval>8,
		      NULL); }
;

derived_subtypeof_clause: 
{ $<oidval>$ =a_list(nil, 
		     nil, 
		     NULL); }

|   _SUBTYPE _OF variable_declaration_commalist derived_subtypeof_cond
{ $<oidval>$ = a_list($<oidval>3,
		      $<oidval>4, 
		      NULL); }
|   _UNDER variable_declaration_commalist derived_subtypeof_cond
{ $<oidval>$ = a_list($<oidval>2,
		      $<oidval>3, 
		      NULL); }
;

derived_subtypeof_cond:
_WHERE simple_expr validate_clause
{ $<oidval>$ = a_list($<oidval>2, 
		      $<oidval>3, 
		      NULL); }

| validate_clause
{ $<oidval>$ = a_list(nil, 
		      $<oidval>1, 
		      NULL); } 
;

validate_clause:    
{ $<oidval>$ = nil; }

|   _VALIDATE simple_expr { $<oidval>$ = $<oidval>2; }
;

derived_key_clause:
 
{ $<oidval>$ = nil; }

|   _KEY variable_declaration_commalist
{ $<oidval>$ = $<oidval>2;}
;

derived_supertypeof_clause: 
{ $<oidval>$ = nil; }

|   _SUPERTYPE _OF st_list functions_clause
{ $<oidval>$ = a_list($<oidval>3,  
		      $<oidval>4, 
		      NULL); } 
;

st_list:   
st_entry  
{ $<oidval>$ = a_list($<oidval>1, NULL);}  

|    st_list _COMMA st_entry
{ $<oidval>$ = nconc1fn(varstack, $<oidval>1, $<oidval>3); }
;

st_entry:  
type_name gen_variable_name optional_expr 
{ $<oidval>$ = a_list($<oidval>1, 
		      $<oidval>2, 
		      $<oidval>3, 
		      NULL);}
;

optional_expr:
{ $<oidval>$ = nil; }
|    _EQUAL simple_expr
{ $<oidval>$ = a_list($<oidval>2, 
		      NULL);}

;

functions_clause:
{ $<oidval>$ = nil; }

| _FUNCTIONS  _LEFTPAREN prop_function_commalist 
_RIGHTPAREN case_list _END _FUNCTIONS
{ $<oidval>$ = a_list($<oidval>3, 
		      $<oidval>5, 
		      NULL); }
;

case_list:   
case_entry    
{ $<oidval>$ = a_list($<oidval>1, NULL);}

| case_list  case_entry
{$<oidval>$ =  nconc1fn(varstack, $<oidval>1, $<oidval>2); } 
;

case_entry:
_CASE id_commalist _COLON case_func_def_list 
{ $<oidval>$ = a_list($<oidval>2, 
		      $<oidval>4, 
		      NULL);}

case_func_def_list:
case_func_def
{ $<oidval>$ = a_list($<oidval>1, NULL);}

|    case_func_def_list _SEMICOLON case_func_def
{$<oidval>$ = nconc1fn(varstack, $<oidval>1, $<oidval>3); }
;

case_func_def:
{ $<oidval>$ = nil; }
|     gen_variable_name  optional_expr
{ $<oidval>$ = a_list($<oidval>1, 
		      $<oidval>2, 
		      NULL);}
;

/*****************************************************************************
 *                        End of the Derived types syntax block
 *****************************************************************************/

properties: { $<oidval>$ = nil; }
/*	| _LEFTPAREN prop_function_commalist _RIGHTPAREN
	{ $<oidval>$ = $<oidval>2; }   */  
| _PROPERTIES _LEFTPAREN prop_function_commalist _RIGHTPAREN 
{ $<oidval>$ = $<oidval>3; } 
;

key_spec: { $<oidval>$ = nil; }
| _KEY { $<oidval>$ = a_list(mksymbol("key"),NULL); }
| _NONKEY { $<oidval>$ = a_list(mksymbol("nonkey"),NULL); }
;

prop_function:
key_spec function_name res_spec fn_implementation
{ $<oidval>$ =
    nconc($<oidval>1,
	  a_list($<oidval>2,NULL),
	  a_list($<oidval>3,NULL),
	  $<oidval>4,
	  NULL);
}
;

prop_function_commalist:
prop_function { $<oidval>$ = a_list($<oidval>1,NULL);}
| prop_function_commalist _COMMA prop_function 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

delete_type_stmt:
_DELETE _TYPE _ID
{ $<oidval>$ = a_list(mksymbol("purge-type"),
		      $<oidval>3,
		      NULL);}
;

function_name:
   _ID 
{$<oidval>$ = $<oidval>1;}
|  _IN
{$<oidval>$ = $<oidval>1;}
;

create_function_stmt:
create_keyword _FUNCTION function_name argl_spec 
               _ARROW resl_spec fn_implementation
{
  oidtype orgtxt = a_textstreamread(yyin_fs->logstream,$<oidval>1);
  if (yyin_fs->function_flg)
    $<oidval>$ = nconc(a_list(mksymbol("create-function"),
			      $<oidval>3,
			      $<oidval>4,
			      $<oidval>6,
			      NULL),
		       $<oidval>7, 
		       NULL);
  else
    $<oidval>$ = nconc(a_list(mksymbol("define-proc"),
			      $<oidval>3,
			      $<oidval>4,
			      $<oidval>6,
			      NULL),
		       $<oidval>7,
		       NULL);
  $<oidval>$ = a_list(mksymbol("set-source"),
		      $<oidval>$,
		      orgtxt,
		      NULL);
}
;

argl_spec:
_LEFTPAREN  _RIGHTPAREN
{ $<oidval>$ = nil; }
| _LEFTPAREN arg_spec_commalist _RIGHTPAREN
{ $<oidval>$ = $<oidval>2; }
;

arg_spec:
type_name variable_name key_spec
{ $<oidval>$ = nconc($<oidval>1,
		     a_list($<oidval>2,NULL),
		     $<oidval>3,
		     NULL); }
| type_name key_spec
{ $<oidval>$ = nconc($<oidval>1,
		     $<oidval>2,
		     NULL); }
;

arg_spec_commalist:
arg_spec { $<oidval>$ = a_list($<oidval>1,NULL); }
| arg_spec_commalist _COMMA arg_spec { }
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

res_spec:
_BAG _OF arg_spec 
{
  $<oidval>$ = a_list(mksymbol("bag"),
                      mksymbol("of"),
                      cons($<oidval>3,nil),
                      NULL);
}
| _BAG _OF tuple_result_spec
{
  $<oidval>$ = a_list(mksymbol("bag"),
                      mksymbol("of"),
                      $<oidval>3,
                      NULL);
}
| arg_spec { $<oidval>$ = $<oidval>1; }
;

resl_spec:
res_spec { $<oidval>$ = cons($<oidval>1,nil); }
| tuple_result_spec { $<oidval>$ = $<oidval>1; }
;

tuple_result_spec:
_LESS arg_spec_commalist _GREATER { $<oidval>$ = $<oidval>2; }
| _LEFTPAREN arg_spec_commalist _RIGHTPAREN { $<oidval>$ = $<oidval>2; }
;

fn_implementation:
{ $<oidval>$ = nil; }
| _AS _STORED { $<oidval>$ = nil; }
| _AS simple_expr { $<oidval>$ = a_list(mksymbol("as"),
                                         cons($<oidval>2,nil),
                                         NULL); }
| _AS select_stmt   { $<oidval>$ = cons(mksymbol("as"),tl($<oidval>2));
                      release($<oidval>2);
                    }
| _AS procedure_stmt1
{ 
/* Remote Query Case */
 if (hd($<oidval>2) == mksymbol("REMOTE-QUERY"))
   $<oidval>$ = cons(mksymbol("as"),
		     a_list(a_list($<oidval>2, NULL),
			    NULL));
 else
   $<oidval>$ = a_list($<oidval>2,NULL);
}
| _AS foreign_body { $<oidval>$ = cons(mksymbol("as"),
				       $<oidval>2); }
;

foreign_body:
_FOREIGN _STRING_CONST
{ $<oidval>$ = a_list(mksymbol("foreign"),
		      cons($<oidval>2,nil),
		      NULL); }
| _MULTIDIRECTIONAL muldir_list
{ $<oidval>$ = a_list(mksymbol("multidirectional"),
		      $<oidval>2,
		      NULL); }
;
muldir_list:
muldir_item
{ $<oidval>$ = cons( $<oidval>1,nil); }
| muldir_item muldir_list
{ $<oidval>$ = cons( $<oidval>1,
		     $<oidval>2); }
;
muldir_item:
_LEFTPAREN _STRING_CONST multidir_options _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>2, 
		    $<oidval>3);} 
;

multidir_option:
_COST cost_model
{ $<oidval>$ = a_list(mksymbol("cost"), 
		      $<oidval>2, 
		      NULL);} 
| _REWRITER _STRING_CONST
{ $<oidval>$ = a_list(mksymbol("rewriter"), 
		      $<oidval>2, 
		      NULL);} 
| _FOREIGN _STRING_CONST
{ $<oidval>$ = a_list(mksymbol("foreign"), 
		      $<oidval>2, 
		      NULL);}
| _KEY
{ $<oidval>$ = a_list(mksymbol("KEY"), 
		      t, 
		      NULL);}

| select_stmt1 { $<oidval>$ = a_list(mksymbol("select"), 
				     tl($<oidval>1), 
				     NULL); 
 release($<oidval>1);}

;

multidir_options:
multidir_option 
{ $<oidval>$ = $<oidval>1;} 
| multidir_option multidir_options
{ $<oidval>$ = nconc($<oidval>1, 
		     $<oidval>2, 
		     NULL);} 
;

cost_model:
function_name   { $<oidval>$ = $<oidval>1; }
| _LEFTCURL numeric_constant _COMMA numeric_constant _RIGHTCURL
{ $<oidval>$ = a_list($<oidval>2,
		      $<oidval>4,
		      NULL); }
;
select_item:
simple_expr /* all functional expr, including boolean */
{ $<oidval>$ = $<oidval>1; }
;

select_item_commalist:
select_item_commalist1 { $<oidval>$ = $<oidval>1; }
| { $<oidval>$ = nil; }
;
    
select_item_commalist1:
select_item { $<oidval>$ = a_list($<oidval>1,NULL); }
| select_item_commalist _COMMA select_item 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

delete_function_stmt:
_DELETE _FUNCTION function_name 
{ $<oidval>$ = 
    a_list(mksymbol("purge-function"),
	   $<oidval>3,
	   NULL); }
;

create_object_stmt:
_CREATE _ID new_instances 
{$<oidval>$ = a_list(mksymbol("create-userobjects"),
		     $<oidval>2,
		     nil,
		     $<oidval>3,
		     NULL); }
| _CREATE _ID _LEFTPAREN function_name_commalist _RIGHTPAREN
new_instances 
{$<oidval>$ = a_list(mksymbol("create-userobjects"),
		     $<oidval>2,
		     $<oidval>4,
		     $<oidval>6,
		     NULL); }
;

function_name_commalist:
function_name { $<oidval>$ = a_list($<oidval>1,NULL); }
| function_name_commalist _COMMA function_name 
{$<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

new_instances:
_INSTANCES initialize_commalist { $<oidval>$ = $<oidval>2; }
;

initialize:
gen_variable_name { $<oidval>$ = a_list($<oidval>1,NULL); }
| _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = a_list($<oidval>2,NULL); }
| gen_variable_name _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = a_list($<oidval>1,
		      $<oidval>3,
		      NULL); }

initialize_commalist:
initialize { $<oidval>$ = $<oidval>1; }
| initialize_commalist _COMMA initialize 
{ $<oidval>$ = nconc($<oidval>1,
		     $<oidval>3,
		     NULL); }
;

delete_object_stmt:
_DELETE gen_variable_name 
{ $<oidval>$ = a_list(mksymbol("delete-object"),
		      $<oidval>2,
		      NULL); }
;

/* Quick fix for remote queries */
select_stmt:
_AT database_id select_stmt1
{ $<oidval>$ = cons(mksymbol("REMOTE-QUERY"),
		    cons($<oidval>2,
			 $<oidval>3)); }
| select_stmt1
{ $<oidval>$ = $<oidval>1; }

;

database_id:
_STRING_CONST { $<oidval>$ = $<oidval>1; }
;

select_stmt1:
_SELECT distinct_spec select_item_commalist
into_clause for_each_clause where_clause 
{ $<oidval>$ = cons(mksymbol("osql-select"),
		    nconc($<oidval>2,
			  a_list($<oidval>3,NULL),
			  $<oidval>4,
			  $<oidval>5,
			  $<oidval>6, 
			  NULL));
}

;

distinct_spec:
{ $<oidval>$ = nil; }
| _DISTINCT { $<oidval>$ = a_list(mksymbol("distinct"),NULL); }
;

into_clause:
{ $<oidval>$ = nil; }
| _INTO gen_variable_name_commalist 
{ $<oidval>$ = a_list(mksymbol("into"),
		      $<oidval>2,
		      NULL); }
;

into_clause1:
{ $<oidval>$ = nil; }
| _INTO gen_variable_name_commalist 
{ $<oidval>$ = $<oidval>2; }
;

for_each_clause:
{ $<oidval>$ = nil; }
| _FROM variable_declaration_commalist
{ $<oidval>$ = a_list(mksymbol("foreach"),
		      $<oidval>2,
		      NULL); }
;

variable_declaration:
type_name variable_name 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>2); }
| type_name
{ $<oidval>$ = call_lisp(mksymbol("fix-simple-decl"),varstack,
			 1,$<oidval>1); } 
;

variable_declaration_commalist:
variable_declaration { $<oidval>$ = a_list($<oidval>1,NULL); }
| variable_declaration_commalist _COMMA variable_declaration 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

where_clause:
{ $<oidval>$ = nil; }
| _WHERE simple_expr 
{ $<oidval>$ = a_list(mksymbol("where"),
		      $<oidval>2,
		      NULL); }
;

function_call0:
  function_name _LEFTPAREN _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>1,nil); }
| function_name _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>1,
		    $<oidval>3); }
| function_name _LEFTPAREN _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1,
		    $<oidval>4); }
| function_name _LEFTPAREN expr_commalist _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1,
                    nconc($<oidval>5, 
			  $<oidval>3, 
			  NULL)); printf("Temporal function call: "); a_print($<oidval>$);}
;

function_call:
  function_name _LEFTPAREN _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>1,nil); }
| function_name _LEFTPAREN select_stmt1 _RIGHTPAREN
{ if(doid($<oidval>3)->head==mksymbol("osql-select"))
    {a_setf(doid($<oidval>3)->head,mksymbol("select"));}
 $<oidval>$ = a_list($<oidval>1, 
		     $<oidval>3, 
		     NULL); }
| function_name _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>1,
		    $<oidval>3); }
| function_name _LEFTPAREN _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1,
		    $<oidval>4); }
| function_name _LEFTPAREN expr_commalist _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1,
                    nconc($<oidval>5, 
			  $<oidval>3, 
			  NULL)); }
| _VSELECT distinct_spec select_item_commalist
into_clause for_each_clause where_clause 
{ $<oidval>$ = a_list(mksymbol("vectorof"),
                      cons(mksymbol("select"),
		           nconc($<oidval>2,
			         a_list($<oidval>3,
                                        NULL),
			   $<oidval>4,
			   $<oidval>5,
			   $<oidval>6, 
			   NULL)),
                      NULL);
}

;

casting:
_CAST _LEFTPAREN simple_expr _AS type_name _RIGHTPAREN 
{ $<oidval>$ = a_list(mksymbol("cast"),
		      $<oidval>3,
		      $<oidval>5,
		      NULL);
}
;

temporal_call:
_ALPHAB temporal_expr 
{ $<oidval>$ = $<oidval>2; }	
| _WITHIN within_expr
{ $<oidval>$ = $<oidval>2; }
;

temporal_value:
timeval_expr
{ $<oidval>$ = $<oidval>1; }
| timeinterval_expr
{ $<oidval>$ = $<oidval>1; }	
| date_expr
{ $<oidval>$ = $<oidval>1; }
| time_expr
{ $<oidval>$ = $<oidval>1; }
;

timeval_expr:
_BAR
_INTEGER_CONST _MINUS
_INTEGER_CONST _MINUS
_INTEGER_CONST _DIVIDE
_INTEGER_CONST _COLON 
_INTEGER_CONST _COLON 
_INTEGER_CONST 
_BAR
{ oidtype datev;
 datev = a_vector($<oidval>2,
		  $<oidval>4,
		  $<oidval>6,
		  $<oidval>8,
		  $<oidval>10,
		  $<oidval>12,
		  mkinteger(0),
		  NULL);
 $<oidval>$ = date_to_timevalfn(varstack,datev);
}
;

timeinterval_expr:
_BAR
_LEFTBRACKET
simple_expr
_COMMA
simple_expr
timeval_leftclosed_end
_BAR
{ if (timevalp($<oidval>3) && timevalp($<oidval>5)) {
  $<oidval>$ = mktimeintervalfn(varstack, 
				$<oidval>3,
				$<oidval>5,
				$<oidval>6);
}
 else
   if ($<oidval>6 == bothclosedtag)
     $<oidval>$ = a_list(mksymbol("timeinterval_both_closed"),
			 $<oidval>3,
			 $<oidval>5,	
			 NULL);
   else
     $<oidval>$ = a_list(mksymbol("timeinterval_left_closed"),
			 $<oidval>3,
			 $<oidval>5,	
			 NULL);}
|
_BAR
_LEFTPAREN
simple_expr
_COMMA
simple_expr
timeval_leftopen_end
_BAR
{ if (timevalp($<oidval>3) && timevalp($<oidval>5)) {
  $<oidval>$ = mktimeintervalfn(varstack, $<oidval>3,
				$<oidval>5,
				$<oidval>6);
}
 else
   if ($<oidval>6 == bothopentag)
     $<oidval>$ = a_list(mksymbol("timeinterval_both_open"),
			 $<oidval>3,
			 $<oidval>5,	
			 NULL);
   else
     $<oidval>$ = a_list(mksymbol("timeinterval_right_closed"),
			 $<oidval>3,
			 $<oidval>5,	
			 NULL);}
;

timeval_leftclosed_end:
_RIGHTBRACKET { $<oidval>$ = bothclosedtag;}
| _RIGHTPAREN { $<oidval>$ = leftclosedtag;}
;	

timeval_leftopen_end:
_RIGHTBRACKET { $<oidval>$ = rightclosedtag;}
| _RIGHTPAREN { $<oidval>$ = bothopentag;}
;	

date_expr:
_BAR
_INTEGER_CONST _MINUS
_INTEGER_CONST _MINUS
_INTEGER_CONST 
_BAR
{ $<oidval>$ = mkdatefn(varstack,$<oidval>2,
			$<oidval>4,
			$<oidval>6);}
;

time_expr:
_BAR
_INTEGER_CONST _COLON 
_INTEGER_CONST _COLON 
_INTEGER_CONST 
_BAR
{$<oidval>$ = mktimefn(varstack,$<oidval>2,
		       $<oidval>4,
		       $<oidval>6);}
;

temporal_expr: tuple_simple_expr { $<oidval>$ = a_list($<oidval>1, NULL); };

within_expr: timeinterval_expr
{ if (listp($<oidval>1)) {
  char *mif; /* make interval function */
  oidtype name;

  mif = getpname(hd($<oidval>1));
  if (strcmp(mif, "TIMEINTERVAL_BOTH_CLOSED") == 0) 
    name =  mksymbol("both_closed_timeinterval");
  else if (strcmp(mif, "TIMEINTERVAL_LEFT_CLOSED") == 0) 
    name =  mksymbol("left_closed_timeinterval");
  else if (strcmp(mif, "TIMEINTERVAL_RIGHT_CLOSED") == 0) 
    name = mksymbol("right_closed_timeinterval");
  else if (strcmp(mif, "TIMEINTERVAL_BOTH_OPEN") == 0) 
    name = mksymbol("both_open_timeinterval");
  else
    p_error(illegal_interval_makefunction, nil);
  $<oidval>$ = a_list(getobjectnamedfn(varstack, name, nil, t),
		      hd(tl($<oidval>1)), 
		      hd(tl(tl($<oidval>1))), 
		      NULL);
  release($<oidval>1);
}
 else { oidtype name;
 switch (gettimeintervaltype($<oidval>1)) {
 case BOTH_CLOSED: {
   name = mksymbol("both_closed_timeinterval");
   break;
 }
 case LEFT_CLOSED: {
   name = mksymbol("left_closed_timeinterval");
   break;
 }
 case RIGHT_CLOSED: {
   name = mksymbol("right_closed_timeinterval");
   break;
 }
 case BOTH_OPEN: {
   name = mksymbol("both_open_timeinterval");
   break;
 }
 default: 
   p_error(illegal_timetype, nil);
 };
 $<oidval>$ = a_list(getobjectnamedfn(varstack, name, nil, t),
		     /*timeintervalstartfn(varstack, ti),
		       timeintervalstopfn(varstack, ti), */
		     NULL); 
 }	
}
;

tuple_simple_expr:
  gen_variable_name { $<oidval>$ = $<oidval>1; } 
| constant { $<oidval>$ = $<oidval>1; }
| bag_value { $<oidval>$ = $<oidval>1; }
| vector_construction { $<oidval>$ = $<oidval>1; }
| temporal_value { $<oidval>$ = $<oidval>1; }
| casting { $<oidval>$ = $<oidval>1; }
| tuple_vector_reference { $<oidval>$ = $<oidval>1; }
| tuple_simple_expr _DIVIDE tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("div"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _CARET tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("power"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _DOTCARET tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("elempower"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _DOTDIVIDE tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("elemdiv"),$<oidval>1,$<oidval>3,NULL);}
| tuple_simple_expr _TIMES tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("times"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _DOTTIMES tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("elemtimes"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _PLUS tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("plus"),$<oidval>1,$<oidval>3,NULL);} 
| tuple_simple_expr _MINUS tuple_simple_expr 
{ $<oidval>$ = a_list(mksymbol("minus"),$<oidval>1,$<oidval>3,NULL);}
| function_call { $<oidval>$ = $<oidval>1; }
| _MINUS simple_expr 	%prec _UMINUS /* set the operator precedence */
{ if ((integerp($<oidval>2)) || (realp($<oidval>2)))
  {$<oidval>$ = minusfn(varstack,$<oidval>2); release($<oidval>2);}
 else
   $<oidval>$ = a_list(mksymbol("uminus"),
		       $<oidval>2,
		       NULL); }
| _HASH _STRING_CONST
{ $<oidval>$ = call_lisp(mksymbol("theresolvent"), varstack, 1,
                         $<oidval>2); }
;

simple_expr:
  gen_variable_name { $<oidval>$ = $<oidval>1; } 
| constant { $<oidval>$ = $<oidval>1; }
| bag_value { $<oidval>$ = $<oidval>1; }
| vector_construction { $<oidval>$ = $<oidval>1; }
| record_construction { $<oidval>$ = $<oidval>1; }
| temporal_value { $<oidval>$ = $<oidval>1; }
| casting { $<oidval>$ = $<oidval>1; }
| vector_reference { $<oidval>$ = $<oidval>1; }
| function_call { $<oidval>$ = $<oidval>1; }
| _LESS tuple_commalist _GREATER %prec _TPL
   { $<oidval>$ = cons(mksymbol("tuple"),$<oidval>2); }
| _LEFTPAREN expr_commalist _RIGHTPAREN 
   { $<oidval>$ = cons(mksymbol("tuple"),$<oidval>2); }
| simple_expr _DIVIDE simple_expr 
{ $<oidval>$ = a_list(mksymbol("div"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _CARET simple_expr 
{ $<oidval>$ = a_list(mksymbol("power"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _DOTCARET simple_expr 
{ $<oidval>$ = a_list(mksymbol("elempower"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _DOTDIVIDE simple_expr 
{ $<oidval>$ = a_list(mksymbol("elemdiv"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _TIMES simple_expr 
{ $<oidval>$ = a_list(mksymbol("times"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _DOTTIMES simple_expr 
{ $<oidval>$ = a_list(mksymbol("elemtimes"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _PLUS simple_expr 
{ $<oidval>$ = a_list(mksymbol("plus"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _MINUS simple_expr 
{ $<oidval>$ = a_list(mksymbol("minus"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _AND simple_expr 
{ $<oidval>$ = a_list(mksymbol("and"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _OR simple_expr 
{ $<oidval>$ = a_list(mksymbol("or"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _EQUAL simple_expr 
{ $<oidval>$ = a_list(mksymbol("="),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _LESSEQ simple_expr 
{ $<oidval>$ = a_list(mksymbol("<="),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _LESS simple_expr 
{ $<oidval>$ = a_list(mksymbol("<"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _GREATEREQ simple_expr 
{ $<oidval>$ = a_list(mksymbol(">="),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _GREATER simple_expr 
{ $<oidval>$ = a_list(mksymbol(">"),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _UNEQUAL simple_expr 
{ $<oidval>$ = a_list(mksymbol("!="),$<oidval>1,$<oidval>3,NULL);} 
| simple_expr _IN simple_expr 
{ $<oidval>$ = a_list(mksymbol("="), 
                      $<oidval>1,
                      a_list(mksymbol("in"),
                             $<oidval>3,
                             NULL),
                      NULL); }
| _MINUS simple_expr 	%prec _UMINUS /* set the operator precedence */
{ if ((integerp($<oidval>2)) || (realp($<oidval>2)))
  {$<oidval>$ = minusfn(varstack,$<oidval>2); release($<oidval>2);}
 else
   $<oidval>$ = a_list(mksymbol("uminus"),
		       $<oidval>2,
		       NULL); }
| _LEFTPAREN simple_expr _RIGHTPAREN
{ $<oidval>$ = $<oidval>2; }
| _HASH _STRING_CONST
{ $<oidval>$ = call_lisp(mksymbol("theresolvent"), varstack, 1,
                         $<oidval>2); }
| _LEFTPAREN select_stmt _RIGHTPAREN
{ if (!(equal(hd($<oidval>2), mksymbol("REMOTE-QUERY"))))
  {
    $<oidval>$ = cons(mksymbol("select"),
		      tl($<oidval>2));
    release($<oidval>2);
  } else
    {
      $<oidval>$ = $<oidval>2;
    };
}
;

expr_commalist:
simple_expr { $<oidval>$ = a_list($<oidval>1,NULL); }
| expr_commalist _COMMA simple_expr
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

tuple_commalist:
tuple_simple_expr { $<oidval>$ = a_list($<oidval>1,NULL); }
| tuple_commalist _COMMA tuple_simple_expr
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }

bag_value:
_BAG _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = cons(mksymbol("bag"),$<oidval>3); }	
| _BAG _LEFTPAREN _RIGHTPAREN 
{ $<oidval>$ = cons(mksymbol("bag"),nil); }
;

record_construction:
_LEFTCURL pair_commalist _RIGHTCURL
{ $<oidval>$ = a_list(mksymbol("make_record"),
                      cons(mksymbol("vector"),$<oidval>2), 
                      NULL);}

pair_commalist:
pair
{ $<oidval>$ = $<oidval>1;}
| pair_commalist _COMMA pair
{ $<oidval>$ = nconcfn(varstack,$<oidval>1,$<oidval>3);}

pair:
_STRING_CONST _COLON simple_expr
{$<oidval>$ = a_list($<oidval>1,$<oidval>3,NULL);}
 
vector_construction:
_LEFTCURL expr_commalist _RIGHTCURL
{ $<oidval>$ = cons(mksymbol("vector"),
		    $<oidval>2); }
| _LEFTCURL _RIGHTCURL
{ $<oidval>$ = cons(mksymbol("vector"), nil); }
| _VECTOR _LEFTPAREN expr_commalist _RIGHTPAREN
{ $<oidval>$ = cons(mksymbol("vector"),
		    $<oidval>3); }
| _VECTOR _LEFTPAREN _RIGHTPAREN
{ $<oidval>$ = cons(mksymbol("vector"),nil); }
;

vector_reference:
simple_expr _LEFTBRACKET simple_expr _RIGHTBRACKET
{ $<oidval>$ = a_list(mksymbol("vref"), 
		      $<oidval>1, 
		      $<oidval>3, 
		      NULL);}

tuple_vector_reference:
tuple_simple_expr _LEFTBRACKET tuple_simple_expr _RIGHTBRACKET
{ $<oidval>$ = a_list(mksymbol("vref"), 
		      $<oidval>1, 
		      $<oidval>3, 
		      NULL);}

init_value:
simple_expr
 {oidtype rhs = $<oidval>1;
 if(listp(rhs)&& hd(rhs)==mksymbol("tuple")) 
   {a_let($<oidval>$,tl(rhs)); release(rhs); decref(doid($<oidval>$)); }
 else $<oidval>$ = a_list(rhs,NULL);}
;

create_rule_stmt:
_CREATE _RULE rule_name argl_spec rule_implementation
{ $<oidval>$ =
    nconc(a_list(mksymbol("create-rule"),
		 $<oidval>3,
		 $<oidval>4,
		 NULL),
	  $<oidval>5,
	  NULL); }
rule_name:
_ID { $<oidval>$ = $<oidval>1;  }
;

simple_event:
_UPDATED _LEFTPAREN event_function_call _RIGHTPAREN
{ $<oidval>$ = a_list(mksymbol("updated"), 
		      $<oidval>3,
		      NULL);}
|_ADDED _LEFTPAREN event_function_call _RIGHTPAREN
{ $<oidval>$ = a_list(mksymbol("added"), 
		      $<oidval>3, 
		      NULL);}
|_REMOVED _LEFTPAREN event_function_call _RIGHTPAREN
{ $<oidval>$ = a_list(mksymbol("removed"), 
		      $<oidval>3, 
		      NULL);}
|_CREATED _LEFTPAREN variable_name _RIGHTPAREN
{ $<oidval>$ = a_list(mksymbol("created"), 
		      $<oidval>3, 
		      NULL);}
|_DELETED _LEFTPAREN variable_name  _RIGHTPAREN
{ $<oidval>$ = a_list(mksymbol("deleted"), 
		      $<oidval>3, 
		      NULL);}
;

event_function_call:
function_name _LEFTPAREN _RIGHTPAREN
{ $<oidval>$ = a_list($<oidval>1, NULL); }
| function_name _LEFTPAREN variable_name_commalist _RIGHTPAREN
{ $<oidval>$ = cons($<oidval>1, 
		    $<oidval>3); }
| function_name _LEFTPAREN _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1, 
		    $<oidval>4); }
| function_name _LEFTPAREN variable_name_commalist _RIGHTPAREN temporal_call
{ $<oidval>$ = cons($<oidval>1, 
		    nconc($<oidval>5, 
			  $<oidval>3, 
			  NULL)); }
;

composite_event:
simple_event { $<oidval>$ = $<oidval>1; }
| composite_event _AFTER composite_event
{ $<oidval>$ = a_list(mksymbol("after"), 
		      $<oidval>1,
		      $<oidval>3, 
		      NULL); }
| composite_event _BEFORE composite_event
{ $<oidval>$ = a_list(mksymbol("before"), 
		      $<oidval>1,
		      $<oidval>3, 
		      NULL); }
| composite_event _AND composite_event
{ $<oidval>$ = a_list(mksymbol("and"), 
		      $<oidval>1,
		      $<oidval>3, 
		      NULL); }
| composite_event _OR composite_event
{ $<oidval>$ = a_list(mksymbol("or"), 
		      $<oidval>1,
		      $<oidval>3, 
		      NULL); }
| _ANDNOT composite_event
{ $<oidval>$ = a_list(mksymbol("andnot"),
		      $<oidval>2, 
		      NULL); }
| _LEFTPAREN composite_event _RIGHTPAREN
{ $<oidval>$ = $<oidval>2; }   
;

event_specification:
composite_event { $<oidval>$ = $<oidval>1;}

;

rule_implementation:
_AS for_each_clause
_ON event_specification
_WHEN simple_expr
_DO procedure_body_stmt
{ $<oidval>$ = a_list( $<oidval>2, 
		       mksymbol("ON"), 
		       $<oidval>4, 
		       mksymbol("WHEN"), 
		       $<oidval>6, 
		       $<oidval>8, 
		       NULL); } 
| _AS for_each_clause
_WHEN simple_expr
_DO procedure_body_stmt
{ $<oidval>$ = 
    a_list( $<oidval>2, 
	    mksymbol("WHEN"), 
	    $<oidval>4, 
	    $<oidval>6, 
	    NULL);}

| _AS  for_each_clause
_ON event_specification
_DO procedure_body_stmt
{ $<oidval>$ = a_list( $<oidval>2, 
		       mksymbol("ON"), 
		       $<oidval>4, 
		       $<oidval>6, 
		       NULL);} 

|_AS 
_ON event_specification
_WHEN simple_expr
_DO procedure_body_stmt
{ $<oidval>$ = a_list( mksymbol("ON"), 
		       $<oidval>3, 
		       mksymbol("WHEN"), 
		       $<oidval>5, 
		       $<oidval>7, 
		       NULL); } 
|_AS 
_WHEN simple_expr
_DO procedure_body_stmt
{ $<oidval>$ = 
    a_list( mksymbol("WHEN"), 
	    $<oidval>3, 
	    $<oidval>5, 
	    NULL);}

|_AS 
_ON event_specification
_DO procedure_body_stmt
{ $<oidval>$ = a_list(mksymbol("ON"), 
		      $<oidval>3, 
		      $<oidval>5, 
		      NULL);} 
;

delete_rule_stmt:
_DELETE _RULE rule_name
{ $<oidval>$ = a_list(mksymbol("delete-rule"),
		      $<oidval>3,
		      NULL); }
;

activate_rule_stmt:
_ACTIVATE _RULE rule_name _LEFTPAREN  _RIGHTPAREN 
{ $<oidval>$ = a_list(mksymbol("activate-rule"),
		      $<oidval>3,
		      nil,
		      nil,
		      t,
		      NULL); }
| _ACTIVATE _RULE rule_name _LEFTPAREN  _RIGHTPAREN activation_props
{ $<oidval>$ = a_list(mksymbol("activate-rule"),$<oidval>3,
		      nil,
		      hd($<oidval>6),
		      hd(tl($<oidval>6)),
		      hd(tl(tl($<oidval>6))),
		      NULL); 
 release($<oidval>6);}
| _ACTIVATE _RULE rule_name _LEFTPAREN expr_commalist _RIGHTPAREN 
{ $<oidval>$ = a_list(mksymbol("activate-rule"),
		      $<oidval>3,
		      $<oidval>5,
		      nil,
		      t,
		      NULL); }
| _ACTIVATE _RULE rule_name _LEFTPAREN expr_commalist _RIGHTPAREN
activation_props
{ $<oidval>$ = a_list(mksymbol("activate-rule"),
		      $<oidval>3,
		      $<oidval>5,
		      hd($<oidval>7),
		      hd(tl($<oidval>7)),
		      hd(tl(tl($<oidval>7))),
		      NULL); 
 release($<oidval>7);}
;

activation_props :
 _PRIORITY _INTEGER_CONST  
{ $<oidval>$ = a_list($<oidval>2, 
		      t, 
		      nil, 
		      NULL); }
| _STRICT 
{ $<oidval>$ = a_list(nil, 
		      nil,
		      nil, 
		      NULL); }
| _PRIORITY _INTEGER_CONST _STRICT  
{ $<oidval>$ = a_list($<oidval>2, 
		      nil,
		      nil, 
		      NULL); }
| _STRICT _PRIORITY _INTEGER_CONST  
{ $<oidval>$ = a_list($<oidval>3, 
		      nil, 
		      nil, 
		      NULL); }
;

deactivate_rule_stmt:
_DEACTIVATE _RULE rule_name _LEFTPAREN  _RIGHTPAREN 
{ $<oidval>$ = a_list(mksymbol("deactivate-rule"),
		      $<oidval>3,
		      nil,
		      NULL); }
| _DEACTIVATE _RULE rule_name _LEFTPAREN expr_commalist _RIGHTPAREN 
{ $<oidval>$ = a_list(mksymbol("deactivate-rule"),
		      $<oidval>3,
		      $<oidval>5,
		      NULL); }
;

open_cursor_stmt:
_OPEN cursor_name _FOR simple_expr
{ $<oidval>$ = a_list(mksymbol("open-dbcursor"),
		      $<oidval>2,
		      $<oidval>4,
		      NULL); }
;
cursor_name:
gen_variable_name
{$<oidval>$ = $<oidval>1;}

fetch_cursor_stmt:
_FETCH cursor_name into_clause1 
{ $<oidval>$ = a_list(mksymbol("fetch-dbcursor"),
		      $<oidval>2,
		      $<oidval>3,
		      NULL);  }
;

close_cursor_stmt:
_CLOSE cursor_name 
{ $<oidval>$ = a_list(mksymbol("close-dbcursor"),
		      $<oidval>2,
		      NULL); }
;

update_stmt:
  _SET update_item for_each_clause where_clause 
{ $<oidval>$ = cons(mksymbol("set-function"),
		    nconc($<oidval>2,
			  $<oidval>3,
			  $<oidval>4,
			  NULL)); }
| _ADD update_item for_each_clause where_clause 
{ $<oidval>$ = cons(mksymbol("add-function"),
		    nconc($<oidval>2,
			  $<oidval>3,
			  $<oidval>4,
			  NULL)); }
| _ADD _TYPE _ID _TO initialize_commalist 
{ $<oidval>$ = nconc(a_list(mksymbol("add-type"),
			    $<oidval>3,
			    nil,
			    NULL),
		     $<oidval>5,
		     NULL); }	
| _ADD _TYPE _ID 
_LEFTPAREN function_name_commalist _RIGHTPAREN
_TO initialize_commalist 
{ $<oidval>$ = nconc(a_list(mksymbol("add-type"),
			    $<oidval>3,
			    $<oidval>5,
			    NULL),
		     $<oidval>8,
		     NULL); }		
| _ADD _TYPE _ID _PROPERTIES 
_LEFTPAREN function_name_commalist _RIGHTPAREN
_TO initialize_commalist 
{ $<oidval>$ = nconc(a_list(mksymbol("add-type"),
			    $<oidval>3,
			    $<oidval>6,
			    NULL),
		     $<oidval>9,
		     NULL); }
| _REMOVE update_item for_each_clause where_clause 
{ $<oidval>$ = cons(mksymbol("rem-function"),
		    nconc($<oidval>2,
		 	  $<oidval>3,
			  $<oidval>4,
			  NULL)); }
| _REMOVE _TYPE _ID _FROM gen_variable_name_commalist 
{ $<oidval>$ = nconc(a_list(mksymbol("remove-type"),
			    $<oidval>3,
			    NULL),
		     $<oidval>5,
		     NULL); }
;

update_item:
function_call0 _EQUAL init_value
{$<oidval>$ = a_list(hd($<oidval>1),
		     tl($<oidval>1),
                     $<oidval>3,
		     NULL);
 release($<oidval>1);
}
;

start:
top 
| error end_char        /* on error, skip until semicolon or eof */
{ oidtype stream = ((flexstream *)yyin)->stream;

 a_ungetc(flex_c, stream);
 yyin_fs->char_num = 0;
 a_setf(parse_return, nil);
 YYACCEPT;
}
;

end_char : _SEMICOLON | _EOF;

top:
_SEMICOLON    { a_setf(parse_return, nil); YYACCEPT;}
| lisp_stmt _SEMICOLON
{oidtype stream = ((flexstream *)yyin)->stream;
 a_setf(parse_return, $<oidval>1);
 /* a_ungetc(flex_c, stream); */
 YYACCEPT;
}
| osql_stmt _SEMICOLON
{ /* oidtype stream = ((flexstream *)yyin)->stream; */
  a_setf(parse_return, $<oidval>1);
  /* a_ungetc(flex_c, stream); */
  YYACCEPT;
}
| _EOF { a_setf(parse_return, mksymbol("*EOF*"));
 yyin_fs->char_num = 0;
 YYACCEPT;
}
;

osql_stmt:
procedure_stmt { $<oidval>$ = $<oidval>1 }
| create_type_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| create_derived_type_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| create_function_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| create_rule_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| delete_type_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| delete_function_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| delete_rule_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| declare_stmt {$<oidval>$ = $<oidval>1 }
| logging { $<oidval>$ = $<oidval>1 }
| image_size { $<oidval>$ = $<oidval>1 }
| save_stmt { $<oidval>$ = $<oidval>1 }
| redirect_stmt {  $<oidval>$ = $<oidval>1 }
| quit_stmt {  $<oidval>$ = $<oidval>1 }
| exit_stmt {  $<oidval>$ = $<oidval>1 }
| general_expr_query  { $<oidval>$ = $<oidval>1; }
;

general_expr_query:
simple_expr  { $<oidval>$ = a_list(mksymbol("osql-select"),
				    cons($<oidval>1,nil),
				    NULL) }
;

general_expr_test:
general_expr_query
{ $<oidval>$ = a_list(mksymbol("test-query"), 
		      $<oidval>1, 
		      NULL); }
;

interface_variable_declaration:
type_name interface_variable_name
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>2); }
;

interface_variable_declaration_commalist:
interface_variable_declaration 
{ $<oidval>$ = a_list($<oidval>1,NULL); }
| interface_variable_declaration_commalist 
_COMMA interface_variable_declaration 
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1,$<oidval>3); }
;

declare_stmt:
_DECLARE interface_variable_declaration_commalist
{ $<oidval>$ = a_list(mksymbol("osql-declare-vars"), 
		      $<oidval>2, 
		      NULL); }
;

procedure_body_stmt:
procedure_stmt { $<oidval>$ = $<oidval>1 }
| function_call 
{ $<oidval>$ = a_list(mksymbol("call-procedure"),
			       hd($<oidval>1),
			       tl($<oidval>1),
			       NULL);
  release($<oidval>1); }
;

procedure_body_stmt_semicolonlist:
procedure_body_stmt { $<oidval>$ = a_list($<oidval>1,NULL); }
| procedure_body_stmt_semicolonlist _SEMICOLON procedure_body_stmt
{ $<oidval>$ = nconc1fn(varstack,$<oidval>1, $<oidval>3); }
;

block:
_BEGIN block_body
{$<oidval>$ = cons(mksymbol("proc-block"),$<oidval>2);}
;

block_body:
| _DECLARE variable_declaration_commalist _SEMICOLON 
         procedure_body_stmt_semicolonlist end_stmt
{$<oidval>$ = cons(cons(mksymbol("osql-let"), 
                        cons($<oidval>2,$<oidval>4)),
                   nil);}
| procedure_body_stmt_semicolonlist end_stmt
{$<oidval>$ = $<oidval>1;}
| end_stmt
{$<oidval>$ = nil;}
;

end_stmt:
_END {}
| _SEMICOLON _END {}
;

set_variable_stmt:
_SET gen_variable_name _EQUAL simple_expr
{ $<oidval>$ = a_list(mksymbol("set-amosql-variable"),
                      $<oidval>2,
		      $<oidval>4,NULL); }
| _SET _LEFTPAREN gen_variable_name_commalist _RIGHTPAREN _EQUAL simple_expr
{ $<oidval>$ = a_list(mksymbol("set-amosql-variables"),
                      $<oidval>3,
		      $<oidval>6,NULL); }
;

procedure_stmt:
procedure_stmt1 { $<oidval>$ = $<oidval>1 }
| select_stmt { $<oidval>$ = $<oidval>1 }
;

procedure_stmt1:
block { yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 } 
| create_object_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| delete_object_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| for_each_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| update_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| set_variable_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| fetch_cursor_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| open_cursor_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| close_cursor_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| if_stmt { yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| result_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| activate_rule_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| deactivate_rule_stmt
{ yyin_fs->function_flg = FALSE;
 $<oidval>$ = $<oidval>1 }
| while_stmt {yyin_fs->function_flg = FALSE; $<oidval>$ = $<oidval>1;}
| loop_stmt {yyin_fs->function_flg = FALSE; $<oidval>$ = $<oidval>1;}
| _LEAVE {yyin_fs->function_flg = FALSE; 
          $<oidval>$ = cons(mksymbol("amosql-leave"),nil);}
| commit_stmt { yyin_fs->function_flg = FALSE; $<oidval>$ = $<oidval>1 }
| rollback_stmt { yyin_fs->function_flg = FALSE; $<oidval>$ = $<oidval>1 }
| _ID { $<oidval>$ = a_list(mksymbol("atomic-statement"),$<oidval>1,NULL); }
;

while_stmt:
_WHILE simple_expr _DO block_body _WHILE
{
  $<oidval>$ = a_list(mksymbol("amosql-while"),$<oidval>2,$<oidval>4,NULL);
}

loop_stmt:
_LOOP block_body _LOOP
{
  $<oidval>$ = a_list(mksymbol("amosql-loop"),$<oidval>2,NULL);
}

if_stmt:
_IF general_expr_test _THEN procedure_body_stmt
{ $<oidval>$ =
    a_list(mksymbol("if"),
	   $<oidval>2,
	   $<oidval>4,
	   NULL); }
| _IF general_expr_test _THEN procedure_body_stmt
_ELSE procedure_body_stmt 
{ $<oidval>$ = 
    a_list(mksymbol("if"),
	   $<oidval>2,
	   $<oidval>4,
	   $<oidval>6,
	   NULL); }
;

result_stmt:
_RETURN init_value
{ $<oidval>$ = 
    cons(mksymbol("osql-return"),
	 $<oidval>2); }

for_each_option:
{$<oidval>$ = nil;/* Default working on original data! */ }
| _DISTINCT { $<oidval>$ = mksymbol("distinct");}
| _ORIGINAL { $<oidval>$ = nil;}
;

for_each_stmt:
_FOR _EACH for_each_option for_each_vars
where_clause procedure_body_stmt 
{ 
  $<oidval>$ = a_list(mksymbol("osql-foreach"), 
		      $<oidval>4, 
		      kar(kdr($<oidval>5)), 
		      $<oidval>3, 
		      $<oidval>6, 
		      NULL);
  release($<oidval>5);
}
;


for_each_vars:
{$<oidval>$ = nil; }
| variable_declaration_commalist
{$<oidval>$ = $<oidval>1; }
;

logging:
_LOGGING toggle 
{ $<oidval>$ = a_list(mksymbol("logging"),
		      $<oidval>2,
		      NULL); }
;

toggle:
_ON { $<oidval>$ = a_list(mksymbol("quote"),
			  mksymbol("on"),
			  NULL); }
| _OFF { $<oidval>$ = a_list(mksymbol("quote"),
			     mksymbol("off"),
			     NULL); }
;

image_size:
_IMAGESIZE _INTEGER_CONST
{ $<oidval>$ = a_list(mksymbol("imagesize"),
		      $<oidval>2,
		      NULL); }
;
	
save_stmt:
_SAVE _STRING_CONST
{ $<oidval>$ = a_list(mksymbol("saveimage"),
		      $<oidval>2,
		      NULL); }
;
	
redirect_stmt:
_LESS _STRING_CONST 
{ $<oidval>$ = a_list(mksymbol("load-amosql"),
		      $<oidval>2,
		      NULL); }
;

commit_stmt:
_COMMIT { $<oidval>$ = a_list(mksymbol("commit"),NULL); }
;


rollback_stmt:
_ROLLBACK { $<oidval>$ = a_list(mksymbol("rollback"),NULL); }
| _ROLLBACK _INTEGER_CONST
{ $<oidval>$ = a_list(mksymbol("rollback"),
		      $<oidval>2,
		      NULL); }
;

lisp_stmt:
_LISP { $<oidval>$ = a_language_object("Lisp"); }
;

quit_stmt:
_QUIT { $<oidval>$ = a_list(mksymbol("quit"),NULL); }
;

exit_stmt:
_EXIT { $<oidval>$ = a_list(mksymbol("exit"),NULL); }
;
