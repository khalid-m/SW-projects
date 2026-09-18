/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 sobhanb, UDBL
 * $RCSfile: JudyMapperTest.c,v $
 * $Revision: 1.8 $ $Date: 2012/08/05 15:27:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mapper for Judy tries
 * ===========================================================================
 * $Log: JudyMapperTest.c,v $
 * Revision 1.8  2012/08/05 15:27:52  sobso953
 * 1.The root level leafs are supported/tested now. 2. some comments removed.
 *
 * Revision 1.7  2012/03/10 15:13:50  sobso953
 * comprehensive set of tests added
 *
 * Revision 1.6  2012/02/12 15:36:04  sobso953
 * kvp_test() added
 *
 * Revision 1.5  2012/01/25 18:56:17  sobso953
 * Btree comparison mesurments added
 *
 * Revision 1.4  2012/01/25 18:21:55  sobso953
 * mesurements added
 *
 * Revision 1.3  2012/01/23 18:32:56  sobso953
 * maping function added
 *
 * Revision 1.2  2012/01/19 15:20:29  sobso953
 * step1: Internal nodes are processed in a full mapper
 *
 * Revision 1.1  2012/01/18 13:22:06  sobso953
 * Judy mapper project added
 *
 *
 ****************************************************************************/

#include <stdio.h>
#include "judy.h"
//#include "..\SCSQ-trie\C\BT.h"
#include <time.h>
#include "JudyMapper.h"

int JudySumMapper(PWord_t key,PWord_t value,void *xa)
{
  *(int *) xa+= (int)*value;
  return 1;
}

int KVP_test_Mapper(PWord_t key,PWord_t value,void *xa)
{
  if (*key!=*value)
  {
	  printf("KVP dont match; key:%u val %u cnt_err %d\n",*key,*value,(*(int*)xa));
	  (*(int*)xa)++;
  }
  return 1;
}


static unsigned long int rand_seed=13465241;

unsigned int randgen(int i) /* returns a random integer 0..i-1 */
{
  rand_seed = rand_seed * 1103515245 + 12345;
  if (i == 0) return 0;
  return (unsigned int)(rand_seed % i);
}

//tests if <key val> pairs are retreived properly
//On insertion, insert val=key, then check if
//the accumolated key matches the value stored in all nodes
int kvp_test(char *msg,int size, unsigned int range){

	int i;
	Word_t   Index;                     // array index
	//Word_t   Rc_word;
	Word_t * PValue;                    // pointer to array element value
	int cnt_err;


	Pvoid_t  PJLArray = (Pvoid_t) NULL; // initialize JudyL array
	
	printf(msg);
	
	//populate the array with val=key
	for (i=0;i<size;i++)
	{
		Index=randgen(range);
		JLI(PValue, PJLArray, Index);
		*PValue=Index;
	}
	
	cnt_err=0;
	JudyMapper(PJLArray,0,cJU_ALLONES,KVP_test_Mapper,&cnt_err,NULL);
	

	if (cnt_err==0)
		printf("passed!\n");
	else
		printf("\nFailed!!!!!!!!!!!!!!!!!!!!!!!!!Number of not matched kvps:%d \n",cnt_err);
	
	//JLFA(Rc_word, PJLArray);
	
	return 0;

}

//makes sure that all keys are covered in a 'full mapper'
//value is set to one for all keys, then a sum mapper is performed
//on the whole trie, the sum has to match the result of calling
//Judy's counting function
coverage_test(char *msg,int size, unsigned int range){

	int i;
	Word_t   Index;                     // array index
	Word_t   intupper=0,intlower=0;
	Word_t * PValue;                    // pointer to array element value
	Word_t sum1,sum2;

	Pvoid_t  PJLArray = (Pvoid_t) NULL; // initialize JudyL array

	printf(msg);

	for (i=0;i<size;i++)
	{
		Index=randgen(range);
		JLI(PValue, PJLArray, Index);
		*PValue=1;
	}

	JLC(sum1, PJLArray, 0, -1);
	sum2=0;
	JudyMapper(PJLArray,0,cJU_ALLONES,JudySumMapper,&sum2,NULL);
	
	if (sum1!=sum2)
		printf("\n\n\n\n\n\n!!!!!!!!!!!!!!!!!!!!!!!!!sum1 is:%d sum2 is:%d \n",sum1,sum2);
	else
		printf("passed!\n");

	//JLFA(sum1, PJLArray);
}

//prints elements in PJLArray that are in
//[intlower,intupper] range
print_elements(Pvoid_t PJLArray,Word_t intlower,Word_t intupper){
	Word_t   Index;
	PWord_t  PValue;

	Index=intlower;
	
	JLF(PValue, PJLArray, Index);
	while ((PValue != NULL) && (Index<=intupper))
	{
		printf("%lu %lu\n", Index, *PValue);
		JLN(PValue, PJLArray, Index);
	}

}

