/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Tore Risch, UDBL
 * $RCSfile: language.c,v $
 * $Revision: 1.1 $ $Date: 2010/12/29 20:16:31 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Initializing foreign programming language interface
 * ===========================================================================
 * $Log: language.c,v $
 * Revision 1.1  2010/12/29 20:16:31  torer
 * Registration of foreign languages
 *
 ****************************************************************************/

#include "language.h"
#include "alisp.h"

#include "intstorage.h" /* Defines EXPORT */

EXPORT void a_register_enabled(char *language,char *lispfn)       
     /* Register Lisp function to test if language enabled */
{ 
  call_lisp(mksymbol("register-enabled"),varstack,2,
            mksymbol(language), mksymbol(lispfn));
}

EXPORT void a_register_loader(char *language, char *lispfn)
     /* Register Lisp function to load foreign function in language */
{ 
  call_lisp(mksymbol("register-loader"),varstack,2,
            mksymbol(language), mksymbol(lispfn));
}
