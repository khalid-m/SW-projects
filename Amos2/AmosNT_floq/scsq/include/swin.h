/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Robert Kajic, UDBL
 * $RCSfile: swin.h,v $
 * $Revision: 1.4 $ $Date: 2010/07/02 03:58:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Stream windowing. 
 * ===========================================================================
 * $Log: swin.h,v $
 * Revision 1.4  2010/07/02 03:58:20  roka4241
 * Added flags field to stream window.
 *
 * Revision 1.3  2010/06/09 12:24:59  roka4241
 * *** empty log message ***
 *
 * Revision 1.2  2010/06/09 12:21:55  roka4241
 * Added headers to swin.[ch].
 *
 ****************************************************************************/

struct swincell
{
	objtags tags;
	HEADFILLER;
	int sizeCounter;
	int timeCounter;
	oidtype headl;
	oidtype taill;
    int flags;
	oidtype incre;	// this attribute is used for incremental calculation
};

void register_swincell(void);
void register_swinfns(void);
