/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: commands.c,v $
 * $Revision: 1.9 $ $Date: 2012/03/10 13:28:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions to manage and execute a command_array.
 *
 ****************************************************************************/

#include "amos.h"
#include "commands.h"

command_array* g_commands = NULL;

/*****************************************************************************
 * Allocate a new command array.
 * Use 'free_command_array' to deallocate.
 *****************************************************************************/
command_array* new_command_array(int elements)
{
  command_array* ca;

  if (elements > 0)
    {
      ca = (command_array*) malloc(sizeof(command_array));
      ca->commands = (a_command*) malloc(elements * sizeof(a_command));
      ca->size = elements;
      ca->current = 0;
      return ca;
    }
  else
    {
      /* error */
      return NULL;
    }
}

/*****************************************************************************
 * Deallocate a command array.
 *****************************************************************************/
void free_command_array(command_array* ca)
{
  int i;

  if (ca == NULL)
    return;

  for (i = 0; i < ca->current; i++)
    {   
      free(ca->commands[i].cmd);
    }
  free(ca);
  ca = NULL;
}

/*****************************************************************************
 * Add a command to the end of a command array.
 *****************************************************************************/
void add_command(command_array* ca, char l, const char* templ, char* cmd)
{
  if (ca->current < ca->size)
    {
      ca->commands[ca->current].lang = l;
      ca->commands[ca->current].cmd =
	(char*) malloc((strlen(templ) + strlen(cmd)) * sizeof(char));
      sprintf(ca->commands[ca->current].cmd, templ, cmd);
      ++(ca->current);
    }
}

/*****************************************************************************
 * Execute all commands in an array of a_command structures.
 * MUST be called AFTER a_connect(...)
 *****************************************************************************/
void exec_commands(void *xx) 
{
  a_command command;
  int       i;
  oidtype p;
  bindtype env=varstack;

  for(p=globval(mksymbol("connect-forms")); listp(p); p=tl(p))
    {
      release(evalfn(env,hd(p)));
    }

  if (g_commands == NULL) return;

  {unwind_protect_begin;
  for (i = 0; i < g_commands->size; i++)
    {
      command = g_commands->commands[i];
      if (command.lang == 'l')
	{          /* LISP */
	  checkauth(AUTH_LISP); 
	  eval_forms(env, command.cmd);
	}
      else if (command.lang == 'o')
	{   /* OSQL */
	  amosql(command.cmd, FALSE);
	}
      else
	{    /* Skip unknown language */
	}
    }
  commitfn(env); /* Commit if load successful */
  unwind_protect_catch;
  free_command_array(g_commands);
  unwind_protect_end;
  }
}

