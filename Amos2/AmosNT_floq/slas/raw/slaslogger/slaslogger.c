/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Thanh Truong, UDBL
 * $RCSfile: slaslogger.c,v $
 * $Revision: 1.1 $ $Date: 2013/12/12 16:29:34 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Log incoming stream tuple and put smart index on the log file
 * ===========================================================================
 * $Log: slaslogger.c,v $
 * Revision 1.1  2013/12/12 16:29:34  thatr500
 * rev23. Compiled on MacOSX 10.8.4
 *
 *
 ****************************************************************************/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "slaslogger.h"


#undef NUM_ROWS_IN_BLOCK
#define  NUM_ROWS_IN_BLOCK 10000
#define  NUM_ROWS_IN_BUFFER 2500

struct WriterInfo
{
	FILE*fh;           // file handle 
	double* buffer;
	size_t nrows_per_block; // number of rows per block
	size_t ncolumns;        // number of columns  
	size_t attribute_size;  // attribute size in bytes
	size_t buffer_length;   // length of buffer 
	size_t nrows_per_buffer; 
	unsigned int rowcount;     // number of rows has been filled in buffer
	unsigned int nwrite;       // number of writes for a given stream 
	unsigned int indexedpos;
        LofixP * lx;
	spos_t offset_startblock;
	spos_t offset_endblock;
	unsigned int blockno;
};

int flushBuffer(struct WriterInfo* winf){
	int endblock = FALSE;
	int startblock = FALSE;
	
	int totalWrite = 0;
	// Buffer is not empty ?
	if (winf->rowcount != 0) { 
		
		winf->nwrite = winf->nwrite + 1;
		slas_print("...buffer # %d \n", winf->nwrite);
		
		startblock = (winf->nwrite % (winf->nrows_per_block / winf->nrows_per_buffer) == 1) ? TRUE:FALSE;
		endblock = (winf->nwrite % (winf->nrows_per_block / winf->nrows_per_buffer) == 0) ? TRUE:FALSE;
		
		if (startblock == TRUE){
			winf->blockno = winf->blockno + 1;
			winf->offset_startblock = sftell(winf->fh) ;
			printf("Startblock here %llu.... ",winf->offset_startblock );
		}

		// Write to file
		totalWrite = writeBuffer(winf->fh, winf->buffer, winf->rowcount, 
							winf->ncolumns, winf->attribute_size);

		if (endblock == TRUE){
			struct LBValue *lbv;
			winf->offset_endblock = sftell(winf->fh);
			printf("End block %llu....\n", winf->offset_endblock);
			lbv = (LBValue*) malloc(sizeof(*lbv));
			// Indexing the complete block
			lbv->indexedPos = winf->indexedpos;
			lbv->maxIndexedAtt = 0;
			lbv->minIndexedAtt = 0;
			lbv->offset_start = winf->offset_startblock;
			lbv->offset_end = winf->offset_endblock;

			lofixP_insert(winf->lx, (void*) winf->blockno, lbv, NULL);
		}

	}	
	winf->rowcount = 0; 
	return totalWrite;
}

oidtype writetupleMapper(a_callcontext cxt, int width, oidtype res[],void *xa)
{ 
  oidtype orow; // original row from stream
  unsigned int rowsize, i;
  struct WriterInfo* winf;

  winf = (struct WriterInfo*) xa;
  orow = res[0];
  if (arrayp(orow)) 
  {
	  	/*Start filling the buffer*/
		if (winf->rowcount == 0) {
			slas_print("Filling the buffer ...");
		}
		rowsize = dr(orow, arraycell)->size; 
		if (rowsize != winf->ncolumns) {
			printf("there is a mismatch between rowsize and number of columns\n");
			return nil; // there is a mismatch between rowsize and number of columns
		}

		// continue filling in the buffer
		for (i = 0; i < rowsize ; i ++) {
			winf->buffer[winf->rowcount * rowsize + i] = getreal(dr(orow, arraycell)->cont[i]);    
		}
	  
		// increase the rowcount
		winf->rowcount = winf->rowcount + 1 ;

		/*If the buffer is full, write it down to log file*/
		if (winf->rowcount == winf->nrows_per_buffer) {
			slas_print("FULL --> Write ");
			flushBuffer(winf);
		}
  }	
  return nil;
}



/*----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------*/
oidtype slas_write_indexed_logfilebbf(a_callcontext cxt)
{
	oidtype ofname;
	oidtype b;
	oidtype oidxpos;
	char *logfilename;
	FILE*fh;
	struct WriterInfo winf;
	double* buffer;
	unsigned int indexedpos;
	LofixP *lxp;
	//LofixS *lxs;

	{unwind_protect_begin;	
	//Unbox filename and open file
	ofname = a_arg(cxt, 3);
	IntoString(ofname, logfilename, cxt->env);
	
	fh = fopen(logfilename, "w+b");
	assert_open(fh);
	
	//Unbox a bag
	b = a_arg(cxt, 1);

	//Unbox indexed position 
	oidxpos = a_arg(cxt, 2);
	IntoInteger(oidxpos, indexedpos, cxt->env);

	// Prep some writer instruction	
	winf.fh = fh;	
	winf.nrows_per_block = NUM_ROWS_IN_BLOCK;
	winf.nrows_per_buffer = NUM_ROWS_IN_BUFFER; // this will cause 2 write per block
	winf.ncolumns = COLS;
	winf.attribute_size = ATTRIBUTE_SIZE_IN_BYTES;
	winf.buffer_length = winf.nrows_per_buffer * winf.ncolumns *winf.attribute_size;
	buffer = (double*) malloc(winf.buffer_length);
	winf.buffer = buffer;
	winf.rowcount = 0;
	winf.nwrite = 0;
	winf.indexedpos = indexedpos;
	winf.blockno = 0;
	winf.offset_endblock = winf.offset_startblock = 0;
	// Prep lofixP index
	lxp = lofixP_create();
	strcpy(lxp->logfilename, logfilename);
	winf.lx = lxp;
	// Prep lofixS index
	//lxs = lofixS_create();

	// Loop over the bag and write the log file
	a_mapbag(cxt, b, writetupleMapper, &winf);

	// If the last filling did not make the buffer full, there was no write.
	// We have to flush the partial buffer to file if it is 
	flushBuffer(&winf);
	
	// last final step. Store the lx index
	g_lx[0] = *lxp;
	unwind_protect_catch; 
	fclose(fh); 
	free(buffer);
	free(lxp);
	//free(lxs);
	return nil;
	unwind_protect_end;	
	}
	return t;
}
