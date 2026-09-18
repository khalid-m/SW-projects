/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: Insertion_Test.c,v $
 * $Revision: 1.2 $ $Date: 2012/01/16 13:08:44 $
 * $State: Exp $ $Locker:  $
 *
 * Description: scalability comparisons between 
 * the main memory B-tree and the HP trie (Judy)
 * ===========================================================================
 *
 ****************************************************************************/

#include "BT.h"
#include "judy.h"
#include "../../Burst_Trie/include/ABT.h"

#include "insertion_test.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#include "Trie_Key.h"

unsigned int tmp_store[1000000];
unsigned int BIG_store[17000000];//stores int keys
char* BIG_store_hk[17000000];//stores string equivalents, used in hash table

//allocates space for elements in BIG_store_hk[]
void allocate_hk_array()
{
	int i;
	for(i=0;i<17000000;i++)
	{
		BIG_store_hk[i]=malloc(5);//4 char long for keys, one for '\0'
		*(BIG_store_hk[i]+4)='\0';//put the terminator char at the end of string
	}
}

void gen_store_rand(int size,int range_low, int range_high)
{
	int i,upkey;
	
	upkey=range_high-range_low;

	for(i=0;i<size;i++)
    {
      tmp_store[i] = range_low+randgen(upkey);
	  //if (i%100000==0)
		//printf("%d\n",tmp_store[i]);
	}
	return;
}

unsigned int extract_sxdv(char* record){

	unsigned int s=0,x=0,d=0,v=0;
//	char* s,x,d,v;
	char *t1;
	t1 = strtok(record," ");
	t1 = strtok(NULL," ");
	t1 = strtok(NULL," ");
	v=(unsigned int)atoi(t1);
	t1 = strtok(NULL," ");
	t1 = strtok(NULL," ");
	x=(unsigned int)atoi(t1);
	t1 = strtok(NULL," ");
	t1 = strtok(NULL," ");
	d=(unsigned int)atoi(t1);
	t1 = strtok(NULL," ");
	s=(unsigned int)atoi(t1);
	x=x<<28;
	d=d<<27;
	s=s<<20;
	return (x|d|s|v);
}

unsigned int extract_sxdv_int(unsigned int s,unsigned int x,unsigned int d, unsigned int v){

	unsigned int sr=0,xr=0,dr=0;

	xr=x<<28;
	dr=d<<27;
	sr=s<<20;
	return (xr|dr|sr|v);
}


void transform_file_to_sxdv(char* in_file,char* out_file)
{
	int i=0;
	FILE *fr=NULL;
	FILE *fw=NULL;
	char* str_in="";
	char* str_out="";
//	char* str_out_line="\0";

	fr = fopen (in_file, "rt");
	fw=fopen(out_file,"wt");

	str_in=fgets(str_in,200,fr);

	while (str_in!=NULL)
	{
		str_out=itoa(extract_sxdv(str_in),str_out,10);
		fprintf(fw,"%s\n",str_out);
		i++;
		str_in=fgets(str_in,200,fr);
	}
	printf("%d number of lines were read!\n",i);
	fclose(fr);
	fclose(fw);
	return;
}

void read_store_LR_data(char* filename,int epoch_size)
{
	static long int position=0;
	int i=0;
	FILE *fr=NULL;
	char* str="";

	fr = fopen (filename, "rt");
	fseek(fr,position,0);
	str=fgets(str,200,fr);//skip the first possible junk lines after seek
	str=fgets(str,200,fr);
	//printf("%s,position:%d\n",str,position);
	while (i<epoch_size && str!=NULL)
	{
		if (i<2)
			printf("%sposition:%d\n",str,position);
		tmp_store[i]= extract_sxdv(str);
		i++;
		str=fgets(str,200,fr);
	}
	printf("i:%d\n",i);
	position=ftell(fr);
	//fclose(fr);
	return;
}

