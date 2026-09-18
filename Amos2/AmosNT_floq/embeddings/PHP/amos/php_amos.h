/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Tore Risch, Christian Werner, UDBL
 * $RCSfile: php_amos.h,v $
 * $Revision: 1.3 $ $Date: 2006/02/15 15:44:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos II as plug-in to PHP
 *
 ****************************************************************************/

#ifndef PHP_AMOS_H
#define PHP_AMOS_H

#if HAVE_AMOS
PHP_FUNCTION(amos_call);
PHP_FUNCTION(amos_connect);
PHP_FUNCTION(amos_execute);
PHP_FUNCTION(amos_eos);
PHP_FUNCTION(amos_getrow);
PHP_FUNCTION(amos_next);
PHP_FUNCTION(amos_getfunction);
#define MAX_ARITY 30

#else
#define phpext_amos_ptr NULL
#endif

#ifdef PHP_WIN32
# ifdef PHP_AMOS_EXPORTS
# define PHP_AMOS_API __declspec(dllexport)
# else
# define PHP_AMOS_API __declspec(dllimport)
# endif
#else
# define PHP_AMOS_API
#endif

#define FUNCTION_PARAMS 50

#endif


/*
 * Local variables:
 * tab-width: 4
 * c-basic-offset: 4
 * End:
 */
