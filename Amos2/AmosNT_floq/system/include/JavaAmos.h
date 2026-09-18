/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Tore Risch, UDBL
 * $RCSfile: JavaAmos.h,v $
 * $Revision: 1.12 $ $Date: 2011/07/06 20:29:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: JavaAmos DLL interface
 * ===========================================================================
 * $Log: JavaAmos.h,v $
 * Revision 1.12  2011/07/06 20:29:14  torer
 * Macros to cache Java class objects for higher performance
 *
 * Revision 1.11  2011/05/10 20:09:53  torer
 * Java class caching macro
 *
 * Revision 1.10  2007/04/05 07:14:16  torer
 * JavaAmos now based on VC++ (not Borland)
 *
 ****************************************************************************/

#define check(statement, message) if ((statement) == NULL) {\
                                    env->FatalError(message);\
                                  }

#define cache_class(var,class) if(!var)\
    {var = (jclass)env->NewGlobalRef(class);\
     env->DeleteLocalRef(class);}

#define cache_class_named(var,class)if(!var)\
      {jclass tmpClass=env->FindClass(class);\
       if(!tmpClass) env->FatalError("Couldn't find class "class);\
       cache_class(var,tmpClass);}

#define CheckNullPointer(env,o) (o==NULL?JavaAmosError(env,null_pointer_received,nil):FALSE)

void init_java(void);

// #define DEBUG_ON		                  // Debug-info
#ifdef DEBUG_ON
  #define debug(msg) (fprintf(stderr, "%s\n", (msg)))
#else
  #define debug(msg)
#endif
