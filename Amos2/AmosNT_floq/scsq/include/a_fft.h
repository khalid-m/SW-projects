/****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 * $RCSfile: a_fft.h,v $
 * $Revision: 1.2 $ $Date: 2007/02/19 09:01:59 $
 * $State: Exp $ $Locker:  $
 *
 * Description: AmosII fft methods
 *
 * ==========================================================================
 * $Log: a_fft.h,v $
 * Revision 1.2  2007/02/19 09:01:59  zeitler
 * *** empty log message ***
 *
 * Revision 1.1  2007/02/15 10:15:08  zeitler
 * *** empty log message ***
 *
 *
 ***************************************************************************/

void a_realfftbf(a_callcontext cxt, a_tuple params);
void a_realifftbf(a_callcontext cxt, a_tuple params);
void a_fft(a_callcontext cxt, a_tuple params);
void a_ifft(a_callcontext cxt, a_tuple params);
void register_fft();
