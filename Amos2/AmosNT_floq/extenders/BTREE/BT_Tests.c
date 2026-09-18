#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "BT.h"

/***** testing *****/

static unsigned long int rand_seed=13465241;
#define MAX_UINT 4294967295
/***** printing *****/

void printBTkv(BTnode *p)
{
  unsigned int i;

  for(i=1;i<=p->m;i++)
    {
      printf("(%d %d) ", p->e[i-1].data.key, p->e[i-1].data.value);
    }
  printf("\n");
}

void printBTsubtree(BTnode *p, unsigned int level)
{
  unsigned int i;

  if(p!=NULL)
    {
      for(i=1;i<=level;i++)
	printf("    ");
      printBTkv(p);
      printBTsubtree(p->p0,level+1);
      for(i=1;i<=p->m;i++)
	printBTsubtree(p->e[i-1].p,level+1);
    }
}

void printBTtree(BThead *bh)
{
  printBTsubtree(bh->root, 0);
}

unsigned int randgen(int i) /* returns a random integer 0..i-1 */
{
  rand_seed = rand_seed * 1103515245 + 12345;
  if (i == 0) return 0;
  return (unsigned int)(rand_seed % i);
}

/*General mapper functions added by Sobhan*/
/////////////////////////////////////////


int BTCountMapper(BTitem *bi, void *xa)
{
  *(int *) xa=*(int *) xa+1;
  return TRUE;
}

int BTCount(BThead *bh, BTdata low,BTdata high)

{
  int *res=NULL;
 
  BTmap0(bh->root,low,high,BTCountMapper,compareBTdata,(void *)&res);
  if(res==NULL) return 0;
  return (int) res;
}

//original BTree test written by Tore
void BTtest(int size)
{
  int i, cnt;
  clock_t cl;
  double time;
  BThead *bh;
  BTdata k;
  int upkey; 
  BTdata k1;
  int ac=1000000;
  
  bh = newBThead();
  upkey = 7*size+3;
  printf("[Building BT with %g rows ... ", size*1.0);
  cl = clock();
  for(i=0;i<size;i++)
    {
      k = (BTdata) randgen(upkey);
      if(i==1) k1 = k;
      BTinsert_value(bh,(BTdata)k,(BTdata)i,NULL);
    }
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  //printf("%d nodes, %g s]\n",nodecnt,time);
  //printBTtree(bh);
  printf("Should be 1: %d\n", BTget(bh, k1, NULL)->data.value);
  printf("[Accessing BT with %g rows %d times ... ", size*1.0, ac);
  cl = clock();
  for(i=0;i<ac;i++)
    BTget(bh,(BTdata)randgen(upkey), NULL);
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  printf("%g s]\n",time);  
  cl = clock();
  printf("[Deleting BT with %g rows ... ", size*1.0);
  cnt = freeBThead(bh);
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  printf("%d nodes deleted, %g s]\n",cnt,time);  
  bh = newBThead();
  printf("[Reused node building BT with %g rows ... ", size*1.0);
  cl = clock();
  for(i=0;i<size;i++)
    {
      k = (BTdata)randgen(upkey);
      if(i==1) k1 = k;
      BTinsert_value(bh,k,(BTdata)i,NULL);
    }
  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
  //  printf("%d nodes, %g s]\n",nodecnt,time);
}

void BTdeltest_ordered(unsigned int size)
{
  BThead *bh;
  size_t k;
  int n=0;
  BTitem bti;

  bh = newBThead();

  printf("*****Testing with ordered keys*****\n");

  printf("Inserting...\n");

  for(k=1;k<=size;k++)
    BTinsert_value(bh,(void *)k,(void *)k,NULL);

  printf("deleting...\n");
  for(k=1;k<=size;k++)
    {
      BTdelete(bh,(BTdata)k,NULL,&bti);
    }

  printBTtree(bh);

  return;
}

