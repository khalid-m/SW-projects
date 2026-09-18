/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Thanh Truong, UDBL
 * $RCSfile: mexmeda.c,v $
 * $Revision: 1.6 $ $Date: 2013/08/06 16:21:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mexima meta-data
 * ========================================================================
 * $Log: mexmeda.c,v $
 * Revision 1.6  2013/08/06 16:21:20  thatr500
 * added check when index type is not available
 *
 * Revision 1.5  2011/12/29 08:48:23  thatr500
 * add new line at the end of file
 *
 * Revision 1.4  2011/12/24 11:50:01  thatr500
 * new design
 *
 * Revision 1.2  2011/12/03 13:04:21  thatr500
 * portable C struct
 *
 * Revision 1.1  2011/12/02 12:38:43  thatr500
 * Meta-data for MEXIMA
 * 
 *
 **************************************************************************/
#include "amos.h"
#include "mexmeda.h"
#include "mexglobvals.h"
#include "amos.h"

/*Add to medatable*/
void add_medatable(meda* m) {
	if (medatable == NULL) {
		int i;
		medatable = (meda*) malloc(sizeof(meda) * MAX_INDEX_TYPES); 
		for( i = 0; i < MAX_INDEX_TYPES; i++) {
			medatable[i].indextype = -1;
			medatable[i].storagetype = -1;
		}
	}
	medatable[m->indextype].idxprops = m->idxprops;
	medatable[m->indextype].indextype = m->indextype;
	medatable[m->indextype].storagetype = m->storagetype;
}
/*Get metadata*/
meda* get_medatable(int indextype){
	if (medatable == NULL || medatable[indextype].indextype == -1) {
		printf("Index type %d is not available \n", indextype);
		return NULL;
	}
	return &medatable[indextype];
}

meda* get_metadata(char *idxtype){
	int i;
	if (medatable != NULL ) {
		for(i = 0; i < MAX_INDEX_TYPES; i++) 
		{
			if (strcmp(idxtype, medatable[i].idxprops.name) == 0)
			{
				return &medatable[i];
			}			
		}		
	}
	return NULL;
}
