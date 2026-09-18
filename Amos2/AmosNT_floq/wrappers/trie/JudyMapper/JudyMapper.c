
/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 sobhanb, UDBL
 * $RCSfile: JudyMapper.c,v $
 * $Revision: 1.15 $ $Date: 2012/08/05 15:27:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Mapper for Judy tries
 * ===========================================================================
 * $Log: JudyMapper.c,v $
 * Revision 1.15  2012/08/05 15:27:52  sobso953
 * 1.The root level leafs are supported/tested now. 2. some comments removed.
 *
 * Revision 1.14  2012/03/10 15:11:42  sobso953
 * Passes all 24 tests now
 *
 * Revision 1.13  2012/02/22 17:15:02  sobso953
 * Passes kvp_test()s and coverage_test()s
 *
 * Revision 1.12  2012/02/16 15:13:13  sobso953
 * Ket formation bug fixed
 *
 * Revision 1.11  2012/02/10 17:57:11  sobso953
 * Mapper logic for L H bounds completed
 *
 * Revision 1.10  2012/02/08 16:18:52  sobso953
 * range bundries enforced on internal nodes.
 *
 * Revision 1.9  2012/02/07 14:48:28  sobso953
 * prefix updated before all judymap0 calls
 *
 * Revision 1.8  2012/02/02 18:01:15  sobso953
 * Support for prefix added
 *
 * Revision 1.7  2012/01/26 14:55:09  sobso953
 * Support for LEFW added
 *
 * Revision 1.6  2012/01/25 18:21:30  sobso953
 * Problem with traversing bitmap nodex fixed
 *
 * Revision 1.5  2012/01/23 18:32:56  sobso953
 * maping function added
 *
 * Revision 1.4  2012/01/20 17:16:45  sobso953
 * Over simplified 'mapper' that covers the whole tree and
 * prints out all values introduced
 *
 * Revision 1.3  2012/01/19 15:20:29  sobso953
 * step1: Internal nodes are processed in a full mapper
 *
 * Revision 1.2  2012/01/18 16:09:15  sobso953
 * Mapper skeleton constructed.
 * Def-lib warning resolved.
 *
 * Revision 1.1  2012/01/18 13:22:06  sobso953
 * Judy mapper project added
 *
 *
 ****************************************************************************/


#include "JudyMapper.h"

#ifdef __DEBUG__
int cntLL=0;//number of linera leafs
int cntBL=0;//number of bitmap leafs
int cntIL=0;//number of immediate leafs
int cntNothandeled;//number of pointers that are not handeled
#endif


