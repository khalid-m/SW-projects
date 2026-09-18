/*****************************************************************************
 * AMOS2
 *
 * Author: SobhanB, UDBL
 * $RCSfile: comparison.c,v $
 * $Revision: 1.1 $ $Date: 2012/05/02 16:23:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description:
 * In this file test cases are implemented to
 * compare the scalability of the range search
 * using the following rutines:
 * 1- B-tree mapper
 * 2- mapping over Judy using JLN
 * 3- new JudyMapper
 * The data used is LR data for L=7.0
 * usage example:
 * populate_and_test("D:\\Desktop\\thesis\\lr-trie\\data\\cardatapoints70.osql",7,500000);
 * ===========================================================================
 * $Log: comparison.c,v $
 * Revision 1.1  2012/05/02 16:23:52  sobso953
 * *** empty log message ***
 *
 *
 ****************************************************************************/

#include "..\SCSQ-trie\C\BT.h"
#include "JudyMapper.h"


int JudySumMapper(PWord_t key,PWord_t value,void *xa);

// calculates and prints the time it takes to
// map over 'low' and 'high' bounds in indexing structure 'root'
// if indextype=1 'root' is supposed to point to a B-tree root
// if indextype=2 'root' is supposed to point to a Judy trie, JLN 'mapper'
// if indextype=3 'root' is supposed to point to a Judy trie, new mapper
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
	if (indextype==2 || indextype==3)//test HP trie
	{
		hpt=(Pvoid_t)root;

		//printf("summing up keys in HPT [%d...%d]...\n",low,high);

		//calculate selectivity based
		JLC(Rc_word_total, hpt, 0, -1);
		if((int)Rc_word_total!=0)
		{
			JLC(Rc_word, hpt, low, high);
			selectivity=((unsigned int)Rc_word+0.0)/((unsigned int)Rc_word_total+0.0);
		}
		sum=0;
		if (indextype==2)
		{
			cl = clock();
			Key=(Word_t) low;
			JLF(PValue, hpt, Key);//starting a full traverse
			while ((PValue != NULL)	&& (Key<(Word_t) high))//While there are values in the range
			{
				sum+=*(int*)PValue;
				JLN(PValue, hpt, Key);
			}
			time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		}
		if (indextype==3)
		{
			cl = clock();
			JudyMapper(hpt,low,high,JudySumMapper,&sum,NULL);
			time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		}
		if (sum!=0)
			return time;
			//printf("sum is:%d,low:%d, high:%d selectivity:%f,   it took %g seconds\n",sum,low,high,selectivity ,time);
		
	}
	return 0.0;

}

// extracts segment s expressway x direction d
// and vehicle id v from a row in LR input
// file, then combines it into a single integer
// that is to be inserted into indexing structures

