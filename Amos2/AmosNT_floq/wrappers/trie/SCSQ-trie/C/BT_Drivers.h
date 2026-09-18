/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: BT_Drivers.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the Alisp drivers of the main memory B-tree
 * ===========================================================================
 *
 ****************************************************************************/
#include "alisp.h"
#include "amos.h"
#include "BT.h"

#define MaxNumberOfBTrees 200
#define FreeBTCellIndicator -1
#define BTWinSize 6	//window size in LRB
#define DelBuffSize 1//size of deletion buffer, used only in BTBulkDel

int DelBuffIndex;//indicates the index of first vacant place in DelBuffer array.(used only in BTBulkDel)

int BTIndex;//indicates were to put the new Btree in Btrees[] array.
BThead*  Btrees[MaxNumberOfBTrees];//array keeping pointers to BTrees.

//this data structure is used in retrieving average from Btrees
typedef struct BTavgDS BTavgDS;
//BTavgDS==BTree average Data Structure
struct BTavgDS
{
  int cnt;// a counter, maintains the number of elemetnts
  double sum;//sum of values
  //avg=sum/cnt
};

void InitializeBTArray();
void test_BT_mappers();

int  BTSum(BThead *bh, BTdata low,BTdata high);
int BTSumMapper(BTitem *bi, void *xa);
int BTFreeMapper(BTitem *bi, void *xa);

void Bind_BT();

oidtype make_BT(bindtype env);
oidtype free_BT(bindtype env,oidtype BTID);
oidtype put_BT(bindtype env, oidtype Key, oidtype BTID, oidtype Value);
oidtype get_BT(bindtype env, oidtype Key, oidtype BTID);
oidtype map_BT(bindtype env, oidtype BTID,oidtype Low,oidtype High, oidtype fn);
oidtype count_BT(bindtype env, oidtype BTID,oidtype Low,oidtype High);
oidtype BT_avg_v_c(bindtype env,oidtype range_vector,oidtype min, oidtype BT_vector);
oidtype BT_avg_v_c64_bulk(bindtype env,	oidtype s,oidtype x,oidtype d,oidtype min, oidtype BT_vector);
oidtype BT_avg_v_c64(bindtype env,	oidtype s,oidtype x,oidtype d,oidtype min, oidtype BTID);
int BTAvgVelocityMapper(BTitem *bi, void *xa);
double BTAvgVelocity(BThead *bh, BTdata low,BTdata high);