//this function is recursively called to process sub-tries
FUNCTION PPvoid_t JudyMap0(
						   Pjp_t     Pjp,
						   Word_t    lower,
						   Word_t    upper,
						   Word_t    prefix,
						   int level,
						   Judymapper fn,
						   void *xa,

						   PJError_t PJError       // optional, for returning error info.
						   )
{
	int i;
	Pjll_t    Pjll;//used in linear leafs
	Word_t    Pop1;//used in linear leafs
	Word_t    DCD=0;//keeps decode bytes of a branch
	Word_t Prefix_High_Bound;//holds the biggest key that is addressed by Prefix
	Word_t Prefix_Low_Bound;//holds the smallest key that is addressed by Prefix
	Word_t prefix_next=0;
	int L,H;//L and H specify the limit for the search in the current node

	//1.find out the range that has to be travesred in this level/node
	
	//1.1 find the total range that the current node covers:[Prefix_Low_Bound,Prefix_High_Bound]
	
	Prefix_High_Bound=PREFIX_HIGH_BOUND(prefix,level);
	Prefix_Low_Bound=prefix;
	//1.2 find the lower(L) and upper(H) bounds for  traversing the current node
	if(Prefix_Low_Bound>=lower)
		L=0;// => traverse the whole expanse
	else
		L=JU_DIGITATSTATE(lower,PREFIX_LENGTH-level);
		// it was L=lower[level];

	if(upper>=Prefix_High_Bound)
		H=255;// => traverse the whole expanse
	else
		H=JU_DIGITATSTATE(upper,PREFIX_LENGTH-level);
		// it was H=upper[level];
	
	if (Pjp==NULL) return NULL;
	//process each node/branch depending on the node type

	switch (JU_JPTYPE(Pjp))
	{
		case 0: goto ReturnCorrupt;     // save a little code.

		case cJU_JPNULL1:
		case cJU_JPNULL2:
		case cJU_JPNULL3:
			assert(ParentJPType >= cJU_JPBRANCH_U2);
            assert(ParentJPType <= cJU_JPBRANCH_U);
			JUDYLCODE(return((PPvoid_t) NULL);)

		// ****************************************************************************
		// JPBRANCH_L*:
		//
		// Note:  The use of JU_DCDNOTMATCHINDEX() in branches is not strictly
		// required,since this can be done at leaf level, but it costs nothing to do it
		// sooner, and it aborts an unnecessary traversal sooner.

		case cJU_JPBRANCH_L2:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(2);
			if (level!=2)//some bytes are skipped, consider DCD
			{
				prefix_next=prefix+DCD;
				level=2;
			}
			goto JudyBranchL;
        case cJU_JPBRANCH_L3:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(3);
			if (level!=1)//some bytes are skipped, consider DCD
			{
				prefix_next=prefix+DCD;
				level=1;
			}
			goto JudyBranchL;
		case cJU_JPBRANCH_L:
		{
            Pjbl_t Pjbl;
			
			prefix_next=prefix;//no DCD needed here

		// Common code for all BranchLs;
JudyBranchL:        	
			
            Pjbl = P_JBL(Pjp->jp_Addr);

			//If the expanse is more grain than the current level,
			//do not map, instead go down in the branch.

			//check all jps, but cover the <L,H> range only
			for (i=0;i<Pjbl->jbl_NumJPs;i++)
				if (L<=Pjbl->jbl_Expanse[i] && Pjbl->jbl_Expanse[i]<=H)//The node is within <L,H>
				{
					prefix_next=prefix+BYTEtoWORD(Pjbl->jbl_Expanse[i],level);
					JudyMap0( &(Pjbl->jbl_jp[i]),lower,upper,prefix_next,level+1,fn,xa,PJError);
				}
			
			break;
        }
		// ****************************************************************************
		// JPBRANCH_B*:
		case cJU_JPBRANCH_B2:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(2);

			prefix_next=prefix;
			if (level!=2)//some bytes are skipped, consider DCD
			{
				prefix_next+=DCD;
				level=2;
			}
			goto JudyBranchB;
		case cJU_JPBRANCH_B3:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(3);
			prefix_next=prefix;
			if (level!=1)//some bytes are skipped, consider DCD
			{
				prefix_next+=DCD;
				level=1;
			}
			goto JudyBranchB;
		case cJU_JPBRANCH_B:
        {
            Pjbb_t    Pjbb;
			int j,ptr;
			Pjp_t subexPjp;
			int L2,H2;

            BITMAPB_t BitMap;   // for one subexpanse.
            BITMAPB_t BitMask;  // bit in BitMap for Indexs Digit.
			Word_t prefix_tmp;
			
			prefix_next=prefix;//no DCD to append

// Common code for all BranchBs;
JudyBranchB:
            Pjbb   = P_JBB(Pjp->jp_Addr);
			
			//If the expanse is more grain than the current level,
			//do not map, instead go down in the branch.

			prefix_tmp=prefix_next;
			//process branches that fall within <L,H>
			for (i=(int)(L/cJU_BITSPERSUBEXPB);i<=(int)(H/cJU_BITSPERSUBEXPB);i++)
			{
				//extract the number of values in this bitmap expanse
				subexPjp=Pjbb->jbb_jbbs[i].jbbs_Pjp;
				BitMap=Pjbb->jbb_jbbs[i].jbbs_Bitmap;

				if(subexPjp!=NULL && BitMap)//some bits are set
				{
					ptr=0;
					
					if(L<(int)(i*cJU_BITSPERSUBEXPB))
						L2=0;
					else
						L2=(L%cJU_BITSPERSUBEXPB);
					
					if(H>(int)((i+1)*cJU_BITSPERSUBEXPB-1))
						H2=cJU_BITSPERSUBEXPB-1;
					else
						H2=(H%cJU_BITSPERSUBEXPB);
					
					//process branches that fall within <L,H>
					for(j=L2;j<=H2;j++)
					{
						BitMask = JU_BITPOSMASKB(j);//make a mask for bit j
						

						if(BitMask & BitMap)//bit j on bitmap is set
						{
							ptr = j__udyCountBitsB(BitMap & (BitMask - 1));
							prefix_next=prefix_tmp+BYTEtoWORD(i*cJU_BITSPERSUBEXPB+j,level);
						 	JudyMap0( &subexPjp[ptr],lower,upper,prefix_next,level+1,fn,xa,PJError);
						}
					}
				}
			}
			break;
        } // case cJU_JPBRANCH_B*

		// ****************************************************************************
		// JPBRANCH_U*:
		case cJU_JPBRANCH_U:
			prefix_next=prefix;
			goto JudyBranchU;
		case cJU_JPBRANCH_U3:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(3);
			if (level!=1)//some bytes are skipped, consider DCD
			{
				prefix_next=prefix+DCD;
				level=1;
			}
			else
				prefix_next=prefix;
			goto JudyBranchU;
		case cJU_JPBRANCH_U2:
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(2);
			if (level!=2)//some bytes are skipped, consider DCD
			{
				prefix_next=prefix+DCD;
				level=2;
			}
			else
				prefix_next=prefix;
JudyBranchU:
			{
			Pjbu_t Pjbu;
			Word_t prefix_tmp;
			Pjbu= P_JBU(Pjp->jp_Addr);
			
			//If the expanse is more grain than the current level,
			//do not map, instead go down in the branch.

			//process branches that fall within <L,H>
			prefix_tmp=prefix_next;
			for (i=L;i<=H;i++)
			{
				prefix_next=prefix_tmp+BYTEtoWORD(i,level);
				JudyMap0(&(Pjbu->jbu_jp[i]),lower,upper,prefix_next,level+1,fn,xa,PJError);
			}
			break;
		}
		// ****************************************************************************
		// JPLEAF*:

		case cJU_JPLEAF1:
		{
			uint8_t *P_leaf;
			Word_t Index;
			

			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(1);

			Pop1 = JU_JPLEAF_POP0(Pjp) + 1;
			Pjll = P_JLL(Pjp->jp_Addr);
			
			P_leaf = (uint8_t *)(Pjll);

			
			for(i=0;i<(int)Pop1;i++)
			{
				Index=prefix;
				Index+=*P_leaf;
				if (lower<=Index && Index<=upper)
					(*fn)(&Index,(PWord_t) (JL_LEAF1VALUEAREA(Pjll, Pop1) + i),xa);
				P_leaf++;
			}

			#ifdef __DEBUG__
			cntLL++;
			#endif

			break;
		}
		case cJU_JPLEAF2:
		{
			uint16_t *P_leaf;
			Word_t Index;
			
			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(2);

			Pop1 = JU_JPLEAF_POP0(Pjp) + 1;
            Pjll = P_JLL(Pjp->jp_Addr);
			
			P_leaf = (uint16_t *)(Pjll);
			
			for(i=0;i<(int)Pop1;i++)
			{
				Index=prefix;
				Index+=*P_leaf;
				if (lower<=Index && Index<=upper)
					(*fn)(&Index,(PWord_t) (JL_LEAF2VALUEAREA(Pjll, Pop1) + i),xa);
				P_leaf++;
			}
			
			#ifdef __DEBUG__
			cntLL++;
			#endif

			break;
			
		}
		case cJU_JPLEAF3:
        {
			uint8_t *P_leaf;
			Word_t Index,partial_index;

			Pop1 = JU_JPLEAF_POP0(Pjp) + 1;
            Pjll = P_JLL(Pjp->jp_Addr);
			
			P_leaf = (uint8_t *)(Pjll);
			
			for(i=0;i<(int)Pop1;i++)
			{
				Index=prefix;
				JU_COPY3_PINDEX_TO_LONG(partial_index,&P_leaf[i * 3]);//get the partial key
				Index+=partial_index;//merge

				if (lower<=Index && Index<=upper)
					(*fn)(&Index,(PWord_t) (JL_LEAF3VALUEAREA(Pjll, Pop1) + i),xa);
			}
			
			#ifdef __DEBUG__
			cntLL++;
			#endif
			
			break;
        }
		// ****************************************************************************
		// JPLEAF_B1:
		case cJU_JPLEAF_B1:
		{
			Pjlb_t    Pjlb;
			int j;
			Pjv_t     Pjv;//pointer to value list
			Word_t Index;
            BITMAPB_t BitMap;   // for one subexpanse.
            BITMAPB_t BitMask;  // bit in BitMap for Indexs Digit.
			int posidx;

			Pjlb = P_JLB(Pjp->jp_Addr);

			DCD= JU_JPDCDPOP0(Pjp) & cJU_DCDMASK(1);
			
			for (i=(int)(L/cJU_BITSPERSUBEXPB);i<=(int)(H/cJU_BITSPERSUBEXPB);i++)
			{
				Pjv=Pjlb->jLlb_jLlbs[i].jLlbs_PValue;
				BitMap=Pjlb->jLlb_jLlbs[i].jLlbs_Bitmap;

				if(Pjv!=NULL && BitMap)//some bits are set
				{
					posidx =0;
					//This is not the most efficient as it considers all
					//keys in the range possible room for improvement...
					for(j=0;j<cJU_BITSPERSUBEXPB;j++)
					{
						BitMask = JU_BITPOSMASKB(j);//make a mask for bit j
						if(BitMask & BitMap)//bit j on bitmap is set
						{
							//build the Index
							Index=prefix;
							Index+=i*cJU_BITSPERSUBEXPB+j;//add digit
							
							if (lower<=Index && Index<=upper)
								(*fn)(&Index,& Pjv[posidx],xa);
							
							posidx++;
						}
					}
				}
			}
			#ifdef __DEBUG__
			cntBL++;
			#endif
			
			break;
		}
		// ****************************************************************************
		// JPIMMED*:
		
		case cJU_JPIMMED_1_01:
        case cJU_JPIMMED_2_01:
        case cJU_JPIMMED_3_01:
			{	//all immediate nodes with pop1=1 come here
				Word_t Index;
				Word_t partial_index;

				Index=prefix;
				partial_index=JU_JPDCDPOP0(Pjp);
				partial_index=partial_index<<level*8;//to remove the unnesasary bits
				partial_index=partial_index>>level*8;//to remove the unnesasary bits

				Index+=partial_index;

				if (lower<=Index && Index<=upper)
					(*fn)(&Index,&((Word_t) Pjp->jp_Addr),xa);
				#ifdef __DEBUG__
				cntIL++;
				#endif
					
				break;
			}
//Immediate nodes with pop1>1 come here
		case cJU_JPIMMED_1_03:
			{
				Word_t Index;
				Index=prefix;
				Index+=((uint8_t *)Pjp->jp_LIndex)[2];
				if (lower<=Index && Index<=upper)
					(*fn)(&Index,(P_JV((Pjp)->jp_Addr) + 2),xa);
			}
        case cJU_JPIMMED_1_02:
		{
			Word_t Index;

			Index=prefix;
			
			Index+=((uint8_t *)Pjp->jp_LIndex)[1];
			if (lower<=Index && Index<=upper)
				(*fn)(&Index,(P_JV((Pjp)->jp_Addr) + 1),xa);
			
			Index=prefix;
			Index+=((uint8_t *)Pjp->jp_LIndex)[0];

			if (lower<=Index && Index<=upper)
				(*fn)(&Index,(P_JV((Pjp)->jp_Addr) + 0),xa);
			
			#ifdef __DEBUG__
			cntIL++;
			#endif
			break;
		
		}
		default :
				#ifdef __DEBUG__
				cntNothandeled++;
				#endif


ReturnCorrupt:
		JU_SET_ERRNO(PJError, JU_ERRNO_CORRUPT);
		JUDY1CODE(return(JERRI );)
		JUDYLCODE(return(PPJERR);)

		
		
	}
	return NULL;

}

