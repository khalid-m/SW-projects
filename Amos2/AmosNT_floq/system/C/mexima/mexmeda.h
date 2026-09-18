/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexmeda.h,v $
 * $Revision: 1.6 $ $Date: 2011/12/30 17:09:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Header file for Mexima meta-data
 * ========================================================================
 * $Log: mexmeda.h,v $
 * Revision 1.6  2011/12/30 17:09:05  thatr500
 * update Mexima according to the code inspection (by Tore)
 *
 * Revision 1.5  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.4  2011/12/24 11:50:01  thatr500
 * new design
 *
 * Revision 1.2  2011/12/03 13:04:21  thatr500
 * portable C struct
 *
 * Revision 1.1  2011/12/02 12:38:43  thatr500
 * Meta-data for MEXIMA
 * 
 *
 **************************************************************************/
#ifndef _mexmeda_h_
#define _mexmeda_h_
#include "mexima.h"

/*Meta-data*/
typedef struct meda{  
  short int indextype;
  short int storagetype;
  struct mexi_index_props idxprops;
} meda;

void add_medatable(meda* m); /*Add to medatable*/
meda* get_medatable(int indextype); /*Get from medatable*/
meda* get_metadata(char *idxtype);

#endif
