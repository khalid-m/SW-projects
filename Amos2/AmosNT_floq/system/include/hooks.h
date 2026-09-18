/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Tore Risch, UDBL
 * $RCSfile: hooks.h,v $
 * $Revision: 1.4 $ $Date: 2012/01/06 15:37:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: System hooks
 * ===========================================================================
 * $Log: hooks.h,v $
 * Revision 1.4  2012/01/06 15:37:45  torer
 * char * -> void *
 *
 * Revision 1.3  2012/01/05 14:26:32  torer
 * New hooks: AFTER_IMAGE_WRITTEN AFTER_IMAGE_READ
 *
 * Revision 1.2  2010/12/29 20:38:42  torer
 * Use of EXTERN macro for C/C++/DLL independence
 *
  ****************************************************************************/

typedef void (*HookFunction) (void*);

EXTERN void a_register_hook(HookFunction fn, int typeofhook);
/* Register C function to be called at specific places in system.
   E.g. before or after rollin/rollout or in a_connect. 
   The parameter depends on the hook            */

EXTERN void a_execute_hooks(int typeofhook, void *param);
/* Execute all hook functions of a given kind with the given parameter */

EXTERN int a_hook_defined(HookFunction fn, int typeofhook);
/* Return TRUE if fn already defined as hook of given type */

#define AFTER_ROLLIN 0          /* Just after image has been completely read */
#define BEFORE_ROLLOUT 1        /* Just before image is about to be read */
#define AFTER_IMAGE_WRITTEN 2   /* Just after main image has been written */
#define AFTER_IMAGE_READ 3      /* Just after main image has been read */
#define AFTER_INIT 4            /* At first a_connect or toploop */   
