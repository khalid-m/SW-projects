/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: strings.c,v $
 * $Revision: 1.5 $ $Date: 2012/04/12 14:55:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Extra string management functions
 * ===========================================================================
 * $Log: strings.c,v $
 * Revision 1.5  2012/04/12 14:55:07  larme597
 * *** empty log message ***
 *
 * Revision 1.4  2011/10/25 14:08:45  larme597
 * string-find looks for a string instead of a single char.
 *
 * Revision 1.3  2011/08/23 12:01:19  larme597
 * Lisp string functions.
 *
 * Revision 1.2  2011/04/13 11:36:53  larme597
 * A better explode function.
 *
 * Revision 1.1  2011/04/12 20:34:28  larme597
 * Extra string management functions. Adding explode function.
 *
 ****************************************************************************/

#include <stdlib.h>
#include <string.h>
#include "alisp.h"

int explode(char ***arr_ptr, char *str, char delimiter)
{
  char *src = str, *end, *dst;
  char **arr;
  int size = 1, i;

  while ((end = strchr(src, delimiter)) != NULL) // Find number of strings
    {
      ++size;
      src = end + 1;
    }
  arr = malloc(size * sizeof(char *) + (strlen(str) + 1) * sizeof(char));

  src = str;
  dst = (char *) arr + size * sizeof(char *);
  for (i = 0; i < size; ++i) // Copy strings
    {
      if ((end = strchr(src, delimiter)) == NULL)
	end = src + strlen(src);
      arr[i] = dst;
      strncpy(dst, src, end - src);
      dst[end - src] = '\0';
      dst += end - src + 1;
      src = end + 1;
    }
  *arr_ptr = arr;

  return size;
}

oidtype string_explodefn(bindtype env, oidtype arg, oidtype delim)
{
  oidtype lst;
  char **arr;
  int i, size;

  OfType(arg, STRINGTYPE, env);
  a_let(lst, nil);
  size = explode(&arr, getstring(arg), *getstring(delim));
  for (i = size - 1; i >= 0; --i)
    push_string(arr[i], lst);

  free(arr);
  a_return(lst);
}

oidtype string_findfn(bindtype env, oidtype arg, oidtype c)
{
  char *pos;
  char *str = getstring(arg);

  OfType(arg, STRINGTYPE, env);
  OfType(c, STRINGTYPE, env);
  if ((pos = strstr(str, getstring(c))) != NULL)
    return mkinteger(pos - str);
  else
    return nil;
}

void register_strings()
{
  extfunction2("string-explode", string_explodefn);
  extfunction2("string-find", string_findfn);
}
