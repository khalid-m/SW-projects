/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2013 Tore Risch, UDBL
 * $RCSfile: systime.h,v $
 * $Revision: 1.2 $ $Date: 2013/05/17 14:27:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface to stream tuple timestamping
 * ===========================================================================
 * $Log: systime.h,v $
 * Revision 1.2  2013/05/17 14:27:54  torer
 * Added CSV report time stamps
 *
 * Revision 1.1  2013/05/17 06:53:10  torer
 * C interface to systime package.
 * Changed name of SET-ENTER-SYSTIME to SET-SYSTIME
 *
 * Revision 1.4  2006/02/13 07:37:48  torer
 ****************************************************************************/

extern struct timeval a_enter_systime,  /* The latest enter system time */
  a_this_systime,     /* The time when the latest enter system time was
		       propagated to the current process */
  a_transaction_time; /* The latest transaction time */

extern void a_set_systime(void);  /* Set the current enter and local system times to 
                                     current time */
 
extern void a_clear_systime(void); /* clear enter and local system times */

extern int a_systimep(void);  /* TRUE if enter or local system times set */

extern void print_entersystime(oidtype stream); /* print current enter system 
                                                   time to stream */

extern void read_entersystime(oidtype stream); /* Read current enter system 
                                                  time stamp from stream */


