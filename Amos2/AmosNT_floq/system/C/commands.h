/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: commands.h,v $
 * $Revision: 1.5 $ $Date: 2012/01/06 15:35:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Interface to the commands module. This module is used to
 *              store and execute AMOS2 commands, before the system is
 *              initialized. The term 'command' means wither LISP ot OSQL.          
 ****************************************************************************/

#ifndef _commands_h_
#define _commands_h_

/* Describes a LISP or OSQL command */
typedef struct a_command_tag {
  char lang;  /* 'l' - lisp; 'o' - osql; '\0' - end */
  char* cmd; /* the command itself */
} a_command;

/* Array of commands */
typedef struct command_array_tag {
    a_command* commands;
    int        current;
    int        size;
} command_array;

/* Global array with Amos commands.
   It has to be global because there is no other way to pass it to exec_commands
   as it has to be executed later as a "hook" after Amos INIT
 */
extern command_array* g_commands;

extern command_array*  new_command_array(int elements);
extern void            free_command_array(command_array* ca);
extern void add_command(command_array* ca, char l, const char* templ, char* cmd);
extern void exec_commands(void *);

/*****************************************************************************
* Portability notes:
* - Maximum path lenght:
*   Windows: _MAX_PATH
*   UNIX:    PATH_MAX
*****************************************************************************/

#ifndef UNIX
#ifdef __BORLANDC__
#include <dir.h>
#endif
#define PATH_MAX _MAX_PATH
#endif

#endif
