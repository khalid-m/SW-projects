/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Maryam Ladjvardi, UDBL
 * $RCSfile: bk_helpfunc.c,v $
 * $Revision: 1.4 $ $Date: 2005/02/01 22:42:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: helpfunctions which are used in bk_foreign.c file
 *
 ****************************************************************************/

#include "bk_helpfunc.h"

void *bk_malloc(int size)
{
  void *res;

  res = malloc(size);
  if(res!=NULL) return res;
  fprintf(stderr,"Space exhaused\n");
  exit(1);
}

void *bk_realloc(void *x,int size)
{
  void *res;

  res = realloc(x,size);
  if(res!=NULL) return res;
  fprintf(stderr,"Space exhaused\n");
  exit(1);
}

/******************************************************************************
* parsing_descr()							      *
* Arguments: a pointer to a string                                            *
* return: datastructure attribute_t                                           *
* A helpfunction which is used for parsing of metadata to determine name, type*
* size of attribute(column of btree). Metadata is stored as strings.	      *
******************************************************************************/
attribute_t *parsing_descr(char *descr){

  char type[5];
  attribute_t *attr;

  attr = (attribute_t*)malloc (sizeof(attribute_t));	
  strtok(descr, " ");
  strcpy(attr->name, strtok(NULL, " "));
  strcpy(type, strtok(NULL, " "));
  sprintf(type ,"%s\0", type);
  attr->type = atoi(type);
  attr->size = atoi(strtok(NULL, " "));


  return attr;
}
/**************************************************
* End of helpfunction parsing_descr()             *
**************************************************/
 
/******************************************************************************
*pars_data()								      *
*Arguments: a pointer to a DBT structure, a tuple, number of primkey          *
*return: void                                                  	              *
*A helpfunction which is used to store metadata for btree on the disk.        *
*Takes input from the user and pars it and make it as string which can be     *
*stored in the metadata btree.	                                              *
******************************************************************************/
void pars_data(DBT *data, a_tuple tpl, int prim_key){


  char attr_name[50];
  char attr_type[30];
  char new_string[70];
  int size, type_spec;

  a_getstringelem(tpl, 0, attr_name, sizeof(attr_name), FALSE);
  a_getstringelem(tpl, 1, attr_type, sizeof(attr_name), FALSE);
  type_spec =  gettypeid(attr_type);
	
  switch(type_spec)
    {
    case INTEGERTYPE:
      sprintf(new_string, "%d %s 2 %d", prim_key, attr_name, sizeof(int));
      data->data =(char *) malloc (strlen(new_string) + 1);
      strcpy(data->data, new_string);
      data->size = strlen(data->data) +1;
      break;

    case REALTYPE:
      sprintf(new_string, "%d %s 3 %d", prim_key, attr_name, sizeof(double));
      data->data =(char *) malloc (strlen(new_string) + 1);
      strcpy(data->data, new_string);
      data->size = strlen(data->data) +1;
      break;

    case STRINGTYPE:
      size = a_getintelem(tpl, 2, FALSE);
      sprintf(new_string, "%d %s 6 %d", prim_key, attr_name, size);
      data->data =(char *) malloc (strlen(new_string) + 1);
      strcpy(data->data, new_string);
      data->size = strlen(data->data) +1;
      break;

    default:
      printf("type is wrong");
      exit(1);
    }

  return;
}
/**************************************************
* End of helpfunction pars_data()                 *
**************************************************/

/******************************************************************************
*bk_open()					        	              *
*Arguments: string filename and string tablename                              *
*return: int                                                   	              *
*A helpfunction which is used to match filename and tablename with handle_id  *
*if it success, return handle_id otherwise zero                               *
******************************************************************************/
   
int bk_open(char file_name[MAX_NAME_LENGTH], char btree_name[MAX_NAME_LENGTH])
{
  int i, j=0;
	
  for(i=1; i< MAX_BK_HANDLE; i++){
    if(bk_handles[i] != NULL){
      j++;
      if(!strcmp(bk_handles[i]->btreename, btree_name) &&
	 !strcmp(bk_handles[i]->filename, file_name))
	return i;}
  }
  if(j==0)
    return -1;

  return 0;
}
/**************************************************
* End of helpfunction bk_open()                   *
**************************************************/

/*************************************************************
*bk_test_endian()                                            *
*A helpfunction which is used to check which byteorder       *
* (big_endian or little_endian) our machine uses.            *
* return 1 if big_endian, otherwise return 0                 *           
*************************************************************/
int bk_test_endian()
{
  int x = 1;
  char *p;

  p = (char *)&x;
	
  if(p[0]==0)
    return 1;
  else 
    return 0;
		

}
/**************************************************
* End of helpfunction bk_test_endian()            *
**************************************************/

