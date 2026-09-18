/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: BT.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:01 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the main memory B-tree implementation
 * ===========================================================================
 *
 ****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <time.h>


#define HALF_SIZE (512/sizeof(BTitem)-1)
#define DB_SIZE 10000000

#define TRUE 1
#define FALSE 0

typedef __int64 BTdata;
typedef struct BTitem BTitem;
typedef struct BTnode BTnode;
typedef struct BThead BThead;

struct BTitem
{
  BTnode *p;    /* Points to child BTree node */
  struct {/*int deleted;*/ BTdata key; BTdata value;} data;
};

struct BTnode  /* Template for btree node */
{
  int m;             /* No of BTitems in node */
  BTnode *p0;                 /* Pointer to child */
  BTitem e[2*HALF_SIZE];      /* Items in node */
};

struct BThead
{
  BTnode *root;               /* Pointer to root btree node */
  int elements;               /* Number of non-deleted items in Btree */
  int items;                  /* Total number of items in Btree */
  /*
  //Added by Sobhan
  int ISUsedByAmos;           // If this is use by Amos, to identify the correct releasing aproach in freeing
  */
};

typedef int (*BTmapper) (BTitem *,void *);
typedef int (*BTcomparer)(BTdata, BTdata);

/* Macros for fast dispatch between integer comparison and user provided
   comparison function: */
#define COMPARE_BITEMS(x,y,fn)(fn?(*fn)(x,y):COMPARE(x,y))
#define COMPARE(x,y) ((x)<(y)?-1:((x)>(y)?1:0))

int compareBTdata(BTdata a,BTdata b);

BThead *newBThead(void);

BTnode *newBTnode (void);

int freeBTnode(BTnode *node);

int freeBThead(BThead *bt);

BTitem *BTinsert1(BThead *bh, BTdata k, BTdata v, BTnode *bn, int *h, BTitem *ui, BTcomparer fn);


BTitem *BTinsert(BThead *bh, BTdata  k, BTdata v, BTcomparer fn);

int BTmap0(BTnode *bt, BTdata lower, BTdata upper, BTmapper fn, BTcomparer cfn, void *xa);

int BTgetMapper(BTitem *bi, void *xa);

BTitem *BTget(BThead *bh, BTdata key);

//General mapper functions added by Sobhan

BTitem *BTnext(BThead *bh, BTdata *key);

int BTSumMapper(BTitem *bi, void *xa);
int BTCountMapper(BTitem *bi, void *xa);
int BTAvgMapper(BTitem *bi, void *xa);
int BTSum(BThead *bh, BTdata low,BTdata high);
int BTCount(BThead *bh, BTdata low,BTdata high);
double BTAvg(BThead *bh, BTdata low,BTdata high);

//////////////////////////////////////////

BTdata BTdelete(BTdata x,BThead *bh);

void printBTkv(BTnode *p);

void printBTsubtree(BTnode *p, int level);

void printBTtree(BThead *bh);

int BTCountNode(BTnode *p);//added by Sobhan

unsigned int randgen(int i);

void BTtest(int size);
