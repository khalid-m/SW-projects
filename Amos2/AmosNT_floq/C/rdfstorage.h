/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: rdfstorage.h,v $
 * $Revision: 1.1 $ $Date: 2012/12/13 17:07:47 $
 * $State: Exp $ $Locker:  $
 *
 * Description: callin-header exporting RDF-related C interface of amos2.dll
 * (not included into amos2.dll project!)
 * ===========================================================================
 * $Log: rdfstorage.h,v $
 * Revision 1.1  2012/12/13 17:07:47  andan342
 * Exporting *TYPE values and interfaces for time and RDF storage objects
 *
 *
 ****************************************************************************/


#include "storage.h"

EXTERN int URITYPE, UNISTRINGTYPE, TYPEDRDFTYPE;


EXPORT oidtype make_uri(char* id);
EXPORT char* uri_id(oidtype uri);

EXPORT oidtype make_unistring(oidtype str, char* lang);
EXPORT oidtype unistring_str(oidtype us);
EXPORT char* unistring_lang(oidtype us);

EXPORT oidtype make_typedrdf(oidtype str, oidtype typeuri);
EXPORT oidtype typedrdf_str(oidtype x);
EXPORT oidtype typedrdf_typeuri(oidtype x);


