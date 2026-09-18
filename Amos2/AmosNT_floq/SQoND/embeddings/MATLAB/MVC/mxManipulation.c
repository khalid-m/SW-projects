#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <mex.h> /* only needed because of mexFunction below and mexPrintf */
#include "mxManipulation.h"

//function declaration
mwSize *make_new_ndims(mxArray*, mwSize, mwSize);
mwSize pageOffset(const mwSize*, mwSize);
mwSize pageStep(const mwSize*, mwSize);
mwSize pageBlock(const mwSize*, mwSize, mwSize);
void page_subset(mxArray*, mxArray*, mwSize, mwSize, mwSize , mwSize);
void row_subset(mxArray*, mxArray*, mwSize, mwSize , mwSize , mwSize);
void column_subset(mxArray*, mxArray*, mwSize, mwSize, mwSize , mwSize);


/* after using convert_to_column_nma function, temp_mx_nma has to be freed by caller*/

extern mxArray* convert_to_column_nma(mxArray *temp_mx_nma)
{
	size_t page_number=1;
	double *temp_nma,*nma;
	const size_t *dims = mxGetDimensions(temp_mx_nma);
	size_t ndim = mxGetNumberOfDimensions(temp_mx_nma);
	size_t element_number_per_page = dims[0]*dims[1];
	size_t column,row,page,i;

	mxArray *new_mx_nma;
	new_mx_nma = mxCreateNumericArray(ndim, dims, mxDOUBLE_CLASS, mxREAL);

	nma = mxGetPr(new_mx_nma);
	temp_nma = mxGetPr(temp_mx_nma);

	for(i=2;i<ndim;i++)
	{
		page_number=page_number*dims[i];
	}
	for(page=0;page<page_number;page++)
	{
		for(row=0;row<dims[0];row++)
		{
			mwSize index=page*element_number_per_page+row;
			for(column=0;column<dims[1];column++)
			{
				nma[index] = *temp_nma;
				temp_nma++;
				index=index+dims[0];
			}
		}
	}
	return new_mx_nma;
}



DLL_EXPORT mxArray* convert_column2row(mxArray *temp_mx_nma)
{/*to convert an input array from Matlab column-wise stored to C row_wise stored mxArray*/
	mxArray *mx_nma;
	mxArray *new_mx_nma;
	mxArray *arg[2];
	size_t i;
	mxArray *new_dims;
	double *dims_element;
	size_t elemNum = 1;
	const size_t *dims = mxGetDimensions(temp_mx_nma);
	size_t ndim = mxGetNumberOfDimensions(temp_mx_nma);

	new_dims = mxCreateDoubleMatrix(1,ndim,mxREAL);
	dims_element = mxGetPr(new_dims);

	/*switch the 1st and 2nd dimension*/
	dims_element[0]=2;
	dims_element[1]=1;
	for(i=2;i<ndim;i++){
		dims_element[i] = i+1;
		mexPrintf("%f",dims_element[i]);
	}

	/*set the arguement for calling "transpose function"*/
	arg[0] = temp_mx_nma;
	arg[1] = new_dims;

	/*to excute matlab "permute" function
	Matlab dynmaically allocate memory for output mxArray */
	mexCallMATLAB(1,&mx_nma,2,arg,"permute"); 

	/*call reshape function*/
	dims_element[0] = dims[0];
	dims_element[1] = dims[1];
	arg[0] = mx_nma;
	arg[1] = new_dims;
	mexCallMATLAB(1,&new_mx_nma,2,arg,"reshape"); 
	mxDestroyArray(mx_nma);
	return new_mx_nma;
}



DLL_EXPORT mxArray* matFn_cwArray2rwArray(mxArray *cwArray)
{
	mxArray* rwArray;
	mxArray* arg[1];
	arg[0] = cwArray;
	mexCallMATLAB(1,&rwArray,1,arg,"cwArray2rwArray");
	return rwArray;
}



//////////////////////////////////CONVERT C ROW-WISE STORED MXARRAY TO MATLAB COLUMN-WISE STORED NAM

DLL_EXPORT mxArray* matFn_rwArray2cwArray(mxArray *rwArray)
{
	mxArray* cwArray;
	mxArray* arg[1];
	arg[0] = rwArray;
	mexCallMATLAB(1,&cwArray,1,arg,"rwArray2cwArray");
	return cwArray;
}



