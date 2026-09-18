/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1993 - 2001 Jonas S Karlsson, M. Werner, Martin Skold,
 *             Tore Risch EDSLAB, UDBL
 * $RCSfile: a_time.h,v $
 * $Revision: 1.21 $ $Date: 2013/05/17 06:53:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Contains time related lisp functions and data types.
 ****************************************************************************/

#ifndef _a_time_h_
#define _a_time_h_

#include <math.h>
#include <time.h>
#include <sys/types.h>
#include <time.h>
#include <sys/timeb.h>
#include "storage.h"
#include "alisp.h"

/* EZ/2006-01-23: Timeval is defined in winsock2.h
   which is included later in the build. Include
   it here to avoid conflicts. */
#if defined(NT)
  #include <winsock2.h>
  #define timeval_def 1
#elif defined(UNIX)
  #include <sys/time.h>
#endif

#define CENTURY 1900  /* 2000 problem here? */

oidtype gmtfn(bindtype);
oidtype time_stringfn(bindtype env, oidtype gmt);
oidtype date_to_timevalfn(bindtype env, oidtype dt);
oidtype timevalpfn(bindtype env, oidtype tv);
oidtype mktimeintervalfn(bindtype env, oidtype start,
                         oidtype stop, oidtype type);
oidtype mkdatefn(bindtype env, oidtype year,
                 oidtype month, oidtype day);
oidtype mktimefn(bindtype env, oidtype hour,
                 oidtype minute, oidtype second);
void register_time_functions(void);

int compare_timeval(oidtype to1,oidtype to2);
EXTERN oidtype timeval_add_durationfn(bindtype env, oidtype to, 
                                      oidtype duration);
EXTERN void add_duration(struct timeval* rt, const struct timeval* st, 
                         double d);
EXTERN void add_duration2(struct timeval* rt, double d);

EXTERN double run_time(void);
EXTERN char* a_now(void);
EXTERN double rnow();

EXTERN unsigned short int TIMEVALTYPE;

#ifndef UNIX
#ifndef timeval_def
#ifndef _STRUCT_TIMEVAL
struct timeval{int tv_sec; int tv_usec;};
#endif
#endif
#endif

struct timevalcell
{
    objtags tags;
    char filler[2];      /* NOT USED, just needed to make the size 12 bytes */
    struct timeval tv;
};

EXTERN oidtype new_timeval(unsigned long seconds, long useconds);

#define mktimeval(sec, usec) new_timeval(sec, usec)
#define timevalp(to) (typetag(doid(to)) == TIMEVALTYPE)
#define gettimeval(to) (dr(to, timevalcell)->tv)

EXTERN oidtype timeval_to_vector(oidtype tv); //AA
EXTERN oidtype make_timeval(int year, int month, int day, int hour, int minute, int second, int usec); //AA

EXTERN unsigned short int TIMETYPE;

struct timecell
{
    objtags tags;
    char filler[2]; /* NOT USED, just needed to make the size 12 bytes */
    int hour; /* integer */
    int minute; /* integer */
    int second; /* integer */
};

/* mktime is unfortunately occupied in HP-UX so I call it mktime3 instead */
#define mktime3(hour, minute, second) new_time(hour, minute, second)
#define timep(o) (typetag(doid(o)) == TIMETYPE)
#define gethour(o) (dr(o, timecell)->hour)
#define getminute(o) (dr(o, timecell)->minute)
#define getsecond(o) (dr(o, timecell)->second)

extern oidtype bothclosedtag, leftclosedtag, rightclosedtag, bothopentag;
EXTERN unsigned short int TIMEINTERVALTYPE;
#define timeintervalp(xx) (typetag(doid(xx)) == TIMEINTERVALTYPE)
#define BOTH_CLOSED 0
#define LEFT_CLOSED 1
#define RIGHT_CLOSED 2
#define BOTH_OPEN 3

struct timeintervalcell
{
    objtags tags;
    char filler[2]; /* NOT USED, just needed to make the size 12 bytes */
    unsigned short int len;
    int type; /* 0: both closed,
		 1: left closed,
		 2: right closed,
		 3: both open */
    struct timeval start;
    struct timeval stop;
};

#define timeintervalsize (int) (ceil \
			     (((double) sizeof(struct timeintervalcell)) / \
			      ((double) OBJECTSIZE)))

#define gettimeintervallen(o) (dr(o, timeintervalcell)->len)
#define gettimeintervaltype(o) (dr(o, timeintervalcell)->type)
#define gettimeintervalstart(o) (dr(o, timeintervalcell)->start)
#define gettimeintervalstop(o) (dr(o, timeintervalcell)->stop)

EXTERN unsigned short int DATETYPE;

struct datecell
{
    objtags tags;
    char filler[2];
    int year; /* integer */
    int month; /* integer */
    int day; /* integer */
};

#define mkdate(year, month, day) new_date(year, month, day)
#define datep(o) (a_datatype(o) == DATETYPE)
#define getyear(o) (dr(o, datecell)->year)
#define getmonth(o) (dr(o, datecell)->month)
#define getday(o) (dr(o, datecell)->day)

#endif
