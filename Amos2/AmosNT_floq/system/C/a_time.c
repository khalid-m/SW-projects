/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1993 - 2006 Jonas S Karlsson, M. Werner, 
 *                         Martin Skold, Tore Risch EDSLAB, UDBL
 * $RCSfile: a_time.c,v $
 * $Revision: 1.32 $ $Date: 2014/01/15 15:30:57 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Time related lisp functions and data types.
 * ===========================================================================
 * $Log: a_time.c,v $
 * Revision 1.32  2014/01/15 15:30:57  andan342
 * Solved year 2038 problem, added timezone information to be stored together with TIMEVAL
 * Added lisp functions DATE-TO-TIMEVALZ, TIMEVALZ-TO-DATE, TIMEVAL-TIMEZONE, GET-TIMEZONE, GET-TZ-RESERVED
 * Functions DATE-TO-TIMEVAL and TIMEVAL-TO-DATE are unchanged, as well as amos stringify()
 * Constructor MKTIMEVAL not takes up to 4 arguments
 * TIMEVAL objects are now printed as #[T <sec> <usec> <epoch> tz>], the lisp reader also accepts the old format #[T <sec> <usec>]
 *
 * Added C interface functions timeval_timezone() and make_timevalz()
 *
 * Revision 1.31  2013/06/26 17:45:28  torer
 * Reverting (CO-SLEEP)
 *
 * Revision 1.29  2013/05/17 14:27:54  torer
 * Added CSV report time stamps
 *
 * Revision 1.28  2013/05/17 06:53:07  torer
 * C interface to systime package.
 * Changed name of SET-ENTER-SYSTIME to SET-SYSTIME
 *
 * Revision 1.27  2013/05/16 20:02:13  torer
 * Propagation of enter systen times for events added
 *
 * Revision 1.26  2013/03/11 19:15:16  torer
 * rnow() is now foreign function in C
 *
 * Revision 1.25  2013/02/16 17:38:41  torer
 * Unnchecked argument in TIMEVAL-ADD-DURATION
 *
 * Revision 1.24  2013/02/08 17:41:01  torer
 * Coercion to integers in mktimeval
 *
 * Revision 1.23  2012/12/21 12:03:17  torer
 * OS independence
 *
 * Revision 1.22  2012/12/18 16:46:46  andan342
 * Added timeval_to_vector() external API function
 *
 * Revision 1.21  2012/12/14 23:59:33  andan342
 * Exporting complece C interface for TIMEVAL objects
 *
 * Revision 1.20  2012/12/13 17:08:15  andan342
 * Exporting *TYPE values and interfaces for time and RDF storage objects
 *
 * Revision 1.19  2011/04/11 21:12:55  torer
 * exporting timeval_add_durationfn
 *
 * Revision 1.18  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.17  2010/12/26 17:08:37  torer
 * Removed C warnings
 *
 * Revision 1.16  2009/08/20 18:54:37  torer
 * *** empty log message ***
 *
 * Revision 1.15  2009/08/20 18:36:32  fred2431
 * Remove duplicate definition of a_sleep on Unix system.
 *
 * Revision 1.14  2009/08/14 18:20:50  torer
 * Argument check in SPIN
 *
 * Revision 1.13  2009/08/14 18:02:39  torer
 * a_sleep to a_time.c
 *
 * Revision 1.12  2009/07/28 10:34:19  zeitler
 * spin sleep
 *
 * Revision 1.11  2008/04/17 22:18:35  zeitler
 * (rnow) returns (real (now))
 *
 * Revision 1.10  2007/10/18 12:27:55  torer
 * Fixed size timestamps (NOW)
 *
 * Revision 1.9  2007/09/02 10:35:13  torer
 * Temporal comparison uniform with rest of system
 *
 * Revision 1.8  2007/04/09 13:24:04  torer
 * dealloc_time used old C convention
 *
 * Revision 1.7  2007/02/26 18:52:17  torer
 * Type tag for TIMEVAL changed to T and reader implemented in C to save time and space
 *
 * Revision 1.6  2006/10/21 13:54:29  torer
 * (trace-packets t) now gives time stamped socket communication logging
 *
 * Revision 1.5  2006/10/19 14:42:26  zeitler
 * Changed floor() to a_round()
 *
 * Revision 1.4  2006/10/16 13:07:12  torer
 * a_round(x) introduced since round(x) does not exist under Windows C
 *
 * Revision 1.3  2006/10/11 08:11:42  zeitler
 * add_duration2 added
 *
 * Revision 1.2  2006/10/10 16:16:21  zeitler
 * oidtype timeval_add_durationfn(
 *   bindtype env, oidtype starttime, oidtype duration)
 * add a (float seconds) duration to a time val
 *
 * Revision 1.1  2006/10/03 17:03:38  torer
 * a_time.c to CVS
 *
 ****************************************************************************/

//#define DEBUGFLG

#include <time.h>
#include "intstorage.h"
#include "a_time.h"
#include "systime.h"

EXTERN double a_round(double x);
EXPORT unsigned short int TIMEVALTYPE;
EXPORT unsigned short int TIMETYPE;
EXPORT unsigned short int TIMEINTERVALTYPE;
EXPORT unsigned short int DATETYPE;

struct timeval a_enter_systime, a_this_systime;

int illegal_date, illegal_timeval, unsupported_timeval, negative_time;

oidtype deep_print, zero;
oidtype bothclosedtag, leftclosedtag, rightclosedtag, bothopentag;

oidtype get_timezonefn(bindtype env)
{
	return mkinteger(timezone);
}

oidtype get_tz_reservedfn(bindtype env)
{
	return mkinteger(TZ_RESERVED);
}

/*********************************
 * new_timeval
 * ===========
 * Allocation function for TIMEVALs.
 *
 */