DLL_EXPORT mxArray* convert_to_row_nma(mxArray *mx_arg)
//make oidtype nma data, input is a mxArray
{
	mxArray *newMatrix;
	mwSize 	d, page, elements_per_page, total_number_of_pages;
	mwSize ndims = mxGetNumberOfDimensions(mx_arg);
	const mwSize *dims_array = mxGetDimensions(mx_arg);	
	double *elem;
	double *new_element;
	elem = mxGetPr(mx_arg);// to get the pointer of the first element in the mxArray
	newMatrix =  mxCreateNumericArray(ndims, dims_array, mxDOUBLE_CLASS, mxREAL);
	new_element = mxGetPr(newMatrix);
	total_number_of_pages = 1;
	elements_per_page = dims_array[0]*dims_array[1];// to get the number of elements in one page

	for(d = 0; d<ndims; d++){
		if(d!=0 && d!=1) total_number_of_pages *= dims_array[d];
	}// to get the number of pages

	//to access every page in a multiple dimension array
	for (page=0; page < total_number_of_pages; page++) {
		mwSize row;
      // On each page, walk through each row. 
		for (row=0; row<dims_array[0]; row++) {
			mwSize column;     
			mwSize index = (page * elements_per_page) + row;
		// Walk along each column in the current row, and access every element
			for (column=0; column<dims_array[1]; column++) {
				*new_element = elem[index];
				new_element++;
				index += dims_array[0];
			}
		}
	}
	return newMatrix;
}



DLL_EXPORT mxArray* m_get_subset(mxArray* matrix, size_t dim, size_t start, size_t step, size_t end)
{
	mwSize dim_num;
	mwSize *new_ndims;
	mwSize new_dim_value;
	const mwSize *ndims = mxGetDimensions(matrix);
	mwSize counter,pagenumbers;
	mxArray *mx_subset_nma, *new_mx_subset_nma;
	
	dim_num = mxGetNumberOfDimensions(matrix);
	new_ndims = (size_t*)malloc(sizeof(size_t)*dim_num);

	pagenumbers=1;
	new_dim_value = 0;
	if(step==0) return NULL;

	if(dim>=dim_num || dim<0){
		free(new_ndims);
		mexErrMsgTxt("Invalid dimension!\n");	
	}
	if(end>=ndims[dim] || end<0){
		free(new_ndims);
		mexErrMsgTxt("Invalid end!\n");	
	}
	if(start<0 || start>=ndims[dim]){
		free(new_ndims);
		mexErrMsgTxt("Invalid start!\n");	
	}

	//to caculate the new size of spesific dimension
	for(counter=start;counter<=end;counter=counter+step){
		new_dim_value++;
	}

	for(counter=0; counter<dim_num; counter++){
		if(counter!=0 && counter!=1){
			pagenumbers = pagenumbers * ndims[counter];
		}
		new_ndims[counter] = ndims[counter];
	}
	new_ndims[dim] = new_dim_value;
	mx_subset_nma = mxCreateNumericArray(dim_num, new_ndims, mxDOUBLE_CLASS, mxREAL);

	if(dim==0){
		row_subset(mx_subset_nma, matrix, pagenumbers, start, step,end);
		new_mx_subset_nma = convert_to_column_nma(mx_subset_nma);
		free(new_ndims);
		mxDestroyArray(mx_subset_nma);
		return new_mx_subset_nma ;
	}
	if(dim==1){
		column_subset(mx_subset_nma, matrix, pagenumbers, start, step,end);
		new_mx_subset_nma = convert_to_column_nma(mx_subset_nma);
		free(new_ndims);
		mxDestroyArray(mx_subset_nma);
		return new_mx_subset_nma ;
	}
	
	if(dim>1){
		page_subset(mx_subset_nma, matrix, dim, start, step, end);
		new_mx_subset_nma = convert_to_column_nma(mx_subset_nma);
		free(new_ndims);
		mxDestroyArray(mx_subset_nma);
		return new_mx_subset_nma;
	}
	return NULL;
}


