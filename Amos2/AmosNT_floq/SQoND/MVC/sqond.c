/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Andrej Andrejev, UDBL
 * $RCSfile: sqond.c,v $
 * $Revision: 1.12 $ $Date: 2013/02/08 00:46:44 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 driver module for SciSparql executable
 ****************************************************************************
 * $Log: sqond.c,v $
 * Revision 1.12  2013/02/08 00:46:44  andan342
 * Added C implementation of NMA chunk cache and NMA-PROXY-RESOLVE
 *
 * Revision 1.11  2012/03/27 10:26:56  andan342
 * Added C implementations of array aggregates
 *
 * Revision 1.10  2012/02/07 16:43:56  andan342
 * - made SOURCE() work on files with language switches
 * - changed internal language name and toploop prompt to "SPARQL"
 *
 * Revision 1.9  2012/01/23 11:20:54  andan342
 * Now compiling SSDM.DLL, and loading it as an extender
 *
 * Revision 1.8  2012/01/20 15:58:10  torer
 * make extender
 *
 * Revision 1.7  2011/12/05 14:21:05  andan342
 * Put all the wrapper code and Lisp functions interfaced from C into sparql-wrapper.lsp
 * Added parse_sparql() and sparql() function in AmosQL, (SPARQL ...) macro in Lisp
 *
 * Revision 1.6  2011/12/02 13:49:34  andan342
 * Default toploop can now be overridden by -q option in command line
 *
 * Revision 1.5  2011/12/02 00:46:43  andan342
 * - now using the complete (evaluating) parser in the toploop
 * - made SparQL the default toploop language
 * - not using any environment variables anywhere
 *
 * Revision 1.4  2011/12/01 11:52:06  andan342
 * Switched to stream-based scanner and parser.
 * ssdm -q SparQL calls Toploop with STUB functionality (translation only)
 *
 * Revision 1.3  2011/11/18 15:36:28  andan342
 * Registered SciSparQL parser in AFTER_ROLLIN hook. STUB reader and printer used in Toplook (no SciSparQL functionality available so far).
 * SciSparQL Toploop is called with ssdm -q SciSparQL
 *
 * Revision 1.2  2011/05/30 11:17:16  andan342
 * Implemented multidimensional array storage as NMA type
 *
 * Revision 1.1  2011/05/29 00:01:41  andan342
 * Added stub MS Visual Studion 6.0 project for SQoND storage extensions
 *
 * Revision 1.4  2006/02/13 07:37:48  torer
 *
 ****************************************************************************/

#include "callout.h"
#include "numarray.h"
#include "nma.h"
#include "nma_fns.h"
#include "nma_chunks.h"

#include "amos.h"

int SciSparQL_ID;

oidtype parseSciSparQL(bindtype env, flexstream *fs)
{
	oidtype parsefn = mksymbol("sparql-stream-eval");	
  oidtype res = call_lisp(parsefn,env,1,fs->stream);
  return res;
}

void printSciSparQLResult(oidtype form)
{
  release(call_lisp(mksymbol("print-sparql-result"),topframe(),1,form));
  return;
}

void enterSciSparQLMode(flexstream *fs) {}
void leaveSciSparQLMode(flexstream *fs) {}


EXPORT void a_initialize_extension(void *argv) 
{	
	SciSparQL_ID = a_define_parser("SPARQL", parseSciSparQL, printSciSparQLResult,
                                 enterSciSparQLMode, leaveSciSparQLMode);		

	a_query_language = SciSparQL_ID; 
	register_numarray();
  register_nma();
	register_nma_fns();
	register_nma_chunks();
}