void BT_ins_del_test_book()
{
  //set HALF_SIZE to 48 for tesing according to Wirth book (int32 data)
  //set HALF_SIZE to 36 for tesing according to Wirth book (void* data)

  BThead *bh;
  BTitem bti;
  BTcursor cursor;
  BTdata bt_key_low;
  BTitem* PBTi_scan;//the B-tree item returned by 'scan'

	
  bh = newBThead();
  printf("\n\nPerforming the tests according to the insertion/deletion examples on ADS book\n[Wirth] (p#246-249)\n\n");

  ///////////////////////////////////////////////////////////////////
    printf("\n\n\n ---------------- Insertion ---------------- \n\n\n");
    ///////////////////////////////////////////////////////////////////

      BTinsert_value(bh,(BTdata)20,(BTdata)200,NULL);
      printf("\n20;\n");
      printBTtree(bh);

      BTinsert_value(bh,(BTdata)40,(BTdata)400,NULL); 
      BTinsert_value(bh,(BTdata)10,(BTdata)100,NULL); 
      BTinsert_value(bh,(BTdata)30,(BTdata)300,NULL);
      BTinsert_value(bh,(BTdata)15,(BTdata)150,NULL);
      printf("\n40 10 30 15;\n");
      printBTtree(bh);

      BTinsert_value(bh,(BTdata)35,(BTdata)350,NULL);
      BTinsert_value(bh,(BTdata)7,(BTdata)70,NULL);
      BTinsert_value(bh,(BTdata)26,(BTdata)260,NULL);
      BTinsert_value(bh,(BTdata)18,(BTdata)180,NULL);
      BTinsert_value(bh,(BTdata)22,(BTdata)220,NULL);
      printf("\n35 7 26 18 22;\n");
      printBTtree(bh);

      BTinsert_value(bh,(BTdata)5,(BTdata)50,NULL);
      printf("\n5;\n");
      printBTtree(bh);
	
      BTinsert_value(bh,(BTdata)42,(BTdata)420,NULL);
      BTinsert_value(bh,(BTdata)13,(BTdata)130,NULL);
      BTinsert_value(bh,(BTdata)46,(BTdata)460,NULL);
      BTinsert_value(bh,(BTdata)27,(BTdata)270,NULL);
      BTinsert_value(bh,(BTdata)8,(BTdata)80,NULL);
      BTinsert_value(bh,(BTdata)32,(BTdata)320,NULL);
      printf("\n42 13 46 27 8 32;\n");
      printBTtree(bh);

      BTinsert_value(bh,(BTdata)38,(BTdata)380,NULL);
      BTinsert_value(bh,(BTdata)24,(BTdata)240,NULL);
      BTinsert_value(bh,(BTdata)45,(BTdata)450,NULL);
      BTinsert_value(bh,(BTdata)25,(BTdata)250,NULL);
      printf("\n38 24 45 25\n");
      printBTtree(bh);

	  //////////////////////////////////////////////////////////////////
      printf("\n\n\n ------------------ Scan ------------------ \n\n\n");
      //////////////////////////////////////////////////////////////////
	
	//scan all elements
	bt_key_low=0;
	cursor=NULL;
	BT_cursor_init(bh->root,bt_key_low,NULL,&cursor);
	
	PBTi_scan=CURSOR_CURRENT(cursor);

	while(PBTi_scan)
	{
		printf("%d\n",PBTi_scan->data.key);
		BT_cursor_next(&cursor);
		PBTi_scan=CURSOR_CURRENT(cursor);
	}
	  //////////////////////////////////////////////////////////////////
      printf("\n\n\n ---------------- Deletion ---------------- \n\n\n");
      //////////////////////////////////////////////////////////////////
	
      BTdelete(bh,(BTdata)25,NULL,&bti);BTdelete(bh,(BTdata)45,NULL,&bti);BTdelete(bh,(BTdata)24,NULL,&bti);
      printf("\n25 45 24;\n");
      printBTtree(bh);
	
      BTdelete(bh,(BTdata)38,NULL,&bti);BTdelete(bh,(BTdata)32,NULL,&bti);
      printf("\n38 32;\n");
      printBTtree(bh);
	
      BTdelete(bh,(BTdata)8,NULL,&bti);BTdelete(bh,(BTdata)27,NULL,&bti);
	  BTdelete(bh,(BTdata)46,NULL,&bti);BTdelete(bh,(BTdata)13,NULL,&bti);BTdelete(bh,(BTdata)42,NULL,&bti);
      printf("\n8 27 46 13 42;\n");
      printBTtree(bh);
	
      BTdelete(bh,(BTdata)5,NULL,&bti);BTdelete(bh,(BTdata)22,NULL,&bti);
	  BTdelete(bh,(BTdata)18,NULL,&bti);BTdelete(bh,(BTdata)26,NULL,&bti);
      printf("\n5 22 18 26;\n");
      printBTtree(bh);

      BTdelete(bh,(BTdata)7,NULL,&bti);BTdelete(bh,(BTdata)35,NULL,&bti);
	  BTdelete(bh,(BTdata)15,NULL,&bti);
      printf("\n7 35 15;\n");
      printBTtree(bh);

      printf("\nDeletion of none existing key returns:%d\n",BTdelete(bh,(BTdata)986532,NULL,&bti));
      printf("\nnumber of elements in bh:%d\n",bh->elements); 

	  BTdelete(bh,(BTdata)10,NULL,&bti);
	  printf("Deletion of 10 returns: <k: %d,v: %d>\n",bti.data.key,bti.data.value);
	  printf("\nnumber of elements in bh:%d\n",bh->elements);

}