/////////////////////////////////////////////PROJECTION FUNCTION/////////////////////////////////////////////
DLL_EXPORT mxArray* m_matrix_projection(mxArray* matrix, mwSize dim, mwSize index)
{
	//variable declaration

	mwSize * new_ndims;
	mwSize dim_num = mxGetNumberOfDimensions(matrix);
	mwSize new_dim_num,element_per_page,page,i,page_index,column,row,idx;
	mwSize pageNumbers=1;
	const mwSize* ndims = mxGetDimensions(matrix);		
	double *projection_element, *matrix_element;
	mxArray *projection_matrix, *new_projection_matrix;


	if(index<0 || index>=ndims[dim]) mexErrMsgTxt("invalid index!\n");
	if(dim>=dim_num || dim<0) mexErrMsgTxt("Invalid dimension!\n");

	//variable initialization 
	if(dim_num==2) new_dim_num=2;
	else new_dim_num = dim_num-1;

	matrix_element = mxGetPr(matrix);
	element_per_page = ndims[0]*ndims[1];
	new_ndims = make_new_ndims(matrix, dim, new_dim_num);
	projection_matrix = mxCreateNumericArray(new_dim_num, new_ndims, mxDOUBLE_CLASS, mxREAL);
	projection_element = mxGetPr(projection_matrix);

	for(i=2;i<dim_num;i++){
		pageNumbers = pageNumbers*ndims[i];
	}
	
	if(dim==0){
	
		//to get row projection
	for(page=0;page<pageNumbers;page++){	
			page_index = page*element_per_page;
			for(column=0;column<ndims[1];column++){
				idx = page_index+column*ndims[0]+index;
				*projection_element = matrix_element[idx];
				projection_element++;
			}
		}
	free(new_ndims);
	return projection_matrix;
	}
	else if(dim==1){
		//to get column projection
		for(page=0;page<pageNumbers;page++){
			page_index = page*element_per_page;
			for(row=0;row<ndims[0];row++){
				idx = page_index+index*ndims[0]+row;
				*projection_element = matrix_element[idx];
				projection_element++;
			}
		}
		 free(new_ndims);
		 return projection_matrix;	
	}
	else{
		//to get page projection
		mwSize page_offset,page_step,j,page_block;
		page_step = pageStep(ndims, dim);
		page_offset = pageOffset(ndims, dim);
		page_block = pageBlock(ndims, dim_num, dim);
		page=index*page_step;
		for(j=0;j<page_block;j++){
			for(i=0;i<page_step;i++){
				page_index = (page+i)*element_per_page;
				for(row=0;row<ndims[0];row++){
					for(column=0;column<ndims[1];column++){
						idx = page_index+column*ndims[0]+row;
						*projection_element = matrix_element[idx];						
						projection_element++;
					}
				}
			}	
			page = page + page_offset;
		}
		 new_projection_matrix =convert_to_column_nma(projection_matrix);
		 mxDestroyArray(projection_matrix);
		 free(new_ndims);
		 return new_projection_matrix;	
	}
}


/////////////////////////////////////////////////TO GET PAGE SUBSET//////////////////////////////////////
void page_subset(mxArray *mx_subset_nma, mxArray *matrix, mwSize dim, mwSize start, mwSize step, mwSize end)
{
	const mwSize *ndims = mxGetDimensions(matrix);
	mwSize dim_num = mxGetNumberOfDimensions(matrix);
	mwSize page_step,page_index,page,row,column,index;
	double *matrix_element,*nma_element;
	mwSize page_block, block_count,page_count, page_offset,page_start,i;


	page_block = pageBlock(ndims, dim_num, dim);
	matrix_element = mxGetPr(matrix);
	nma_element = mxGetPr(mx_subset_nma);
	page_step = pageStep(ndims,dim);
	page_offset = pageOffset(ndims, dim);
	page=0;
	page_start=0;

	for(block_count=0; block_count<page_block; block_count++){
		for(page_count=start; page_count<=end; page_count=page_count+step){
			page = page_start + page_count*page_step;
			for(i=0;i<page_step;i++){	
				page_index = page*ndims[0]*ndims[1];
				for(row=0;row<ndims[0];row++){
					for(column=0;column<ndims[1];column++){
						index = page_index+column*ndims[0]+row;
						*nma_element = matrix_element[index];
						nma_element++;
					}
				}
				page=page+1;
			}
		}
		page_start = page_start+page_offset;
	}
}
/////////////////////////////////////////PAGE SUBSET END///////////////////////////////////////////////////////////////////



