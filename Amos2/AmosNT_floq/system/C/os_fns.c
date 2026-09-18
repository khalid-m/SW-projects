/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: os_fns.c,v $
 * $Revision: 1.14 $ $Date: 2007/09/01 14:40:18 $
 * $State: Exp $ $Locker:  $
 *
 * Description: OS dependent functions.
 *
 * ==========================================================================
 * $Log: os_fns.c,v $
 * Revision 1.14  2007/09/01 14:40:18  torer
 * Nicer error messages
 *
 * Revision 1.13  2007/08/08 15:35:35  torer
 * (PUSHD path) and (POPD) defined
 *
 * Revision 1.12  2006/02/07 07:49:11  torer
 * *** empty log message ***
 *
 * Revision 1.11  2006/02/07 07:33:13  torer
 * Removed annoying warnings
 *
 ****************************************************************************/

#include <errno.h>
#include <callin.h>
#include <storage.h>
#include <alisp.h>
#ifdef NT
#include <direct.h>
#else
#include <unistd.h>
#endif
#include "commands.h"

int err_system;
int err_getcwd;
int err_cd;


/*****************************************************************************
* The 'system' function passes command to the command interpreter.
* Windows:
*     system refers to the COMSPEC and PATH environment variables that locate
*     the command-interpreter file (the file named CMD.EXE in Windows NT).
* UNIX:
*     invokes the user shell with 'command'
*
* LISP: (system command)
*	params:	command   - string - a shell command
*	return:           - T on success, NIL otherwise
*****************************************************************************/
oidtype systemfn(bindtype env, oidtype oidCommand) {
    char*   pszCommand = NULL;
    int     result;

    // TODO: check for the authority level, and if too low
    //       deny permission.

	// extract the command string
	IntoString(oidCommand, pszCommand, env);
    result = system(pszCommand);
    if (result == -1) {
        return a_error(err_system, mkstring(strerror(errno)), FALSE);
    } else {
        return mkinteger(result);
    }
}

/*****************************************************************************
* Get the current directory of this AMOS process.
* LISP: (pwd)
*	return:				- the current AMOS directory
*****************************************************************************/
oidtype pwdfn(bindtype env) {
    char*  path = NULL;   // buffer for current directory
    char*  pch;
    oidtype pwd = nil;


    /* Get the current working directory: */
    path = getcwd(path, PATH_MAX);
    if(path == NULL ) {
        return a_error(err_getcwd, mkstring(path), FALSE);
    }

    // Convert delimiters in 'path' to UNIX style '/'
    for (pch = path; *pch != '\0'; pch++) {
        if (*pch == '\\') {
            *pch = '/';
        }
    }

    pwd = mkstring(path);

    return pwd;
}

/*****************************************************************************
* Change the current directory of this AMOS process.
* LISP: (cd path)
*	params:	path            - string - an OS specific path
*	return:                 - the new AMOS directory
*****************************************************************************/
oidtype cdfn(bindtype env, oidtype path) {
    char*  pszPath;
    int    result;

	IntoString(path, pszPath, env);

    result = chdir(pszPath);
    if (result == 0) {
        return pwdfn(env);
    } else {
        return a_error(err_cd, mkstring(pszPath), FALSE);
    }
}

/*****************************************************************************
* (PUSHD path) and (POPD)
*****************************************************************************/

#define DIRSTACK_SIZE 30
static char *dirstack[DIRSTACK_SIZE];
static dirstacktop=-1;
int err_pushd_overflow, err_popd_underflow;

oidtype pushdfn(bindtype env, oidtype path)
{
  oidtype pw, res;

  if(dirstacktop>=DIRSTACK_SIZE-1)
     return lerror(err_pushd_overflow,path,env);
  a_let(pw,pwdfn(env));
  dirstack[dirstacktop+1] = strdup(getstring(pw));
  a_free(pw);
  {unwind_protect_begin;
  res = cdfn(env,path);
  dirstacktop++;
  unwind_protect_catch;
  if(unwind_reset) free(dirstack[dirstacktop+1]);
  unwind_protect_end;}
  return res;
}

oidtype popdfn(bindtype env)
{
  oidtype pw,res;

  if(dirstacktop<0) return lerror(err_popd_underflow,pwdfn(env),env);
  a_let(pw,mkstring(dirstack[dirstacktop]));
  {unwind_protect_begin;
  res = cdfn(env,pw);
  dirstacktop--;
  unwind_protect_catch;
  a_free(pw);
  if(unwind_reset)free(dirstack[dirstacktop]);
  unwind_protect_end;}
  return res;
}

/*****************************************************************************
* Get the value of an environment variable
* LISP: (getenv varname)
*	return:         - the value of this process environment variable or
*                         NIL o/w
*****************************************************************************/
oidtype getenvfn(bindtype env, oidtype oidVarname) {
    char*   pszVarname;
    char*   pszValue;

	IntoString(oidVarname, pszVarname, env);

    pszValue = getenv(pszVarname);

    if (pszValue != NULL) {
        return mkstring(pszValue);
    } else {
        return nil;
    }
}


/*****************************************************************************
* Initialization
*****************************************************************************/
void register_os_functions() {
    err_system  = a_register_error("System error");
    err_getcwd  = a_register_error("Unable to get current directory");
    err_cd      = a_register_error("Unable to change to directory");
    err_pushd_overflow = a_register_error("Too many pushd");
    err_popd_underflow = a_register_error("Too many popd");

    extfunction1("system",      systemfn);
    extfunction0("pwd",         pwdfn);
    extfunction1("cd",          cdfn);
    extfunction1("getenv",      getenvfn);
    extfunction1("pushd",       pushdfn);
    extfunction0("popd",        popdfn);
}