int exists(int k,int* array,int pos)
{
  int i;
  for (i=0;i<pos-1;i++)
    if (array[i]==k)
      {
	//printf("duplicate elliminated\n");
	return 1;
      }
  return 0;
}

void gen_store_rand(int size, int * array,int range_low, int range_high,int integritycheck)
{
  int i,upkey;
  int tmp;
	
  upkey=range_high-range_low;
  if (integritycheck)//should not produce duplicate keys.
    {
      for(i=0;i<size;i++)
	{
	  tmp= range_low+randgen(upkey);
	  if (exists(tmp,array,i))
	    i--;
	  else
	    array[i]=tmp;
	}
    }
  else
    for(i=0;i<size;i++)
      array[i]= range_low+randgen(upkey);
  return;
}

//tests BTree insertion/deletion using random numbers
//if integritycheck flag is none ziro, it performs expensive integrity chacks
void BTdeltest_rand(int size, int integritycheck)
{//433135
  BThead *bh;
  int* tmp_store;
  int i,j,flag=0,delflag=0;
  BTitem *bi;
  BTitem bd;

  tmp_store=malloc(size*sizeof(int));
  printf("*****Testing with random keys*****\n");
  printf("Generating/storing random numbers...\n");
  gen_store_rand(size,tmp_store,1,1000000000,integritycheck);

  printf("Inserting into Btree...\n");
  bh = newBThead();
  for(i=0;i<size;i++)
    {
      BTinsert_value(bh,(BTdata)tmp_store[i],(BTdata)(tmp_store[i]+1),NULL);
      if (integritycheck)//check if it is really inserted
	{
	  bi=BTget(bh,(BTdata)tmp_store[i],NULL);
	  if (bi!=NULL)
	    {
	      if (bi->data.key!=(BTdata)tmp_store[i] || bi->data.value!=(BTdata)(tmp_store[i]+1))
		printf("#-1 insertion failed for %d\n",tmp_store[i]);
	    }
	  else
	    printf("#-1 insertion failed for %d\n",tmp_store[i]);
	}
    }
  if (integritycheck)//check if the insertion was done for all items.
    {
      for(i=0;i<size;i++)
	{
	  bi=BTget(bh,(BTdata)tmp_store[i],NULL);
	  if (bi!=NULL)
	    {
	      if (bi->data.key!=(BTdata)tmp_store[i] || bi->data.value!=(BTdata)(tmp_store[i]+1))
		printf("#-1 insertion failed for %d\n",tmp_store[i]);
	    }
	  else
	    printf("#-1 insertion failed for %d\n",tmp_store[i]);
	}
    }
  //printBTtree(bh);
  printf("Deleting all entries from the Btree...\n");
  //for(i=size;i>0;i--)
  for(i=0;i<size;i++)
    {
      if (integritycheck)
	//perform following integrity checks:
	//0.0-check if the key exists before deletion
	//0.5-check if the value returned from deletion is ok
	//1.0-check if this key is deleted
	//2.0-check to see if all other keys are still in BTree
	//3.0-check if no extra junk-key is inserted/created
	{
	  flag=0;
	  //printf("deletion of %d ...",tmp_store[i]);
	  //integrity check #0
	  bi=BTget(bh,(BTdata)tmp_store[i],NULL);
	  if (bi!=NULL)
	    {
	      if (bi->data.key!=(BTdata)tmp_store[i] || bi->data.value!=(BTdata)(tmp_store[i]+1))
		{
		  printf("\n#0 key %d was currupt before deletion\n",tmp_store[i]);
		  flag=1;
		}
	    }
	  else
	    {
	      printf("\n#0 key %d did not exist before deletion\n",tmp_store[i]);
	      flag=1;
	    }
	}
      delflag=BTdelete(bh,(BTdata)tmp_store[i],NULL,&bd);
	  if (delflag==0)//the key must be found
		{
	      printf("\n#0.1 key %d was not found\n",tmp_store[i]);
	      flag=1;
	    }
	  if (bh->elements!=size-(i+1))
		{
	      printf("\n#0. deleting key %d wrong bh->elements\n",tmp_store[i]);
	      flag=1;
	    }
      if (integritycheck)
	{
	  if (bd.data.value!=(BTdata)(tmp_store[i]+1))
	    {
	      printf("\n#0.5 returned value for deletion of %d was incorrect\n",tmp_store[i]);
	      flag=1;
	    }

	  //integrity check #1
	  bi=BTget(bh,(BTdata)tmp_store[i],NULL);
	  if (bi!=NULL)
	    {
	      printf("\n#1 deletion practically failed for %d\n",tmp_store[i]);
	      flag=1;
	    }
	  //integrity check #2
	  for(j=i+1;j<size;j++)
	    {
	      bi=BTget(bh,(BTdata)tmp_store[j],NULL);
	      if (bi==NULL)
		{
		  printf("\n#2 key %d is missing\n",tmp_store[j]);
		  flag=1;
		}
	    }
	  //integrity check #3
	  if(BTCount(bh,(BTdata)0,(BTdata)2147483647)!=(size-i-1))//2^31-1=2147483647
	    {
	      printf("\n#3 something added after deleting %d\n",tmp_store[i]);
	      flag=1;
	    }
	  if (flag==0);
	  //	printf("finished successfully\n");
	  else
	    {
	      printf("Deletion failed i=%d,tmp_store[i]=%d\n",i,(int)tmp_store[i]);
	      break;
	    }
	}
		
    }
  if (!flag)
    printf("***Deletion tests finished sucessfully***\n");
  else
	printf("Failed!!!!!!!!!!!!!!!\n");
  printf("the btree after deletion:\n");
  printBTtree(bh);

}