//////////////////////////////////////////TO GET ROW SUBSET////////////////////////////////////////////////////////////////////
void row_subset(mxArray *mx_subset_nma, mxArray *matrix, mwSize pagenumbers, mwSize start, mwSize step, mwSize end)
{
	mwSize page,page_index,row,column,index;
	const mwSize *ndims = mxGetDimensions(matrix);
	double *subset_element = mxGetPr(mx_subset_nma);
	double *matrix_element = mxGetPr(matrix);

	for(page=0; page<pagenumbers; page++){
			page_index = page*ndims[0]*ndims[1];
			for(row=start; row<=end; row=row+step){
				for(column=0; column<ndims[1]; column++){
					index = page_index+column*ndims[0]+row;
					*subset_element = matrix_element[index];
					subset_element++;
				}
			}
	}
}
/////////////////////////////////////////ROW SUBSET END///////////////////////////////////////////////////////////////////////


//////////////////////////////////////TO GET COLUMN SUBSET////////////////////////////////////////////////////////////////////////
void column_subset(mxArray *mx_subset_nma, mxArray *matrix, mwSize pagenumbers, mwSize start, mwSize step, mwSize end)
{
	mwSize page,page_index,row,column,index;
	const mwSize *ndims = mxGetDimensions(matrix);
	double *subset_element = mxGetPr(mx_subset_nma);
	double *matrix_element = mxGetPr(matrix);

	for(page=0; page<pagenumbers; page++){
		page_index = page*ndims[0]*ndims[1];
			for(row=0;row<ndims[0];row++){
				for(column=start;column<=end;column=column+step){
					index = page_index + column*ndims[0]+row;
					*subset_element = matrix_element[index];
					subset_element++;
				}
			}
	}
}
///////////////////////////////////////////COLUMN SUBSET END///////////////////////////////////////////////



///////////////////////////////PAGE_BLOCK PAGE_OFFSET PAGE_STEP CACULATION//////////////////////////
mwSize pageBlock(const mwSize* ndims, mwSize dim_num, mwSize dim)
{
	mwSize i;
	mwSize page_block=1;
	for(i=dim+1;i<dim_num;i++){
		page_block = ndims[i]*page_block;
	}
	return page_block;
}


//same index of a specific demsion 
mwSize pageOffset(const mwSize *ndims, mwSize dim)
{
	mwSize page_offset=1;
	mwSize i;
	for(i=2;i<(dim+1); i++){
		page_offset = page_offset*ndims[i];
	}
	return page_offset;
}

//same dimension with increasing index
mwSize pageStep(const mwSize *ndims, mwSize dim)
{
	mwSize i,page_step=1;
	for(i=2;i<dim;i++){
		page_step = page_step*ndims[i];
	}	
	return page_step;
}




//////////////////////////CREATE NEW_DIMENSION ARRAY FOR PROJECTION FUNCTION////////////////////////
mwSize *make_new_ndims(mxArray* matrix, mwSize dim, mwSize new_dim_num)
{
	const mwSize* ndims = mxGetDimensions(matrix);
	mwSize *new_ndims;
	mwSize dim_num = mxGetNumberOfDimensions(matrix);
	mwSize i;

	new_ndims = (mwSize*)malloc(sizeof(mwSize)*new_dim_num);
	
	if(dim>=dim_num || dim<0) mexErrMsgTxt("Invalid dimension!\n");

	if(dim_num == 2){
		if(dim==0){
			new_ndims[0] = ndims[1];
			new_ndims[1] = 1;
		}
		else if(dim==1){
			new_ndims[0] = ndims[0];
			new_ndims[1] = 1;
		}
		return new_ndims;
	}
	else{
		if(dim<2){
			if(dim==0) new_ndims[0]=ndims[1];

			else if(dim==1) new_ndims[0]=ndims[0];
			
			for(i=1;i<new_dim_num;i++){
				new_ndims[i]=ndims[i+1];
			}
		}
		else{
			for(i=0;i<new_dim_num;i++){
				if(i<dim) new_ndims[i]=ndims[i];
				else new_ndims[i]=ndims[i+1];
			}
		}
		return new_ndims;
	}

}
