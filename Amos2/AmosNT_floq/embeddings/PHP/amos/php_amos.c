/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Tore Risch, Chistian Werner, UDBL
 * $RCSfile: php_amos.c,v $
 * $Revision: 1.12 $ $Date: 2012/01/13 17:41:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II as plug-in to PPP
 * ===========================================================================
 * $Log: php_amos.c,v $
 * Revision 1.12  2012/01/13 17:41:33  torer
 * New top.c has no load_amosqlfn
 *
 * Revision 1.11  2011/04/06 14:43:59  torer
 * Using adll project
 *
 * Revision 1.10  2008/01/31 16:07:27  torer
 * PHPAmos now works under WAMP and PHP Version 5 (not 4)
 *
 * Revision 1.9  2007/08/30 18:30:12  torer
 * Reverted back to raising ERROR rather than WARNING when errors
 * detected in amos_callfunction or amos_excute.
 * Simplifies PHP coding substantially
 *
 * Revision 1.8  2007/08/30 17:51:27  torer
 * Error exceptions raised inside Amos II when calling amos_call or amos_execute
 * are now treated as PHP warnings that do not terminate PHP.
 * amos_call and amos_execute will instead return NULL if error happened in call.
 * The warnings can be trapped in PHP with a user error handler
 *
 * Revision 1.7  2007/02/25 16:23:52  torer
 * 1. amos_getfunction in PHP now obsolete and function names passed instead of objects
 * 2. Fixed bug when using boolean arguments in calls to AmosQL from PHP
 *
 * Revision 1.6  2007/02/23 22:01:42  torer
 * Making init file for PHP optional
 * Allowing function names as strings in PHP
 *
 ****************************************************************************/

/* include amos */
#include "callin.h"
#include "alisp.h"

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "php_amos.h"

#if HAVE_AMOS

/* PHP Includes */
#include "ext/standard/file.h"
#include "ext/standard/info.h"
#include "ext/standard/php_string.h"

function_entry amos_functions[] = {
	PHP_FE(amos_call, NULL)
	PHP_FE(amos_connect, NULL)
	PHP_FE(amos_execute, NULL)
	PHP_FE(amos_eos, NULL)
	PHP_FE(amos_getrow, NULL)
	PHP_FE(amos_next, NULL)
	PHP_FE(amos_getfunction, NULL)
	{NULL, NULL, NULL}
};

ZEND_MINIT_FUNCTION(amos_init);
ZEND_MSHUTDOWN_FUNCTION(amos_free);

