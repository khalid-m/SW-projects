/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Erik Zeitler, UDBL
 * $RCSfile: amosfns.h,v $
 * $Revision: 1.2 $ $Date: 2009/09/30 15:25:09 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Defines for amosfns.c
 * ===========================================================================
 * $Log: amosfns.h,v $
 * Revision 1.2  2009/09/30 15:25:09  zeitler
 * max(a, b) #define'd
 *
 * Revision 1.1  2009/09/30 15:07:30  zeitler
 * cross platform representation of infinity
 *
 *
 ****************************************************************************/

int VDIM_DISAGREE;

#ifdef _WIN32
#define u_is_nan(d)         (_isnan(d))
#define u_is_neg_inf(d)     (_fpclass(d) == _FPCLASS_NINF)
#define u_is_pos_inf(d)     (_fpclass(d) == _FPCLASS_PINF)
#else // Linux
#define u_is_neg_inf(d)     (isinf(d) == -1)
#define u_is_pos_inf(d)     (isinf(d) == 1)
#endif

#ifndef max
#define max(a, b) ( (a) > (b) ? a : b)
#endif