EXPORT oidtype new_timeval(unsigned long seconds, long useconds)
{ 
  oidtype timevalobject;
  struct timevalcell *dtimevalobject;

  inittype2(TIMEVALTYPE, timevalobject, dtimevalobject, timevalcell);
  dtimevalobject->tv.tv_sec = seconds;
  dtimevalobject->tv.tv_usec = useconds;
	dtimevalobject->epoch = 0; //AA: use current epoch
	dtimevalobject->timezone = timezone; //AA: store local timezone
  return timevalobject;
}

EXPORT oidtype new_timeval_ez(unsigned long seconds, long useconds, int epoch, int tz) //AA
{ //create TIMEVAL object storing UTC seconds, epoch and timezone
	oidtype res = new_timeval(seconds, useconds);
	struct timevalcell *dres = dr(res, timevalcell);

	dres->epoch = epoch;
	dres->timezone = tz;
	return res;
}

/*********************************
 * dealloc_timeval
 * ===============
 * Deallocation function for timevals.
 *
 */
void dealloc_timeval(oidtype x)
{
  struct timevalcell *dx = dr(x,timevalcell);

  free1(x, dx);
}

/*********************************
 * compare_timeval
 * =============
 * Compare function for timevals. Two timevals are equal if both tv_sec and
 * tv_usec are equal in both timevals.
 *
 */

int timevalcell_normalize(const struct timevalcell *tvc, time_t *sec) //AA
{ // Normalize UTC seconds within the canonical range (e.g. translating to years 70..137 in local timezone)
	struct tm *date;	
	int epoch;

	*sec = tvc->tv.tv_sec ;
	epoch = tvc->epoch;

	date = localtime(sec);
	if (date->tm_year < (EPOCH0 - CENTURY)) { // <70
		date->tm_year += EPOCH_LENGTH;
		epoch --;
		*sec = mktime(date);
	}
	else if (date->tm_year >= (EPOCH0 - CENTURY + EPOCH_LENGTH)) { //>= 138
		date->tm_year -= EPOCH_LENGTH;
		epoch ++;
		*sec = mktime(date);
	}
	return epoch;
}

int compare_timeval(oidtype to1, oidtype to2) //AA: changed to account for epochs and timezones
{ 
	time_t sec1, sec2;
	int epoch1 = timevalcell_normalize(dr(to1, timevalcell), &sec1),
		  epoch2 = timevalcell_normalize(dr(to2, timevalcell), &sec2);
  int cmp = COMPARE(epoch1, epoch2);
	if (!cmp) cmp = COMPARE(sec1, sec2); //compare UTC time
	if (!cmp) cmp = COMPARE(gettimeval(to1).tv_usec, gettimeval(to2).tv_usec);
	return cmp;
}

/*********************************
 * hash_timeval
 * ============
 * Hash function for timevals. Return the second part of a timeval.
 *
 */
unsigned int hash_timeval(oidtype to)
{
  return (unsigned int)gettimeval(to).tv_sec;
}

/*********************************
 * timeval_printfn
 * ============
 * Print function for timevals.
 *
 */
void timeval_printfn(oidtype pobj, oidtype stream, int princflg)
{
//	struct timevalcell *dobj = dr(pobj, timevalcell);
  if (stream == nil) stream = stdoutstream;
  a_puts("#[T ", stream);
  a_puts(IntegerToString(gettimeval(pobj).tv_sec),stream);
  a_putc(' ', stream);
  a_puts(IntegerToString(gettimeval(pobj).tv_usec),stream);
	a_putc(' ', stream);
  a_puts(IntegerToString(dr(pobj, timevalcell)->epoch),stream);
	a_putc(' ', stream);
  a_puts(IntegerToString(dr(pobj, timevalcell)->timezone),stream);
  a_putc(']', stream);
}

void gettimevalofday(struct timeval *res)
{
#ifdef UNIX
  struct timezone tzp; /* Not used */
  gettimeofday(res, &tzp);
#else
  struct timeb tm;
  ftime(&tm);
  res->tv_sec=tm.time;
  res->tv_usec=1000*tm.millitm;
#endif
}

void a_set_systime(void)
     /** Set the enter system time of leaf process to current time **/
{
  gettimevalofday(&a_this_systime);
  a_enter_systime = a_this_systime;
}

void a_clear_systime(void)
{
  a_enter_systime.tv_sec = 0;
  a_enter_systime.tv_usec = 0;
  a_this_systime = a_enter_systime;
}

int a_systimep(void)
{
  return ((a_enter_systime.tv_sec!=0) | (a_enter_systime.tv_usec!=0));
}

void read_entersystime(oidtype stream)
     /** Read a propagated enter system time from stream **/
{
  struct timeval tv;

  a_readbytes(stream, &tv, sizeof(tv));
  if((unsigned int)tv.tv_sec>(unsigned int)a_enter_systime.tv_sec  ||
     ((unsigned int)tv.tv_sec==(unsigned int)a_enter_systime.tv_sec &&
      (unsigned int)tv.tv_usec>(unsigned int)a_enter_systime.tv_usec))
    {
       gettimevalofday(&a_this_systime);
       a_enter_systime = tv;
    }
}

void print_entersystime(oidtype stream)
     /** Print enter system time into stream **/
{
  a_puts("#t ", stream);
  if(a_enter_systime.tv_sec==0 && a_enter_systime.tv_usec==0) // leaf process
    {
      struct timeval tv;
      
      gettimevalofday(&tv);
      a_writebytes(stream,&tv,sizeof(tv));
    }
  else a_writebytes(stream,&a_enter_systime,sizeof(a_enter_systime));
}

oidtype enter_systimefn(bindtype env)
     /** Get the current enter system times **/
{
  if(a_enter_systime.tv_sec==0 && a_enter_systime.tv_usec==0) return nil;
  return new_timeval(a_enter_systime.tv_sec, a_enter_systime.tv_usec);
}