void LR_insertion_test(char* filename,int epoch_size, long int l,int indextype)
{	
	int i,j,rounds;
	clock_t cl;
	double time;
	BThead* bh;
	Pvoid_t hpt;
	void * PValue;// pointer to value of an HP trie
	Word_t   Rc_word;// to maintain the count of elements in the range

	bh = newBThead();
	hpt=(Pvoid_t) NULL;//make an empty trie
	rounds=l*12000000/epoch_size;

	for (i=0;i<rounds;i++)
	{
		read_store_LR_data(filename,epoch_size);
		//if (i<50) continue;
		if (indextype==1)//test B-trees
		{
			cl = clock();
			for (j=0;j<epoch_size;j++)
				BTinsert(bh,tmp_store[j],1,NULL);
			time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
			printf("%d,%g\n",i+1,time);
		}
		if (indextype==2)//test HP trie
		{
			cl = clock();
			for (j=0;j<epoch_size;j++)
			{
				JLI(PValue,hpt, (Word_t) tmp_store[j]);
				*(int*) PValue=1;
			}
			time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
			printf("%d,%g\n",i+1,time);
			JLC(Rc_word, hpt, 0, -1);
			printf("number of the keys:%d\n",(int)Rc_word);
		}


	}
	return;
}

void ordered_insertion_test(int epoch_size,int rounds,int indextype,int direction,int output)
{
	int i,j;
	BThead* bh;
	Pvoid_t hpt;
	clock_t cl;
	double time;
	void * PValue;// pointer to value of an HP trie


	bh = newBThead();
	hpt=(Pvoid_t) NULL;//make an empty trie

	for(j=0;j<rounds;j++)
	{
		if (indextype==1)//test B-trees
			if(direction==1)
			{
				cl = clock();
				for (i=j*epoch_size;i<(j+1)*epoch_size;i++)
					BTinsert(bh,i,1,NULL);
				time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
				if(output==1)
					printf("%d,%g\n",j+1,time);
				else
					range_search_test(bh,j*epoch_size,(j+1)*epoch_size,1);

			}
			else
			{
				cl = clock();
				for (i=(j+1)*epoch_size;i>j*epoch_size;i--)
					BTinsert(bh,i,1,NULL);
				time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
				if(output==1)
					printf("%d,%g\n",j+1,time);
				else
					range_search_test(bh,j*epoch_size,(j+1)*epoch_size,1);
			}
		if (indextype==2)//test HP trie
			if(direction==1)
			{
				cl = clock();
				for (i=j*epoch_size;i<(j+1)*epoch_size;i++)
				{
				  JLI(PValue,hpt, (Word_t) i);
				  *(int*) PValue=1;
				}
				time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
				if(output==1)
					printf("%d,%g\n",j+1,time);
				else
					range_search_test(hpt,j*epoch_size,(j+1)*epoch_size,2);
			}
			else
			{
				cl = clock();
				for (i=(j+1)*epoch_size;i>j*epoch_size;i--)
				{
				  JLI(PValue,hpt, (Word_t) i);
				  *(int*) PValue=1;
				}
				time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
				if(output==1)
					printf("%d,%g\n",j+1,time);
				else
					range_search_test(bh,j*epoch_size,(j+1)*epoch_size,1);
			}
			
	}

		return;

}

void rand_insertion_test(int epoch_size,int rounds, int indextype)
{

  int i,j,high,low,range_size;
  BThead *bh;
  clock_t cl;
  double time;
  Pvoid_t hpt;
  void * PValue;// pointer to value of an HP trie
  Word_t bytes_freed;
  Word_t   Rc_word;// to maintain the count of elements in the range



  bh = newBThead();
  hpt=(Pvoid_t) NULL;//make an empty trie

  range_size=2000000000/rounds;
  low=0;
  high=range_size;
  if (indextype==2)//testing HPTire
	  printf("\n\nTesting HPT\n\n");
  else//testing BT
	  printf("\n\nTesting B-Tree\n\n");
  for (i=0;i<rounds;i++){
	  //printf("low: %d, high: %d\n",low,high);
	  gen_store_rand(epoch_size,low,high);

	  cl = clock();
	  if (indextype==1)//test B-trees
		  for (j=0;j<epoch_size;j++)
			  BTinsert(bh,tmp_store[j],1,NULL);
	  if (indextype==2)//test HPTire
		  for (j=0;j<epoch_size;j++)
		  {
			  JLI(PValue,hpt, (Word_t) tmp_store[j]);
			  *(int*) PValue=1;
		  }
	  time = (clock() - cl)*1.0/CLOCKS_PER_SEC;

	  //printf("%d,%g\n",i+1,time);//prints insertion time

  	  if (indextype==2)//test HPTire
	  {
		  JLMU(Rc_word, hpt);
		  printf("%d,%d\n",i+1,Rc_word/1048576);
	  }
	  if (indextype==1)//test BT
	  {
		  printf("%d,%d\n",i+1,BTCountNode(bh->root)*sizeof(BTnode)/1048576);
	  }


	  low=high+1;
	  high=high+range_size;
	  
  }
  //free indexing structures
  freeBThead(bh);
  JLFA(bytes_freed,hpt);
}