zend_module_entry amos_module_entry = {
	STANDARD_MODULE_HEADER,
	"amos",
	amos_functions,
	ZEND_MINIT(amos_init),
	ZEND_MSHUTDOWN(amos_free),
	NULL,
	NULL,
	NULL,
	NO_VERSION_YET,
	STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_AMOS
ZEND_GET_MODULE(amos)
#endif

	 /* Error Messages */
#define ILLEGAL_PARAM zend_error(E_ERROR, "Illegal function argument");
#define AMOS_ERROR (a_errform==nil?zend_error(E_ERROR, "%s", a_errstr):zend_error(E_WARNING, "%s : %s", a_errstr, a_to_string(a_errform)))
#define AMOS_WARNING (a_errform==nil?zend_error(E_WARNING, "%s", a_errstr):zend_error(E_WARNING, "%s : %s", a_errstr, a_to_string(a_errform)))
#define CHECK_AMOS_ERROR if(a_errorflag) AMOS_ERROR
#define FETCH_SCAN(to,from) ZEND_FETCH_RESOURCE(to, a_scan, (zval**)from, -1, "AmosScan", scan_resource)
#define FETCH_CONNECTION(to,from) ZEND_FETCH_RESOURCE(to, a_connection, (zval**)from, -1, "AmosConnection", connection_resource)
int empty_scan; /* Amos II error id */

///////////////////////////////////////////////////////////////////////////////
//
// Rerouting standard output
//
///////////////////////////////////////////////////////////////////////////////

int PHP_readconsole; // Error code
int PHP_output; // stream implementation id for PHP standard output

int PHP_close(oidtype stream)
{
	return 0;
}

int PHP_fflush(oidtype stream)
{
	return 0;
}

int PHP_feof(oidtype stream)
{
	a_error(PHP_readconsole,nil,FALSE);
    return FALSE;
}

char PHP_getc(oidtype o)
{
	a_error(PHP_readconsole,nil,FALSE);
    return ' ';
}

int PHP_ungetc(char c, oidtype o)
{
	a_error(PHP_readconsole,nil,FALSE);
    return 0;
}

void PHP_putc(char c, oidtype stream)
{
	if(c=='\n')zend_printf("<br>\n");
	else zend_printf("%c",c);  
}

void PHP_puts(char *str, oidtype stream)
{
	unsigned int i;

	for(i=0;i<strlen(str);i++)
		PHP_putc(str[i], stream);
}

///////////////////////////////////////////////////////////////////////////////
//
// Basic functions
//
///////////////////////////////////////////////////////////////////////////////

PHP_INI_BEGIN()
	 PHP_INI_ENTRY("amos.image", NULL, PHP_INI_ALL, NULL)
	 PHP_INI_ENTRY("amos.init", NULL, PHP_INI_ALL, NULL)
	 PHP_INI_ENTRY("amos.output", NULL, PHP_INI_ALL, NULL)
	 PHP_INI_END()

int scan_resource;
void scan_destruction_handler(zend_rsrc_list_entry *rsrc TSRMLS_DC)
{
	free_scan(rsrc->ptr);
}

int connection_resource;
void connection_destruction_handler(zend_rsrc_list_entry *rsrc TSRMLS_DC)
{
	a_connection conn= (a_connection)rsrc->ptr;
    dcl_scan(a_scan);

	a_execute(conn,a_scan,"commit;",TRUE); /* Flush changes and empty log */
	free_connection(conn);
}

ZEND_MINIT_FUNCTION(amos_init) 
{
	char *image_file, *init_script, *output_file;
	FILE *lf;
	static int initialized=FALSE;
	//extern int trace_interface;

	REGISTER_INI_ENTRIES();
	init_script = INI_STR("amos.init");
    output_file = INI_STR("amos.output"); 

    lf = freopen(output_file,"a",stdout); // open log file as standard output
	printf("Starting Amos II Zend init function\n");
	scan_resource = 
		zend_register_list_destructors_ex(scan_destruction_handler, NULL, 
										  "AmosScan", module_number);
	connection_resource =
		zend_register_list_destructors_ex(connection_destruction_handler, NULL, 
										  "AmosConnection", module_number);
	image_file = INI_STR("amos.image");
	if(image_file == NULL)
	{
		printf("No Amos II image file specified\n");
		exit(1);
	}
	if(!initialized)
		{
			extern int trace_interface;
			dcl_connection(c);
			dcl_scan(s);

			printf("-----------------------------------\nInitializing embedded Amos II...\n");
			a_initialize(image_file,FALSE);
			a_connect(c,"",FALSE);
			{unwind_protect_begin;
			a_execute(c,s,"print(amos_version());",FALSE);
			if(init_script != NULL)
				call_lisp(mksymbol("load-amosql"), varstack, 1, mkstring(init_script));
			unwind_protect_catch;
			}
			free_connection(c);
			free_scan(s);
			empty_scan = a_register_error("Empty scan");
			/* The following code reroutes printing to web browser 
               instead of log:
			PHP_readconsole = 
				a_register_error("Cannot read from PHP standard output");
			PHP_output = 
				a_define_stream_implementation(PHP_getc, PHP_ungetc, PHP_feof,
											   PHP_puts, PHP_putc, PHP_fflush,
											   PHP_close);
			dr(stdoutstream,streamcell)->streamtype = PHP_output; // reroute stdoutput
			// trace_interface = TRUE; // trace Amos II system calls
			*/
			initialized=TRUE;
		}
	return SUCCESS;
}

ZEND_MSHUTDOWN_FUNCTION(amos_free) 
{
	return SUCCESS;
}

///////////////////////////////////////////////////////////////////////////////
//
// Converting Amos II tuples <-> Indexed PHP arrays
//
///////////////////////////////////////////////////////////////////////////////

int is_OID_string(char *str)
{
	/* Returns length of OID number if str is an object identifier */

	if(strlen(str)<=7 || strncmp(str,"#[OID ",6)) return 0;
	return strspn(str+6,"0123456789");
}

oidtype getoidtype(char *s, a_connection conn) 
{
    /* Gets Amos II handle to stringified OID */

	int oid, idlen;
	char num[100];
	oidtype res=nil;
     
	idlen=is_OID_string(s);
	if(!idlen) zend_error(E_ERROR,"Not a legal OID: '%s'",s);
	strncpy(num,s+6,idlen);
	num[idlen]='\0';
	oid = atoi(num);
	res = a_getobjectno(conn, oid, TRUE);
	CHECK_AMOS_ERROR;
	return res;
}

char* make_OID_string(oidtype oid) 
{
	/* Makes stringified OIDs given a handle to a surrogate object */

	char *toreturn;
	char buffer[30];
	int id = a_getid(oid, TRUE);
	
	CHECK_AMOS_ERROR;
	sprintf(buffer, "#[OID %d]", id);
	toreturn = (char *)emalloc(strlen(buffer)+1);
    strcpy(toreturn,buffer);
	return toreturn;
}

zval *tuple_to_array(a_tuple tpl, void *tsrm_ls)
{
    /* Convert an Amos II tuple to a PHP array */
	int size, i;
	zval *the_array;
	MAKE_STD_ZVAL(the_array);
	array_init(the_array);
	size=a_getarity(tpl, TRUE);
	CHECK_AMOS_ERROR;
	for(i=0; i<size; i++)
		{
			int tpe = a_getelemtype(tpl,i,TRUE);
			zval *the_zval;

			MAKE_STD_ZVAL(the_zval);
			CHECK_AMOS_ERROR;
			switch(tpe)
				{
				case INTEGERTYPE:
					{
						int j;

						j = a_getintelem(tpl,i,TRUE);
						CHECK_AMOS_ERROR;
						ZVAL_LONG(the_zval,j);
						break;
					}
				case REALTYPE:
					{
						double r;

						r = a_getdoubleelem(tpl,i,TRUE);
						CHECK_AMOS_ERROR;
						ZVAL_DOUBLE(the_zval,r);
						break;
					}
				case STRINGTYPE:
					{
						char str[10000];

						a_getstringelem(tpl, i, str, sizeof(str), TRUE);
						CHECK_AMOS_ERROR;
						ZVAL_STRING(the_zval,str,1);
						break;
					}
				case ARRAYTYPE:
					{
						dcl_tuple(a);

						a_getseqelem(tpl, i, a, TRUE);
						if(a_errorflag)
							{
								free_tuple(a);
								AMOS_ERROR;
							}
						else
							{
								the_zval = tuple_to_array(a,tsrm_ls);
								free_tuple(a);
							}
						break;
					}
				case SYMBOLTYPE:
					{
						oidtype symb = a_getobjectelem(tpl, i, TRUE);
						
						CHECK_AMOS_ERROR;
						if(symb == a_true) ZVAL_BOOL(the_zval,TRUE)
						else if(symb == a_false) ZVAL_BOOL(the_zval, FALSE)
						else ZVAL_NULL(the_zval); /* symbols except NIL regarded as NULL */
						break;
					}
				case SURROGATETYPE:
					{
						char *str;
						oidtype obj = a_getobjectelem(tpl, i, TRUE);

						CHECK_AMOS_ERROR;
						str = make_OID_string(obj);
						ZVAL_STRING(the_zval,str,1);
					    break;
					}
				default: zend_error(E_ERROR, "Illegal Amos II type in tuple %d", tpe);
				}
			zend_hash_index_update(HASH_OF(the_array), i, 
								   &the_zval, sizeof(zval *), NULL);
		}
	return the_array;
}

a_tuple array_to_tuple(zval *zarray, a_connection conn, void *tsrm_ls)
{
        /* Convert indexed PHP array to Amos II tuple. */

	    HashTable *ar;
		int i;
		zval **element;

		ar = HASH_OF(zarray);
		if(!ar) php_error(E_ERROR, "Not array.");
		if(zend_hash_get_current_key_type(ar)!=HASH_KEY_IS_LONG)
			php_error(E_ERROR, "Not indexed array.");
		{ 
			int arity = zend_hash_num_elements(ar);
			dcl_tuple(tpl);
		
		    a_setarity(tpl,arity);
			for(i=0;i<arity;i++)
			{
			    if(zend_hash_index_find(ar,i, (void**)&element)==SUCCESS)
				{
                    switch(Z_TYPE_PP(element))
					{
					  case IS_NULL:
					      break;
					  case IS_BOOL:
						  if(Z_LVAL_PP(element)) a_setobjectelem(tpl, i, a_true, TRUE);
						  else a_setobjectelem(tpl, i, a_false, TRUE);
						  break;
				      case IS_LONG: 
					      a_setintelem(tpl, i, Z_LVAL_PP(element), TRUE);
					      break;
				      case IS_DOUBLE:
					      a_setdoubleelem(tpl, i, Z_DVAL_PP(element), TRUE);
					      break;
				      case IS_STRING:
						  {
							  char *str = Z_STRVAL_PP(element);

						      if(is_OID_string(str)) 
								  a_setobjectelem(tpl, i, getoidtype(str, conn), TRUE);
						      else a_setstringelem(tpl, i, str, TRUE);
					          break;
						  }
					  case IS_ARRAY:
                          a_setseqelem(tpl, i, array_to_tuple(*element,conn,tsrm_ls),TRUE);
						  break;
				      default:
						  free_tuple(tpl);
					      php_error(E_ERROR,"Illegal element in array used as AmosTuple");
					      break;
					}
					if(a_errorflag)
					{
						free_tuple(tpl);
						AMOS_ERROR;
					}
				}
				else 
				{
					free_tuple(tpl);
					php_error(E_ERROR, "Not continuous array.");
				}
			}
			return tpl;
		}
}

///////////////////////////////////////////////////////////////////////////////
//
// Interface for connecting Amos II
//
///////////////////////////////////////////////////////////////////////////////

PHP_FUNCTION(amos_connect) 
{
    /* Establishes a connection to Amos II. If this function is called
	   with a database name as parameter a client-server connection
	   is established, otherwise a connection to the local database is
	   established. The return value is a PHP resource holding the connection.
	*/

	char *dbname;
	int dbname_len;
	int param_count = ZEND_NUM_ARGS();

	switch (param_count) 
		{
		case 1:
			if (zend_parse_parameters(param_count TSRMLS_CC, "s",
									  &dbname, &dbname_len) == FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
    {
		dcl_connection(conn);

		a_connect(conn, dbname, TRUE);
		if(a_errorflag)
			{
				free_connection(conn);
				AMOS_ERROR;
			}
	    ZEND_REGISTER_RESOURCE(return_value, (void *)conn, 
							   connection_resource);
		return;
	}
}

PHP_FUNCTION(amos_call)
{
    /* Call an Amos II function from PHP.
       Result returned as a scan resource.
	   amos_call(connection, function, a1,....,an) -> scan
	*/

	zval **parameter_array[MAX_ARITY];
	int param_count = ZEND_NUM_ARGS();
	int i;
	oidtype fno;
	a_connection conn;
	zval *zconnection;

    MAKE_STD_ZVAL(zconnection);
	if(param_count<2 || param_count>MAX_ARITY) 
		{
			WRONG_PARAM_COUNT;
			return;
		}
    if(zend_get_parameters_array_ex(param_count, parameter_array) != SUCCESS)
		{
			WRONG_PARAM_COUNT;
			return;
		}
	if((*parameter_array[0])->type!=IS_RESOURCE)
		zend_error(E_ERROR, "First arg. in amos_call not connection id");
	zconnection = parameter_array[0];
	FETCH_CONNECTION(conn,zconnection);
	if((*parameter_array[1])->type!=IS_STRING) 
		zend_error(E_ERROR, "Second arg. in amos_call not function OID");
    if(is_OID_string((*parameter_array[1])->value.str.val))
	   fno = getoidtype((*parameter_array[1])->value.str.val,conn);
	else fno = a_mksymbol((*parameter_array[1])->value.str.val,TRUE);
	CHECK_AMOS_ERROR;
	{
		dcl_tuple(argl);

		a_setarity(argl,param_count - 2);
	    if(a_errorflag)
			{
				free_tuple(argl);
				CHECK_AMOS_ERROR;
			}
	    for(i=2;i<param_count;i++)
			{
				int tpe = (*parameter_array[i])->type;
				switch(tpe)
					{
					case IS_LONG:
						a_setintelem(argl,i-2, (*parameter_array[i])->value.lval,TRUE);
						break;
					case IS_STRING:
						  {
							  char *str = (*parameter_array[i])->value.str.val;

						      if(is_OID_string(str)) 
								  a_setobjectelem(argl, i-2, getoidtype(str, conn), TRUE);
						      else a_setstringelem(argl, i-2, str, TRUE);
					          break;
						  }
						//a_setstringelem(argl, i-2, (*parameter_array[i])->value.str.val, TRUE);
						break;
					case IS_DOUBLE:
						a_setdoubleelem(argl, i-2, (*parameter_array[i])->value.dval, TRUE);
						break;
					case IS_ARRAY:
						a_setseqelem(argl, i-2,	
							         array_to_tuple(*parameter_array[i],conn, tsrm_ls),TRUE);
						break;
                    case IS_BOOL:
						if((*parameter_array[i])->value.lval) 
							a_setobjectelem(argl, i-2, truesymbol, TRUE);
						else a_setobjectelem(argl, i-2, falsesymbol, TRUE);
					case IS_NULL:
						break;
					default:
						free_tuple(argl);
						zend_error(E_ERROR,"Not supported PHP datatype %d",tpe);
						return;
					}
				if(a_errorflag)
				{
					free_tuple(argl);
					AMOS_ERROR;
				}
			}
		{
			dcl_scan(a_scan);

			a_callfunction(conn, a_scan, fno, argl, TRUE); 
	        if(a_errorflag)
				{
					free_tuple(argl);
					free_scan(a_scan);
					AMOS_ERROR;
					ZVAL_NULL(return_value);
				}
			else
			{
				  free_tuple(argl);
	              ZEND_REGISTER_RESOURCE(return_value, (void *)a_scan, 
								         scan_resource);
			}
		}
	}
}

PHP_FUNCTION(amos_execute) 
{
    /* Send a command to Amos II for execution. Result returned as scan. */

	int param_count = ZEND_NUM_ARGS();
	char *query;
	int query_len;
	a_connection conn;
	zval *zconnection;

    MAKE_STD_ZVAL(zconnection);
	switch (param_count) 
		{
		case 2:
			if (zend_parse_parameters(param_count TSRMLS_CC, "rs",
									  zconnection, &query, &query_len) 
				== FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
    { 
		dcl_scan(a_scan);

		FETCH_CONNECTION(conn,zconnection);
		a_execute(conn, a_scan, query, TRUE);
		if(a_errorflag)
			{
				free_scan(a_scan);
				AMOS_ERROR;
				ZVAL_NULL(return_value);
			}
		else ZEND_REGISTER_RESOURCE(return_value, (void *)a_scan, scan_resource);
	}
}

PHP_FUNCTION(amos_eos) 
{
    /* Returns TRUE if there are no more tuples in the scan */

	int param_count = ZEND_NUM_ARGS();
	zval *zscan;
	a_scan sc;

    MAKE_STD_ZVAL(zscan);

	switch (param_count) 
		{
		case 1:
			if (zend_parse_parameters(param_count TSRMLS_CC, "r", zscan) 
				== FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
	FETCH_SCAN(sc, zscan);
	RETURN_BOOL(a_eos(sc));
}

PHP_FUNCTION(amos_getrow) 
{
    /* Retrieves the current row from a scan converted to a PHP array */

	int param_count = ZEND_NUM_ARGS();
	zval *zscan;

    MAKE_STD_ZVAL(zscan);
	switch (param_count) 
		{
		case 1: 
			if (zend_parse_parameters(param_count TSRMLS_CC, "r", zscan) 
				== FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
	// get next row
	{
		dcl_tuple(row);
		a_scan sc;
		
		FETCH_SCAN(sc, zscan);
		a_getrow(sc, row, TRUE);
	    if(a_errorflag)
			{
				free_tuple(row);
				if(a_errno==empty_scan)
				{
                   ZVAL_NULL(return_value);
				   return;
				}
				AMOS_ERROR;
			}
	    *return_value = *tuple_to_array(row,tsrm_ls);
	    free_tuple(row);
	    return;
	}
}

PHP_FUNCTION(amos_next) 
{
    /* Advances the scan forward to the next tuple.  */

	int param_count = ZEND_NUM_ARGS();
	zval *zscan;
	a_scan sc;

    MAKE_STD_ZVAL(zscan);
	switch (param_count) 
		{
		case 1:
			if (zend_parse_parameters(param_count TSRMLS_CC, "r", zscan) 
				== FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
    FETCH_SCAN(sc, zscan)
		if (a_nextrow(sc, TRUE) != 0) AMOS_ERROR;
}

PHP_FUNCTION(amos_getfunction) 
{
    /* Returns the OID of a given function name */
	
	int param_count = ZEND_NUM_ARGS();
	char *name;
	int name_len;
	oidtype fct;
	a_connection conn;
	zval *zconnection;

	MAKE_STD_ZVAL(zconnection);
	switch (param_count) 
		{
		case 2:
			if (zend_parse_parameters(param_count TSRMLS_CC, "rs", zconnection, &name, &name_len) == FAILURE) 
				{
					ILLEGAL_PARAM;
					return;
				}
			break;
		default:
			WRONG_PARAM_COUNT;
			return;
		}
	FETCH_CONNECTION(conn,zconnection);
	fct = a_getfunction(conn, name, TRUE);
	CHECK_AMOS_ERROR;
	else RETURN_STRING(make_OID_string(fct), 1);
}

#endif

/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 * vim600: fdm=marker
 * vim: noet sw=4 ts=4
 */
