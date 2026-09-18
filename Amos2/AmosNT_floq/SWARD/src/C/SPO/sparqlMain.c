 /*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2007 Yu Cao, Tore Risch, UDBL
 * $RCSfile: sparqlMain.c,v $
 * $Revision: 1.1 $ $Date: 2007/11/22 14:58:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Driver program for SparQL parser
 * ===========================================================================
 * $Log: sparqlMain.c,v $
 * Revision 1.1  2007/11/22 14:58:21  petrini
 * Added functionality for:
 * 1. Running SparQL parser outside java for debugging purposes.
 * 2. Support for implicit 'FROM' clauses by SparQL parser.
 * 3. Regression testing of RDQL, original SparQL parser and SparQL parser.
 * 4. Handling of foreign and composite keys in SWARD.
 * 5. Handling of class instances in SWARD.
 * 6. Regression testing of foreign, composite keys and class instances.
 *
 * Revision 1.1  2007/07/24 05:55:38  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/06/12 14:32:38  torer
 * Stand-alone SparQL parser in C
 *
 ****************************************************************************/

#include "callin.h"
#include "sparqlMemory.h"
#include "sparqlUtils.h"
 
void main(int argc,char **argv)
{
  init_amos(argc,argv);
  sparql_init();
  amos_toploop("Amos");
  delete_memory();
}

