unsigned int extract_sxdv(char* record){

	unsigned int s=0,x=0,d=0,v=0;
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

unsigned int sxdv_to_int(unsigned int s,unsigned int x,unsigned int d, unsigned int v){

	unsigned int sr=0,xr=0,dr=0;

	xr=x<<28;
	dr=d<<27;
	sr=s<<20;
	return (xr|dr|sr|v);
}
// populates a B-tree and a judy array from an LR input file
// 'filename'. Insertions are done in steps, 'epoch_size' 
// determines the number of keys to be inserted between the range search calls.
// 'L' is the L-rating in LRB, i.e. number of expressways.
void populate_and_test(char* filename,int L,int epoch_size){

	FILE *fr=NULL;
	char* str;
	Pvoid_t hpt1,hpt2;
	void * PValue;// pointer to value of an HP trie
	Word_t   Rc_word;// to maintain the count of elements in the range
	int seq,i,j,k,l;
	unsigned int sxdv;
	double time_JLN,time_Judy_mapper,time_BT_mapper;
	BThead* bh=NULL;
	int v;
	unsigned int low,high;
	Word_t Rc_word_total;

	hpt1=(Pvoid_t) NULL;//make an empty trie
	hpt2=(Pvoid_t) NULL;//make an empty trie
	bh=newBThead();//make an empty B-tree

	str=malloc(1000);
	fr = fopen (filename, "rt");
	
	i=0;
	seq=0;
	str=fgets(str,1000,fr);
	while(str!=NULL)
	{
		sxdv= extract_sxdv(str);
		
		// Insert into B-tree
		BTinsert(bh,(Word_t) sxdv,(Word_t) sxdv,NULL);
		// Insert into Judy
		JLG(PValue,hpt1,(Word_t) sxdv);
		if (PValue==NULL)//If there is value for the key don't insert
		{
			JLI(PValue,hpt1,(Word_t) sxdv );
			*(int*) PValue=(Word_t) sxdv;
			seq++;
		}
		i++;
		if (i%1000000==1)
		{
			// perform range search scalability tests
			// go through all possible x,d,s and map over
			// all vehicles running in them, measure the time.
			time_BT_mapper=0;
			time_Judy_mapper=0;
			time_JLN=0;
			
			// the whole tree is traversed here,
			// but the order of for loops is such
			// that the individual range searches
			// are not adjacent.
			for(l=0;l<100;l++)//s
				for(k=0;k<2;k++)//d
					for(j=0;j<1;j++)//x
					{
						v=0;
						low=sxdv_to_int(l,j,k,v);
						v=1048575;//2^20
						high=sxdv_to_int(l,j,k,v);
						
						time_JLN+=range_search_test(hpt1,low,high,2);
						time_Judy_mapper+=range_search_test(hpt1,low,high,3);
						range_search_test(bh,low,high,1);//to warm up the cache for B-tree
						time_BT_mapper+=range_search_test(bh,low,high,1);
					}
			JLC(Rc_word_total, hpt1, 0,-1);
			printf("%dM,%d,%g,%g,%g\n",i/1000000,Rc_word_total,time_JLN,time_Judy_mapper,time_BT_mapper);
		
		}

		
		str=fgets(str,1000,fr);
	}
	
	JLC(Rc_word, hpt1, 0, -1);
	printf("number of the lines: %d keys:%d\n",seq,(int)Rc_word);//supposed to be 9355891 for L=4
	
	fclose(fr);
/*
	///////////////////////////////////
	//to remove all reading overheads,
	//populate a flat array that stores
	//all the keys
	///////////////////////////////////

	Key=0; 
	JLF(PValue, hpt1, Key);//starting a full traverse
	for (i=0;(i<L*2400000)&&PValue;i++)
	{
		BIG_store[i]=*(unsigned int*)PValue;
		JLN(PValue, hpt1, Key);	
	}

	//JLFA(bytes_freed,hpt1);

	//////////////////////////////////////////////
	/////////////////testing Judy/////////////////
	//////////////////////////////////////////////

	// insertion is done in steps/epochs, to measure
	// the scalability, after each step the operations
	// are performed to find out how the size of index
	// affects the performance of the data structure
	
	printf("Testing Judy ...\n\n");

	for(i=0;i<(L*2400000)/epoch_size-1;i++)
	{
		//perform one step of insertion
		cl = clock();
		for (j=0;j<epoch_size;j++)
		{
			JLI(PValue,hpt2,*(BIG_store+i*epoch_size + j));
			*(int*) PValue=*(BIG_store+i*epoch_size + j);
		}
		
		time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		//print the insertion time
		printf("%d,%g",i+1,time);

		// meeasure the performance of the range search 
		// by performing 500 random range searches
		time=0;
		cnt=0;
		for (j=0;j<5000;j++)
		{
			s=randgen(100);
			x=randgen(L);
			d=randgen(2);
			v=0;
			low=sxdv_to_int(s,x,d,v);
			v=1048575;//2^20
			high=sxdv_to_int(s,x,d,v);
			//printf("random sxd:%d,%d,%d\n",s,x,d);
			tmp=range_search_test(hpt2,low,high,2);
			if (tmp!=0)
			{
				time+=tmp;
				cnt++;
			}
		}
		//print the average range search time
		if(cnt==0)
			printf(",N/A\n");
		else
			printf("cnt:%d,%g\n",cnt,time/cnt);
	}
	//extra, just for testing!
	//count how many cars are running in x,d,s 03,01,50

	v=0;
	low=sxdv_to_int(50,3,1,v);
	v=1048575;
	high=sxdv_to_int(50,3,1,v);
	
	JLC(Rc_word_total, hpt2, low, high);

	//////////////////////////////////////////////
	//////////////////testing B-tree//////////////
	//////////////////////////////////////////////

	// insertion is done in steps/epochs, to measure
	// the scalability, after each step the operations
	// are performed to find out how the size of index
	// affects the performance of the data structure

	printf("Testing B-tree ...\n\n");
	
	for(i=0;i<(L*2400000)/epoch_size-1;i++)
	{
		//perform one step of insertion
		cl = clock();
		for (j=0;j<epoch_size;j++)
			BTinsert(bh,*(BIG_store+i*epoch_size + j),*(BIG_store+i*epoch_size + j),NULL);
		
		time = (clock() - cl)*1.0/CLOCKS_PER_SEC;
		//print the insertion time
		printf("%d,%g",i+1,time);

		// meeasure the performance of the range search 
		// by performing 500 random range searches
		time=0;
		cnt=0;
		for (j=0;j<500;j++)
		{
			s=randgen(100);
			x=randgen(L);
			d=randgen(2);
			v=0;
			low=sxdv_to_int(s,x,d,v);
			v=1048575;//2^20
			high=sxdv_to_int(s,x,d,v);
			//printf("random sxd:%d,%d,%d\n",s,x,d);
			tmp=range_search_test(bh,low,high,1);
			if (tmp!=0)
			{
				time+=tmp;
				cnt++;
			}
		}
		//print the average range search time
		if(cnt==0)
			printf(",N/A\n");
		else
			printf("cnt:%d,%g\n",cnt,time/cnt);
	}
*/	

}