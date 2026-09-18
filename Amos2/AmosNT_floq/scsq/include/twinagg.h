/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 *
 * Description:  Time window aggregation
 * Language:     C
 ****************************************************************************/

struct twinaggstate {
	int bufsize, bufstart, bufpos;
	int count, emit_empty_intervals, emit_tail;
	double winlength;
	double stride;
	struct timeval tstart, tend, now;
	int firsttime;
	a_callcontext cxt;
	a_tuple params;
	oidtype vsymb;
	oidtype* buf;
};

oidtype twinaggbf_mapper(a_callcontext cxt, int width, oidtype *restpl, void *xa);
oidtype tsamapper(a_callcontext cxt, int width, oidtype *restpl, void *xa);
void twinaggbf(a_callcontext cxt, a_tuple params);
void register_twinagg(void);
void twin_emit(struct twinaggstate* state);
void twin_set_ends(struct twinaggstate* state, struct timeval *now);
void twin_skip_empty(struct twinaggstate* state);
void twin_realloc_buf(struct twinaggstate* state);
void twin_get_timestamp(struct timeval* t, oidtype timestamped);
int compare_tv(const struct timeval* tv1, const struct timeval* tv2);
