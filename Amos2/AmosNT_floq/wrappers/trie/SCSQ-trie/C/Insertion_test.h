/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: Insertion_test.h,v $
 * $Revision: 1.1 $ $Date: 2011/08/24 05:43:02 $
 * $State: Exp $ $Locker:  $
 *
 * Description: the Header file for the scalability comparisons between
 * HP trie (Judy) and B-tree
 * ===========================================================================
 *
 ****************************************************************************/
void gen_store_rand(int size,int range_low, int range_high);
void BT_insertion_test(int size);
void rand_insertion_test(int epoch_size,int rounds, int indextype);
void ordered_insertion_test(int epoch_size,int rounds,int indextype,int direction,int output);
double range_search_test(void* root,unsigned int low, unsigned int high, int indextype);
void read_store_LR_data(char* filename,int epoch_size);
void LR_insertion_test(char* filename,int epoch_size, long int l,int indextype);
void LR_insertion_file(char* filename,int L,int epoch_size);
void transform_to_sxdv(char* in_file,char* out_file);
void test_bt_64();
void test_hpt_64();
//void test_linh();
//void gen_hash_key(int ikey,char* hkey);