//tests to find out if a range is properly covered
//range_diverge_flag specifies if lower and upper ranges in the test
//should share a common prefix (0) or not(1).
range_test(char *msg,int size, unsigned int range, int range_diverge_flag){

	int i;
	int value=2;
	Word_t   Index;                     // array index
	Word_t   upper,lower;
	Word_t * PValue;                    // pointer to array element value
	Word_t sum1,sum2,total_cnt;
	Pvoid_t  PJLArray = (Pvoid_t) NULL; // initialize JudyL array
	Word_t   Two_upper_bytes;
	
	printf("%s",msg);
	
	for (i=0;i<size;i++)
	{
		Index=randgen(range);
		JLI(PValue, PJLArray, Index);
		*PValue=1;
	}
	
	// generate random lower and upper bounds
	//skip the [low,high] bounds in which there
	//are no keys (try max 100 times)
	i=0;
	sum1=0;
	while (sum1==0 && i<50000)
	{
		if (range_diverge_flag)
			while (
				JU_DIGITATSTATE(lower,PREFIX_LENGTH-0)
				==
				JU_DIGITATSTATE(upper,PREFIX_LENGTH-0)
				)
			{// make sure lower[0]!=upper[0]
				lower=randgen(range);
				upper=randgen(range);
			}
		else
		{
			lower=randgen(range);
			upper=randgen(range);
			
			//make a common prefix
			//we want to achieve the following:
			//lower[0]=upper[0];
			//lower[1]=upper[1];

			//mask high bits of lower
			lower=lower & 0X0000FFFF;
			//take the two left most bytes of upper
			Two_upper_bytes=upper & 0XFFFF0000;
			//put the upper bytes in lower
			lower=lower | Two_upper_bytes;
		}

		JLC(sum1, PJLArray, lower,upper);
		
		i++;
	}

	JLC(sum1, PJLArray, lower,upper);
	//printf("\n");
	//print_elements(PJLArray, lower,upper);

	sum2=0;
	JudyMapper(PJLArray,lower,upper,JudySumMapper,&sum2,NULL);


	JLC(total_cnt, PJLArray, 0,-1);

	//printf("cnt:%d total_cnt:%d\n",sum1 ,total_cnt);
	
	if (sum1!=sum2)
		printf("\n\n\n\n\n\n!!!!!!!!!!!!!!!!!!!!!!!!!sum1 is:%d sum2 is:%d \n",sum1,sum2);
	else
		if(sum1==0 && sum2==0)
			printf("sum1==0 && sum2==0 BUT passed!\n");
		else
			printf("passed!\n");

	//JLFA(sum1, PJLArray);

}

void populate_and_test(char* filename,int L,int epoch_size);


main(){

	int size=0;
	unsigned int range=cJU_ALLONES;
/*
	populate_and_test("D:\\Desktop\\thesis\\lr-trie\\data\\cardatapoints70.osql",7,500000);


*/	//**********1.testing narrow ranges**********
	//0.0 leaf level nodes
	
	size=4;
	range=1000000;
	printf("\n**************** leaf level nodes ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);

	//1.1 spars
	size=400;
	range=1000000;
	printf("\n**************** narrow range spars1 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	//range_test("rage_test diverging...",size,range,1);


	size=400;
	range=4000000;
	printf("\n**************** narrow range spars2 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	//range_test("rage_test diverging...",size,range,1);
	
	//1.2 dense
	size=800000;
	range=80000;
	printf("\n**************** narrow range dense1 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	//range_test("rage_test diverging...",size,range,1);
	
	size=4000000;
	range=8000000;
	printf("\n**************** narrow range dense2 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	//range_test("rage_test diverging...",size,range,1);

	//***********2.testing wide ranges***********
	//2.1 spars
	size=400;
	range=cJU_ALLONES;//(2~32)-1
	printf("\n**************** wide range spars1 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	range_test("rage_test diverging...",size,range,1);

	size=4000;
	range=cJU_ALLONES;//(2~32)-1
	printf("\n**************** wide range spars2 ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	range_test("rage_test diverging...",size,range,1);



	//2.2 dense
	size=10000000;
	range=cJU_ALLONES;//(2~32)-1
	printf("\n**************** wide range dense ****************\n");
	kvp_test("kvp_test...",size,range);
	coverage_test("coverage_test...",size,range);
	range_test("rage_test common prefix...",size,range,0);
	range_test("rage_test diverging...",size,range,1);

}