//the main function
void LR_insertion_file(char* filename,int L,int epoch_size)
{

	FILE *fr=NULL;
	char* str="";
	Pvoid_t hpt1,hpt2;
	void * PValue;// pointer to value of an HP trie
	Word_t   Rc_word;// to maintain the count of elements in the range
	int seq=1,i=0,j=0;
	unsigned int sxdv;
	Word_t Key;
	Word_t bytes_freed=0;
	clock_t cl;
	double time,tmp=0.0;
	BThead* bh=NULL;
	int s=0,x=0,d=0,v=0,cnt=0;
	unsigned int low=0,high=0;
	BTrie* trie=NULL;
	BTrieKey BTKey,BTKey0;
	int Rc_int=0;// return code - integer
	char chr=0;



	hpt1=(Pvoid_t) NULL;//make an empty trie
	hpt2=(Pvoid_t) NULL;//make an empty trie

	fr = fopen (filename, "rt");
	str=fgets(str,1000,fr);
	while(str!=NULL)
	{
		sxdv= extract_sxdv(str);
		JLG(PValue,hpt1,(Word_t) sxdv);
		if (PValue==NULL)//If there is value for the key don't insert
		{
			JLI(PValue,hpt1,(Word_t) sxdv );
			*(int*) PValue=seq;
			seq++;
		}
		i++;
		if (i%1000000==1)
			printf("%d million rows imported\n",i/1000000);
		
		str=fgets(str,1000,fr);
	}
	JLC(Rc_word, hpt1, 0, -1);
	printf("number of the lines: %d keys:%d\n",seq,(int)Rc_word);//supposed to be 9355891 for L=4
	
	fclose(fr);

	//populate the flat array 
	//allocate_hk_array();
	Key=0; 
	JLF(PValue, hpt1, Key);//starting a full traverse
	for (i=0;(i<L*2400000)&&PValue;i++)
	{
		BIG_store[i]=*(unsigned int*)PValue;
		//gen_hash_key(BIG_store[i],BIG_store_hk[i]);
		JLN(PValue, hpt1, Key);	
	}

	//JLFA(bytes_freed,hpt1);
	printf("i:%d,BIG_store[i-1]:%d,bytes_freed:%d\n",i,BIG_store[i-1],bytes_freed);

	//now the insertion, range search, deletion scalability test by reading epochs from the array


//	printf("number of keys in hpt2 after deletion: %d \n",BTCount(bh,0,-1));//supposed to be 9355891 for L=4
	///////////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////testing Burst Tries//////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	printf("Enter any key to start insertioni nto the trie\n");

	scanf("%d",&chr);

//	_N_Nodes_=0;
//	_N_Containers_=0;
//	_S_Containers_=0;
	
	trie=BTrie_new();

	printf("\n\nInserting into Burst Trie...\n\n");
	for(i=0;i<(L*2400000)/epoch_size-1;i++)
	{
		cl = clock();
		for (j=0;j<epoch_size;j++)
		{
			memcpy(BTKey0,BIG_store+i*epoch_size + j,sizeof(unsigned int));
			
			//fixing endianness
			BTKey[0]=BTKey0[3];//xd
			BTKey[1]=BTKey0[2];//s
			BTKey[2]=BTKey0[1];//v
			BTKey[3]=BTKey0[0];//v

			//printf("BIG_store:%d, BTKey: [%d,%d,%d,%d]",*(BIG_store+i*epoch_size + j),BTKey[0],BTKey[1],BTKey[2],BTKey[3]);
			BTrie_insert(trie,BTKey,2);
		
		}
		time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		//calculate the number of elements in hpt
		//printf("%d,%d,%g\n",i+1,(int)Rc_word,time);
		//JLC(Rc_word, hpt2, 0, -1);
		printf("%d,%g\n",i+1,time);

		//printf("%d,%d,%g\n",i+1,(int)Rc_word,time);
		time=0;
		cnt=0;
		/*
		//the range search
		for (j=0;j<500;j++)
		{
			s=randgen(100);
			x=randgen(L);
			d=randgen(2);
			v=0;
			low=extract_sxdv_int(s,x,d,v);
			v=1048575;//2^20
			high=extract_sxdv_int(s,x,d,v);
			//printf("random sxd:%d,%d,%d\n",s,x,d);
			tmp=range_search_test(hpt2,low,high,2);
			if (tmp!=0)
			{
				time+=tmp;
				cnt++;
			}
		}
		printf("%d,%f\n",i+1,time/cnt);
		*/
	}
	//TBD: testing deletion


}

