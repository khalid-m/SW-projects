/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2000 Timour Katchaounov, UDBL
 * $RCSfile: text_fns.c,v $
 * $Revision: 1.7 $ $Date: 2009/10/22 18:31:00 $
 * $State: Exp $ $Locker:  $
 *
 * Description: string functions
 * ===========================================================================
 * $Log: text_fns.c,v $
 * Revision 1.7  2009/10/22 18:31:00  torer
 * a_capitalize(str) (C) and (STRING-CAPITALIZE STR)
 *
 * Revision 1.6  2009/08/20 18:31:00  torer
 * Added STRING-TRIM, STRING-LEFT-TRIM, and STRING-RIGHT-TRIM
 *
 * Revision 1.5  2009/05/05 18:46:34  torer
 * Case insensitive STRING-LIKE-I
 *
 ****************************************************************************/

#include <callin.h>
#include <storage.h>
#include <alisp.h>
#include "text_match.h"

int pattern_esc;
int pattern_range;
int pattern_close;
int pattern_empty;
int internal_disagreement;
int internal_error;

/*****************************************************************************
 * Test if a string matches a pattern. The pattern syntax is:
 *   `*' matches any sequence of characters (zero or more)
 *   `?' matches any character
 *   [SET] matches any character in the specified set,
 *   [!SET] or [^SET] matches any character not in the specified set.
 *
 * LISP: (string-like string pattern)
 *   params	    - string - a string to test for match
 *	params:     - pattern - the pattern to be matched
 *	return:	    - 0 if string does not matche the pattern, 
                  1 if it matches
				  error code otherwise
*****************************************************************************/
oidtype string_like(bindtype env, char *pszString, char *pszPattern) 
{
  int     error_type;
  int     is_valid_error;

  error_type = matche(pszPattern, pszString);
  is_valid_pattern(pszPattern, &is_valid_error);

  switch (error_type) {
  case MATCH_VALID:
    if (is_valid_error == PATTERN_VALID) {
      return (error_type == MATCH_VALID ) ? 1 : 0;
    }

  case MATCH_LITERAL:
  case MATCH_RANGE:
  case MATCH_ABORT:
  case MATCH_END:
    return 0;

  case MATCH_PATTERN: /* bad pattern */
    switch (is_valid_error) {
    case PATTERN_VALID:
      is_valid_error = internal_disagreement;
      break;
    case PATTERN_ESC:
      is_valid_error = pattern_esc;
      break;
    case PATTERN_RANGE:
      is_valid_error = pattern_range;
      break;
    case PATTERN_CLOSE:
      is_valid_error = pattern_close;
      break;
    case PATTERN_EMPTY:
      is_valid_error = pattern_empty;
      break;
    default:
      is_valid_error = internal_error;
    }
    break;

  default:
    is_valid_error = internal_error;
    break;
  }
  return is_valid_error;
}

oidtype string_likefn(bindtype env, oidtype string, oidtype pattern) 
{
  char*   pszString;
  char*   pszPattern;
  int ret;

  IntoString(string, pszString, env);
  IntoString(pattern, pszPattern, env);
  ret = string_like(env, pszString, pszPattern);
  switch (ret)
    {
    case 0: return nil;
    case 1: return t;
    default: return lerror(ret, pattern, env);
    }
}

oidtype string_like_ifn(bindtype env, oidtype string, oidtype pattern) 
{
  char*   pszString;
  char*   pszPattern;
  int ret;

  IntoString(string, pszString, env);
  IntoString(pattern, pszPattern, env);
  pszString = strdup(pszString);
  a_toupper(pszString);
  pszPattern = strdup(pszPattern);
  a_toupper(pszPattern);
  ret = string_like(env, pszString, pszPattern);
  free(pszString);
  free(pszPattern);
  switch (ret)
    {
    case 0: return nil;
    case 1: return t;
    default: return lerror(ret, pattern, env);
    }
}