/******************************************************************************
*bk_normal_int() 							      *
*Arguments: an unsigned int and a char_array  of size int		      *
*return: void                                                                 *
*A helpfunction which is used to change an integer from little endian         *
* byteorder to big endian  before inseting it to database, if the machine     *
* uses little endian byteorder.                                               *
******************************************************************************/
void bk_normal_int(unsigned x, char ibuf[sizeof(int)]){

  int i;
	
  i = sizeof(int) - 1;

  //if big_endian byteorder is used, don't change ordering
  if(bk_test_endian()){
    ui.i32 = x;
    for(i ; i >= 0; i--)
      ibuf[i] = ui.bytes[i];
  }
  else
    {
      for(i ; i >= 0; i--){
	ibuf[i] = x % 256;
	x = x >> 8;}
    }
}

/**************************************************
* End of helpfunction bk_normal_int()             *
**************************************************/

/******************************************************************************
*bk_normalinvers_int()			                            	      *
*Arguments: two char_arrays  of size int		                      *
*return: void                                                                 *
*A helpfunction which is used to change an integer from big endian byteorder  *
*to little endian  before sending result to AmosII. If the machine on which   *
*AmosII run, uses little endian byteorder                                     *
******************************************************************************/
void bk_normalinvers_int(char mybuf[sizeof(int)], char ibuf[sizeof(int)]){


  int i;
  int j;

  j = sizeof(int) - 1;

  //if big_endian byteorder. don't change ordering
  if(bk_test_endian()){
    for(i = 0 ;i < sizeof(int) ;i++)
      mybuf[i] = ibuf[i];
  }
  else
    {
      for(i = 0 ;i < sizeof(int) ;i++){
	mybuf[i] = ibuf[j];
	j--;}
    }
  return;
}
/**************************************************
* End of helpfunction bk_normalinvers_int()       *
**************************************************/

/******************************************************************************
*bk_normal_shortint()							      *
*Arguments: an unsigned short int and a char_array  of size  short int        *
*return: void                                                                 *
*A helpfunction which is used to change an short integer from little endian   *
*byteorder to big endian  before inseting it to database, if the machine uses *
*little endian byteorder.                                                     *
******************************************************************************/
void bk_normal_shortint(unsigned short x, char ibuf[sizeof(short int)]){

  int i;
	
  i = sizeof(short int) - 1;

  //if big_endian byteorder is used, don't change ordering
  if(bk_test_endian()){
    us.s16 = x;
    for(i ; i >= 0; i--)
      ibuf[i] = us.bytes[i];
  }
  else
    {
      for(i ; i >= 0; i--){
	ibuf[i] = x % 256;
	x = x >> 8;}
    }
}

/**************************************************
* End of helpfunction bk_normal_int()             *
**************************************************/

/******************************************************************************
*bk_normalinvers_shortint()						      *
*Arguments: two char_arrays  of size short_int                                *
*return: void                                                                 *
*A helpfunction which is used to change an short integer from big endian      *
*byteorder to little endian  before sending result to Amos, if our machine    *
*uses little endian.                                                          *
******************************************************************************/
void bk_normalinvers_shortint(char mybuf[sizeof(short int)], 
			      char ibuf[sizeof(short int)]){


  int i;
  int j;

  j = sizeof(short int) - 1;
  //if big_endian byteorder, don't change ordering
  if(bk_test_endian()){
    for(i = 0 ;i < sizeof(short int) ;i++)
      mybuf[i] = ibuf[i];
  }
  else
    {
      for(i = 0 ;i < sizeof(short int) ;i++){
	mybuf[i] = ibuf[j];
	j--;
      }
    }
}

/**************************************************
* End of helpfunction bk_normalinvers_shortint()  *
**************************************************/

/******************************************************************************
*bk_encode()				                                      *
*Arguments: an integer		                                              *
*return: unsigned int                                                         *
*A helpfunction which is used to encode an integer by shifting it to be able  *
*to compare negative and positive integers.                                   *
*The result of encoding is a positive integer.                                *
******************************************************************************/
unsigned bk_encode(int myint){

  int temp;
  unsigned uint;

  temp = (int)MAXINT+myint;
  memcpy(&uint, &temp, sizeof(temp));
		
  return uint;
}
/**************************************************
* End of helpfunction bk_encode()                 *
**************************************************/

