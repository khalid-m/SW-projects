/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 SobhanB, UDBL
 * $RCSfile: JudyMapper.h,v $
 * $Revision: 
 * $State: Exp $ $Locker:  $
 *
 * Description: Judymapper interface
 * ===========================================================================
 * $Log: JudyMapper.h,v $
 * Revision 1.4  2012/03/10 15:12:50  sobso953
 * macros added to support faster key/prefix transformation
 *
 * Revision 1.3  2012/02/16 15:13:41  sobso953
 * *** empty log message ***
 *
 * Revision 1.2  2012/02/10 17:57:45  sobso953
 * Mapper logic for L/H bound completed
 *
 * Revision 1.1  2012/02/08 12:35:34  sobso953
 * *** empty log message ***
 *
 ****************************************************************************/
#include <string.h>
#include "JudyL.h"
#include "JudyPrivate1L.h"

//key specifications
#define PREFIX_LENGTH 4
typedef uint8_t PREFIX[PREFIX_LENGTH];

//initializes a PREFIX object to zero.
#define init_prefix(__prefix__)						\
{													\
	int ___i___;									\
	for(___i___=0;___i___<PREFIX_LENGTH;___i___++)	\
		__prefix__[___i___]=0;						\
}

//returns the integer representation of a prefix
//works only if the PREFIX_LENGTH is smaller than
//or equal to sizeof(int)
#define prefix_to_int(__prefix__,__out__)							\
	__out__=0;														\
	{																\
	int ___i___,__pow__;											\
	__pow__=1;														\
	for(___i___=0;___i___<PREFIX_LENGTH;___i___++)					\
		{															\
			__out__+=__prefix__[PREFIX_LENGTH - ___i___-1]*__pow__;	\
			__pow__*=256;											\
		}															\
	}

//general specification for the mapping function 
typedef int (*Judymapper) (PWord_t key,PWord_t value,void *xa);

PPvoid_t JudyMapper(Pcvoid_t  PArray,Word_t lower,Word_t upper,Judymapper fn,void *xa,PJError_t PJError);

//converts the BYTE to a word, and puts the BYTE in word[LEVEL]
#define BYTEtoWORD(BYTE,LEVEL) (      (Word_t)(BYTE)<<(PREFIX_LENGTH-LEVEL-1)*8      )

//produces the mask associated with a prefix
//at a given level
#define LEVEL_HIGH_BOUND_MASK(__LEVEL__) \
		(cJU_ALLONES>>(__LEVEL__)*cJU_BITSPERBYTE )

//generates the highest possible key the prefix
//__PRFX__ can cover
#define PREFIX_HIGH_BOUND(__PRFX__,__LEVEL__) \
		(__PRFX__ | LEVEL_HIGH_BOUND_MASK(__LEVEL__))

//generates the lowest possible key the prefix
//__PRFX__ can cover
#define PREFIX_LOW_BOUND(__PRFX__,__LEVEL__) \
		(__PRFX__ & ~(LEVEL_HIGH_BOUND_MASK(__LEVEL__)))