void test_bt_64()
{
	BThead *bh;
	BTdata i64=2000000000;

	bh=newBThead();
	
	BTinsert(bh,i64,i64*100,NULL);
	i64*=2;
	BTinsert(bh,i64,i64*200,NULL);
	i64*=3;
	BTinsert(bh,i64/4,i64*300,NULL);
	i64*=4;
	BTinsert(bh,i64,i64*400,NULL);
	i64*=20;
	BTinsert(bh,i64,i64*500,NULL);
	printBTtree(bh);

}




//Following 2 lines added just as a temporary measure to stop the linker warnings
void cons_64_trie_key(int x,int d, int s, int v, uint8_t* key);
int compare_trie_keys(uint8_t* a,uint8_t* b);

void test_hpt_64(int x,int d, int s, int v)
{

	Pvoid_t   PJArray = (PWord_t)NULL;  // Judy array.
    PWord_t   PValue;                   // Judy array element.
    uint8_t   Index[5]="";               // string to insert
	Word_t    Bytes;                    // size of JudySL array.
	uint8_t   I1[5]="";
	uint8_t   I2[5]="";

	//cons_trie_key(52,1,34,54645,Index);

	//i64*=2;
	//memcpy(Index,&i64,8);
	//xdsv
	//xd=0,s=1 v=2&3&4

	cons_64_trie_key(58,0,68,1,Index);
	JSLI(PValue, PJArray, Index);   // store string into array
	(*PValue)=3;

	cons_64_trie_key(1,0,68,6985324,Index);
	JSLI(PValue, PJArray, Index);   // store string into array
	(*PValue)=1;

	cons_64_trie_key(58,0,69,658,Index);
	JSLI(PValue, PJArray, Index);   // store string into array
	(*PValue)=4;

	cons_64_trie_key(30,1,1,4,Index);
	JSLI(PValue, PJArray, Index);   // store string into array
	(*PValue)=2;


	//to test the range search in a given interval
	//cons_64_trie_key(58,0,68,0,Index);

	Index[0] = '\0';					// start with smallest string.

	JSLF(PValue, PJArray, Index);       // get first string
    while (PValue != NULL)
    {
        //while ((*PValue)--)             // print duplicates
            printf("%s,%d\n", Index,*PValue);
        JSLN(PValue, PJArray, Index);   // get next string
    }
    JSLFA(Bytes, PJArray);              // free array

    fprintf(stderr, "The JudySL array used %lu bytes of memory\n", Bytes);


	printf("testing comparison between strings..\n");
	
	cons_64_trie_key(1,1,26,100,I1);
	cons_64_trie_key(2,0,26,100,I2);

	if (compare_trie_keys(I1,I2))
		printf("result of compare_trie_keys(I1,I2) is:%d \n",compare_trie_keys(I1,I2));
	
}