/******************************************************************************
*bk_decode()	        						      *
*Arguments: unsigned int		                                      *
*return: int                                                                  *
*A helpfunction which be used to decode an unsigned integer to get back a sign*
*integer.                                                                     *
*This function is an invers function of bk_encode function.                   *
******************************************************************************/
int	bk_decode(unsigned uint){

  int myint;
  int temp;
		
  memcpy(&temp, &uint, sizeof(uint));
  myint =  temp - (int)MAXINT;
	
  return myint;
}

/**************************************************
* End of helpfunction bk_decode()                 *
**************************************************/

/******************************************************************************
*double_Bits() 								      *
*Arguments: a double and a char_array  of size double		              *
*return: void                                                                 *
*A helpfunction which be used to extract big endian bit representation from   *
*a 64_bit double which has little endian bit order. If our machine uses       *
*big_endian, byteordering is not changed.                                     *
******************************************************************************/
void double_Bits(double  dbl, unsigned char dst[sizeof(double)])
{

  int i, j;

  i = sizeof(double) - 1;
  j=0;

  u.d64 = dbl;

  //if big_endian byteorder, don't change ordering
  if(bk_test_endian()){
    for(i ; i>=0 ;i--)
      dst[i] = u.bytes[i];
  }
  else
    {
      for(i; i>=0; i--){
	dst[i] = u.bytes[j];
	j++;}
    }
}

/**************************************************
* End of helpfunction double_Bits()               *
**************************************************/

/******************************************************************************
*bk_encode_double()    							      *
*Arguments: a double, a char array of size short_int and a unsigned char array*
*of size double	                                                              *
*return: void                                                                 *
*A helpfunction which is used to encode a double by breaking it to two parts  *
*a mantissa which is of double type and an expresion which is unsigned short  *
*int and then encodes two part separately.                                    *
*It is done  to be able to compare double numbers with each other             *
******************************************************************************/
void bk_encode_double(double dbl, char rbuf[sizeof(short int)], 
		      unsigned char dst[sizeof(double)])
{   
  int  e1;
  unsigned short int exp;
  double fract;
		
  fract = frexp(dbl,&e1);
	
  if(fract > 0)
    exp = (3*MAX_DBL_EXP) + e1;
  else {
    if(fract < 0)
      exp = MAX_DBL_EXP - e1;
    else
      exp = 2 * MAX_DBL_EXP;
  }
		
  fract = 1 + fract;
     
  bk_normal_shortint(exp, rbuf);
  double_Bits(fract,dst);

  return ;
}
/**************************************************
* End of helpfunction bk_encode_double()          *
**************************************************/

/******************************************************************************
*bk_decode_exp()							      *
*Arguments: a short integer		                                      *
*return: int                                                                  *
*A helpfunction which is used to decode a short integer to get back a sign    *
*integer.                                                                     *
******************************************************************************/
int bk_decode_exp(short int e){


  int exp;

  if(e > DBL_MAX_EXP /2)
    {
      exp = e -  DBL_MAX_EXP/2;
      exp = exp - DBL_MAX_EXP/4;
    }
  else{
    if(e < DBL_MAX_EXP / 2){
	
      exp = DBL_MAX_EXP/2 - e;
      exp = exp - DBL_MAX_EXP/4;
    }
    else
      exp = 0;
  }

  return exp;
}
/**************************************************
* End of helpfunction bk_encode_exp()             *
**************************************************/

/**************************************************************************
*bk_decode_double()							  *
*Arguments: double							  *
*return: double                                                           *
*A helpfunction which is used to decode an double to get back a positive  *   
* or a negaive double.                                                    *
**************************************************************************/
double bk_decode_double(double fract)
{
	

  fract = fract - 1.0;
	
  return fract;
}
/**************************************************
* End of helpfunction bk_encode_double()          *
**************************************************/

/******************************************************************************
*bk_normalinvers_double()						      *
*Arguments: two char_arrays  of size double		                      *
*return: void                                                                 *
*A helpfunction which is used to change an integer from big endian byteorder  *
*to little endian  before sending result to Amos. If our machine uses         *
*little_endian byteordering                                                   *
******************************************************************************/
void bk_normalinvers_double(char mybuf[sizeof(double)], 
			    char ibuf[sizeof(double)]){


  int i;
  int j = sizeof(double)-1;
	
  //if big_endian mybuf=ibuf dvs mybuf[i]= ibuf[i]
  if (bk_test_endian())
    { 
      for(i = 0 ;i < sizeof(double) ;i++)
	mybuf[i] = ibuf[i];
    }
  else
    {
      for(i = 0 ;i < sizeof(double) ;i++){
	mybuf[i] = ibuf[j];
	j--;
      }
    }
}
/**************************************************
* End of helpfunction bk_normalinvers_double()    *
**************************************************/

