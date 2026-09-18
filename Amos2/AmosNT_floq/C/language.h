/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Tore Risch, UDBL
 * $RCSfile: language.h,v $
 * $Revision: 1.1 $ $Date: 2010/12/29 20:14:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Initialization of foreign programming language interface
 * ===========================================================================
 * $Log: language.h,v $
 * Revision 1.1  2010/12/29 20:14:42  torer
 * Foreign language interface
 *
 ****************************************************************************/

#include "callin.h"

EXTERN void a_register_language(void fn(char *)); 
/*         Register C function to initialize foreign language runtime system */

EXTERN void a_register_enabled(char *language,char *lispfn);  
                                /* Lisp function to test if language enabled */

EXTERN void a_register_loader(char *language,char *lispfn); 
                       /* Lisp function to dynamically load foreign function */