oidtype set_systimefn(bindtype env, oidtype to)
{
  if(to == t) // set to now
    a_set_systime();
  else if(to == nil) // unset
    a_clear_systime();
  else
    {
      OfType(to, TIMEVALTYPE, env);
      a_enter_systime = gettimeval(to);
      a_this_systime = a_enter_systime;
    }
  return new_timeval(a_enter_systime.tv_sec, a_enter_systime.tv_usec);
}

oidtype this_systimefn(bindtype env)
     /** Get the time when last enter system time was set **/ 
{
  if(a_this_systime.tv_sec==0 && a_this_systime.tv_usec==0) return nil;
  return new_timeval(a_this_systime.tv_sec, a_this_systime.tv_usec);
}

/*********************************
 * mktimevalfn
 * =========
 * Given two integers SEC and USEC, constructs a timeval.
 *
 */
oidtype mktimevalfn(bindtype env, oidtype sec, oidtype usec, oidtype epoch, oidtype tz)
{
  unsigned int dsec, dusec, depoch, dtz;

  IntoInteger(sec, dsec, env);
  IntoInteger(usec, dusec, env);
	if (epoch == nil) depoch = 0;
	else IntoInteger(epoch, depoch, env);
	if (tz == nil) dtz = timezone; // use current timezone as default
	else IntoInteger(tz, dtz, env);
  return new_timeval_ez(dsec, dusec, depoch, dtz);
}

/*********************************
 * timeval_readfn
 * ============
 * Read function for timevals.
 *
 */
oidtype timeval_readfn(bindtype env, oidtype tag, oidtype descr, oidtype str)
{
	oidtype sec = hd(descr),
		      usec = hd(tl(descr)),
					cddr = tl(tl(descr));

	if (cddr != nil) 
		return mktimevalfn(env, sec, usec, hd(cddr), hd(tl(cddr)));
	else
		return mktimevalfn(env, sec, usec, nil, nil);
}

/*********************************
 * timevalpfn
 * ==========
 * Returns T if TV is a timeval, otherwise NIL is returned.
 * 
 */
oidtype timevalpfn(bindtype env, oidtype tv)
{
  if (timevalp(tv)) return t;
  else return nil;
}

/*********************************
 * timeval_secfn
 * =============
 * Given a timeval T, returns an integer representing the number of seconds.
 *
 */
oidtype timeval_secfn(bindtype env, oidtype tm)
{
  OfType(tm, TIMEVALTYPE, env);
  return mkinteger(gettimeval(tm).tv_sec);
}

/*********************************
 * timeval_usecfn
 * ==============
 * Given a timeval T, returns an integer representing the number of micro
 * seconds.
 *
 */
oidtype timeval_usecfn(bindtype env, oidtype tm)
{
  OfType(tm, TIMEVALTYPE, env);
  return mkinteger(gettimeval(tm).tv_usec);
}


EXPORT int timeval_timezone(oidtype tv) //AA
{
	return dr(tv, timevalcell)->timezone; 
}

oidtype timeval_timezonefn(bindtype env, oidtype tv) //AA
{  //ALisp: get timeval's timezone: seconds west of GMT
	OfType(tv, TIMEVALTYPE, env);
	return mkinteger(timeval_timezone(tv)); 
}

/*********************************
 * add_duration
 * ==============
 * Add a duration in seconds to timeval starttime. Return a new timeval.
 *
 */

EXPORT oidtype timeval_add_durationfn(bindtype env, oidtype starttime,
			       oidtype duration) {
  struct timeval st=gettimeval(starttime);
  struct timeval rt;
  double d;

  IntoDouble(duration, d, env);
  add_duration(&rt, &st, d);
  return new_timeval(rt.tv_sec, rt.tv_usec);
}

EXPORT void add_duration(struct timeval* rt, const struct timeval* st, 
			 double d) 
{
  rt->tv_sec  = (unsigned long)floor(d);
  rt->tv_usec = (unsigned long)a_round((d-rt->tv_sec)*1000000.);
  if ((rt->tv_usec += st->tv_usec) >= 1000000) {
    rt->tv_usec -= 1000000;
    rt->tv_sec += st->tv_sec + 1;
  } else {
    rt->tv_sec += st->tv_sec;
  }
}

/*********************************
 * add_duration2
 * ==============
 * Destructively add a duration in seconds to timeval starttime.
 *
 */
EXPORT void add_duration2(struct timeval* rt, double d) {
  unsigned long sec  = (unsigned long)floor(d);
  unsigned long usec = (unsigned long)a_round((d-sec)*1000000.);
  if((rt->tv_usec += usec) >= 1000000) {
    rt->tv_usec -= 1000000;
    rt->tv_sec += sec +1;
  } else {
    rt->tv_sec += sec;
  }
}


/*********************************
 * timeval_lessfn
 * ==============
 * Given two timevals T1 and T2, returns T if T1<T2, NIL otherwise.
 *
 */
oidtype timeval_lessfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, TIMEVALTYPE, env);
  OfType(t2, TIMEVALTYPE, env);
  if(compare_timeval(t1,t2)<0) return t;
  return nil;
}

/*********************************
 * timeval_greaterfn
 * =================
 * Given two timevals T1 and T2, returns T if T1>T2, NIL otherwise.
 *
 */
oidtype timeval_greaterfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, TIMEVALTYPE, env);
  OfType(t2, TIMEVALTYPE, env);
  if(compare_timeval(t1,t2)>0) return t;
  return nil;
}

/*********************************
 * gettimeofdayfn
 * ==============
 * Returns a timeval constructed from a system call to gettimeofday. Useful
 * for constructing time stamps.
 *
 */

