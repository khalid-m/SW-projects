/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: matWrapper.c,v $
 * $Revision: 1.4 $ $Date: 2013/04/17 08:42:57 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Inerface to .MAT files
 * ===========================================================================
 * $Log: matWrapper.c,v $
 * Revision 1.4  2013/04/17 08:42:57  andan342
 * Closing .MAT file after retrieval
 *
 * Revision 1.3  2013/04/16 15:39:03  andan342
 * Involving MATLAB garbage collection after a variable is retrieved
 *
 * Revision 1.2  2012/12/17 23:29:48  andan342
 * - registering file-linke reader as Turtle extension,
 * - allowing to omit "desired type" parameter for AUTO behavior
 *
 * Revision 1.1  2012/12/17 17:34:35  andan342
 * Added reader interface for .MAT files
 *
 *
 ****************************************************************************/

/* REQUIREMENTS:
 - The following .dll locations should be *in the beginning* of system PATH:
   $(MATLAB_HOME)\runtime\win32
	 $(MATLAB_HOME)\bin
	 $(MATLAB_HOME)\bin\win32
 
 - The following .lib files are included in the project
   libmat.lib libmx.lib   in $(MATLAB_HOME)/extern/lib/win32/microsoft
   amos2.lib ssdm.lib     in $(AMOS_HOME)/bin
	*/


#include "amos.h"  //in $(AMOS_HOME)/system/include
#include "binary.h"  

#include "ssdm.h"  //in $(AMOS_HOME)/SQoND/include

#include "mat.h"  //in $(MATLAB_HOME)/extern/include

int MAT_FILE_ERROR, MAT_VAR_ERROR, MAT_MATTYPE_ERROR, MAT_DTYPE_ERROR,
    OmitUnaryDimensions = 1; //0 = none, 1 = trailing only, 2 = all

/*
void makebinaries_bbff(a_callcontext cxt, a_tuple tpl)
{ //gets binary objects' count and size, returns Bag of <Integer, Binary>
	int binaryCount = a_getintelem(tpl,0,FALSE);
	int binarySize = a_getintelem(tpl,1,FALSE);
	int i;
	a_blob theBLOB = NULL; 
	for (i=0; i<binaryCount; i++) {
		theBLOB = a_initBLOB();
		a_newBLOB(theBLOB, binarySize, FALSE);
		// contents can be filled with a_putBLOBbytes() function
		a_setintelem(tpl, 2, i, FALSE);
		a_putBLOBelem(tpl, 3, theBLOB, FALSE);
		a_emit(cxt,tpl,FALSE);
	}
}*/

/* Set the value for OmitUnaryDimensions - see global var definition comments */
oidtype setOmitUnaryDimensions(bindtype env, oidtype val)
{
	OfType(val, INTEGERTYPE, env);
	OmitUnaryDimensions = getinteger(val);
	return val;
}

/* Get the effective number of dimensions based on OmitUnaryDimensions strategy */
mwSize getReducedNDims(mwSize ndims, const mwSize *dims)
{
	int d, res = 0;
	
	if (!OmitUnaryDimensions) res = ndims;
	else for (d=ndims-1; d>=0; d--) {
		if (dims[d]>1 || (OmitUnaryDimensions==1 && res>0)) res++;
	}
	return res;
}
			
/* Assign the dimensions of NMA based on OmitUnaryDimensions strategy */
int setNMADims(oidtype nma, int nmaNDims, const mwSize *dims) 
{ //returns dimModifier that can be used for 2d sparse arrays
	int k, d = 0, dimModifier;

	for (k=0; k<nmaNDims; k++) {
		while (dims[d]==1 && OmitUnaryDimensions==2) d++;
		nma_setdim(nma, k, dims[d]);
		if (k==0) dimModifier = 2 - d; //1 if original rows are omitted, 2 otherwise
		else dimModifier = 0; //always 0 for 2d and other arrays
		d++;
	}
	return dimModifier;
}

/* Copy the contents of MATLAB array to NMA */

void copyDense_D_D(mxArray* pV, oidtype nma) 
{
	mwSize k, nelt = mxGetNumberOfElements(pV);
	double *pr = mxGetPr(pV);
	double *ps = nma_iter2pointer(nma);

	for (k=0; k < nelt; k++)
		ps[k] = pr[k];
}

void copyDense_D_I(mxArray* pV, oidtype nma) 
{
	mwSize k, nelt = mxGetNumberOfElements(pV);
	double *pr = mxGetPr(pV);
	int *ps = nma_iter2pointer(nma);

	for (k=0; k < nelt; k++)
		ps[k] = (int)(pr[k]);
}

/* Copy the contents of 2d MATLAB sparse array to NMA */
/* dimModifier: 0 = 2d array as is, 1 = map columns to rows, 2 = ignore columns */

void copySparse_D_D(mxArray* pV, oidtype nma, int dimModifier)
{	
  mwIndex *ir = mxGetIr(pV), 
	        *jc = mxGetJc(pV), j, k;
	mwSize n = mxGetN(pV);
	double *pr = mxGetPr(pV);  

	for (j=0; j<n; j++) {
		if (dimModifier != 2) nma_iter_setidx(nma, 1 - dimModifier, j); // set column index
		for (k = jc[j]; k < jc[j+1]; k++) {
			if (dimModifier != 1) nma_iter_setidx(nma, 0, ir[k]); //set row index
			*(double*)nma_iter2pointer(nma) = pr[k];	
		}
	}
}

