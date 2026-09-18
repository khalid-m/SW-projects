/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2012 Thanh Truong, UDBL
 * $RCSfile: test.c,v $
 * $Revision: 1.1 $ $Date: 2013/12/12 16:29:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Simulator main
 ****************************************************************************/
#include "slaslogger.h"
#define assert_block(blockno, lbv) {if (lbv->offset_start != (blockno - 1) * 400000 && lbv->offset_end != (blockno) * 400000) { printf("Block %d was not retrieved correctly (%llu, %llu) \n", blockno, lbv->offset_start,lbv->offset_end);} else printf("Block %d start %llu and end %llu \n", blockno, lbv->offset_start, lbv->offset_end);} 

 
void testGenerate() {
	amosql("slaslogger1(csv_file_tuples('raw/measuredB.txt'), 4, 'measuredB.bin');", FALSE);
}
void testGetRandom() {


}

int printBlockInfo(LBKey k, LBValue* lbv,  void *xa){
  return TRUE;
}

void testMap() {
	// Retrieve the first block info
	//lofixP_map(&g_lx[0], (LBKey) 1, (LBKey) 10, (LofixPMapper) printBlockInfo, NULL, NULL);	
}

void testRelease() {
  //lofixP_release(&g_lx[0]);
}