oidtype gettimeofdayfn(bindtype env)
{
  oidtype tv;

  tv = mktimeval(0,0);
  gettimevalofday(&(gettimeval(tv)));
	dr(tv, timevalcell)->timezone = timezone; //AA

  return tv;
}

EXPORT double run_time(void)
{
  static int firstcall=TRUE;
  static struct timeval start_time;
  struct timeval now;

  if(firstcall)
    {
      gettimevalofday(&start_time);
      firstcall=FALSE;
    }
  gettimevalofday(&now);
  return (now.tv_sec - start_time.tv_sec+
	  (now.tv_usec - start_time.tv_usec)/1000000.);
}

oidtype clockfn(bindtype env)
{
  return mkreal(run_time());
}

char *a_now(void)
{
   struct timeval now;
   struct tm *date;
   static char nowstring[40];

   gettimevalofday(&now);
   date = localtime(&now.tv_sec);
   sprintf(nowstring,"%d-%02d-%02d %02d:%02d:%02d.%03d",date->tm_year+1900,
           date->tm_mon+1, date->tm_mday, date->tm_hour, date->tm_min,
           date->tm_sec, now.tv_usec/1000);
   return nowstring;
}

oidtype nowfn(bindtype env)
{
   return mkstring(a_now());
}

EXPORT double rnow() 
{
  struct timeval now;
  gettimevalofday(&now);
  return now.tv_sec + now.tv_usec/1000000.;
}

oidtype rnowfn(bindtype env) 
{
  return mkreal(rnow());
}

#ifdef UNIX
void a_sleep(double s)
{
#include <unistd.h>

  usleep(s*1000000);
}
#else
#include <windows.h>
void a_sleep(double s)
{
  DWORD ms;
  if(s>1.0)
    {
      double fs = floor(s);
      int is, i;

      is = (int)fs;
      s = s - is;
      for(i=0;i<is;i++)
	{
	  Sleep(1000);
	  CheckInterrupt;
	}
    }
  ms = (DWORD)(s * 1000);
  Sleep(ms);
}
#endif

void spinsleep(double s) {
  int i, dummy=0, periods = 0;
  double start, end;
  start = rnow();
  end = start + s;

  while (rnow() < end) {
    periods++;
    for (i = 0; i < 1000; i++) {
      dummy += i;
    }
  }
#ifdef DEBUGFLG
  printf("spun %f seconds, %d periods\n", rnow() - start, periods);
#endif
}

oidtype spinfn(bindtype env, oidtype s) 
{
  double sl = coerce_real(env,s);

  spinsleep(sl);
  return nil;
}


/*********************************
 * timeval_to_datefn
 * ==============
 * Translates a timeval into a date
 *
 */

EXPORT oidtype timeval_to_vector(oidtype tv, oidtype tz)
{ //if TZ is T, apply stored timezone, if TZ is integer apply timezone specified by it, otherwise apply local timezone
  time_t tm;
  struct tm *date;
	struct timevalcell *dtv = dr(tv, timevalcell);
#ifdef NT
  extern int _daylight;
#endif  
	tm = dtv->tv.tv_sec; //AA: adjust to the specified timezone
	if (tz == t) 
		tm += timezone - ((dtv->timezone == TZ_RESERVED)? 0 : dtv->timezone); //if TZ_RESERVED timezone stored, assume UTC timezone
	else if (a_datatype(tz) == INTEGERTYPE) 
		tm += timezone - getinteger(tz);
#ifdef NT
  _daylight = 0;
#endif
  date = localtime(&tm); 
  if(date == NULL) return nil;
  return(a_vector(mkinteger(date->tm_year + CENTURY + EPOCH_LENGTH * dtv->epoch), /* year */  //AA
		  mkinteger(date->tm_mon + 1), /* month in year */
		  mkinteger(date->tm_mday),    /* day in month */
		  mkinteger(date->tm_hour),    /* hour in day */
		  mkinteger(date->tm_min),     /* min in hour */
		  mkinteger(date->tm_sec),     /* sec in min */
		  mkinteger(dtv->tv.tv_usec), /* usec in sec */
		  NULLH));
}

oidtype timevalz_to_datefn(bindtype env, oidtype tv, oidtype tz)
{	
	oidtype res;

	OfType(tv, TIMEVALTYPE, env);	
	res = timeval_to_vector(tv, tz);
	if (res==nil) return lerror(illegal_date,tv,env);
	return res;
}

oidtype timeval_to_datefn(bindtype env, oidtype tv)
{
	return timevalz_to_datefn(env, tv, nil);
}

//AA: C API to create timeval - code moved from date_to_timevalfn

time_t make_time_t(int year, int month, int day, int hour, int minute, int second) //AA
{ //return UTC seconds since the beginning of an epoch in local timezone
  struct tm *date;
  time_t res;	

  date = (struct tm *)mymalloc(sizeof(*date));
  /* malloc structure and set timezone fields */
  memset(date,0,sizeof(*date));	  
	date->tm_year = (year - EPOCH0) % EPOCH_LENGTH; // year in [-67..67]
	if (date->tm_year < 0) date->tm_year += EPOCH_LENGTH; // year in [0..67]
	date->tm_year += EPOCH0 - CENTURY; // year in [70..137]
  date->tm_mon = month - 1;
  date->tm_mday = day;
  date->tm_hour = hour;
  date->tm_min = minute;
  date->tm_sec = second;
  res = mktime(date);
  free(date); //TEST: this was only under NT!
  return res;
}


EXPORT oidtype make_timevalz(int year, int month, int day, int hour, int minute, int second, int usec, int tz) //AA
{ //make TIMEVAL object storing UTC seconds since the beginning of an epoch in given timezone, together with epoch and timezone
	//store TZ_RESERVED timezone if specified, but assume UTC timezone for computing UTC seconds
	time_t tm = make_time_t(year, month, day, hour, minute, second); // count UTC corresponding to the date in local timezone
	int epoch = (year - EPOCH0) / EPOCH_LENGTH;	  
	if (year < EPOCH0) epoch -= 1;
  return new_timeval_ez((int) tm + ((tz == TZ_RESERVED)? 0 : tz) - timezone, usec, epoch, tz); //TODO: wrap the correction across epochs!
}

