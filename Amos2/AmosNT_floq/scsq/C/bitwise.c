/***************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: bitwise.c,v $
 * $Revision: 1.2 $ $Date: 2010/07/03 02:47:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Bitwise operations (and, or, not).
 *
 * =============================================================
 * $Log: bitwise.c,v $
 * Revision 1.2  2010/07/03 02:47:01  roka4241
 * Now using correct versions of extfunction. Wrote regress tests for stream group by and fixed some bugs. Refactored stream window datatype.
 *
 * Revision 1.1  2010/07/02 03:59:06  roka4241
 * Added bitwise operations and, or, not.
 *
 **************************************************************/

#include "alisp.h"   /* Include Lisp Interfaces */
#include "callout.h"
#include "bitwise.h"

oidtype bitwise_and(bindtype env, oidtype o_left, oidtype o_right)
{
    int left, right;
    
    IntoInteger(o_left, left, env);
    IntoInteger(o_right, right, env);
    
    return mkinteger(left & right);
}

oidtype bitwise_or(bindtype env, oidtype o_left, oidtype o_right)
{
    int left, right;
    
    IntoInteger(o_left, left, env);
    IntoInteger(o_right, right, env);
    
    return mkinteger(left | right);
}

oidtype bitwise_not(bindtype env, oidtype o_left)
{
    int left;
    
    IntoInteger(o_left, left, env);
    
    return mkinteger(~left);
}


void register_bitwise(void)
{
    extfunction2("band", bitwise_and);
    extfunction2("bor", bitwise_or);
    extfunction1("bnot", bitwise_not);
}