void mem_free_test(__int64 size)
{
  int i;
  BThead *bh;
  BTitem bti;
  int n;
	
  bh=newBThead();
  for (i=1;i<size;i++)
    BTinsert_value(bh,(BTdata)i,(BTdata)(i+1),NULL);

  scanf("%d", & n);

  for (i=1;i<size;i++)
    BTdelete(bh,(BTdata)i,NULL,&bti);
	
  scanf("%d", & n);
}

int BTnextMapper(BTitem *bi, void *xa)
{
	if (bi==NULL)//the key itself is not found, continue forwards until the next key
		return TRUE;
	else
	{//'Next' is found,return it and stop traversing the tree.
		*((BTitem **)xa) = bi;
		return FALSE;
	}
}
//returns the smallest BTitem bti such that bti.data.key>=key
BTitem *BTnext(BThead *bh, BTdata key)
{
  BTitem *res=NULL;
 //TBD: define MAXKEYVAL somewhere global...
  
  BTmap0(bh->root,key,(BTdata)MAX_UINT,BTnextMapper,compareBTdata,(void *)&res);
  
  return res;
}

test_init_cursor(int size){
	int i;
	int correct_results=0,prblm1=0,prblm2=0,prblm3=0;
	BThead *bh;
	BTcursor cursor;
	BTdata bt_key;

	BTitem* PBTi_next;//the B-tree item returned by 'next'
	BTitem* PBTi_scan;//the B-tree item returned by 'scan'
	
	printf("\ntesting init_cursor...");
	bh=newBThead();
  
	for (i=0;i<size;i++)
	{
		bt_key=(BTdata)randgen(MAX_UINT);
		BTinsert_value(bh,bt_key,bt_key,NULL);
	}


	//for 'some' of the keys perform the test
	for (i=0;i<size/10;i++)
	{
		bt_key=(BTdata)randgen(MAX_UINT);
		cursor=NULL;
		BT_cursor_init(bh->root,bt_key,NULL,&cursor);
		
		PBTi_next=BTnext(bh, bt_key);
		PBTi_scan=CURSOR_CURRENT(cursor);
	
		//problem #1:
		if(!PBTi_next && PBTi_scan)
		{
			printf("scan returns something, but next does not\n");
			//recreate the bug
			FREE_CURSOR(cursor);
			BT_cursor_init(bh->root,bt_key,NULL,&cursor);
			prblm1++;
			
			FREE_CURSOR(cursor);
			continue;

		}
		//problem #2:
		if(PBTi_next && !PBTi_scan)
		{
			printf("next returns something, but scan does not\n");
			//recreate the bug
			FREE_CURSOR(cursor);
			BT_cursor_init(bh->root,bt_key,NULL,&cursor);
			prblm2++;
			
			FREE_CURSOR(cursor);
			continue;
		}
		//problem #3:
		if(PBTi_next!=PBTi_scan)
		{
			printf("wrong results for bt_key: %d,BTnext: %d,CURSOR_CURRENT: %d\n"
					,bt_key,PBTi_next->data.key,PBTi_scan->data.key);
			prblm3++;
			
			FREE_CURSOR(cursor);
			continue;
		}
		//correct results:
		if(PBTi_next=PBTi_scan)
		{	
			correct_results++;
			
			FREE_CURSOR(cursor);
			continue;
		}
	}

	if(!prblm1&&!prblm2&&!prblm3)
	{
		printf("passed!\n\n");
	}
	else
	{
		printf("\n\n !!!!!!!!!!!!!!! failed!!!!!!!!!\n\n");

		printf(
		"correct_results: %d,  prblm1: %d, , prblm2: %d, , prblm3: %d, sum: %d \n\n",
		correct_results,prblm1,prblm2,prblm3,
		correct_results+prblm1+prblm2+prblm3
		);	
	}
}

