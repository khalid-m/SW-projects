
#ifndef MXMANIPULATION_H
#define MXMANIPULATION_H
#define DLL_EXPORT __declspec(dllexport)
#ifdef __cplusplus
extern "C"
{
#endif

#include "mex.h"

DLL_EXPORT mxArray* m_get_subset(mxArray*, size_t, size_t, size_t, size_t);
DLL_EXPORT mxArray* m_matrix_projection(mxArray*, mwSize, mwSize);

//extern mxArray* convert_to_mx_nma(mxArray*);

DLL_EXPORT mxArray* convert_to_column_nma(mxArray *temp_mx_nma);
DLL_EXPORT mxArray* convert_column2row(mxArray*);
DLL_EXPORT mxArray* matFn_cwArray2rwArray(mxArray *cwArray);

//matlab column-wise stored array to C row-wise stored array
DLL_EXPORT mxArray* convert_to_row_nma(mxArray*);
DLL_EXPORT mxArray* matFn_rwArray2cwArray(mxArray*);
DLL_EXPORT mxArray* convert_to_row_nma(mxArray *mx_arg);

#ifdef __cplusplus
}
#endif
#endif