/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Maryam Ladjvardi, UDBL
 * $RCSfile: bk_helpfunc.h,v $
 * $Revision: 1.4 $ $Date: 2005/03/11 14:07:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description: declarations which are used in bk_foreign.c file
 *
 ****************************************************************************/

#ifndef	_bk_helpfunc_h_
#define	_bk_helpfunc_h_

#include<sys/types.h>
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
#include<errno.h>
#include<math.h>
#include<float.h>

#include"callin.h"
#include"callout.h"
#include"db.h"

#define MAX_BK_HANDLE  100
#define MAX_NAME_LENGTH 30
#define MAX_KEY_LENGTH 1024
#define MAX_DATA_LENGTH 1024

#define MAXINT 21474883647
   //Maximum value which can be stored in an int variable
#define MAX_DBL_EXP 256

union inumber{
  int i32;
  unsigned char bytes[sizeof(int)];
}ui ;

union snumber{
  short int s16;
  unsigned char bytes[sizeof(short int)];
}us ;

/* Each element of above array is a pointer to this structure witch 
   contains information about metadata */
typedef struct attribute{
  int type;
  char name[20];
  int  size;
}attribute_t;

int no_of_table;
DB dbp_array[10];

typedef struct btree_info{
  char filename[MAX_NAME_LENGTH];
  char btreename[MAX_NAME_LENGTH];
  DB  *dbp;
  attribute_t *attr_key[40];
  attribute_t *attr_data[40];
  int keyspec;       //used to specified duplictate or unique
  int primkeyNO;     //number of attributes i key
  int noprimkeyNO;   //number of attributes i data
}btree_info_t;

union fnumber{
  double d64;
  unsigned char bytes[sizeof(float)];
}u ;

btree_info_t *bk_handles[MAX_BK_HANDLE];     //An Array of btree_info type


typedef struct bk_buf{
	int size;
	int pos;
	char *buf;
}bk_buf_t;
/////////////////7
typedef struct hanld_tpl{
	int index;
	DB *dbp;
	DBC *dbcp;
}handle_tpl_t;
///////////////////

typedef struct handle_db{
	DB *dbp;
}handle_db_t;
 
handle_db_t *handle_array[500];

int test_endian();

attribute_t *parsing_descr(char *);

void pars_data(DBT *, a_tuple, int );

int bk_open(char *, char *);

void bk_normal_int(unsigned, char *);

void bk_normalinvers_int(char *, char *);

void bk_normalinvers_shortint(char *, char *);

unsigned bk_encode(int);

int	bk_decode(unsigned int);

void double_Bits(double , unsigned char *);

void bk_encode_double(double, char *, unsigned char *);

int bk_decode_exp(short int);

double bk_decode_double(double);

void bk_normalinvers_double(char *, char *);
void commit();
void rollback();

void *bk_realloc(void *,int);
void *bk_malloc(int);

#endif /* _bk_helpfunc_h */
