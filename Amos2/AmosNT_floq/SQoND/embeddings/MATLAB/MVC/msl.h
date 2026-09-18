
#ifndef _AMOSSAMPLE_H_
#define _AMOSSAMPLE_H_
#define DLL_EXPORT __declspec(dllexport)



#ifdef __cplusplus
extern "C" {
#endif

#include "mxManipulation.h"

//////////////////////////////////Amos Interface
DLL_EXPORT void amosInit();
DLL_EXPORT int amosExecute(int,mxArray*);
DLL_EXPORT mxArray *amosGetElement(int, int);



//////////////////////////////////////////Scan interface
DLL_EXPORT int scan_next_row(int);
DLL_EXPORT int scan_end(int);
DLL_EXPORT void free_SE_list(void);
DLL_EXPORT int SE_search(int);
DLL_EXPORT void free_a_SE(int);

/////////////////////////////////////////Connection interface
DLL_EXPORT void setRemotePort(int port); //AA
DLL_EXPORT int newConnection(mxArray *ahost, mxArray *apeer);
DLL_EXPORT void free_CE_list();
DLL_EXPORT void free_CE(int);
DLL_EXPORT void systemFinalize(void);

/////////////////////////////////SPARQL interface
DLL_EXPORT void sparqlInit();
DLL_EXPORT int sparqlExecute(int,mxArray*);
DLL_EXPORT int sparqlFnExe(int,const char*, mxArray *);
DLL_EXPORT void sparqlRdfInsertFn(int,mxArray*, mxArray* , mxArray*);
DLL_EXPORT mxArray* sparqlGetElement(int, int);



/////////////MXARRAY FUNCTION
/*
DLL_EXPORT mxArray* m_get_subset(mxArray*, size_t, size_t, size_t , size_t);
DLL_EXPORT mxArray* m_matrix_projection(mxArray* , mwSize, mwSize);
*/

#ifdef __cplusplus
}
#endif

#endif