EXPORT oidtype make_timeval(int year, int month, int day, int hour, int minute, int second, int usec) //AA
{ //store global variable 'timezone', since local-to-UTC converssion is used in mktime()
	return make_timevalz(year, month, day, hour, minute, second, usec, timezone); 
}

/*********************************
 * date_to_timevalfn
 * ==============
 * Translates a date to timeval
 *
 */

oidtype date_to_timevalzfn(bindtype env, oidtype dt, oidtype tz) //AA: renamed from date_to_timevalfn
{
  oidtype year;
  oidtype month;
  oidtype dayint;
  oidtype hour;
  oidtype min;
  oidtype sec;
  oidtype usec;
//  time_t tm;
	int dtz; //AA

  OfType(dt, ARRAYTYPE, env);
  if (a_arraysize(dt) != 7)
    return a_error(illegal_date, dt, FALSE);
  year = a_elt(dt, 0);
  month = a_elt(dt, 1);
  dayint = a_elt(dt, 2);
  hour = a_elt(dt, 3);
  min = a_elt(dt, 4);
  sec = a_elt(dt, 5);
  usec = a_elt(dt, 6);
  OfType(year, INTEGERTYPE, env);
  OfType(month, INTEGERTYPE, env);
  OfType(dayint, INTEGERTYPE, env);
  OfType(hour, INTEGERTYPE, env);
  OfType(min, INTEGERTYPE, env);
  OfType(sec, INTEGERTYPE, env);
  OfType(usec, INTEGERTYPE, env);
	if (tz == nil) dtz = timezone; //AA: use current timezone if timezone is not specified (makes the call location-dependent!)
	else {
		OfType(tz, INTEGERTYPE, env);
		dtz = getinteger(tz);
	};

	return make_timevalz(getinteger(year), getinteger(month), getinteger(dayint), getinteger(hour), getinteger(min), getinteger(sec), getinteger(usec), dtz ); //AA
/*  tm = make_time_t(dyear, getinteger(month), getinteger(dayint), 
                   getinteger(hour), getinteger(min), getinteger(sec));
#ifdef NT
  if(tm < 0) return lerror(illegal_date,dt,env);
#endif	
  return mktimeval((int) tm, getinteger(usec)); */
}


oidtype date_to_timevalfn(bindtype env, oidtype dt) //AA
{
	return date_to_timevalzfn(env, dt, nil);
}

/*************** timeinterval functions ***************/

/*********************************
 * alloc_timeintervalfn
 * ===============
 * Allocation function for time intervals
 *
 */
oidtype alloc_timeintervalfn(struct timeval start, struct timeval stop,
                             int type)
{
  int len;
  struct timeintervalcell *dtiobject;
  oidtype timeintervalobject;

  len = sizeof(*dtiobject);
  inittypen(TIMEINTERVALTYPE, timeintervalobject, dtiobject,
	    len, timeintervalcell);
  gettimeintervallen(timeintervalobject) = (unsigned short int) len;
  gettimeintervaltype(timeintervalobject) = type;
  gettimeintervalstart(timeintervalobject) = start;
  gettimeintervalstop(timeintervalobject) = stop;
  return timeintervalobject;
};

/*********************************
 * dealloc_timeintervalfn
 * ===============
 * Deallocation function for time intervals
 *
 */
void dealloc_timeintervalfn(oidtype x)
{
  freebytes(x, sizeof(struct timeintervalcell));
  return;
}

/*********************************
 * timeintervalpfn
 * ==========
 * Returns T if TV is a timeinterval, otherwise NIL is returned.
 *
 */
oidtype timeintervalpfn(bindtype env, oidtype ti)
{
  if (timeintervalp(ti)) return t;
  else return nil;
}

/*********************************
 * equal_timeinterval
 * =============
 * Equal function for timevals. Two timevals are equal they are
 * of the same type and if both tv_sec and
 * tv_usec are equal in both ends of the interval.
 *
 */
int equal_timeinterval(oidtype ti1, oidtype ti2)
{
  return((gettimeintervaltype(ti1) == gettimeintervaltype(ti2)) &&

	 ((((gettimeintervalstart(ti1).tv_sec) ==
            (gettimeintervalstart(ti2).tv_sec)) &&
	   ((gettimeintervalstart(ti1).tv_usec) ==
            (gettimeintervalstart(ti2).tv_usec)))
	  &&
	  (((gettimeintervalstop(ti1).tv_sec) ==
            (gettimeintervalstop(ti2).tv_sec)) &&
	   ((gettimeintervalstop(ti1).tv_usec) ==
            (gettimeintervalstop(ti2).tv_usec)))));
}

/*********************************
 * hash_timeinterval
 * ============
 * Hash function for timeintervals. Return the second part of a start timeval.
 *
 */
unsigned int hash_timeinterval(oidtype ti)
{
  return((unsigned int)(gettimeintervalstart(ti).tv_sec));
}

/*********************************
 * timeintervaltypefn
 * ==========
 * Returns type of interval as symbol
 *
 */
oidtype timeintervaltypefn(bindtype env, oidtype ti)
{
  switch (gettimeintervaltype(ti)) {
  case BOTH_CLOSED: {
    return bothclosedtag;
  }
  case LEFT_CLOSED: {
    return leftclosedtag;
  }
  case RIGHT_CLOSED: {
    return rightclosedtag;
  }
  case BOTH_OPEN: {
    return bothopentag;
  }
  }
  return nil;
}

/*********************************
 * timeintervalstartfn
 * ==========
 * Returns start timeval of interval
 *
 */