double range_search_test(void* root,unsigned int low, unsigned int high, int indextype)
{
	BThead *bh;
	clock_t cl;
	double time;
	Pvoid_t hpt;
	void * PValue;// pointer to value of an HP trie
	Word_t Key;
	Word_t Rc_word_total=0,Rc_word=0;
	int sum;
	double selectivity=0.0;

	if (indextype==1)//test B-trees
	{
		bh=(BThead *)root;
		sum=0;

		Rc_word=BTCount(bh,low,high);
		
		Rc_word_total=BTCount(bh,0,-1);

		if((int)Rc_word_total!=0)
		{
			selectivity=((unsigned int)Rc_word+0.0)/((unsigned int)Rc_word_total+0.0);
		}

		cl = clock();
		sum=BTSum(bh,low,high);
		time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		if (sum!=0)
			return time;
			//printf("sum is:%d,low:%d, high:%d selectivity:%f,   it took %g seconds\n",sum,low,high,selectivity ,time);

	}
	if (indextype==2)//test HP trie
	{
		hpt=(Pvoid_t)root;
		sum=0;
		//printf("summing up keys in HPT [%d...%d]...\n",low,high);

		//calculate selectivity based
		JLC(Rc_word_total, hpt, 0, -1);
		if((int)Rc_word_total!=0)
		{
			JLC(Rc_word, hpt, low, high);
			selectivity=((unsigned int)Rc_word+0.0)/((unsigned int)Rc_word_total+0.0);
		}

		cl = clock();
		Key=(Word_t) low;
		JLF(PValue, hpt, Key);//starting a full traverse
		while ((PValue != NULL)	&& (Key<(Word_t) high))//While there are values in the range
		{
			sum+=*(int*)PValue;
			JLN(PValue, hpt, Key);
		}
		time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		if (sum!=0)
			return time;
			//printf("sum is:%d,low:%d, high:%d selectivity:%f,   it took %g seconds\n",sum,low,high,selectivity ,time);
		
	}
	return 0.0;

}
/* 
void gen_hash_key(int ikey,char* hkey)
{
	int hi, mid1, mid2, lo;
	hi=(ikey>>24) & 0xff;
	mid1=(ikey>>16) & 0xff;
	mid2=(ikey>>8) & 0xff;
	lo=ikey&0xff;
  


	*hkey=(char)hi;
	*(hkey+1)=(char)mid1;
	*(hkey+2)=(char)mid2;
	*(hkey+3)=(char)lo;
	*(hkey+4)='\0';
}
*/
/*
void test_linh()
{
	hashtable_t * lht;
	char* hk0;
	char* hk1;
	char* hk2;
	char* hk3;
	char* hk4;
	char* hk5;
	char* hk6;
	char* hk7;
	char* hk8;
	char* hk9;
	char* hk10;

	hk0=malloc(5);hk1=malloc(5);hk2=malloc(5);hk3=malloc(5);hk4=malloc(5);hk5=malloc(5);hk6=malloc(5);hk7=malloc(5);hk8=malloc(5);hk9=malloc(5);hk10=malloc(5);

	//testing conversion from int to char[5]
	BIG_store[0]=1245523714;//0
	BIG_store[1]=1335523714;//1
	BIG_store[2]=1345423714;//2
	BIG_store[3]=1345523714;//3
	BIG_store[4]=1345623714;//4
	BIG_store[5]=1345673714;//5
	BIG_store[6]=1345678714;//6
	BIG_store[7]=1345678914;//7
	BIG_store[8]=1345679014;//8
	BIG_store[9]=1345679114;//9
	BIG_store[10]=1345679119;//10
	

//	printf("%d\n",*hk);
	
	lht= lh_init_hashtable(200);

	gen_hash_key(BIG_store[0],hk0);
	lh_enter("0",hk0,lht);

	gen_hash_key(BIG_store[1],hk1);
	lh_enter("1",hk1,lht);

	gen_hash_key(BIG_store[2],hk2);
	lh_enter("2",hk2,lht);

	gen_hash_key(BIG_store[3],hk3);
	lh_enter("3",hk3,lht);

	gen_hash_key(BIG_store[4],hk4);
	lh_enter("4",hk4,lht);

	gen_hash_key(BIG_store[5],hk5);
	lh_enter("5",hk5,lht);

	gen_hash_key(BIG_store[6],hk6);
	lh_enter("6",hk6,lht);

	gen_hash_key(BIG_store[7],hk7);
	lh_enter("7",hk7,lht);

	gen_hash_key(BIG_store[8],hk8);
	lh_enter("8",hk8,lht);

	gen_hash_key(BIG_store[9],hk9);
	lh_enter("9",hk9,lht);

	gen_hash_key(BIG_store[10],hk10);
	lh_enter("10",hk10,lht);

	printf(lh_retrieve(hk0,lht));
	printf("\n");
	printf(lh_retrieve(hk1,lht));
	printf("\n");
	printf(lh_retrieve(hk2,lht));
	printf("\n");
	printf(lh_retrieve(hk3,lht));
	printf("\n");
	printf(lh_retrieve(hk4,lht));
	printf("\n");
	printf(lh_retrieve(hk5,lht));
	printf("\n");
	printf(lh_retrieve(hk6,lht));
	printf("\n");
	printf(lh_retrieve(hk7,lht));
	printf("\n");
	printf(lh_retrieve(hk8,lht));
	printf("\n");
	printf(lh_retrieve(hk9,lht));
	printf("\n");
	printf(lh_retrieve(hk10,lht));
	printf("\n");
	
}*/








































unsigned long int next=1;

/*return pseudo random integer on 0..32776*/
int standard_rand(void)
{
	next=next*1103515245+12345;
	return (unsigned int) (next/65536)%32768;
}

/*set seed for rand()*/
void standard_srand(unsigned int seed)
{
	next=seed;
}