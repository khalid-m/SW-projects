#ifndef _PYAMOS_RECORD_H
#define _PYAMOS_RECORD_H

EXTERN oidtype make_recordfn(bindtype, oidtype);
EXTERN oidtype record_getfn(bindtype, oidtype, oidtype);
EXTERN oidtype record_putfn(bindtype, oidtype, oidtype, oidtype);
EXTERN oidtype record_fieldsfn(bindtype, oidtype);

#endif