oidtype timeintervalstartfn(bindtype env, oidtype ti)
{
  oidtype res;

  res =  mktimeval(gettimeintervalstart(ti).tv_sec,
		   gettimeintervalstart(ti).tv_usec);
  return res;
}

/*********************************
 * timeintervalstopfn
 * ==========
 * Returns sttop timeval of interval
 *
 */
oidtype timeintervalstopfn(bindtype env, oidtype ti)
{
  oidtype res;

  res = mktimeval(gettimeintervalstop(ti).tv_sec,
		  gettimeintervalstop(ti).tv_usec);
  return res;
}

/*********************************
 * timeinterval_print
 * ===============
 * Print function for timeintervals
 *
 */
void timeinterval_print(oidtype tint, oidtype stream, int princflg)
{
  if (stream == nil) stream=stdoutstream;
  if (globval(deep_print) == nil)
    {
      a_puts("#[TIMEINTERVAL ", stream);
      a_puts(IntegerToString(tint),stream);  /* print image address */
      a_puts("]", stream);
    }
  else
    { /* used for writing on the log */
      /* dummy code for now */
      oidtype itype;
      oidtype start;
      oidtype stop;

      start = timeintervalstartfn(varstack, tint);
      stop = timeintervalstopfn(varstack, tint);
      itype = timeintervaltypefn(varstack, tint);
      a_puts("#[TIMEINTERVAL ", stream);
      prin1fn(varstack, start, stream); /* print start timeval */
      a_putc(' ', stream);
      prin1fn(varstack, stop, stream); /* print stop timeval */
      a_putc(' ', stream);
      prin1fn(varstack, itype, stream); /* print interval type */
      a_puts("]", stream);
    }
}

/*********************************
 * mktimeintervalfn
 * ===============
 * Top function for creating time intervals
 *
 */
oidtype mktimeintervalfn(bindtype env, oidtype start, oidtype stop,
                         oidtype type)
{
  oidtype tint;
  int itype;

  if (!(timevalp(start))) a_error(illegal_timeval, start, FALSE);
  if (!(timevalp(stop))) a_error(illegal_timeval, stop, FALSE);
  OfType(type, SYMBOLTYPE, env);
  if (equal(type, bothclosedtag)) itype = BOTH_CLOSED;
  else if (equal(type, leftclosedtag)) itype = LEFT_CLOSED;
  else if (equal(type, rightclosedtag)) itype = RIGHT_CLOSED;
  else if (equal(type, bothopentag)) itype = BOTH_OPEN;
  else if (equal(type, nil)) itype = BOTH_CLOSED;
  else a_error(unsupported_timeval, type, FALSE);
  tint = alloc_timeintervalfn(gettimeval(start), gettimeval(stop), itype);
  return tint;
}

/*********************************
 * new_time
 * ===========
 * Allocation function for TIMEs.
 *
 */
oidtype new_time(int hour, int minute, int second)
{
  oidtype timeobject;
  struct timecell *dtimeobject;

  inittype2(TIMETYPE, timeobject, dtimeobject, timecell);
  dtimeobject->hour = hour;
  dtimeobject->minute = minute;
  dtimeobject->second = second;

  return timeobject;
}

/*********************************
 * dealloc_time
 * ===============
 * Deallocation function for times.
 *
 */
void dealloc_time(oidtype x)
{
  struct timecell *dx = dr(x,timecell);

  free2(x, dx);
}

/*********************************
 * compare_time
 * =============
 * Compare function for times. Two times are equal if hour, minute, and
 * second are equal in both times.
 *
 */
int compare_time(oidtype to1, oidtype to2)
{
  int cmp;

  cmp = COMPARE(gethour(to1),gethour(to2));
  if(cmp) return cmp;
  cmp = COMPARE(getminute(to1),getminute(to2));
  if(cmp) return cmp;
  return COMPARE(getsecond(to1),getsecond(to2));
}

/*********************************
 * hash_time
 * ============
 * Hash function for times. Return the number of seconds since midnight
 *
 */
unsigned int hash_time(oidtype to)
{
  return((unsigned int)(gethour(to)*360+getminute(to)*60+getsecond(to)));
}

/*********************************
 * time_printfn
 * ============
 * Print function for times.
 *
 */
void time_printfn(oidtype pobj, oidtype stream, int princflg)
{
  oidtype tmp=nil;
  oidtype print_stream;

  if (stream == nil) print_stream = stdoutstream;
  else print_stream = stream;

  a_puts("#[TIME ", print_stream);
  a_setf(tmp, mkinteger(gethour(pobj)));
  a_prin1(tmp, print_stream, TRUE);
  a_puts(" ", print_stream);
  a_setf(tmp, mkinteger(getminute(pobj)));
  a_prin1(tmp, print_stream, TRUE);
  a_puts(" ", print_stream);
  a_setf(tmp, mkinteger(getsecond(pobj)));
  a_prin1(tmp, print_stream, TRUE);
  a_puts("]", print_stream);
  released(tmp);
}

/*********************************
 * mktimefn
 * =========
 * Given three integers hour, minute, and second, constructs a time.
 *
 */
oidtype mktimefn(bindtype env, oidtype hour, oidtype minute, oidtype second)
{
  int h, m, s;

  OfType(hour, INTEGERTYPE, env);
  OfType(minute, INTEGERTYPE, env);
  OfType(second, INTEGERTYPE, env);
  h = getinteger(hour);
  m = getinteger(minute);
  s = getinteger(second);
  if ((h < 0) || (m < 0) || (s < 0))
    a_error(negative_time, a_list(hour, minute, second, NULL), FALSE);
  if (s >= 60) {
    m = m + (s / 60);
    s = s % 60;
  };
  if (m >= 60) {
    h = h + (m / 60);
    m = m % 60;
  };
  return mktime3(h, m, s);
}

