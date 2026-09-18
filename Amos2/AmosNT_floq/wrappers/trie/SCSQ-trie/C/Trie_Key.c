/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: Trie_Key.c,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:03 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Alisp driver functions for making integer keys
 * for tries in the Linear Road Benchmark
 * ===========================================================================
 *
 ****************************************************************************/
#include "Trie_Key.h"

////////////////////////////////////////////////////////////////////////////////////
//Extra functions that convert vector keys to trie keys(integers) in LRB
////////////////////////////////////////////////////////////////////////////////////

//Takes vector of numbers (s x d vehicle) and maps it to a unique representative integer
oidtype trie_key(bindtype env, oidtype vector_key){
	int s, x, d, v;
	
	if (!arrayp(vector_key)){//do not return any value if the argument is not an array
		printf("Argument is not an array\n");
		return nil;
	}
	//it is assumed that x is 4 bits long, d is one bit, s is 7 bits long.
	//remaining 20 bits are reserved for vehicle id
	//the bitmap is xdsv, with x taking the highest bit values and v the lowest
	IntoInteger(a_elt(vector_key,0),s,env);
	IntoInteger(a_elt(vector_key,1),x,env);
	IntoInteger(a_elt(vector_key,2),d,env);
	IntoInteger(a_elt(vector_key,3),v,env);
	x=x<<28;
	//printf("x after shift:%d\n",x);
	d=d<<27;
	//printf("d after shift:%d\n",d);
	//printf("s before shift:%d\n",s);
	s=s<<20;
	//printf("s after shift:%d\n",s);

	return mkinteger(x|d|s|v);
}

//Takes vector of numbers eg. (s x d *) and returns the trie key representing the buttom of the range
oidtype trie_low_range(bindtype env, oidtype vector_key){
	//set vehicle id to 0;
	a_seta(vector_key,3,mkinteger(0));
	return trie_key(env,vector_key);
	
}
//Takes vector of numbers eg. (s x d *) and returns the trie key representing the top of the range
oidtype trie_high_range(bindtype env, oidtype vector_key){
	//set vehicle id to 1048575,the biggest possible vehicle id
	a_seta(vector_key,3,mkinteger(1048575));
	return trie_key(env,vector_key);
}

void Bind_Trie_Key()
{
	extfunction1("trie-key",trie_key);
	extfunction1("trie-high-range",trie_high_range);
	extfunction1("trie-low-range",trie_low_range);
}

/*Code for forming '64'bit trie keys*/
void bin_prnt_byte(int x)
{
   int n;
   for(n=0; n<8; n++)
   {
      if((x & 0x80) !=0)
      {
         printf("1");
      }
      else
      {
         printf("0");
      }
      if (n==3)
      {
         printf(" "); /* insert a space between nybbles */
      }
      x = x<<1;
   }
}

void bin_prnt_int(int x)
{
   int hi, mid1, mid2, lo;
   hi=(x>>24) & 0xff;
   mid1=(x>>16) & 0xff;
   mid2=(x>>8) & 0xff;
   lo=x&0xff;
   bin_prnt_byte(hi);
   printf(" ");
   bin_prnt_byte(mid1);
   printf(" ");
   bin_prnt_byte(mid2);
   printf(" ");
   bin_prnt_byte(lo);
   printf("\n");
}
void bin_prnt_int64(__int64 x)
{
   int b1, b2, b3, b4, b5, b6, b7, b8;

   b1=(int)(x>>56) & 0xff;
   b2=(int)(x>>48) & 0xff;
   b3=(int)(x>>40) & 0xff;
   b4=(int)(x>>32) & 0xff;
   b5=(int)(x>>24) & 0xff;
   b6=(int)(x>>16) & 0xff;
   b7=(int)(x>>8) & 0xff;
   b8=(int)(x & 0xff);

   bin_prnt_byte(b1); printf(" ");
   bin_prnt_byte(b2); printf(" ");
   bin_prnt_byte(b3); printf(" ");
   bin_prnt_byte(b4); printf(" ");
   bin_prnt_byte(b5); printf(" ");
   bin_prnt_byte(b6); printf(" ");
   bin_prnt_byte(b7); printf(" ");
   bin_prnt_byte(b8); printf(" ");
   printf("\n");
}

//constructs a 64 bit key in an __int64 data type
void int64key(int s, int x,int d,int v, __int64* result)
{
	*result=(x<<1)|d;//7 bits for x
	printf("after xd \n");
	bin_prnt_int64(*result);
	*result=*result<<8;
	printf("after xd shift\n");
	bin_prnt_int64(*result);
	*result=*result|s;
	printf("after s \n");
	bin_prnt_int64(*result);
	*result=*result*16777216;//equivalant of 24 bit left shift (max 24 bits for v)
	printf("after s shift\n");
	bin_prnt_int64(*result);

	*result=*result+v;
	//0xffffffffffffffff

	printf("after v \n");
	bin_prnt_int64(*result);
	printf("output of int64key: %I64d \n",*result);
	//return result;
	
	
	
	//return (((((x<<1)|d)<<8)|s)<<24)|v;
}

void cons_64_trie_key(int x,int d, int s, int v, uint8_t* key)
{
	key[0]=((x<<1)|d);
	key[1]=s;
	key[2]=(uint8_t)((v&0xff0000)>>16);
	key[3]=(uint8_t)((v&0xff00)>>8);
	key[4]=(uint8_t)(v&0xff);
	return;
}

void cons_64_BT_key  (int m, int x,int d, int s, int v, __int64* result)
{
	*result=m;
	*result=*result<<8;//one byte for m
	*result=*result|((x<<1)|d);//7 bits for x, one for d
	*result=*result<<8;//one byte for s
	*result=*result|s;
	*result=*result*16777216;//equivalant of 24 bit left shift (24 bits for v)
	*result=*result+v;
	//bin_prnt_int64(*result);
	return;
}
//comapre two key strings (a b) if a>b return 1, if a<b return -1 if a=b return 0
int compare_trie_keys(uint8_t* a,uint8_t* b)
{
	int i;
	for (i=0;i<5;i++)
	{
		if(a[i]>b[i])
			return 1;
		if(a[i]<b[i])
			return -1;
	}

	//implies a[i]==b[i] for all i 
	return 0;
}