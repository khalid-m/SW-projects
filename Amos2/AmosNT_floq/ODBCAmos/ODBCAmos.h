#ifndef _OdbcAmos_h
#define _OdbcAmos_h

#ifdef __cplusplus
#define EXTLANG extern "C"
#else
#define EXTLANG
#endif

#ifndef EXTERN
  #ifdef  __BORLANDC__
    #define EXTERN EXTLANG __declspec(dllimport)
  #else
    #define EXTERN EXTLANG
  #endif
#endif

EXTERN void odbc_init(void);
EXTERN void odbc_close(void);

#endif