/*****************************************************************************
 * Conversion of a string to upper case.
 *****************************************************************************/
oidtype string_upcase(bindtype env, oidtype string) 
{
  char*   pszString;
  oidtype res;

  IntoString(string, pszString, env); /* get the input string */
  res = mkstring(pszString); /* make a copy */
  a_toupper(getstring(res)); /* convert it */
  return res;
}

/*****************************************************************************
 * Conversion of a string to lower case.
 *****************************************************************************/
oidtype string_downcasefn(bindtype env, oidtype string) 
{
  char*   pszString;
  oidtype res;

  IntoString(string, pszString, env); /* get the input string */
  res = mkstring(pszString);  /* make a copy */
  a_tolower(getstring(res)); /* convert it */
  return res;
}

/*****************************************************************************
 * Capitalization of a string 
 *****************************************************************************/
oidtype string_capitalizefn(bindtype env, oidtype string) 
{
  char*   pszString;
  oidtype res;

  IntoString(string, pszString, env); /* get the input string */
  res = mkstring(pszString);  /* make a copy */
  a_capitalize(getstring(res)); /* convert it */
  return res;
}

extern int whitespace(char);

oidtype whitespacesfn(bindtype env, oidtype str)
{
  char *s;

  IntoString(str, s, env);
  while(*s)
    {
      if(!whitespace(*s)) return nil;
      s++;
    }
  return t;
}

oidtype string_left_trimfn(bindtype env, oidtype chars, oidtype str)
{
  char *ch, *s;

  IntoString(chars,ch,env);
  IntoString(str,s,env);
  return mkstring(s+strspn(s,ch));
}

oidtype string_right_trimfn(bindtype env, oidtype chars, oidtype str)
{
  char *ch, *s;
  char buffer[50], *buffp=buffer;
  oidtype res;
  int len, i;

  IntoString(chars,ch,env);
  IntoString(str,s,env);
  len = strlen(s);
  if(len>=sizeof(buffer)) buffp=strdup(s);
  else strcpy(buffp,s);
  for(i=len-1;i>=0&&strchr(ch,s[i])!=NULL;i--);
  buffp[i+1]='\0';
  res = mkstring(buffp);
  if(buffp!=buffer) free(buffp);
  return res;
}

oidtype string_trimfn(bindtype env, oidtype chars, oidtype str)
{
  char *ch, *s;
  char buffer[50], *buffp=buffer;
  oidtype res;
  int len, i;

  IntoString(chars,ch,env);
  IntoString(str,s,env);
  len = strlen(s);
  if(len>=sizeof(buffer)) buffp=strdup(s);
  else strcpy(buffp,s);
  for(i=len-1;i>=0&&strchr(ch,s[i])!=NULL;i--);
  buffp[i+1]='\0';
  res = mkstring(buffp+strspn(buffp,ch));
  if(buffp!=buffer) free(buffp);
  return res;
}

/*****************************************************************************
 * Initialization
 *****************************************************************************/
void register_text_functions() {
  pattern_esc     = a_register_error("literal escape at end of pattern");
  pattern_range   = a_register_error("malformed range in [..] construct");
  pattern_close   = a_register_error("no end bracket in [..] construct");
  pattern_empty   = a_register_error("[..] construct is empty");
  internal_disagreement = a_register_error("Internal disagreement on Pattern");
  internal_error = a_register_error("Internal pattern-matcher error");

  extfunction2("string-like", string_likefn);
  extfunction2("string-like-i", string_like_ifn);
  extfunction1("string-upcase", string_upcase);
  extfunction1("string-downcase", string_downcasefn);
  extfunction1("string-capitalize", string_capitalizefn);
  extfunction1("whitespaces", whitespacesfn);
  extfunction2("string-left-trim", string_left_trimfn);
  extfunction2("string-right-trim", string_right_trimfn);
  extfunction2("string-trim", string_trimfn);
}