test_BT_cursor_next(int size){
	int i,j;
	int prblms=0;
	int sum,count;
	BThead *bh;
	BTcursor cursor;
	BTdata bt_key,bt_key_low;

	BTitem* PBTi_next;//the B-tree item returned by 'next'
	BTitem* PBTi_scan;//the B-tree item returned by 'scan'
	
	printf("\ntesting BT_cursor_next...");
	bh=newBThead();
  
	for (i=0;i<size;i++)
	{
		bt_key=(BTdata)randgen(MAX_UINT);
		BTinsert_value(bh,bt_key,(BTdata)1,NULL);
	}

	//1.generate size/100 low_bounds and
	//start a scan, each returned element
	//should match the corresponding element
	//returned by next mapper
	for (i=0;i<size/100;i++)
	{
		bt_key_low=(BTdata)randgen(MAX_UINT);

		cursor=NULL;
		BT_cursor_init(bh->root,bt_key_low,NULL,&cursor);
		//get the current values:
		PBTi_next=BTnext(bh, bt_key_low);
		PBTi_scan=CURSOR_CURRENT(cursor);
		j=0;
		//move forward
		while(PBTi_next||PBTi_scan){
			
			if(PBTi_next!=PBTi_scan)
			{
				printf("error!\n");
				prblms++;
			}
			j++;
			//move forward:
			bt_key=(PBTi_next->data.key);
			//not sure if this is safe in all platforms, works under windows though
			bt_key=(BTdata)((unsigned int)(bt_key)+1);
			BT_cursor_next(&cursor);

			PBTi_next=BTnext(bh, bt_key);
			PBTi_scan=CURSOR_CURRENT(cursor);
			
		}
		if(j==0)
			;//printf("nothing in range\n");
		FREE_CURSOR(cursor);
	}

	//1.sum all values using scan,
	// should match the result from count mapper

	cursor=NULL;
	BT_cursor_init(bh->root,(BTdata)0,NULL,&cursor);
	PBTi_scan=CURSOR_CURRENT(cursor);

	sum=0;
	while(PBTi_scan)
	{
		sum+=(int)PBTi_scan->data.value;
		BT_cursor_next(&cursor);
		PBTi_scan=CURSOR_CURRENT(cursor);
	}
	count=BTCount(bh, (BTdata)0,(BTdata)MAX_UINT);
	
	if (sum!=count)
	{
		printf("sum!=count\n");
		prblms++;
	}
	if (!prblms)
		printf("passed!\n\n");
	else
		printf("\n\n !!!!!!!!!!!!!!! failed!!!!!!!!!\n\n");
}
int main(int argc, char**argv)
{
  BTdeltest_ordered(10000000);
  BTdeltest_rand(5000,1);
//  BT_ins_del_test_book();	/*This test requires setting specific size for BT node*/
  test_init_cursor(1000000);
  test_BT_cursor_next(50000);
}