/*********************************
 * timepfn
 * ==========
 * Returns T if to is a time, otherwise NIL is returned.
 *
 */
oidtype timepfn(bindtype env, oidtype to)
{
  if (timep(to))return t;
  else return nil;
}

/*********************************
 * time_hourfn
 * =============
 * Given a time to, returns an integer representing the number of hours
 *
 */
oidtype time_hourfn(bindtype env, oidtype to)
{
  OfType(to, TIMETYPE, env);

  return mkinteger(gethour(to));
}

/*********************************
 * time_minutefn
 * =============
 * Given a time to, returns an integer representing the number of minutes
 *
 */
oidtype time_minutefn(bindtype env, oidtype to)
{
  OfType(to, TIMETYPE, env);

  return mkinteger(getminute(to));
}

/*********************************
 * time_secondfn
 * =============
 * Given a time to, returns an integer representing the number of seconds.
 *
 */
oidtype time_secondfn(bindtype env, oidtype to)
{
  OfType(to, TIMETYPE, env);

  return mkinteger(getsecond(to));
}

/*********************************
 * time_lessfn
 * ==============
 * Given two times T1 and T2, returns T if T1<T2, NIL otherwise.
 *
 */
oidtype time_lessfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, TIMETYPE, env);
  OfType(t2, TIMETYPE, env);
  if(compare_time(t1,t2)<0) return t;
  return nil;
}

/*********************************
 * time_greaterfn
 * =================
 * Given two times T1 and T2, returns T if T1>T2, NIL otherwise.
 *
 */
oidtype time_greaterfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, TIMETYPE, env);
  OfType(t2, TIMETYPE, env);
  if(compare_time(t1,t2)>0) return t;
  return nil;
}

/*********************************
 * new_date
 * ===========
 * Allocation function for DATEs.
 *
 */
oidtype new_date(int year, int month, int day)
{
  oidtype dateobject;
  struct datecell *ddateobject;

  inittype2(DATETYPE, dateobject, ddateobject, datecell);
  ddateobject->year = year;
  ddateobject->month = month;
  ddateobject->day = day;

  return dateobject;
}

/*********************************
 * dealloc_date
 * ===============
 * Deallocation function for dates.
 *
 */
void dealloc_date(oidtype x)
{
  struct datecell *dx = dr(x,datecell);

  free2(x, dx);
}

/*********************************
 * compare_date
 * =============
 * Compare function for dates. Two dates are equal if year, month, and
 * day are equal in both dates.
 *
 */
int compare_date(oidtype to1, oidtype to2)
{
  int cmp;

  cmp = COMPARE(getyear(to1),getyear(to2));
  if(cmp)return cmp;
  cmp = COMPARE(getmonth(to1),getmonth(to2));
  if(cmp) return cmp;
  return COMPARE(getday(to1),getday(to2));
}

/*********************************
 * hash_date
 * ============
 * Hash function for dates. Return the number of approx. days since
 * beginning of time
 *
 */
unsigned int hash_date(oidtype to)
{
  return((unsigned int)(getyear(to)*365+getmonth(to)*30+getday(to)));
}

/*********************************
 * date_printfn
 * ============
 * Print function for dates.
 *
 */
void date_printfn(oidtype pobj, oidtype stream, int princflg)
{
  oidtype print_stream;

  if (stream == nil) print_stream = stdoutstream;
  else print_stream = stream;
  a_puts("#[DATE ", print_stream);
  a_puts(IntegerToString(getyear(pobj)), print_stream);
  a_puts(" ", print_stream);
  a_puts(IntegerToString(getmonth(pobj)), print_stream);
  a_puts(" ", print_stream);
  a_puts(IntegerToString(getday(pobj)), print_stream);
  a_puts("]", print_stream);
}

/*********************************
 * mkdatefn
 * =========
 * Given three integers year, month, and day, constructs a date.
 *
 */
oidtype mkdatefn(bindtype env, oidtype year, oidtype month, oidtype day)
{
  int yi, mi, di;
  dcloid(tv);
  dcloid(dt);
  dcloid(v);
  oidtype yobj, mobj, dobj;
  unwind_protect_begin;

  OfType(year, INTEGERTYPE, env);
  OfType(month, INTEGERTYPE, env);
  OfType(day, INTEGERTYPE, env);

  a_setf(v, a_vector(year, month, day, zero, zero, zero, zero, NULL));
  a_setf(tv, date_to_timevalfn(env, v));
  a_setf(dt, timeval_to_datefn(env, tv));
  yobj = a_elt(dt, 0);
  mobj = a_elt(dt, 1);
  dobj = a_elt(dt, 2);
  yi = getinteger(yobj);
  mi = getinteger(mobj);
  di = getinteger(dobj);
  unwind_protect_catch;
  released(v);
  released(tv);
  released(dt);
  unwind_protect_end;
  return mkdate(yi, mi, di);
}

/*********************************
 * datepfn
 * ==========
 * Returns T if to is a date, otherwise NIL is returned.
 *
 */
oidtype datepfn(bindtype env, oidtype to)
{
  if (datep(to))return t;
  else return nil;
}

/*********************************
 * date_yearfn
 * =============
 * Given a date to, returns an integer representing the number of years
 *
 */
oidtype date_yearfn(bindtype env, oidtype to)
{
  OfType(to, DATETYPE, env);

  return mkinteger(getyear(to));
}

/*********************************
 * date_monthfn
 * =============
 * Given a date to, returns an integer representing the number of months
 *
 */
oidtype date_monthfn(bindtype env, oidtype to)
{
  OfType(to, DATETYPE, env);

  return mkinteger(getmonth(to));
}

/*********************************
 * date_dayfn
 * =============
 * Given a date to, returns an integer representing the number of days.
 *
 */