//processes trie root
//passes sub-trie pointer to the recursive traversal function JudyMap0
FUNCTION PPvoid_t JudyMapper(
							 Pcvoid_t  PArray,       // from which to retrieve.
							 Word_t    lower,
							 Word_t    upper,
							 Judymapper fn,
							 void *xa,
							 PJError_t PJError       // optional, for returning error info.
							 )
{
	Pjp_t     Pjp;          // current JP while walking the tree.
	Pjpm_t    Pjpm;         // for global accounting.
	PPvoid_t result;
	Word_t prefix=0;

	if (PArray == (Pcvoid_t) NULL)  // empty array.
	{
		JUDY1CODE(return(0);)
		JUDYLCODE(return((PPvoid_t) NULL);)
	}

	if (JU_LEAFW_POP0(PArray) < cJU_LEAFW_MAXPOP1) // must be a LEAFW
	{
		Pjlw_t Pjlw = P_JLW(PArray);        // first word of leaf.
		Word_t   Index;
		Word_t * PValue;

        //map all elements in LEAFW using JLN
		//This can be improved by iterating over
		//the LEAFW node instead of calling JLN
		Index = 0;
		JLF(PValue, PArray, Index);
		while (PValue != NULL)
		{
			if(Index>=lower && Index<=upper)
				(*fn) (&Index,PValue,xa);
			JLN(PValue, PArray, Index);
		}
		
		JUDY1CODE(return(0);)
		JUDYLCODE(return((PPvoid_t) NULL);)
	}
	
	Pjpm = P_JPM(PArray);
	Pjp = &(Pjpm->jpm_JP);  // top branch is below JPM.
	
	result= JudyMap0(Pjp,lower,upper,prefix,0,fn,xa,PJError);
	
	#ifdef __DEBUG__
	printf("number of leafs: Linear: %d, Bitmap: %d, Immediate: %d nothandeled: %d\n",cntLL,cntBL,cntIL,cntNothandeled);
	#endif

	return result;
}
