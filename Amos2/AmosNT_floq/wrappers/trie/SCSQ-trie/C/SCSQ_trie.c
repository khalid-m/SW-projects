/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Sobhan Badiozamany, UDBL
 * $RCSfile: SCSQ_trie.c,v $
 * $Revision: 1.2 $ $Date: 2012/01/16 13:08:44 $
 * $State: Exp $ $Locker:  $
 *
 * Description: main program containing all Amos2 extensions that are used in
 * the trie-based LRB
 * ===========================================================================
 *
 ****************************************************************************/
#include "alisp.h"
#include "amos.h"

#include "Trie_Key.h"
#include "NT_Drivers.h"
#include "HPT_Drivers.h"
#include "BT_Drivers.h"

#include "Insertion_test.h"

main(int argc,char **argv)
{

	//LR_insertion_file("D:\\Desktop\\thesis\\lr-trie\\data\\cardatapoints70.osql",7,500000);

	init_amos(argc,argv); /* Initialize embedded Amos and ALisp */

	//Binding general trie external functions
	Bind_Trie_Key();
	//Binding HPtrie external functions
	Bind_HPT();
	//Binding Naivetrie external functions
	Bind_NT();
	//Binding BTree external functions
	Bind_BT();

	/*** Enter Amos top loop ***/
	amos_toploop("LR-Indexing Amos2");

	return 0;
}