oidtype date_dayfn(bindtype env, oidtype to)
{
  OfType(to, DATETYPE, env);

  return mkinteger(getday(to));
}

/*********************************
 * date_lessfn
 * ==============
 * Given two dates T1 and T2, returns T if T1<T2, NIL otherwise.
 *
 */
oidtype date_lessfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, DATETYPE, env);
  OfType(t2, DATETYPE, env);
  if(compare_date(t1,t2)<0) return t;
  return nil;
}

/*********************************
 * date_greaterfn
 * =================
 * Given two dates T1 and T2, returns T if T1>T2, NIL otherwise.
 *
 */
oidtype date_greaterfn(bindtype env, oidtype t1, oidtype t2)
{
  OfType(t1, DATETYPE, env);
  OfType(t2, DATETYPE, env);
  if(compare_date(t1,t2)>0) return t;
  return nil;
}

oidtype sleepfn(bindtype env, oidtype sec)
{
  double s;

  s=coerce_real(env,sec);
  a_sleep(s);
  return sec;
}

/*********************************
 * register_time_fuctions
 * ======================
 * register Lisp functions in Amos II.
 *
 */
void register_time_functions(void)
{
  a_let(zero, mkinteger(0));

  TIMEVALTYPE = a_definetype("TIMEVAL", dealloc_timeval,
			     timeval_printfn);
  typefns[TIMEVALTYPE].comparefn = compare_timeval;
  typefns[TIMEVALTYPE].hashfn = hash_timeval;
  type_reader_function("T", timeval_readfn);
  extfunction4("MKTIMEVAL", mktimevalfn); //AA: changed from extfunction2
  extfunction1("TIMEVALP", timevalpfn);
  extfunction1("TIMEVAL-SEC", timeval_secfn);
  extfunction1("TIMEVAL-USEC", timeval_usecfn);
  extfunction2("TIMEVAL-LESS", timeval_lessfn);
  extfunction2("TIMEVAL-GREATER", timeval_greaterfn);
  extfunction2("TIMEVAL-ADD-DURATION", timeval_add_durationfn);
  extfunction0("GETTIMEOFDAY", gettimeofdayfn);
  extfunction0("CLOCK",clockfn);
  extfunction0("NOW",nowfn);
  extfunction0("RNOW",rnowfn);
  extfunction0("enter-systime", enter_systimefn);
  extfunction1("set-systime", set_systimefn);
  extfunction0("this-systime", this_systimefn);  
  extfunction1("DATE-TO-TIMEVAL", date_to_timevalfn);
	extfunction2("DATE-TO-TIMEVALZ", date_to_timevalzfn); //AA
	extfunction2("TIMEVALZ-TO-DATE", timevalz_to_datefn); //AA
	extfunction1("TIMEVAL-TO-DATE", timeval_to_datefn);
	extfunction1("TIMEVAL-TIMEZONE", timeval_timezonefn); //AA
	extfunction0("get-timezone", get_timezonefn); //AA
	extfunction0("get-tz-reserved", get_tz_reservedfn); //AA

  a_let(bothclosedtag, mksymbol("both-closed"));
  a_let(leftclosedtag, mksymbol("left-closed"));
  a_let(rightclosedtag, mksymbol("right-closed"));
  a_let(bothopentag, mksymbol("both-open"));
  TIMEINTERVALTYPE = a_definetype("TIMEINTERVAL",
				  dealloc_timeintervalfn,
				  timeinterval_print);
  typefns[TIMEINTERVALTYPE].equalfn =  equal_timeinterval;
  typefns[TIMEINTERVALTYPE].hashfn = hash_timeinterval;
  extfunction3("MKTIMEINTERVAL", mktimeintervalfn);
  extfunction1("TIMEINTERVALP", timeintervalpfn);
  extfunction1("TIMEINTERVAL-TYPE", timeintervaltypefn);
  extfunction1("TIMEINTERVAL-START", timeintervalstartfn);
  extfunction1("TIMEINTERVAL-STOP", timeintervalstopfn);

  TIMETYPE = a_definetype("TIME", dealloc_time,time_printfn);
  typefns[TIMETYPE].comparefn =  compare_time;
  typefns[TIMETYPE].hashfn =  hash_time;
  extfunction3("MKTIME", mktimefn);
  extfunction1("TIMEP", timepfn);
  extfunction1("TIME-HOUR", time_hourfn);
  extfunction1("TIME-MINUTE", time_minutefn);
  extfunction1("TIME-SECOND", time_secondfn);
  extfunction2("TIME-LESS", time_lessfn);
  extfunction2("TIME-GREATER", time_greaterfn);
  extfunction1("spin", spinfn);

  DATETYPE = a_definetype("DATE",  dealloc_date, date_printfn);
  typefns[DATETYPE].comparefn =  compare_date;
  typefns[DATETYPE].hashfn =  hash_date;
  extfunction3("MKDATE", mkdatefn);
  extfunction1("DATEP", datepfn);
  extfunction1("DATE-YEAR", date_yearfn);
  extfunction1("DATE-MONTH", date_monthfn);
  extfunction1("DATE-DAY", date_dayfn);
  extfunction2("DATE-LESS", date_lessfn);
  extfunction2("DATE-GREATER", date_greaterfn);
  extfunction1("sleep",sleepfn);
  illegal_date = a_register_error("Illegal date");
  illegal_timeval = a_register_error("Illegal type, expected timeval");
  unsupported_timeval = a_register_error("Unsupported type for timeintervals");
  negative_time = a_register_error("Negative times are not allowed");
  deep_print = mksymbol("DEEP-PRINT");
  globval(deep_print)=nil;
  a_enter_systime.tv_sec = 0;
  a_enter_systime.tv_usec = 0;
  a_this_systime.tv_sec = 0;
  a_this_systime.tv_usec = 0;
}