void copySparse_D_I(mxArray* pV, oidtype nma, int dimModifier)
{	
  mwIndex *ir = mxGetIr(pV), 
	        *jc = mxGetJc(pV), j, k;
	mwSize n = mxGetN(pV);
	double *pr = mxGetPr(pV);  

	for (j=0; j<n; j++) {
		if (dimModifier != 2) nma_iter_setidx(nma, 1 - dimModifier, j); // set column index
		for (k = jc[j]; k < jc[j+1]; k++) {
			if (dimModifier != 1) nma_iter_setidx(nma, 0, ir[k]); //set row index
			*(int*)nma_iter2pointer(nma) = (int)(pr[k]);	
		}
	}
}

/* Read a variable from .MAT file into Amos */
oidtype matGetVarfn(bindtype env, oidtype filename, oidtype vname, oidtype dtype)
{
	MATFile* pmat;
	mxArray *pV;
	mxClassID classid;
	int nmatype, nmaNDims, dimModifier;
	const mwSize *dims;
	bool isSparse;
	oidtype res;

	//Check input types
	OfType(filename, STRINGTYPE, env);
	OfType(vname, STRINGTYPE, env);
	

	//Locate file & variable
	pmat = matOpen(getstring(filename), "r");
	if (!pmat) lerror(MAT_FILE_ERROR, filename, env);

	pV = matGetVariable(pmat, getstring(vname));
	if (!pV) lerror(MAT_VAR_ERROR, vname, env);	

	//Adjust types
	if (dtype==nil) nmatype = NMA_AUTO; //default value
	else {
		OfType(dtype, INTEGERTYPE, env);
		nmatype = getinteger(dtype);
	}
	classid = mxGetClassID(pV);
	if (nmatype==NMA_AUTO) 
		switch(classid) {
		case mxDOUBLE_CLASS:
			nmatype = NMA_DOUBLE;
			break;
		//TODO: handle more MAT classes!
		default:
			mxDestroyArray(pV);
			matClose(pmat);
			lerror(MAT_MATTYPE_ERROR, dtype, env);		
	}

	//Analyze dimensions & sparsity
	dims = mxGetDimensions(pV);
	nmaNDims = getReducedNDims(mxGetNumberOfDimensions(pV), dims);
	isSparse = mxIsSparse(pV);

	if (!nmaNDims) 
		//Return atomic value
		switch (classid) { 
		case mxDOUBLE_CLASS:
			switch (nmatype) {
			case NMA_DOUBLE:
				if (isSparse && !mxGetPr(pV)) res = mkreal(0.0); //1x1 empty sparse array
				else res = mkreal(*(double*)mxGetPr(pV));
				break;
			case NMA_INTEGER:
				if (isSparse && !mxGetPr(pV)) res = mkinteger(0); //1x1 empty sparse array
				res = mkinteger((int)(*(double*)mxGetPr(pV)));
				break;
			default:
				mxDestroyArray(pV);
				matClose(pmat);
				lerror(MAT_DTYPE_ERROR, dtype, env);
				return nil;
			} 			
			//TODO: handle more MAT classes!
		default:
			mxDestroyArray(pV);
			matClose(pmat);
			lerror(MAT_MATTYPE_ERROR, dtype, env);			
			return nil;
	} else { 
		//Return NMA
		res = make_nma0(nmaNDims);
		dimModifier = setNMADims(res, nmaNDims, dims);

		// MATLAB arrays are stored in column-major order, NMA is row-major by default, 
		// but can be reversed with '1' option - that's what we do when reading non-sparse arrays
		nma_init(res, nmatype, !isSparse); 
		if (!isSparse) nma_iter_reset(res); //when reading sparse arrays, we supply indexes for each element

		switch(classid) {
		case mxDOUBLE_CLASS:
			switch (nmatype) {
			case NMA_DOUBLE:
				if (isSparse) copySparse_D_D(pV, res, dimModifier);
				else copyDense_D_D(pV, res);
				break;
			case NMA_INTEGER:
				if (isSparse) copySparse_D_I(pV, res, dimModifier);
				else copyDense_D_I(pV, res);
				break;
			default:
				mxDestroyArray(pV);
				matClose(pmat);
				a_free(res);
				lerror(MAT_DTYPE_ERROR, dtype, env);
			} break;
		//TODO: more MATLAB classes
		default:
			mxDestroyArray(pV);
			matClose(pmat);
			a_free(res);
			lerror(MAT_MATTYPE_ERROR, dtype, env);			
		}			
	}
	mxDestroyArray(pV);
	matClose(pmat);
	return res;
}


EXPORT void a_initialize_extension(void *argv) 
{	
	MAT_FILE_ERROR = a_register_error("Cannot read file");
	MAT_VAR_ERROR = a_register_error("Cannot read variable");
	MAT_MATTYPE_ERROR = a_register_error("Unsupported MATLAB type");
	MAT_DTYPE_ERROR = a_register_error("Unsupported desired type");

	extfunction1("mat-set-omit-unary-dims", setOmitUnaryDimensions);
	extfunction3("mat-get-var", matGetVarfn);

//	a_extfunction("MakeBinaries--++",makebinaries_bbff);
}
